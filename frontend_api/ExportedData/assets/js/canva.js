document.getElementById('btn-clean').addEventListener('click', (e) => {
    myCanvas.clear()
});

document.getElementById('submit-img').addEventListener('click', (e) => {

    var canvas = document.getElementById("demoCanvas");
    var canvas_url = canvas.toDataURL();
    console.log(canvas_url);
    
    const formData = new FormData()
    formData.append('data', canvas_url)

    // post form data
    const xhr = new XMLHttpRequest()

    // log response
    xhr.onload = () => {
        console.log(xhr.responseText)
    }

    // create and send the reqeust
    xhr.open('POST', '/apis/submit')
    xhr.send(formData)

    xhr.onreadystatechange = function() { // listen for state changes
        if (xhr.readyState == 4 && xhr.status == 200) { // when completed we can move away
          document.body.innerHTML = xhr.response
        }
      }

});

