// Fast Selector Function Define
var $ = function (id) { return document.getElementById(id) };
// var fabric_canvas = new fabric.Canvas('photo-adjust', {});
$('btn-clean').style.display = 'none';

// Set Size
const video_size = $('camera').parentElement.clientWidth - 20;
$('camera').width = video_size;
$('camera').height = video_size;
$('photo').width = video_size;
$('photo').height = video_size;
$('filter').width = video_size;
$('filter').height = video_size;

// Draw Square on picture
var filter_ctx = $('filter').getContext('2d');
filter_ctx.beginPath();
filter_ctx.rect(video_size / 4, video_size / 4, video_size / 2, video_size / 2);
filter_ctx.stroke();

// // Otsu's Algorithm - https://gist.github.com/zz85/2ebc8e4da705dc3244200de564ab5557
// function otsu(histData /* Array of 256 greyscale values */, total /* Total number of pixels */) {
//     let sum = 0;
//     for (let t = 0; t < 256; t++) sum += t * histData[t];

//     let sumB = 0;
//     let wB = 0;
//     let wF = 0;

//     let varMax = 0;
//     let threshold = 0;

//     for (let t = 0; t < 256; t++) {
//         wB += histData[t];               // Weight Background
//         if (wB == 0) continue;

//         wF = total - wB;                 // Weight Foreground
//         if (wF == 0) break;

//         sumB += t * histData[t];

//         let mB = sumB / wB;            // Mean Background
//         let mF = (sum - sumB) / wF;    // Mean Foreground

//         // Calculate Between Class Variance
//         let varBetween = wB * wF * (mB - mF) * (mB - mF);

//         // Check if new maximum found
//         if (varBetween > varMax) {
//             varMax = varBetween;
//             threshold = t;
//         }
//     }

//     return threshold;
// }

// function getHistData(imageData) {
//     hist = new Array(256).fill(0);
//     for (let i = 0; i < imageData.length; i += 4) {
//         hist[Math.round(0.299 * imageData[i] + 0.587 * imageData[i + 1] + 0.114 * imageData[i + 2])]++;
//     }
//     return hist;
// }

// function calc_thresh(imageData) {
//     hist = getHistData(imageData);
//     return otsu(hist, imageData.length / 4);
// }

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
        })
        .catch((err) => {
            console.error(`An error occurred: ${err}`);
            alert(`開啟相機時發生${err}的錯誤！`)
        });
}

function stopCamera() {
    var video = $('camera');
    video.style.display = 'none';
    stream = video.srcObject;
    if (stream != null) {
        stream.getTracks().forEach(track => track.stop());
        video.srcObject = null;
    }
}



// 拍照
async function cheese() {
    let canva = $('photo');
    let camera = $('camera');


    // 縮放
    canva.getContext('2d').drawImage(camera, video_size / 4, video_size / 4, video_size / 2, video_size / 2, 0, 0, video_size, video_size);

    // ==== 預覽 ==== //

    // 清除gray變數
    gray = new Array();

    const canvas_data = $('photo').getContext('2d').getImageData(0, 0, video_size, video_size);
    const threshold = calc_thresh(canvas_data.data); // 使用OTSU演算法計算分辨黑白的閥值

    for (let i = 0; i < canvas_data.data.length; i += 4) {
        let tmp = (0.299 * canvas_data.data[i] + 0.587 * canvas_data.data[i + 1] + 0.114 * canvas_data.data[i + 2]) < threshold;
        canvas_data.data[i] = (!tmp) * 255;
        canvas_data.data[i + 1] = (!tmp) * 255;
        canvas_data.data[i + 2] = (!tmp) * 255;
    }

    console.log(canvas_data)

    // canva.getContext('2d').putImageData(canvas_data, 0, 0, 0, 0, video_size, video_size);
    createImageBitmap(canvas_data)
        .then(function (imgBitmap) {
            canva.getContext('2d').drawImage(imgBitmap, 0, 0, video_size, video_size, 0, 0, video_size, video_size);
        });

    // ==== 預覽結束 ==== //


    camera.style.display = 'none';
    canva.style.display = 'inline';
}


// Init
window.onload = init_camera();

// 重拍
$('btn-clean').addEventListener('click', () => {
    $('photo').style.display = 'none';
    $('btn-clean').style.display = 'none';
    $('filter').style.display = 'inline';
    $('camera').style.display = 'inline';
    $('submit-img').innerHTML = '拍攝';
    init_camera();
});

// 拍攝或是送出
$('submit-img').addEventListener('click', async () => {

    if ($('submit-img').innerHTML == '拍攝') {
        $('filter').style.display = 'none';
        cheese();
        stopCamera();
        $('btn-clean').style.display = 'inline';
        $('submit-img').innerHTML = '送出';
    } else {
        // alert('送出');
        const image_input = await $('photo').getContext('2d').getImageData(0, 0, video_size, video_size);
        const canvas_data = await resizeImageData(image_input, 28, 28);
        console.log(canvas_data);

        // == GrayScale Image Start ==
        let gray = new Array();

        // 使用OTSU演算法計算分辨黑白的閥值
        const threshold = calc_thresh(canvas_data.data);

        for (let i = 0; i < canvas_data.data.length; i += 4) {
            // GrayScale
            // gray.push(Math.round(0.299 * canvas_data.data[i] + 0.587 * canvas_data.data[i+1] + 0.114 *canvas_data.data[i+2])); 

            // Binary
            gray.push((0.299 * canvas_data.data[i] + 0.587 * canvas_data.data[i + 1] + 0.114 * canvas_data.data[i + 2]) > threshold ? 0 : 1);
            // gray.push(' ');

        }

        gray = await padding(gray, 28, 28);
        console.log(gray);

        // == GrayScale Image End ==

        // === SEND === //
        showLoadingScreen();

        const formData = new FormData();
        const xhr = new XMLHttpRequest();

        formData.append('gray_img', gray);

        // log response
        xhr.onload = () => {
            console.log(xhr.responseText);
        }

        // create and send the reqeust
        xhr.open('POST', 'https://u.yinchian.com/apis/submit');
        xhr.send(formData);

        xhr.onload = () => {
            if (xhr.status == 200) {
                // document.documentElement.innerHTML = xhr.responseText;
                localStorage.setItem('prevData', xhr.responseText);
                hideLoadingScreen();
                window.location.href = '/result.html';

            } else {
                alert(`收到${xhr.status}回傳碼，原因：${xhr.responseText || '未知'}，請再試一次`);
                hideLoadingScreen();
            }
        }

        xhr.onerror = () => {
            alert('發生問題，請再試一次');
            hideLoadingScreen();
        }
    }

});

