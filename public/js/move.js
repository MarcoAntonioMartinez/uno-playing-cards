 

function move(e) {

  var card = document.getElementById(e.target.id);
  console.log(e.target.id)
  

var cardX = 0;
    cardX += 20;
   card.style.position = "relative";
   card.style.transform = "translateY(" + -cardX + "px)";
  


};
