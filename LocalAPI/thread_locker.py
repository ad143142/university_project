import threading
import time

lock = threading.Lock()


def thread_entry():
    lock.acquire()
    main_function()
    lock.release()


def main_function():
    for _ in range(0, 30):
        time.sleep(0.1)
        print('Processing..', _)