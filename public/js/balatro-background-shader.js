 

// function move(e) {

//   var card = document.getElementById(e.target.id);
//   console.log(e.target.id)
  

// var cardX = 0;
//     cardX += 20;
//    card.style.position = "relative";
//    card.style.transform = "translateY(" + -cardX + "px)";
  


// };

const WIDTH = window.innerWidth;
const HEIGHT = window.innerHeight;
const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(WIDTH, HEIGHT);
renderer.setClearColor(0xdddddd, 1);
document.body.appendChild(renderer.domElement);

const scene = new THREE.Scene();

const camera = new THREE.PerspectiveCamera(70, WIDTH / HEIGHT);
// camera.position.z = 50;

THREE.OrthographicCamera( -1, 1, 1, -1, 0, 1 );

scene.add(camera);

const shaderMaterial = new THREE.ShaderMaterial({
  vertexShader: document.getElementById("vertext.vert").textContent,
  fragmentShader: document.getElementById("fragShader").textContent,
});

 const quad = new THREE.Mesh( new THREE.PlaneBufferGeometry( 2, 2, 1, 1 ), material );
    scene.add( quad );


function render() {
  requestAnimationFrame(render);
  renderer.render(scene, camera);
}
render();
