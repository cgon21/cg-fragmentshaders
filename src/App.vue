<script setup>
import { reactive, onMounted } from 'vue';

import { Engine } from '@babylonjs/core/Engines/engine';
import { Scene } from '@babylonjs/core/scene';
import { UniversalCamera } from '@babylonjs/core/Cameras/universalCamera';
import { Vector3 } from '@babylonjs/core/Maths/math.vector';
import { Mesh } from '@babylonjs/core/Meshes/mesh';
import { VertexData } from '@babylonjs/core/Meshes/mesh.vertexData';
import { ShaderMaterial } from '@babylonjs/core/Materials/shaderMaterial';
import { VideoTexture } from '@babylonjs/core/Materials/Textures/videoTexture';

const BASE_URL = import.meta.env.BASE_URL || '/';

let data = reactive({
    gl: null,
    scene: null,
    filter_button: null,
    filter: 'standard',
    filter_options: [
        {id: 'standard', name: 'Standard', selected: true},
        {id: 'blackwhite', name: 'Black & White', selected: false},
        {id: 'fisheye', name: 'Fish Eye', selected: false},
        {id: 'ripple', name: 'Ripple', selected: false},
        {id: 'toon', name: 'Toonify', selected: false},
        {id: 'custom', name: 'Custom', selected: false}
    ],
    materials: {},
    selected_texture: 'video',
    textures: {video: null, webcam: null},
    start_stop: 'Stop'
});


function createShaderMaterial(shader, scene) {
    let material = new ShaderMaterial(shader, scene, BASE_URL + 'shaders/' + shader, {
        attributes: ['position', 'uv'],
        uniforms: ['worldViewProjection'],
        samplers: ['image']
    });
    material.backFaceCulling = false;
    return material;
}

function selectFilter(event) {
    data.filter = event.target.id;
    data.filter_button.setAttribute('selected', 'false');
    let new_filter_button = document.getElementById(event.target.id + '_button');
    new_filter_button.setAttribute('selected', 'true');
    data.filter_button = new_filter_button;
}

function toggleImageInput(event) {
    if (data.selected_texture === 'video') {
        data.selected_texture = 'webcam';
        data.textures.video.video.pause();
        if (data.textures.webcam === null && data.start_stop === 'Stop') {
            VideoTexture.CreateFromWebCam(data.scene, (texture) => {
                data.textures.webcam = texture;
            }, {width: {ideal: 1280}, height: {ideal: 720}}, false, false);
        }
    }
    else {
        data.selected_texture = 'video';
        if (data.textures.webcam !== null) {
            let webcam_stream = data.textures.webcam.video.srcObject;
            webcam_stream.getTracks().forEach((track) => {
                track.stop();
            });
            data.textures.webcam.dispose();
            data.textures.webcam = null;
        }
        if (data.start_stop === 'Stop') {
            data.textures.video.video.play();
        }
    }
}

function startStop(event) {
    let start_stop_button = document.getElementById('start_stop');
    if (data.start_stop === 'Start') {
        data.start_stop = 'Stop';
        start_stop_button.style.backgroundColor = '#D85A58';
        if (data.selected_texture === 'video') {
            data.textures.video.video.play();
        }
        else {
            VideoTexture.CreateFromWebCam(data.scene, (texture) => {
                data.textures.webcam = texture;
            }, {width: {ideal: 1280}, height: {ideal: 720}}, false, false);
        }
    }
    else {
        data.start_stop = 'Start';
        start_stop_button.style.backgroundColor = '#48C45B';
        if (data.selected_texture === 'video') {
            data.textures.video.video.pause();
        }
        else {
            let webcam_stream = data.textures.webcam.video.srcObject;
            webcam_stream.getTracks().forEach((track) => {
                track.stop();
            });
            data.textures.webcam.dispose();
            data.textures.webcam = null;
        }
    }
}

onMounted(() => {
    // Get the canvas element from the DOM
    const canvas = document.getElementById('renderCanvas');
    canvas.width = 800;
    canvas.height = 450;

    // Set initial selected filter
    data.filter_button = document.getElementById('standard_button');

    // Create a WebGL 2 rendering context
    data.gl = canvas.getContext('webgl2');
    if (!data.gl) {
        alert('Error: Browser does not support WebGL2 Canvas');
        return;
    }

    // Associate a Babylon Render Engine to it.
    const engine = new Engine(data.gl);

    // Create our first scene.
    data.scene = new Scene(engine);
    data.scene.useRightHandedSystem = true;
    data.scene.skipFrustumClipping = true;

    // Add a camera to the scene
    let camera = new UniversalCamera('camera', new Vector3(0.0, 0.0, 0.0), data.scene);
    camera.detachControl();

    // Create materials
    data.materials.standard = createShaderMaterial('standard', data.scene);
    data.materials.blackwhite = createShaderMaterial('blackwhite', data.scene);
    data.materials.fisheye = createShaderMaterial('fisheye', data.scene);
    data.materials.ripple = createShaderMaterial('ripple', data.scene);
    data.materials.toon = createShaderMaterial('toon', data.scene);
    data.materials.custom = createShaderMaterial('custom', data.scene);

    // Create video textures
    data.textures.video = new VideoTexture('video', BASE_URL + 'videos/rainBee.mp4', data.scene, false,
                                           false, VideoTexture.BILINEAR_SAMPLINGMODE, 
                                           {autoUpdateTexture: true, autoPlay: true, loop: true, muted: true});

    data.materials.standard.setTexture('image', data.textures.video);
    data.materials.blackwhite.setTexture('image', data.textures.video);
    data.materials.fisheye.setTexture('image', data.textures.video);
    data.materials.ripple.setTexture('image', data.textures.video);
    data.materials.toon.setTexture('image', data.textures.video);
    data.materials.custom.setTexture('image', data.textures.video);

    // Create simple rectangle model
    let rect = new Mesh('rect', data.scene);
    let vertex_positions = [
        -1.0, -1.0,  0.0, // vertex 0 (x,y,z)
         1.0, -1.0,  0.0, // vertex 1 (x,y,z)
         1.0,  1.0,  0.0, // vertex 2 (x,y,z)
        -1.0,  1.0,  0.0  // vertex 3 (x,y,z)
    ];
    let vertex_texcoords = [
        0.0, 0.0, // vertex 0 (u,v)
        1.0, 0.0, // vertex 1 (u,v)
        1.0, 1.0, // vertex 2 (u,v)
        0.0, 1.0  // vertex 3 (u,v)
    ]
    let triangle_indices = [
        0, 1, 2,   // connect vertices 0,1,2 to make a triangle
        0, 2, 3    // connect vertices 0,2,3 to make a triangle
    ];
    let vertex_data = new VertexData();
    vertex_data.positions = vertex_positions;
    vertex_data.uvs = vertex_texcoords;
    vertex_data.indices = triangle_indices;
    vertex_data.applyToMesh(rect);

    // Assign triangle a material
    rect.material = data.materials.standard;

    // Animation function - called before each frame gets rendered
    data.scene.onBeforeRenderObservable.add(() => {
        if (data.filter !== rect.material.name) {
            rect.material = data.materials[data.filter];
        }

        if (data.textures[data.selected_texture] !== null) {
            data.materials[data.filter].setTexture('image', data.textures[data.selected_texture]);
        }
    });

    // Render every frame
    engine.runRenderLoop(() => {
        data.scene.render();
    });
});
</script>

<template>
    <h1>WebGL Fragment Shader Fun!</h1>
    <canvas id="renderCanvas" touch-action="none"></canvas>
    <br/>
    <div class="spacer"></div>
    <div id="gui">
        <div v-for="f in data.filter_options" :id="f.id + '_button'" class="filter_button" :selected="f.selected"  @click="selectFilter">
            <p :id="f.id">{{ f.name }}</p>
        </div>
    </div>
    <div class="spacer"></div>
    <div>
        <div id="image_toggle">
            <div style="display: inline-block;">
                <label class="toggle_label">Video</label>
            </div>
            <div style="display: inline-block;">
                <label class="switch" style="margin-top: 0.25rem;">
                    <input id="image_input" type="checkbox" @change="toggleImageInput">
                    <span class="slider round"></span>
                </label>
            </div>
            <div style="display: inline-block;">
                <label class="toggle_label">WebCam</label>
            </div>
        </div>
        <div id="start_stop_button">
            <p id="start_stop" @click="startStop">{{ data.start_stop }}</p>
        </div>
    </div>
</template>

<style scoped>
h1 {
    font-size: 1.5rem;
    font-weight: bold;
    font-style: normal;
}

p, label {
    font-size: 0.875rem;
}

input {
    margin: 0.2rem;
}

#start_stop_button {
    display: inline-block;
    vertical-align: top;
    background-color: #D85A58;
    width: 8rem;
    height: 2.5rem;
    margin: 0.5rem;
    cursor: pointer;
}

#start_stop_button p {
    height: 2.5rem;
    line-height: 2.5rem;
    color: #000000;
}

#image_toggle {
    display: inline-block;
    vertical-align: top;
    width: 20rem;
    height: 3rem;
    margin: 0.5rem;
}

.toggle_label {
    display: inline-block;
    margin: 0.75rem 1rem 0 1rem;
}

.filter_button {
    display: inline-block;
    background-color: #6A6A6A;
    width: 8rem;
    height: 2.5rem;
    margin: 0.5rem;
    cursor: pointer;
}

.filter_button[selected="true"] {
    background-color: #2A3A8A;
}

.filter_button p {
    height: 2.5rem;
    line-height: 2.5rem;
    color: #FFFFFF;
}

.spacer {
    height: 1rem;
}

.switch {
    position: relative;
    display: inline-block;
    width: 3.5rem;
    height: 1.5rem;
}
  
.switch input { 
    opacity: 0;
    width: 0;
    height: 0;
}

.slider {
    position: absolute;
    cursor: pointer;
    top: -0.3rem;
    left: 0;
    right: 0;
    bottom: 0.3rem;
    background-color: #CCCCCC;
    -webkit-transition: .4s;
    transition: .4s;
}
  
.slider:before {
    position: absolute;
    content: "";
    height: 1.1rem;
    width: 1.1rem;
    left: 0.2rem;
    bottom: 0.2rem;
    background-color: #FFFFFF;
    -webkit-transition: 0.4s;
    transition: 0.4s;
}
  
input:checked + .slider {
    background-color: #2196F3;
}
  
input:focus + .slider {
    box-shadow: 0 0 1px #2196F3;
}
  
input:checked + .slider:before {
    -webkit-transform: translateX(2rem);
    -ms-transform: translateX(2rem);
    transform: translateX(2rem);
}
  
/* Rounded sliders */
.slider.round {
    border-radius: 1.1rem;
}
  
.slider.round:before {
    border-radius: 50%;
}
</style>
