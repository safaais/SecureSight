"""Convert HMDB51-style frame folders into fixed-length keypoint sequences."""
import os
from glob import glob

import cv2
import mediapipe as mp
import torch

from config import CLASS_TO_IDX, DATA_SAVE_PATH, DATASET_PATH
from poses import extract_keypoints_enhanced


def preprocess_hdmb51_enhanced(dataset_path: str = DATASET_PATH) -> None:
    """
    Walk through DATASET_PATH/<action>/<clip>/*.jpg and produce sequences.

    Each sequence is 30 consecutive keypoint vectors, saved to DATA_SAVE_PATH.
    """
    pose = mp.solutions.pose.Pose(static_image_mode=True, min_detection_confidence=0.5)
    sequences, labels = [], []

    for action_dir in sorted(glob(os.path.join(dataset_path, '*'))):
        action_name = os.path.basename(action_dir)
        if action_name not in CLASS_TO_IDX:
            print(f"Skipping '{action_name}' — not in defined classes")
            continue

        for video_dir in sorted(glob(os.path.join(action_dir, '*'))):
            frames = []
            for ext in ('*.jpg', '*.jpeg', '*.png'):
                frames.extend(sorted(glob(os.path.join(video_dir, ext))))
            if len(frames) < 30:
                continue

            seq = []
            for path in frames[:60]:
                try:
                    image = cv2.imread(path)
                    if image is None:
                        continue
                    res = pose.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
                    seq.append(extract_keypoints_enhanced(res))
                except Exception:
                    continue

            if len(seq) >= 30:
                for i in range(0, len(seq) - 30 + 1, 10):
                    sequences.append(seq[i:i + 30])
                    labels.append(CLASS_TO_IDX[action_name])

    os.makedirs(os.path.dirname(DATA_SAVE_PATH), exist_ok=True)
    torch.save(
        {"inputs": sequences, "labels": labels},
        DATA_SAVE_PATH,
        _use_new_zipfile_serialization=True,
    )
    print(f"Saved {len(sequences)} sequences from {len(set(labels))} classes")