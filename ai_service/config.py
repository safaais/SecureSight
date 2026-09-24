"""
Configuration for SecureSightAI.

All secrets are read from environment variables (see .env.example).
Never commit your real .env file.
"""
import os

from dotenv import load_dotenv

load_dotenv()

# ============ Paths ============
MODEL_SAVE_PATH = os.getenv("MODEL_SAVE_PATH", "model/best_lstm_model_enhanced.pt")
DATA_SAVE_PATH = os.getenv("DATA_SAVE_PATH", "data/processed_enhanced_joint_sequences_v2.pt")
PLOTS_DIR = os.getenv("PLOTS_DIR", "plots")
DATASET_PATH = os.getenv("DATASET_PATH", "HMDB51")

# ============ Camera ============
CAMERA_USERNAME = os.getenv("CAMERA_USERNAME", "admin")
CAMERA_PASSWORD = os.getenv("CAMERA_PASSWORD", "")
CAMERA_IP = os.getenv("CAMERA_IP", "")
RTSP_PATH = os.getenv("RTSP_PATH", "/h264/ch1/main/av_stream")

# ============ Backend ============
ALERT_SERVER_URL = os.getenv("ALERT_SERVER_URL", "http://127.0.0.1:8000")
ALERT_INTERVAL_SEC = int(os.getenv("ALERT_INTERVAL_SEC", "60"))

# ============ GenAI ============
USE_LLM_ALERTS = os.getenv("USE_LLM_ALERTS", "false").lower() == "true"
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3")

# ============ Action Classes ============
FIGHT_ACTIONS = {'hit', 'punch', 'kick', 'throw'}
ABNORMAL_ACTIONS = {'fight', 'shoot_gun', 'fall_floor'}
SUSPICIOUS_ACTIONS = {'smoke', 'climb', 'hit', 'punch', 'kick', 'throw'}
NORMAL_ACTIONS = {
    'climb_stairs', 'drink', 'eat', 'pick', 'sit',
    'stand', 'talk', 'walk', 'jump', 'dribble', 'kick_ball',
    'ride_bike', 'run',
}

ALL_CLASSES = sorted(list(ABNORMAL_ACTIONS | SUSPICIOUS_ACTIONS | NORMAL_ACTIONS))
CLASS_TO_IDX = {action: i for i, action in enumerate(ALL_CLASSES)}
IDX_TO_CLASS = {i: action for action, i in CLASS_TO_IDX.items()}

# ============ Model Hyperparameters ============
INPUT_SIZE = 132
SEQUENCE_LENGTH = 30
HIDDEN_SIZE = 512
NUM_LAYERS = 2
DROPOUT = 0.3
NUM_CLASSES = len(ALL_CLASSES)


def build_rtsp_url() -> str:
    """Build RTSP URL from env vars. Raises if password is missing."""
    if not CAMERA_PASSWORD:
        raise EnvironmentError(
            "CAMERA_PASSWORD is not set. "
            "Copy .env.example to .env and fill in your credentials."
        )
    if not CAMERA_IP:
        raise EnvironmentError("CAMERA_IP is not set in .env")
    return f"rtsp://{CAMERA_USERNAME}:{CAMERA_PASSWORD}@{CAMERA_IP}{RTSP_PATH}"