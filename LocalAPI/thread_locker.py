import random
import threading
import time
import sys

# sys.path.append('/home/xilinx/jupyter_notebooks/[TOP] Flexible University Project/')
lock = threading.Lock()


# import main_code

def thread_entry(data):
    lock.acquire()
    ret = main_function(data)
    lock.release()

    return ret


def main_function(data):
    """
    >> 當有外部請求的時候，會呼叫這個程式。欲與後端整合請修改這邊。 <<
    ---
    後端與訓練程式的連結
    :return: 用JSON格式表示的Python Dictionary
    """

    # print('Get Data>', data)

    # Simulate a long execution time function
    for _ in range(0, 10):
        time.sleep(0.1)
        print('Processing..', _)

    # JSON-like Dictionary Object
    return {'result': random.randint(0, 9),
            'probability_arr': [3.4994741e-06, 9.9958432e-01, 2.4019920e-08, 1.7870320e-08,
                                1.0729757e-05, 1.0367481e-06, 7.5637257e-07, 3.9836887e-04,
                                5.4714109e-09, 1.2623170e-06],
            'total_time': 0.08027005195617676,
            'data_prep_time': 0.045114755630493164,
            'conv_time': 0.021091222763061523,
            'pool_time': 0.01205897331237793,
            'fc_time': 0.0007233619689941406}
