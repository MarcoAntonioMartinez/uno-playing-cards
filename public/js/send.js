
function send(s){
// 2. Prepare the data to send.
    const dataToSend = { item: s };
console.log(dataToSend);
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

  }
