<div align="center">

# SecureSight

**AI-powered surveillance for real-time detection of abnormal and suspicious activity.**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)
![PyTorch](https://img.shields.io/badge/PyTorch-2.x-EE4C2C?logo=pytorch&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

[Overview](#overview) •
[Features](#features) •
[Architecture](#system-architecture) •
[Getting Started](#getting-started) •
[Roadmap](#roadmap)

</div>

<!-- Optional: add a short demo GIF here, e.g. -->
<!-- <p align="center"><img src="docs/images/demo.gif" width="700" alt="SecureSight demo"></p> -->

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [How It Works](#how-it-works)
- [System Architecture](#system-architecture)
- [Screenshots](#screenshots)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Security Notes](#security-notes)
- [Use Cases](#use-cases)
- [Roadmap](#roadmap)
- [Team](#team)
- [License](#license)
- [Acknowledgments](#acknowledgments)

---

## Overview

**SecureSight** is a full-stack AI surveillance platform that helps security personnel monitor multiple cameras, detect abnormal activity in real time, and respond to incidents from a single mobile app.

The system combines:

| Component | Technology |
|-----------|-----------|
| Computer vision | MediaPipe pose estimation |
| Deep learning | LSTM action classifier (PyTorch) |
| Mobile app | Flutter + Firebase |
| Backend API | FastAPI |
| Push notifications | Firebase Cloud Messaging (FCM) |

When a suspicious event is detected (for example a fight or a fall), an alert is pushed instantly to the security team's phones with the event type, camera location, and timestamp.

---

## Features

### Surveillance

- **Live camera monitoring** — view multiple RTSP streams at the same time.
- **Footage management** — browse and review previously recorded clips.
- **Multi-building support** — organize cameras by building and location.

### AI Detection

- **Real-time pose extraction** — 33 body keypoints per frame via MediaPipe.
- **LSTM action classifier** — recognizes 18+ action classes (fight, fall, run, and more).
- **Risk forecasting** — analyzes action sequences in context and rates risk from low to critical.
- **Optional GenAI enrichment** — a local LLaMA-3 model writes human-readable alert descriptions and recommended actions.

### Alerts and Management

- **Real-time push notifications** — instant alerts through FCM.
- **Detailed alert cards** — event type, camera, building, timestamp, and confidence score.
- **User and role management** — separate admin and security-personnel accounts.
- **Authentication** — Firebase Auth (email/password).
- **Multi-language UI** — English and Arabic.

---

## How It Works

1. **Capture** — the AI service reads frames from an RTSP camera (or a test video file) using OpenCV.
2. **Extract** — MediaPipe converts each frame into 33 pose keypoints.
3. **Classify** — an LSTM model classifies short keypoint sequences into action classes.
4. **Forecast** — the risk engine evaluates the sequence of actions and assigns a risk level.
5. **Alert** — if the risk is high enough, the AI service sends the event to the FastAPI backend.
6. **Notify** — the backend stores the alert in Firestore and pushes a notification to the mobile app through FCM.

---

## System Architecture

<p align="center">
  <img src="docs/images/architecture.png" alt="SecureSight system architecture diagram" width="850">
</p>

<!--
  Put your image at docs/images/architecture.png
  (or change the path above to wherever you save it).
-->

| Layer | Role |
|-------|------|
| **IP cameras** | Stream video over RTSP (EZVIZ, Hikvision, etc.) |
| **AI service (Python)** | Pose extraction, action classification, risk forecasting |
| **Backend (FastAPI)** | Receives detections, writes to Firestore, sends FCM pushes via Firebase Admin |
| **Mobile app (Flutter)** | Live view, footage, alerts, and user management |
| **Firebase Cloud** | Auth, Firestore, Cloud Messaging, and Storage |

---

## Screenshots

<!-- Replace the placeholders with real screenshots (recommended width: 200–250px). -->

| Login | Home | Live View | Alerts |
|:-----:|:----:|:---------:|:------:|
| <img src="docs/images/login.png" width="200"> | <img src="docs/images/home.png" width="200"> | <img src="docs/images/live.png" width="200"> | <img src="docs/images/alerts.png" width="200"> |

---

## Project Structure

```text
SecureSight/
├── lib/                    # Flutter application
│   ├── admin/              # Admin screens
│   ├── settings/           # Settings screens
│   ├── alerts_page.dart    # Alerts list
│   ├── footage_page.dart   # Footage viewer
│   ├── home_page.dart      # Main dashboard
│   ├── login_page.dart     # Authentication
│   └── main.dart           # App entry point
│
├── ai_service/             # Python AI service
│   ├── config.py           # Configuration and env loading
│   ├── poses.py            # MediaPipe keypoint extraction
│   ├── model.py            # LSTM architecture and dataset
│   ├── forecaster.py       # Sequence-based risk logic
│   ├── genai.py            # Optional LLM alert enrichment
│   ├── alerts.py           # Alert dispatch to backend
│   ├── preprocessing.py    # Dataset -> keypoint sequences
│   ├── train.py            # Model training entry point
│   ├── main.py             # Real-time detection loop
│   └── requirements.txt
│
├── assets/translations/    # i18n (en, ar)
├── docs/images/            # README images
├── android/ ios/ web/ ...  # Platform folders
├── test/                   # Flutter tests
├── pubspec.yaml
└── README.md
```

---

## Technologies Used

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Mobile | Flutter / Dart | Cross-platform app |
| Auth | Firebase Authentication | User login |
| Database | Cloud Firestore | Real-time data sync |
| Notifications | Firebase Cloud Messaging | Push alerts |
| Backend | Python / FastAPI | API and alert dispatch |
| Pose estimation | MediaPipe | 33-keypoint extraction |
| Action classifier | PyTorch LSTM | Sequence classification |
| Computer vision | OpenCV | Video stream processing |
| GenAI (optional) | Ollama / LLaMA-3 | Human-readable alerts |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.10 or newer
- Python 3.10 or newer
- A Firebase project with Auth, Firestore, and FCM enabled
- An RTSP camera (or a test video file)

### 1. Clone the repository

```bash
git clone https://github.com/safaais/SecureSight.git
cd SecureSight
```

### 2. Set up the Flutter app

```bash
flutter pub get
flutter run
```

> **Note:** Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from your Firebase console. They are not included in the repo for security reasons.

### 3. Set up the AI service

```bash
cd ai_service
python -m venv venv
source venv/bin/activate          # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

Create your environment file:

```bash
cp .env.example .env
```

Edit `.env` with your camera credentials (see [Configuration](#configuration)):

```env
CAMERA_USERNAME=admin
CAMERA_PASSWORD=your_password_here
CAMERA_IP=192.168.1.100
RTSP_PATH=/h264/ch1/main/av_stream
ALERT_SERVER_URL=http://127.0.0.1:8000
```

Train the model (or download a pre-trained one):

```bash
python train.py
```

### 4. Start the backend API

<!-- TODO: replace with your actual backend path and command -->

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

### 5. Run real-time detection

In a new terminal, from `ai_service/`:

```bash
python main.py
```

### 6. Enable GenAI alerts (optional)

Requires [Ollama](https://ollama.com) installed locally.

```bash
ollama pull llama3
pip install ollama
```

Then set these in `.env`:

```env
USE_LLM_ALERTS=true
OLLAMA_MODEL=llama3
```

Every alert will now include an AI-generated description and recommended actions.

---

## Configuration

All AI-service settings are read from environment variables in `ai_service/.env`.

| Variable | Description | Example |
|----------|-------------|---------|
| `CAMERA_USERNAME` | Camera login username | `admin` |
| `CAMERA_PASSWORD` | Camera login password | `your_password_here` |
| `CAMERA_IP` | Camera IP address on your network | `192.168.1.100` |
| `RTSP_PATH` | RTSP stream path (varies by camera brand) | `/h264/ch1/main/av_stream` |
| `ALERT_SERVER_URL` | URL of the FastAPI backend | `http://127.0.0.1:8000` |
| `USE_LLM_ALERTS` | Enable GenAI alert descriptions | `false` |
| `OLLAMA_MODEL` | Ollama model used for enrichment | `llama3` |

---

## Security Notes

- Never commit `.env`, `google-services.json`, or `GoogleService-Info.plist`.
- Camera credentials are read from environment variables only.
- Firebase secrets are managed through the Firebase Console.
- Model weights (`*.pt`) and preprocessed data are git-ignored.

### Responsible Use

Video surveillance can affect people's privacy. Deploy SecureSight only where monitoring is legal, follow local privacy and data-protection regulations, and inform people that cameras are in use. AI predictions can be wrong, so alerts should support, not replace, human judgment.

---

## Use Cases

- **Office buildings** — monitor entrances and detect intrusions.
- **Schools and universities** — detect fights, falls, and suspicious behavior.
- **Hospitals** — fall detection for patient safety.
- **Industrial facilities** — safety and unauthorized-access monitoring.
- **Retail** — theft and violence detection.

---

## Roadmap

- [x] Real-time pose extraction (MediaPipe)
- [x] LSTM action classifier (18+ classes)
- [x] Risk forecasting engine
- [x] Firebase push notifications
- [x] Multi-camera support
- [x] Multi-language support (English, Arabic)
- [ ] GenAI alert enrichment (beta)
- [ ] Edge deployment (Jetson Nano / Raspberry Pi)
- [ ] Web dashboard for admins
- [ ] Docker containerization

---

## Team

SecureSight was developed as a graduation project at **[Your University Name]**.

| Role | Contributor |
|------|-------------|
| Mobile app (Flutter) | [@safaais](https://github.com/safaais) |
| AI service (Python) | [@safaais](https://github.com/safaais) |
| Backend API | [@safaais](https://github.com/safaais) |

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [MediaPipe](https://developers.google.com/mediapipe) — pose estimation
- [PyTorch](https://pytorch.org/) — deep learning framework
- [Flutter](https://flutter.dev/) — cross-platform UI
- [Firebase](https://firebase.google.com/) — backend-as-a-service
- [Ollama](https://ollama.com/) — local LLM runtime
- [HMDB51 Dataset](https://serre-lab.clps.brown.edu/resource/hmdb-a-large-human-motion-database/) — training data

---

<div align="center">

If you find this project useful, please consider giving it a star.

</div>
