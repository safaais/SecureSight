"""LSTM model, dataset class, and temporal augmentation."""
import random
from collections import Counter

import torch
import torch.nn as nn
from torch.utils.data import Dataset

from config import (
    DROPOUT, HIDDEN_SIZE, INPUT_SIZE, NUM_CLASSES, NUM_LAYERS, SEQUENCE_LENGTH,
)


class ActionLSTM(nn.Module):
    """LSTM classifier over a fixed-length pose-sequence window."""

    def __init__(
        self,
        input_size: int = INPUT_SIZE,
        hidden_size: int = HIDDEN_SIZE,
        num_layers: int = NUM_LAYERS,
        num_classes: int = NUM_CLASSES,
        dropout: float = DROPOUT,
    ):
        super().__init__()
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.lstm = nn.LSTM(
            input_size, hidden_size, num_layers,
            batch_first=True, dropout=dropout,
        )
        self.fc = nn.Linear(hidden_size, num_classes)
        self.to(self.device)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x = x.to(self.device)
        h0 = torch.zeros(
            self.lstm.num_layers, x.size(0), self.lstm.hidden_size
        ).to(self.device)
        c0 = torch.zeros(
            self.lstm.num_layers, x.size(0), self.lstm.hidden_size
        ).to(self.device)
        out, _ = self.lstm(x, (h0, c0))
        return self.fc(out[:, -1, :])


class ActionDataset(Dataset):
    """Dataset with class-balanced weights for imbalanced classes."""

    def __init__(self, data, labels, transform=None):
        valid = [i for i, y in enumerate(labels) if y < NUM_CLASSES]
        self.data = [data[i] for i in valid]
        self.labels = [labels[i] for i in valid]
        self.transform = transform

        counts = Counter(self.labels)
        total = len(self.labels)
        self.class_weights = torch.ones(NUM_CLASSES)
        for idx, count in counts.items():
            if count > 0 and idx < NUM_CLASSES:
                self.class_weights[idx] = total / (len(counts) * count)

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        seq = self.data[idx]
        if self.transform:
            seq = self.transform(seq)
        return (
            torch.tensor(seq, dtype=torch.float32),
            torch.tensor(self.labels[idx], dtype=torch.long),
        )


class TemporalJitter:
    """Random window crop — temporal augmentation."""

    def __init__(self, jitter_range: int = 5, seq_len: int = SEQUENCE_LENGTH):
        self.jitter_range = jitter_range
        self.seq_len = seq_len

    def __call__(self, sequence):
        n = len(sequence)
        if n > 2 * self.jitter_range and n >= self.seq_len:
            start = random.randint(-self.jitter_range, self.jitter_range)
            start = max(0, min(n - self.seq_len, start))
            return sequence[start:start + self.seq_len]
        if n >= self.seq_len:
            return sequence[:self.seq_len]
        return sequence