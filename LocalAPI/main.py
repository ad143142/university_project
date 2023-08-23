import asyncio
import json

from websockets.exceptions import ConnectionClosedOK
from thread_locker import *
from fastapi import FastAPI, WebSocket, WebSocketDisconnect


app = FastAPI()


@app.post("/")
async def root(data: dict):
    print(data['data'])
    ret = thread_entry(data['data'])
    return ret


@app.websocket('/ws-api')
async def websocket_handler(websocket: WebSocket):
    await websocket.accept()

    try:
        while 1:
            data = await websocket.receive_json()

            data = data['data'].split('\n')
            ret = []
            for _ in range(len(data)):
                ret.append(list(map(int, data[_].split(' '))))

            try:
                if type(ret) != list and type(ret[0]) != int:
                    raise TypeError('型別錯誤')
            except Exception as e:
                raise Exception(e)

            """
                嚴正警告：如果要即時性的資料，前端傳送第二次以後的資料前，需要等到前一個回應送達再送出請求。
                若不停傳送會拖累後面送達的資料，延遲會如滾雪球般的累積！！！
                
            """
            ret = thread_entry(ret)

            await websocket.send_json(ret)

            await asyncio.sleep(0.01)

    except (ConnectionClosedOK, WebSocketDisconnect) as e:
        print('closed!')
