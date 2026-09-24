"""Alert dispatch: notify backend devices, optionally enriched by GenAI."""
import requests

from config import ALERT_SERVER_URL, USE_LLM_ALERTS


def send_alert_to_backend(action_name: str, risk_level: str,
                          server_url: str = ALERT_SERVER_URL) -> None:
    """
    Send an alert to all registered device tokens on the backend.

    If USE_LLM_ALERTS=true, description and actions are enriched by the
    GenAI assistant defined in genai.py.
    """
    if USE_LLM_ALERTS:
        from genai import generate_alert_details
        description, actions = generate_alert_details(action_name, risk_level)
    else:
        description = f"Detected {action_name} behavior"
        actions = []

    try:
        r = requests.get(f"{server_url}/active_tokens", timeout=3)
        tokens = r.json().get('tokens', [])
        if not tokens:
            print("⚠️ No active tokens found")
            return

        for token in tokens:
            payload = {
                "device_token": token,
                "title": f"Security Alert: {action_name}",
                "description": description,
                "status": "new",
                "location": "Camera 1",
                "risk_level": risk_level.lower(),
                "actions": actions,
            }
            try:
                r = requests.post(f"{server_url}/alerts", json=payload, timeout=3)
                print(f"📢 Alert sent (Status: {r.status_code})")
            except Exception as e:
                print(f"❌ Failed to send alert: {e}")
    except Exception as e:
        print(f"🔥 Critical alert error: {e}")