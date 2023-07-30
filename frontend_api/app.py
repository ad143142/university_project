import requests

from flask import *
from flask_cors import *

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
@cross_origin()
def submit():
    form_data = request.form['gray_img']
    # gray_img = list(map(int, form_data.split(',')))
    print(len(form_data))
    if len(form_data) != 958:
        return "長度不符合標準", 400

    print(form_data)

    # Simulate Super Long Runtime Function (3sec)
    # time.sleep(3)

    req = requests.post(url='http://home-vpn.yinchian.com:8000', data={'data': form_data})

    if req.status_code == 200:
        res = json.loads(req.text)
        print('result =', res['result'])
        return render_template('result.html', result=res['result']), 200
    else:
        return 'Local Server Error!', 500


if __name__ == '__main__':
    app.run()
