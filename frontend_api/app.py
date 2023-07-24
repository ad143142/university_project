import random
import time

from flask import *

app = Flask(__name__, static_folder='ExportedData/assets/', template_folder='ExportedData/')


@app.route('/')
def hello_world():  # put application's code here
    return redirect('/index')


@app.route('/index')
@app.route('/index.html')
def index():
    return render_template('index.html')


@app.route('/demo')
@app.route('/demo.html')
def demo():
    return render_template('demo.html')


@app.route('/intro')
@app.route('/intro.html')
def intro():
    return render_template('intro.html')


# 使用AJAX方法
# @app.route('/api/submit', methods=['POST'])
# def api_submit():
#     time.sleep(1)
#     return random.randint(0, 9)


# 不使用AJAX方法
@app.route('/apis/submit', methods=['POST'])
def submit():
    # TODO:圖片處理
    time.sleep(3)
    return render_template('result.html', result=random.randint(0, 9))


if __name__ == '__main__':
    app.run()
