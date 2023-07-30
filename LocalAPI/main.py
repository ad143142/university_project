import random
from thread_locker import *
from fastapi import FastAPI, Request
from pydantic import BaseModel

app = FastAPI()


class Data(BaseModel):
    data: str


@app.post("/")
async def root(req: Data):
    print(req.data)
    ret = thread_entry(req.data)
    return ret
