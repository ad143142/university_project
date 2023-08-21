// Fast Selector Function Define
var $ = function (id) { return document.getElementById(id) };

// Otsu's Algorithm - https://gist.github.com/zz85/2ebc8e4da705dc3244200de564ab5557
function otsu(histData /* Array of 256 greyscale values */, total /* Total number of pixels */) {
    let sum = 0;
    for (let t = 0; t < 256; t++) sum += t * histData[t];

    let sumB = 0;
    let wB = 0;
    let wF = 0;

    let varMax = 0;
    let threshold = 0;

    for (let t = 0; t < 256; t++) {
        wB += histData[t];               // Weight Background
        if (wB == 0) continue;

        wF = total - wB;                 // Weight Foreground
        if (wF == 0) break;

        sumB += t * histData[t];

        let mB = sumB / wB;            // Mean Background
        let mF = (sum - sumB) / wF;    // Mean Foreground

        // Calculate Between Class Variance
        let varBetween = wB * wF * (mB - mF) * (mB - mF);

        // Check if new maximum found
        if (varBetween > varMax) {
            varMax = varBetween;
            threshold = t;
        }
    }

    return threshold;
}

function getHistData(imageData) {
    hist = new Array(256);
    for (let i = 0; i < imageData.length; i += 4) {
        hist[0.299 * imageData.data[i] + 0.587 * imageData.data[i + 1] + 0.114 * imageData.data[i + 2]]++;
    }
    return hist;
}

function calc_thresh(imageData) {
    hist = getHistData(imageData);
    return otsu(hist, imageData.length / 4);
}


let streaming = false;
const video_size = $('camera').parentElement.clientWidth - 20;
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


// Init
window.onload = () => {
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

// Submit
$('submit-img').addEventListener('click', () => {

    stopCamera();

    // === SEND === //

    const formData = new FormData();
    const xhr = new XMLHttpRequest();

    formData.append('gray_img', /* __ToBeFilled__ */);

    // log response
    xhr.onload = () => {
        console.log(xhr.responseText);
    }

    // create and send the reqeust
    xhr.open('POST', '/apis/submit');
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
});

function stopCamera() {
    var videoSource = $('camera');
    stream = videoSource.srcObject;
    if (stream != null) {
        stream.getTracks().forEach(track => track.stop());
        videoSource.srcObject = null;
    }
}