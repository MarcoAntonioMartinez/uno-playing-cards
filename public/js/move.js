//move()
//{
//var card = document.getElementById("img");

//not really working i only want click one and move that one and be able click more than once not just first time so i will have to make it so tehyre buttons that have the images like that

//and instead of getelementbyid or whatever just do it to self so it moves current object

//card.addEventListener("click", move);
//function move(e) {
//window.onload = function() {
  function move(e) {
//var card = document.getElementById("card");
//card.addEventListener("click", move);
  //document.getElementById('card').addEventListener('click', function (e) {
//  card.addEventListener('click', function (e) {
//function move(e) {
  var card = document.getElementById(e.target.id);
  console.log(e.target.id)
  //const card = document.getElementsByClassName("card");

var cardX = 0;
    cardX += 20;
   card.style.position = "relative";
   card.style.transform = "translateY(" + -cardX + "px)";
   //" + "0px" + cardX + "px)";
   //e.preventDefault();     //prevents the page from redirecting
  
//}
//}
//};

//}

/*
var cardX = 0;
function move(e) {
   cardX += 20;
   card.style.position = "relative";
   card.style.transform = "translateX(" + cardX + "px)";
   e.preventDefault();     //prevents the page from redirecting
}

*/
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
