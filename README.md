# SecureSight

An AI-powered surveillance system for real-time detection of abnormal and suspicious activities.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)
![PyTorch](https://img.shields.io/badge/PyTorch-2.x-EE4C2C?logo=pytorch&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## Overview

**SecureSight** is a full-stack AI surveillance platform that helps security personnel monitor multiple cameras, detect abnormal activities in real time, and respond to incidents through a centralized mobile interface.

The system combines:

- **Computer vision** (MediaPipe pose estimation)
- **Deep learning** (LSTM action classifier)
- **Mobile app** (Flutter + Firebase)
- **Backend API** (FastAPI)
- **Push notifications** (Firebase Cloud Messaging)

When a suspicious event is detected (e.g., fight, fall, weapon), an alert is pushed instantly to the security team's mobile devices with event details, camera location, and timestamp.

---

## Features

### Surveillance

- **Live Camera Monitoring** — View multiple RTSP streams simultaneously.
- **Footage Management** — Browse and review previously recorded clips.
- **Multi-Building Support** — Organize cameras by building and location.

### AI Detection

- **Real-Time Pose Extraction** — 33 keypoints per frame via MediaPipe.
- **LSTM Action Classifier** — Detects 18+ action classes (fight, fall, run, etc.).
- **Risk Forecasting** — Contextual analysis of action sequences (low to critical).
- **Optional GenAI Enrichment** — LLaMA-3 generates human-readable alert descriptions.

### Alerts and Management

- **Real-Time Push Notifications** — Instant alerts via FCM.
- **Detailed Alert Cards** — Event type, camera, building, timestamp, confidence.
- **User and Role Management** — Admin and security personnel accounts.
- **Authentication** — Firebase Auth (email/password).

---

## System Architecture
