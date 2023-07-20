import random
from thread_locker import *
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def root():
    thread_entry()
    return {"result": random.randint(0, 9), "time": 3000}

