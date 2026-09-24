"""Pose keypoint extraction and drawing helpers using MediaPipe."""
import cv2
import mediapipe as mp
import numpy as np

mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils


def extract_keypoints_enhanced(results) -> np.ndarray:
    """
    Extract a 132-dim feature vector from MediaPipe results.

    Returns: [x1,y1,z1, x2,y2,z2, ..., x33,y33,z33, vis1..vis33]
    Normalized when enough confidence is available.
    """
    if not results.pose_landmarks:
        return np.zeros(132)

    landmarks = results.pose_landmarks.landmark
    keypoints = []
    confidences = []
    for lm in landmarks:
        keypoints.extend([lm.x, lm.y, lm.z])
        confidences.append(lm.visibility)

    keypoints = np.array(keypoints)
    confidences = np.array(confidences)
    confidences_expanded = np.repeat(confidences, 3)

    if np.sum(confidences) > 10:
        valid = confidences_expanded > 0.1
        if np.any(valid):
            keypoints[valid] = (
                keypoints[valid] - np.mean(keypoints[valid])
            ) / (np.std(keypoints[valid]) + 1e-8)

    return np.concatenate([keypoints, confidences])


def draw_pose(frame, landmarks):
    """Draw pose landmarks and connections on a BGR frame."""
    mp_drawing.draw_landmarks(
        frame,
        landmarks,
        mp_pose.POSE_CONNECTIONS,
        mp_drawing.DrawingSpec(color=(245, 117, 66), thickness=2, circle_radius=2),
        mp_drawing.DrawingSpec(color=(245, 66, 230), thickness=2, circle_radius=2),
    )