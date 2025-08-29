from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Any, Dict
import os

app = FastAPI(title="Password Strength Service", version="1.0.0")

MODEL_ID = os.getenv("MODEL_ID", "dima806/strong-password-checker-bert")
THRESHOLD = float(os.getenv("THRESHOLD", "0.5"))

class CheckRequest(BaseModel):
    password: str

class Prediction(BaseModel):
    label: str
    score: float

class CheckResponse(BaseModel):
    ok: bool
    label: str
    score: float
    raw: List[Prediction]

# Lazy-load the pipeline to reduce cold start cost during import
_nlp = None

def get_pipeline():
    global _nlp
    if _nlp is None:
        try:
            from transformers import pipeline  # lazy import to avoid hard dependency at startup
        except Exception as e:
            raise HTTPException(status_code=503, detail=f"transformers not available: {e}")
        _nlp = pipeline("text-classification", model=MODEL_ID)
    return _nlp

@app.get("/healthz")
async def healthz():
    return {"status": "ok"}

@app.post("/check", response_model=CheckResponse)
async def check_password(body: CheckRequest):
    if body.password is None:
        raise HTTPException(status_code=400, detail="password is required")
    text = body.password
    if not isinstance(text, str):
        raise HTTPException(status_code=400, detail="password must be a string")
    if text.strip() == "":
        # treat empty as not ok
        return CheckResponse(ok=False, label="empty", score=0.0, raw=[])

    pipe = get_pipeline()
    try:
        preds: List[Dict[str, Any]] = pipe(text, top_k=None)  # return all labels if supported
    except TypeError:
        # Some pipeline versions don't accept top_k=None, fallback to default (top-1)
        preds = pipe(text)

    # Normalize output to list of dicts
    if isinstance(preds, dict):
        preds = [preds]

    # Coerce to Prediction objects
    normalized: List[Prediction] = []
    for p in preds:
        label = str(p.get("label") or p.get("labels", "")).strip()
        score = float(p.get("score") or 0.0)
        normalized.append(Prediction(label=label, score=score))

    # Choose top by score
    best = max(normalized, key=lambda x: x.score) if normalized else Prediction(label="unknown", score=0.0)

    # Heuristic: ok if label contains "strong" and score >= THRESHOLD
    label_lower = best.label.lower()
    ok = ("strong" in label_lower) and (best.score >= THRESHOLD)

    return CheckResponse(ok=ok, label=best.label, score=best.score, raw=normalized)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=int(os.getenv("PORT", "8001")), reload=False)
