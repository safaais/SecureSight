"""Sequence-level risk forecasting from recent action predictions."""
from collections import deque

from config import FIGHT_ACTIONS, SUSPICIOUS_ACTIONS


class ActionForecaster:
    """Tracks recent predictions and returns a scene-level risk level."""

    def __init__(self, window: int = 10, fight_threshold: int = 3):
        self.action_sequence: deque = deque(maxlen=window)
        self.fight_threshold = fight_threshold

    def update_sequence(self, action: str) -> str:
        """Append a prediction and return updated risk assessment."""
        self.action_sequence.append(action)
        return self.assess_risk()

    def assess_risk(self) -> str:
        """Return one of: 'critical', 'fight', 'medium', 'low'."""
        seq = list(self.action_sequence)

        if 'shoot_gun' in seq or 'fall_floor' in seq:
            return "critical"

        fight_count = sum(1 for a in seq if a in FIGHT_ACTIONS)
        if fight_count >= self.fight_threshold:
            return "fight"

        if any(a in SUSPICIOUS_ACTIONS for a in seq):
            return "medium"

        return "low"