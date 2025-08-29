import json
from typing import List, Dict, Any

from fastapi.testclient import TestClient
import main

client = TestClient(main.app)

print("GET /healthz ->", client.get("/healthz").status_code, client.get("/healthz").json())

# Empty password -> should be ok=False without using transformers
resp = client.post("/check", json={"password": ""})
print("POST /check empty ->", resp.status_code, resp.json())

# Monkeypatch get_pipeline to avoid transformers and simulate strong/weak

def fake_pipe_factory(result: List[Dict[str, Any]]):
    def pipe(text, top_k=None):
        return result
    return pipe

# Strong case
main._nlp = None
main.get_pipeline = lambda: fake_pipe_factory([{"label": "STRONG", "score": 0.95}])
resp = client.post("/check", json={"password": "Abc!2345"})
print("POST /check strong ->", resp.status_code, resp.json())

# Weak case
main._nlp = None
main.get_pipeline = lambda: fake_pipe_factory([{"label": "WEAK", "score": 0.12}])
resp = client.post("/check", json={"password": "password"})
print("POST /check weak ->", resp.status_code, resp.json())

