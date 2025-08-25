function move(e) {

  var card = document.getElementById(e.target.id);
  console.log(e.target.id)
  

var cardX = 0;
    cardX += 20;
   card.style.position = "relative";
   card.style.transform = "translateY(" + -cardX + "px)";
  
const src = e.target.src
   // 2. Prepare the data to send.
    const dataToSend = { item: src };

    // 3. Use fetch to send the data to the Sinatra server.
    fetch('/api/process-click', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(dataToSend), // Convert the JavaScript object to a JSON string.
    })
    .then(response => response.json())
    .then(data => {
      console.log('Success:', data);
      alert(data.message);
    })
    .catch((error) => {
      console.error('Error:', error);
    });



};
