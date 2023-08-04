from thread_locker import *
from fastapi import FastAPI

app = FastAPI()


@app.post("/")
async def root(data: dict):
    print(data)
    data = data['data']
    ret = thread_entry(data)
    return ret
