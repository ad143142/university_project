import random
from thread_locker import *
from fastapi import FastAPI, Request

app = FastAPI()


@app.post("/")
async def root(req: Request):
    print(req.values())
    thread_entry()
    return {"result": random.randint(0, 9), "time": 3000}
