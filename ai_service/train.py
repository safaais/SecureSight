"""Training entry point for the ActionLSTM model.

Usage:
    python train.py
"""
import os
from collections import Counter

import torch
import torch.nn as nn
from sklearn.model_selection import train_test_split
from torch.utils.data import DataLoader

from config import ALL_CLASSES, DATA_SAVE_PATH, MODEL_SAVE_PATH
from model import ActionDataset, ActionLSTM, TemporalJitter
from preprocessing import preprocess_hdmb51_enhanced


def train_model_enhanced(epochs: int = 50, batch_size: int = 32) -> None:
    """Train ActionLSTM on preprocessed keypoint sequences."""

    if not os.path.exists(DATA_SAVE_PATH):
        print("Preprocessing data...")
        preprocess_hdmb51_enhanced()

    data = torch.load(DATA_SAVE_PATH, weights_only=False)
    print(f"Loaded {len(data['inputs'])} sequences")

    # Filter out classes with < 2 samples
    counts = Counter(data['labels'])
    valid_classes = {lbl for lbl, c in counts.items() if c >= 2}
    idxs = [i for i, y in enumerate(data['labels']) if y in valid_classes]
    inputs = [data['inputs'][i] for i in idxs]
    labels = [data['labels'][i] for i in idxs]

    stratify = labels if len(set(labels)) > 1 else None
    train_inputs, _, train_labels, _ = train_test_split(
        inputs, labels, test_size=0.2, random_state=42, stratify=stratify,
    )

    train_ds = ActionDataset(train_inputs, train_labels, transform=TemporalJitter())
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")

    model = ActionLSTM(num_classes=len(ALL_CLASSES)).to(device)
    optimizer = torch.optim.AdamW(model.parameters(), lr=1e-3)
    loss_fn = nn.CrossEntropyLoss(weight=train_ds.class_weights.to(device))

    loader = DataLoader(train_ds, batch_size=batch_size, shuffle=True)
    for epoch in range(epochs):
        model.train()
        total = 0.0
        for x, y in loader:
            optimizer.zero_grad()
            loss = loss_fn(model(x), y.to(device))
            loss.backward()
            optimizer.step()
            total += loss.item()
        print(f"Epoch {epoch + 1}/{epochs} — Loss: {total / len(loader):.4f}")

    os.makedirs(os.path.dirname(MODEL_SAVE_PATH), exist_ok=True)
    torch.save(model.state_dict(), MODEL_SAVE_PATH, _use_new_zipfile_serialization=True)
    print(f"✅ Model saved to {MODEL_SAVE_PATH}")


if __name__ == "__main__":
    train_model_enhanced()