# pip install uvicorn
# pip install fastapi
# pip install slpp

from fastapi import FastAPI
from pydantic import BaseModel
from slpp import SLPP as lua


class SWMatrix(BaseModel):
    one: float
    two: float
    three: float
    four: float
    five: float
    six: float
    seven: float
    eight: float
    nine: float
    ten: float
    eleven: float
    twelve: float
    thirteen: float
    fourteen: float
    fifteen: float
    sixteen: float


app = FastAPI()


@app.get("/")
async def home():
    return {"connected": True}


@app.get("/addfinishedmission/{reward}{SWMatrix}{peerID}")
async def putMoneyRequest(reward: int, SWMatrix: str, peerID: int):
    pass
