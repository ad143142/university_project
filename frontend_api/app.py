import random
import time

from flask import *

app = Flask(__name__, static_folder='assets')


@app.route('/')
def hello_world():  # put application's code here
    return redirect('/index.html')


@app.route('/index.html')
def index():
    return render_template('index.html')


@app.route('/demo.html')
def demo():
    return render_template('demo.html')


@app.route('/intro.html')
def intro():
    return render_template('intro.html')


@app.route('/api/submit', methods=['POST'])
def api_submit():
    # TODO:完成向真後端傳送之資料
    time.sleep(1)
    return random.randint(0, 9)


if __name__ == '__main__':
    app.run()
