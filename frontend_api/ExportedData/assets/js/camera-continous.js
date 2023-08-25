// Fast Selector Function Define
var $ = function (id) { return document.getElementById(id) };

// 尺寸設定
const video_size = $('camera').parentElement.clientWidth - 20;

// 取Context
let canva = $('frame');
let camera = $('camera');
var ctx = canva.getContext("2d", { willReadFrequently: true });

// 全域變數
var isReady = false;
var black_white = [];


// Init Function
window.onload = () => {
    // 設定相機
    init_camera();

    // 隱藏清除按鈕
    // $('btn-clean').style.display = 'none';


    $('camera').width = video_size;
    $('camera').height = video_size;
    $('frame').width = video_size;
    $('frame').height = video_size;
    $('filter').width = video_size;
    $('filter').height = video_size;

    // 繪製中間的方框
    var filter_ctx = $('filter').getContext('2d');
    filter_ctx.strokeStyle = "blue";
    filter_ctx.beginPath();
    filter_ctx.rect(video_size / 4, video_size / 4, video_size / 2, video_size / 2);
    filter_ctx.stroke();
}

$('camera').addEventListener('canplay', () => {
    while(Socket.readyState != 1);
    isReady = true;
})

const constraints = {
    video: {
        width: {
            ideal: video_size
        },
        height: {
            ideal: video_size
        },
        facingMode: "environment"
    },
    audio: false
};

function init_camera() {
    var video = $('camera');
    navigator.mediaDevices
        .getUserMedia(constraints)
        .then((stream) => {
            video.srcObject = stream;
            video.play();
            frame();
        })
        .catch((err) => {
            console.error(`An error occurred: ${err}`);
            alert(`開啟相機時發生${err}的錯誤！`)
        });
}


// Init Websocket Connection OnLoad
const url = "wss://rasbpi.yinchian.com:8000/ws-api";
// const url = "ws://127.0.0.1:8000/ws-api";
var Socket = new WebSocket(url);

Socket.onmessage = (e) => {
    let prev_result = JSON.parse(e.data);
    $('infobox').innerHTML = `${prev_result.result}: ${Math.round(Math.max(...prev_result.probability_arr) * 1000000) / 10000}%  硬體FPS = ${Math.round(1 / prev_result.total_time * 100) / 100}`
    isReady = true;
}

const grayer = (imageData, threshold) => {
    // return new Promise((res) => {
    //     black_white = [];
    //     for (let i = 0; i < imageData.data.length; i += 4) {
    //         let tmp = (0.299 * imageData.data[i] + 0.587 * imageData.data[i + 1] + 0.114 * imageData.data[i + 2]) < threshold;
    //         imageData.data[i] = (!tmp) * 255;
    //         imageData.data[i + 1] = (!tmp) * 255;
    //         imageData.data[i + 2] = (!tmp) * 255;
    //         black_white.push(tmp);
    //     }
    //     res(imageData);
    // });

    black_white = [];
    for (let i = 0; i < imageData.data.length; i += 4) {
        let tmp = (0.299 * imageData.data[i] + 0.587 * imageData.data[i + 1] + 0.114 * imageData.data[i + 2]) < threshold;
        imageData.data[i] = (!tmp) * 255;
        imageData.data[i + 1] = (!tmp) * 255;
        imageData.data[i + 2] = (!tmp) * 255;
        black_white.push(tmp * 1);
    }
    return imageData;

}

async function frame() {

    if (camera.paused || camera.ended) return;

    await ctx.drawImage(camera, 0, 0, canva.width, canva.height);

    let imageData = await ctx.getImageData(0, 0, canva.width, canva.height);

    // OTSU演算法取閥值
    const threshold = await calc_thresh(imageData.data);

    // 套用新值
    // black_white = [];
    // for (let i = 0; i < imageData.data.length; i += 4) {
    //     let tmp = (0.299 * imageData.data[i] + 0.587 * imageData.data[i + 1] + 0.114 * imageData.data[i + 2]) < threshold;
    //     imageData.data[i] = (!tmp) * 255;
    //     imageData.data[i + 1] = (!tmp) * 255;
    //     imageData.data[i + 2] = (!tmp) * 255;
    //     black_white.push(tmp);
    // }

    imageData = await grayer(imageData, threshold);

    // 顯示！
    ctx.putImageData(imageData, 0, 0);

    if (isReady) {
        isReady = false;
        // Do Something
        image_prep().then((r) => {
            console.log('Send> ', r);
            Socket.send(JSON.stringify({ "data": r }));
        });
        
    }

    requestAnimationFrame(frame);
}



async function image_prep() {
    // const imageData = ctx.getImageData(0, 0, canva.width, canva.width);
    // const ret = BilinearInterpolation(imageData, 28, 28)
    let ret = await BilinearInterpolation(black_white, 28, 28, video_size / 4, video_size / 4, video_size * 3 / 4, video_size * 3 / 4, canva.width);
    // console.log(ret);
    ret = await padding([].concat.apply([], ret), 28, 28);
    console.log(ret);
    return ret;
}