document.getElementById('btn-clean').addEventListener('click', (e) => {
    myCanvas.clear()
});

document.getElementById('submit-img').addEventListener('click', async () => {

    const canvas = document.getElementById("demoCanvas");
    const ctx = canvas.getContext("2d");
    const canvas_data = (await resizeImageData(ctx.getImageData(0, 0, canvas.width, canvas.height), 28, 28));
    console.log(canvas_data);

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
    let gray = new Array();

    for (let i = 0; i < canvas_data.data.length; i += 4) {
      gray.push(Math.round(0.299 * canvas_data.data[i] + 0.587 * canvas_data.data[i+1] + 0.114 *canvas_data.data[i+2]));
    }

    const formData = new FormData();
    formData.append('gray_img', gray);

    // == GrayScale Image End ==


    // post form data
    const xhr = new XMLHttpRequest();

    // log response
    xhr.onload = () => {
        console.log(xhr.responseText);
    }

    // create and send the reqeust
    xhr.open('POST', '/apis/submit');
    // xhr.open('POST', 'https://495a4430-21de-4766-8cd9-c7a3c5d89cab.mock.pstmn.io');
    xhr.send(formData);

    xhr.onreadystatechange = function() { // listen for state changes
        if (xhr.readyState == 4 && xhr.status == 200) { // when completed we can move away
          document.body.innerHTML = xhr.response;
          myCanvas.clear();
        }
      }

    

});

async function resizeImageData (imageData, width, height) {
  const resizeWidth = width >> 0
  const resizeHeight = height >> 0
  const ibm = await window.createImageBitmap(imageData, 0, 0, imageData.width, imageData.height, {
    resizeWidth, resizeHeight
  })
  const canvas = document.createElement('canvas')
  canvas.width = resizeWidth
  canvas.height = resizeHeight
  const ctx = canvas.getContext('2d')
  // ctx.scale(resizeWidth / imageData.width, resizeHeight / imageData.height)
  ctx.drawImage(ibm, 0, 0)
  return ctx.getImageData(0, 0, resizeWidth, resizeHeight)
}