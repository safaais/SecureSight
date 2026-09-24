"""
Generative-AI alert enrichment using a local Ollama model.

This module is OPTIONAL. It's only used when USE_LLM_ALERTS=true in .env
and the `ollama` Python package is installed.

Usage:
    from genai import generate_alert_details
    description, actions = generate_alert_details("punch", "high")
"""
from config import OLLAMA_MODEL


def generate_alert_details(action: str, risk_level: str):
    """
    Use a local LLM to draft a description + recommended actions.

    Args:
        action: the detected action name (e.g. "punch", "fall_floor")
        risk_level: one of "low", "medium", "high", "critical"

    Returns:
        tuple: (description: str, actions: list[str])

    Falls back to static text if Ollama is unavailable.
    """
    try:
        import ollama
    except ImportError:
        print("⚠️  ollama package not installed — using fallback text")
        return _fallback(action)

    prompt = _build_prompt(action, risk_level)

    try:
        response = ollama.generate(
            model=OLLAMA_MODEL,
            prompt=prompt,
            options={'temperature': 0.5},
            stream=False,
        )
        text = response['response']
    except Exception as e:
        print(f"❌ LLM generation error: {e}")
        return _fallback(action)

    return _parse_response(text, action)


def _build_prompt(action: str, risk_level: str) -> str:
    """Construct the instruction prompt sent to the LLM."""
    return (
        "You are a security AI assistant. Analyze this event:\n\n"
        f"- Detected Action: {action}\n"
        f"- Risk Level: {risk_level}\n\n"
        "Provide output in this exact format:\n\n"
        "DESCRIPTION: [1-2 sentence description]\n\n"
        "ACTIONS:\n"
        "1. [Immediate action]\n"
        "2. [Secondary action]\n"
        "3. [Preventative measure]"
    )


def _parse_response(text: str, action: str):
    """Extract description + numbered actions from raw LLM output."""
    description = ""
    actions = []

    for line in text.splitlines():
        if line.startswith("DESCRIPTION:"):
            description = line.replace("DESCRIPTION:", "").strip()
        elif line.strip().startswith(('1.', '2.', '3.')):
            actions.append(line.strip())

    if not description:
        description = f"{action} detected"
    if not actions:
        actions = ["1. Investigate area", "2. Check cameras", "3. Report findings"]

    return description, actions


def _fallback(action: str):
    """Static fallback when LLM is unavailable."""
    return (
        f"{action} detected",
        [
            "1. Verify situation",
            "2. Dispatch personnel",
            "3. Document incident",
        ],
    )