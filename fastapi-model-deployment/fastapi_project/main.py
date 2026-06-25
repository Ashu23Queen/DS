from fastapi import FastAPI

from pydantic import BaseModel

app = FastAPI()

class Item(BaseModel):
    name:str
    price: float
    in_stock:bool = True
 
@app.get("/") 
def home() -> dict[str, str]:
    return {"message": "Welcome to FastAPI with Typing"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str | None = None) -> dict[str, str | int | None]:
    return {"item_id": item_id, "query": q}

@app.post("/items")
def creat_item(item: Item):
    return {"item": item}      

