

// Fast Selector Function Define
var $ = function (id) { return document.getElementById(id) };

// Global Objects
const canvas = $('demoCanvas');
var ctx = canvas.getContext("2d", { willReadFrequently: true });
const canvas_size = canvas.parentElement.clientWidth - 20;

// Canvas Setup
const f_canvas = new fabric.Canvas('demoCanvas', {
  isDrawingMode: true,
  height: canvas_size,
  width: canvas_size,
  backgroundColor: 'white'
});

if (f_canvas.freeDrawingBrush) {
  var brush = f_canvas.freeDrawingBrush;
  brush.width = canvas_size / 28;
  brush.color = 'black';
} else {
  alert('您的瀏覽器不被支援');
  location.replace("/");
}

// Clear Button
$('btn-clean').addEventListener('click', () => {
  f_canvas.clear();
  f_canvas.backgroundColor = 'white';
});

// Init Websocket Connection OnLoad
const url = "wss://rasbpi.yinchian.com:8000/ws-api";
// const url = "ws://127.0.0.1:8000/ws-api";
var Socket = new WebSocket(url);
Socket.onopen = async () => {
  await image_prep();
  Socket.send(JSON.stringify({ "data": gray }));
}


// WebSocket Callback
// var timestamp = new Date();
Socket.onmessage = (e) => {
  // FPS計算
  // const timePassed = timestamp - new Date();
  // timestamp = new Date();

  // 送出取好的資料
  Socket.send(JSON.stringify({ "data": gray }));

  // 更新網頁資料
  let prev_result = JSON.parse(e.data);
  // console.log(prev_result);
  $('infobox').innerHTML = `${prev_result.result}: ${Math.round(Math.max(...prev_result.probability_arr) * 1000000) / 10000}%  硬體FPS = ${Math.round(1 / prev_result.total_time * 100) / 100}`

  // -- Chart --
  // var prob = prev_result.probability_arr;
  // chart = $('chart').getElementsByTagName('canvas')[0].chart;


  // chart.data.datasets[0].datasets = []; // 清空原資料
  // chart.data.labels = [];

  // for(let i = 0; i < prob.length; i = i + 1){
  //     chart.data.datasets[0].data.push(prob[i]);
  //     chart.data.labels.push(i);
  // }

  // chart.update();

  // 準備下一筆資料
  image_prep();
}

var gray;
async function image_prep() {
  let image_input = ctx.getImageData(0, 0, canvas.width, canvas.height);
  let canvas_data = await resizeImageData(image_input, 28, 28);

  gray = new Array();
  for (let i = 0; i < canvas_data.data.length; i += 4) {
    // GrayScale
    // gray.push(Math.round(0.299 * canvas_data.data[i] + 0.587 * canvas_data.data[i+1] + 0.114 *canvas_data.data[i+2])); 

    // Binary
    gray.push((0.299 * canvas_data.data[i] + 0.587 * canvas_data.data[i + 1] + 0.114 * canvas_data.data[i + 2]) > 50 ? 0 : 1);
    // gray.push(' ');

  }
  console.log(gray);
  gray = await padding(gray, res_width, res_height);
}

// 關閉交互模式
$('end-conti').addEventListener('click', () => {
  Socket.close();
});