"""Real-time suspicious-action detection from an RTSP camera stream.

Usage:
    python main.py
Press 'q' to quit.
"""
import os
import time
from collections import deque

import cv2
import mediapipe as mp
import torch

from alerts import send_alert_to_backend
from config import (
    ALERT_INTERVAL_SEC,
    IDX_TO_CLASS,
    MODEL_SAVE_PATH,
    build_rtsp_url,
)
from forecaster import ActionForecaster
from model import ActionLSTM
from poses import draw_pose, extract_keypoints_enhanced


def main() -> None:
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")

    if not os.path.exists(MODEL_SAVE_PATH):
        raise FileNotFoundError(
            f"Model not found at {MODEL_SAVE_PATH}. Run `python train.py` first."
        )

    model = ActionLSTM().to(device)
    model.load_state_dict(torch.load(MODEL_SAVE_PATH, map_location=device))
    model.eval()
    print("✅ Model loaded")

    cap = cv2.VideoCapture(build_rtsp_url())
    if not cap.isOpened():
        print("❌ Error: Unable to open video stream. Check your .env settings.")
        return

    pose = mp.solutions.pose.Pose(min_detection_confidence=0.7)
    sequence_window = deque(maxlen=60)
    last_alert: dict = {}
    forecaster = ActionForecaster()

    print("🎥 Live detection started — press 'q' to quit")

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                print("⚠️ Frame not received, retrying...")
                time.sleep(0.5)
                continue

            frame = cv2.resize(frame, (640, 480))
            results = pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))

            if results.pose_landmarks:
                draw_pose(frame, results.pose_landmarks)
                sequence_window.append(extract_keypoints_enhanced(results))

                if len(sequence_window) >= 30:
                    tensor = torch.tensor(
                        [list(sequence_window)[-30:]], dtype=torch.float32
                    )
                    with torch.no_grad():
                        pred = torch.argmax(model(tensor)).item()

                    detected = IDX_TO_CLASS.get(pred, "unknown")
                    forecast = forecaster.update_sequence(detected)

                    color, risk, final = (0, 255, 0), "low", detected
                    if forecast == "fight":
                        final, risk, color = "fight", "high", (0, 0, 255)
                    elif forecast == "critical":
                        risk, color = "critical", (0, 0, 255)
                    elif forecast == "medium":
                        risk, color = "medium", (0, 165, 255)

                    now = time.time()
                    if risk in ("medium", "high", "critical"):
                        if now - last_alert.get(final, 0) > ALERT_INTERVAL_SEC:
                            send_alert_to_backend(final, risk)
                            last_alert[final] = now
                            if risk in ("high", "critical"):
                                cv2.putText(
                                    frame, f"ALERT: {final}", (10, 60),
                                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2,
                                )

                    cv2.putText(
                        frame, f"Action: {final}", (10, 30),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2,
                    )
                    cv2.putText(
                        frame, f"Risk: {risk}", (10, 90),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2,
                    )

                    if forecaster.action_sequence:
                        seq_text = "Seq: " + ", ".join(
                            list(forecaster.action_sequence)[-3:]
                        )
                        cv2.putText(
                            frame, seq_text, (10, 120),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1,
                        )

            cv2.imshow("Action Detection", frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
    finally:
        cap.release()
        cv2.destroyAllWindows()
        print("👋 Detection stopped")


if __name__ == "__main__":
    main()