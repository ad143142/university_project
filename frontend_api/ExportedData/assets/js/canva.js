// Fast Selector Function Define
var $ = function(id){return document.getElementById(id)};

// Global Objects
const canvas = $('demoCanvas');
var ctx = canvas.getContext("2d");

const canvas_size = canvas.parentElement.clientWidth - 20;

// Canvas Setup
const f_canvas = new fabric.Canvas('demoCanvas', {
  isDrawingMode: true,
  height: canvas_size,
  width: canvas_size,
  backgroundColor: 'white'
});

if(f_canvas.freeDrawingBrush){
  var brush = f_canvas.freeDrawingBrush;
  brush.width = canvas_size / 28;
  // brush.width = 10;
  brush.color = 'black';
}else{
  alert('您的瀏覽器不被支援');
  location.replace("/");
}

// Clear Button
$('btn-clean').addEventListener('click', () => {
    f_canvas.clear();
    f_canvas.backgroundColor = 'white';
});

$('submit-img').addEventListener('click', async () => {
    
    showLoadingScreen();


    // -- Get Limits --
    // var lines = [];
    // f_canvas.getObjects().forEach(function (obj) {
    //     if (obj.type === 'path') {
    //         lines.push(obj);
    //     }
    // });

    // console.log(lines);
    
    // Limit for one block => [left top right buttom] -> 遇到像是4之類需要兩個筆畫的物件，需要找上下左右的極值
    // var limits = [canvas.width, canvas.height, 0, 0];

    // lines.forEach((obj) => {
    //   // Left
    //   f_canvas.add(new fabric.Line([obj.left, 0, obj.left, canvas.height], {stroke: 'green'}))
    //   if(limits[0] > obj.left) limits[0] = obj.left;
    //   // Top
    //   f_canvas.add(new fabric.Line([0, obj.top, canvas.width, obj.top], {stroke: 'green'}))
    //   if(limits[1] > obj.top) limits[1] = obj.top;
    //   // Right
    //   f_canvas.add(new fabric.Line([obj.left + obj.width + obj.strokeWidth, 0, obj.left + obj.width + obj.strokeWidth, canvas.height], {stroke: 'green'}))
    //   if(limits[2] < obj.left + obj.width + obj.strokeWidth) limits[2] = obj.left + obj.width + obj.strokeWidth;
    //   // Button
    //   f_canvas.add(new fabric.Line([0, obj.top + obj.height + obj.strokeWidth, canvas.width, obj.top + obj.height + obj.strokeWidth], {stroke: 'green'}))
    //   if(limits[3] < obj.top + obj.height + obj.strokeWidth) limits[3] = obj.top + obj.height + obj.strokeWidth;
    // })

    // Un-Comment to show Limits
    // f_canvas.add(new fabric.Line([limits[0], 0, limits[0], canvas.height], {stroke: 'red'}));
    // f_canvas.add(new fabric.Line([0, limits[1], canvas.width, limits[1]], {stroke: 'red'}));
    // f_canvas.add(new fabric.Line([limits[2], 0, limits[2], canvas.height], {stroke: 'red'}));
    // f_canvas.add(new fabric.Line([0, limits[3], canvas.width, limits[3]], {stroke: 'red'}));

    // console.log(limits);

    // const size = ((limits[2] - limits[0]) > (limits[3] - limits[1]))? limits[2] - limits[0] : limits[3] - limits[1];
    // const image_input = await ctx.getImageData(limits[0], limits[1], limits[0] + size, limits[1] + size);
    const image_input = await ctx.getImageData(0, 0, canvas.width, canvas.height);

    // const canvas_data = await ctx.getImageData(limits[0], limits[1], limits[0] + size, limits[1] + size);
    // const canvas_data = await resizeImageData(canvas, image_input, 28, 28, limits);
    // const canvas_data = await resizeImageData(image_input, 28, 28);
    const canvas_data = await BilinearInterpolation(image_input, 28, 28);
    // f_canvas.zoomToPoint({x: canvas.width / 2, y: canvas.height / 2}, 28 / size);
    // console.log(canvas_data.data);
    

    // == ColorFul Image Start ==
    
    // let r = new Array();
    // let g = new Array();
    // let b = new Array();

    // for (let i = 0; i < canvas_data.data.length; i += 4) {
    //   r.push(canvas_data.data[i+0]);
    //   g.push(canvas_data.data[i+1]);
    //   b.push(canvas_data.data[i+2]);
    // }

    // const formData = new FormData();
    // formData.append('color_r', r);
    // formData.append('color_g', g);
    // formData.append('color_b', b);
    
    // == ColorFul Imgae End ==


    // == GrayScale Image Start ==
    let gray = [];

    // Original Gray function
    // for (let i = 0; i < canvas_data.data.length; i += 4) {
    //   // GrayScale
    //   // gray.push(Math.round(0.299 * canvas_data.data[i] + 0.587 * canvas_data.data[i+1] + 0.114 *canvas_data.data[i+2])); 
      
    //   // Binary
    //   gray.push((0.299 * canvas_data.data[i] + 0.587 * canvas_data.data[i+1] + 0.114 *canvas_data.data[i+2]) > 127 ? 0 : 1); 
    //   // gray.push(' ');

    // }

    for (let y = 0; y < canvas_data.length; y++){
      for (let x = 0; x < canvas_data[0].length; x++){
        gray.push((0.299 * canvas_data[y][x] + 0.587 * canvas_data[y][x] + 0.114 *canvas_data[y][x]) > 127 ? 0 : 1);
      }
    }
    console.log(gray);

    gray = await padding(gray, res_width, res_height);

    console.log(gray);

    const formData = new FormData();
    formData.append('gray_img', gray);
    formData.append('size_height', res_height);
    formData.append('size_width', res_width);

    // == GrayScale Image End ==


    // post form data
    const xhr = new XMLHttpRequest();

    // log response
    xhr.onload = () => {
        console.log(xhr.responseText);
    }

    // create and send the reqeust
    xhr.open('POST', 'https://u.yinchian.com/apis/submit');
    // xhr.open('POST', 'http://127.0.0.1:5000/apis/submit');
    // xhr.open('POST', 'https://rasbpi.yinchian.com:8000');
    // xhr.open('POST', 'https://495a4430-21de-4766-8cd9-c7a3c5d89cab.mock.pstmn.io');

    xhr.send(formData);

    xhr.onload = () => {
      if(xhr.status == 200){
        // document.documentElement.innerHTML = xhr.responseText;
        localStorage.setItem('prevData', xhr.responseText);
        hideLoadingScreen();
        window.location.href = '/result.html';

      }else{
        alert(`收到${xhr.status}回傳碼，原因：${xhr.responseText || '未知'}，請再試一次`);
        hideLoadingScreen();
      }
    }

    // xhr.onreadystatechange = () => { // 沒沙小路用
    //   console.log(xhr.readyState);
    // }

    xhr.onerror = () => {
      alert('發生問題，請再試一次');
      hideLoadingScreen();
    }

  }
);
