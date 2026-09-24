from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore, messaging
import uuid
from typing import Optional
from dotenv import load_dotenv
import os

load_dotenv()

# Initialize Firebase
cred = credentials.Certificate("firebase-adminsdk.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

app = FastAPI()

# ================== MODELS ==================

class NotificationRequest(BaseModel):
    title: str
    body: str
    location: str
    description: str
    risk_level: str
    device_token: str

class AlertUpdate(BaseModel):
    status: str  # "resolved", "investigating"
    resolved_by: Optional[str] = None
    notes: Optional[str] = None

class DeviceRegister(BaseModel):
    token: str

class AlertCreate(BaseModel):
    title: str
    body: str
    location: str
    description: str
    risk_level: str
    device_token: str

# ================== ENDPOINTS ==================

@app.post("/register_device")
async def register_device(device: DeviceRegister):
    """Store FCM token from Flutter app"""
    try:
        db.collection("devices").document().set({
            "token": device.token,
            "registered_at": datetime.now().isoformat()
        })
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/alerts")
async def create_alert(alert: AlertCreate):
    """Create new alert with dynamic device token"""
    try:
        alert_id = str(uuid.uuid4())
        alert_data = {
            "alert_id": alert_id,
            **alert.dict(),
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }

        db.collection("alerts").document(alert_id).set(alert_data)

        message = messaging.Message(
            notification=messaging.Notification(
                title=alert.title,
                body=alert.description or "Security alert detected"
            ),
            data={
                "alert_id": alert_id,
                "location": alert.location or "Unknown",
                "risk_level": alert.risk_level or "medium",
                "description": alert.description or ""
            },
            token=alert.device_token
        )

        messaging.send(message)
        return {"status": "success", "alert_id": alert_id}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.patch("/alerts/{alert_id}")
async def update_alert(alert_id: str, update: AlertUpdate):
    """Update alert status (Flutter app will call this)"""
    try:
        alert_ref = db.collection("alerts").document(alert_id)
        if not alert_ref.get().exists:
            raise HTTPException(status_code=404, detail="Alert not found")

        updates = {
            "status": update.status,
            "updated_at": datetime.now().isoformat()
        }

        if update.resolved_by:
            updates["resolved_by"] = update.resolved_by
        if update.notes:
            updates["notes"] = update.notes

        alert_ref.update(updates)
        return {"status": "success", "alert_id": alert_id}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/alerts/{alert_id}")
async def get_alert(alert_id: str):
    """Get alert details (for Flutter's alert details screen)"""
    try:
        doc = db.collection("alerts").document(alert_id).get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="Alert not found")
        return doc.to_dict()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
