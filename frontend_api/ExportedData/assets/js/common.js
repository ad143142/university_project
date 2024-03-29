// Parameter
const res_height = 28, res_width = 28;

function showLoadingScreen() {
  let popup = document.createElement('div');
  document.body.style.setProperty('overflow', 'hidden');
  document.body.appendChild(popup);
  popup.classList.add('animate__animated', 'animate__fadeIn');
  popup.style = `
      box-shadow: rgba(0, 0, 0, 0.2) 0px 3px 10px;
      background: rgba(0, 0, 0, 0.125);
      position: fixed;
      inset: 0px;
      backdrop-filter: blur(10px);
      `;
  popup.id = 'popup';
  popup.innerHTML = `
    <svg id="loading">
      <g>
        <path class="ld-l" fill="#39C0C4" d="M43.6,33.2h9.2V35H41.6V15.2h2V33.2z"/>
        <path class="ld-o" fill="#39C0C4" d="M74.7,25.1c0,1.5-0.3,2.9-0.8,4.2c-0.5,1.3-1.2,2.4-2.2,3.3c-0.9,0.9-2,1.6-3.3,2.2
          c-1.3,0.5-2.6,0.8-4.1,0.8s-2.8-0.3-4.1-0.8c-1.3-0.5-2.4-1.2-3.3-2.2s-1.6-2-2.2-3.3C54.3,28,54,26.6,54,25.1s0.3-2.9,0.8-4.2
          c0.5-1.3,1.2-2.4,2.2-3.3s2-1.6,3.3-2.2c1.3-0.5,2.6-0.8,4.1-0.8s2.8,0.3,4.1,0.8c1.3,0.5,2.4,1.2,3.3,2.2c0.9,0.9,1.6,2,2.2,3.3
          C74.4,22.2,74.7,23.6,74.7,25.1z M72.5,25.1c0-1.2-0.2-2.3-0.6-3.3c-0.4-1-0.9-2-1.6-2.8c-0.7-0.8-1.6-1.4-2.6-1.9
          c-1-0.5-2.2-0.7-3.4-0.7c-1.3,0-2.4,0.2-3.4,0.7c-1,0.5-1.9,1.1-2.6,1.9c-0.7,0.8-1.3,1.7-1.6,2.8c-0.4,1-0.6,2.1-0.6,3.3
          c0,1.2,0.2,2.3,0.6,3.3c0.4,1,0.9,2,1.6,2.7c0.7,0.8,1.6,1.4,2.6,1.9c1,0.5,2.2,0.7,3.4,0.7c1.3,0,2.4-0.2,3.4-0.7
          c1-0.5,1.9-1.1,2.6-1.9c0.7-0.8,1.3-1.7,1.6-2.7C72.4,27.4,72.5,26.3,72.5,25.1z"/>
        <path class="ld-a" fill="#39C0C4" d="M78.2,35H76l8.6-19.8h2L95.1,35h-2.2l-2.2-5.2H80.4L78.2,35z M81.1,27.9h8.7l-4.4-10.5L81.1,27.9z"/>
        <path class="ld-d" fill="#39C0C4" d="M98,15.2h6.6c1.2,0,2.5,0.2,3.7,0.6c1.2,0.4,2.4,1,3.4,1.9c1,0.8,1.8,1.9,2.4,3.1s0.9,2.7,0.9,4.3
          c0,1.7-0.3,3.1-0.9,4.3s-1.4,2.3-2.4,3.1c-1,0.8-2.1,1.5-3.4,1.9c-1.2,0.4-2.5,0.6-3.7,0.6H98V15.2z M100,33.2h4
          c1.5,0,2.8-0.2,3.9-0.7c1.1-0.5,2-1.1,2.8-1.8c0.7-0.8,1.3-1.6,1.6-2.6s0.5-2,0.5-3c0-1-0.2-2-0.5-3c-0.4-1-0.9-1.8-1.6-2.6
          c-0.7-0.8-1.6-1.4-2.8-1.8c-1.1-0.5-2.4-0.7-3.9-0.7h-4V33.2z"/>
        <path class="ld-i" fill="#39C0C4" d="M121.2,35h-2V15.2h2V35z"/>
        <path class="ld-n" fill="#39C0C4" d="M140.5,32.1L140.5,32.1l0.1-16.9h2V35h-2.5l-11.5-17.1h-0.1V35h-2V15.2h2.5L140.5,32.1z"/>
        <path class="ld-g" fill="#39C0C4" d="M162.9,18.8c-0.7-0.7-1.5-1.3-2.5-1.7c-1-0.4-2-0.6-3.3-0.6c-1.3,0-2.4,0.2-3.4,0.7s-1.9,1.1-2.6,1.9
          c-0.7,0.8-1.3,1.7-1.6,2.8c-0.4,1-0.6,2.1-0.6,3.3c0,1.2,0.2,2.3,0.6,3.3c0.4,1,0.9,2,1.6,2.7c0.7,0.8,1.6,1.4,2.6,1.9
          s2.2,0.7,3.4,0.7c1.1,0,2.1-0.1,3.1-0.4c0.9-0.2,1.7-0.5,2.3-0.9v-6h-4.6v-1.8h6.6v9c-1.1,0.7-2.2,1.1-3.5,1.5
          c-1.3,0.3-2.5,0.5-3.9,0.5c-1.5,0-2.9-0.3-4.1-0.8s-2.4-1.2-3.3-2.2c-0.9-0.9-1.6-2-2.1-3.3s-0.8-2.7-0.8-4.2s0.3-2.9,0.8-4.2
          c0.5-1.3,1.2-2.4,2.2-3.3c0.9-0.9,2-1.6,3.3-2.2c1.3-0.5,2.6-0.8,4.1-0.8c1.6,0,3,0.2,4.1,0.7s2.2,1.1,3,2L162.9,18.8z"/>
      </g>
    </svg>
    <svg width='182px' height='182px' xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid" class="uil-ripple"><rect x="0" y="0" width="100" height="100" fill="none" class="bk"></rect><g> <animate attributeName="opacity" dur="4s" repeatCount="indefinite" begin="0s" keyTimes="0;0.33;1" values="1;1;0"></animate><circle cx="50" cy="50" r="40" stroke="#eeeeee" fill="none" stroke-width="2" stroke-linecap="round"><animate attributeName="r" dur="4s" repeatCount="indefinite" begin="0s" keyTimes="0;0.33;1" values="0;22;44"></animate></circle></g><g><animate attributeName="opacity" dur="4s" repeatCount="indefinite" begin="2s" keyTimes="0;0.33;1" values="1;1;0"></animate><circle cx="50" cy="50" r="40" stroke="#eeeeee" fill="none" stroke-width="2" stroke-linecap="round"><animate attributeName="r" dur="4s" repeatCount="indefinite" begin="2s" keyTimes="0;0.33;1" values="0;22;44"></animate></circle></g></svg>`;

}


function hideLoadingScreen() {
  $('popup').remove();
  document.body.style.setProperty('overflow', 'unset');
}

// 1-D Array -> String
async function padding(imageArray, width, height) {
  let ret = '';

  // Assuming 'imageArray' only contains 0 and 1

  for (let i = 0; i < width + 2; i += 1) {
    ret += 1 - i % 2;
    ret += ' '
  }

  ret = ret.substring(0, ret.length - 1);
  ret += '\n';

  // ret += ' ';
  for (let i = 0; i < width; i += 1) {
    ret += i % 2;

    ret += ' ';

    for (let j = 0; j < height; j += 1) {
      ret += imageArray[i * width + j];

      ret += ' ';
    }
    ret += 1 - i % 2;
    ret += '\n';
    // ret += ' ';
  }
  for (let i = 0; i < width + 2; i += 1) {
    ret += i % 2;
    ret += ' ';
  }
  ret = ret.substring(0, ret.length - 1);
  return ret;
}

async function resizeImageData(imageData, width, height) {
  const resizeWidth = width >> 0
  const resizeHeight = height >> 0
  const ibm = await window.createImageBitmap(imageData, 0, 0, imageData.width, imageData.height, {
    resizeWidth, resizeHeight
  })
  const _canvas = document.createElement('canvas')
  _canvas.width = resizeWidth
  _canvas.height = resizeHeight
  const _ctx = _canvas.getContext('2d')
  _ctx.drawImage(ibm, 0, 0)
  return _ctx.getImageData(0, 0, resizeWidth, resizeHeight)
}

// 手刻縮放的演算法 - 輸入為imageData，僅需輸入欲設定的大小(整數)
// function BilinearInterpolation(imageData, res_x, res_y) {
  
//   // 輸入是imageData物件
//   const data = [];
//   for (let y = 0; y < imageData.height; y++) {
//     data.push(new Array());
//     for (let x = 0; x < imageData.width * 4; x += 4) {
//       data[y].push(imageData.data[y * imageData.width * 4 + x]);
//     }
//   }


//   // 應該相等
//   x_ratio = (data[0].length - 1) / (res_x - 1);
//   y_ratio = (data.length - 1) / (res_y - 1);

//   let ret = new Array(res_x);
//   for (let x = 0; x < res_x; x++) {
//     ret[x] = new Array(res_y);
//     for (let y = 0; y < res_y; y++) {
//       // 四個鄰近的座標
//       x_l = Math.floor(x_ratio * x);
//       y_l = Math.floor(y_ratio * y);
//       x_h = Math.ceil(x_ratio * x);
//       y_h = Math.ceil(y_ratio * y);

//       // 位置的比例當權重
//       x_ratio_weight = x_ratio * x - x_l;
//       y_ratio_weight = y_ratio * y - y_l;

//       ret[x][y] = (data[x_l][y_l] * (1 - x_ratio_weight) * (1 - y_ratio_weight) + data[x_h][y_l] * x_ratio_weight * (1 - y_ratio_weight) + data[x_l][y_h] * (1 - x_ratio_weight) * y_ratio_weight + data[x_h][y_h] * x_ratio_weight * y_ratio_weight);
//     }
//   }

//   return ret;
// }

// // 手刻縮放的演算法 - overding 1: 輸入是array, 可調整大小
// function BilinearInterpolation(imageData, res_x, res_y, orig_xl, orig_yl, orig_xh, orig_yh, orig_xlen) {

//   const data = [];
//   for (let y = orig_yl; y < orig_yh; y++) {
//     data.push(new Array());
//     for (let x = orig_xl; x < orig_xh; x++) {
//       data[y - orig_yl].push(imageData[Math.round(y) * orig_xlen + Math.round(x)] * 1);
//     }
//   }

//   x_ratio = (data[0].length - 1) / (res_x - 1);
//   y_ratio = (data.length - 1) / (res_y - 1);

//   let ret = new Array(res_x);
//   for (let x = 0; x < res_x; x++) {
//     ret[x] = new Array(res_y);
//     for (let y = 0; y < res_y; y++) {
//       // 四個鄰近的座標
//       x_l = Math.floor(x_ratio * x);
//       y_l = Math.floor(y_ratio * y);
//       x_h = Math.ceil(x_ratio * x);
//       y_h = Math.ceil(y_ratio * y);

//       // 位置的比例當權重
//       x_ratio_weight = x_ratio * x - x_l;
//       y_ratio_weight = y_ratio * y - y_l;

//       ret[x][y] = Math.round(data[x_l][y_l] * (1 - x_ratio_weight) * (1 - y_ratio_weight) + data[x_h][y_l] * x_ratio_weight * (1 - y_ratio_weight) + data[x_l][y_h] * (1 - x_ratio_weight) * y_ratio_weight + data[x_h][y_h] * x_ratio_weight * y_ratio_weight);
//     }
//   }
//   return ret;
// }

// Function with Overloading
function BilinearInterpolation(imageData, res_x, res_y, orig_xl, orig_yl, orig_xh, orig_yh, orig_xlen) {

  const data = new Array();
  if(arguments.length == 8){
    for (let y = orig_yl; y < orig_yh; y++) { // 輸入是array物件
      data.push(new Array());
      for (let x = orig_xl; x < orig_xh; x++) {
        data[y - orig_yl].push(imageData[Math.round(y) * orig_xlen + Math.round(x)] * 1);
      }
    }
  } else if (arguments.length == 3){  // 輸入是imageData物件
    for (let y = 0; y < imageData.height; y++) {
      data.push(new Array());
      for (let x = 0; x < imageData.width * 4; x += 4) {
        data[y].push(imageData.data[y * imageData.width * 4 + x]);
      }
    }
  } else {
    console.error(`BilinearInterpolation's argument amount suouldn't be ${arguments.length}`);
  }

  x_ratio = (data[0].length - 1) / (res_x - 1);
  y_ratio = (data.length - 1) / (res_y - 1);

  let ret = new Array(res_x);
  for (let x = 0; x < res_x; x++) {
    ret[x] = new Array(res_y);
    for (let y = 0; y < res_y; y++) {
      // 四個鄰近的座標
      x_l = Math.floor(x_ratio * x);
      y_l = Math.floor(y_ratio * y);
      x_h = Math.ceil(x_ratio * x);
      y_h = Math.ceil(y_ratio * y);

      // 位置的比例當權重
      x_ratio_weight = x_ratio * x - x_l;
      y_ratio_weight = y_ratio * y - y_l;

      ret[x][y] = Math.round(data[x_l][y_l] * (1 - x_ratio_weight) * (1 - y_ratio_weight) + data[x_h][y_l] * x_ratio_weight * (1 - y_ratio_weight) + data[x_l][y_h] * (1 - x_ratio_weight) * y_ratio_weight + data[x_h][y_h] * x_ratio_weight * y_ratio_weight);
    }
  }
  return ret;
}

// Testing
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

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
  hist = new Array(256).fill(0);
  for (let i = 0; i < imageData.length; i += 4) {
    hist[Math.round(0.299 * imageData[i] + 0.587 * imageData[i + 1] + 0.114 * imageData[i + 2])]++;
  }
  return hist;
}

// Entry Function of OTSU
// Input: ImageData: 
function calc_thresh(imageData) {
  hist = getHistData(imageData);
  return otsu(hist, imageData.length / 4);
}