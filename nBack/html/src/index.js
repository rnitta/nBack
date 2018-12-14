function init(detail) {
  const scene = new THREE.Scene();
    const geometry = function(n) {
        if (n % 2 == 0) {
            return new THREE.OctahedronBufferGeometry(200, (n)/2);
        } else {
            return new THREE.IcosahedronGeometry(200, (n-1)/2);
        }
    }(detail);
  const material = new THREE.MeshBasicMaterial({color: 0xff0000, wireframe: true});
  const cube = new THREE.Mesh(geometry, material);
  scene.add(cube);
  const camera = new THREE.PerspectiveCamera(45, 1.0);
  camera.position.set(0, 0, +600);
  const renderer = new THREE.WebGLRenderer({
    canvas: document.querySelector('#stage'),
    antialias: true
  });

  function onResize() {
    const width = window.innerWidth;
    const height = window.innerHeight;
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(width, height);
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
  }

  function tick() {
    renderer.render(scene, camera);
    cube.rotation.x += 0.003;
    cube.rotation.y += 0.003;
    requestAnimationFrame(tick);
  }

  tick();
  onResize();
  window.addEventListener('resize', onResize);
}


//window.addEventListener('load', init);
