from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def home() -> dict[str, str]:
    return {"message": "Welcome to FastAPI with Typing"}

@app.get("/items/{item_id}")
def tead_item(item_id: int, q: str | None = None) -> dict[str, str | int | None]:
    return {"item_id": item_id, "query": q}