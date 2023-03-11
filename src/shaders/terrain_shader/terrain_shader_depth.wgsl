struct CameraUniform {
    view_proj: mat4x4<f32>,
};
@group(0)@binding(0)
var<uniform> camera: CameraUniform;
struct Light {
    position: vec3<f32>,
    flag: vec3<f32>,
}
@group(1) @binding(0)
var<uniform> light: Light;

struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) color: vec4<f32>,
    @location(2) normal: vec3<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec4<f32>,
    @location(1) depth_strength: f32,
};

struct InstanceInput {
    @location(5) model_matrix_0: vec4<f32>,
    @location(6) model_matrix_1: vec4<f32>,
    @location(7) model_matrix_2: vec4<f32>,
    @location(8) model_matrix_3: vec4<f32>,
    @location(9) color: vec4<f32>,
    @location(10) normal: vec3<f32>,
    @location(11) depth_strength:f32,
    @location(12) normal_strength:f32,
};

@vertex
fn vs_main(
    model: VertexInput,
    instance: InstanceInput,
) -> VertexOutput {

    let model_matrix = mat4x4<f32>(
        instance.model_matrix_0,
        instance.model_matrix_1,
        instance.model_matrix_2,
        instance.model_matrix_3,
    );

    var out: VertexOutput;

    out.clip_position =  camera.view_proj * model_matrix *vec4<f32>(model.position, 1.0);
    out.depth_strength = instance.depth_strength;
    return out;
}

// Fragment

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> { 
    let ndc = in.clip_position.z * 2.0 - 1.0;
    let near = 1300.0;
    let far = 3750.0;
    let linear_depth = (2.0 * near * far) / (far + near - ndc * (far - near));

    //let normalized_depth = in.clip_position.z * in.clip_position.z * 8.333 - 0.13; 

    if(in.depth_strength == 0.0){
        return vec4<f32>(1.0,1.0,1.0,1.0);
    }
    else{
        return vec4<f32>(vec3<f32>((linear_depth  * linear_depth- near * near)/(far * far  - near * near)),1.0) * (2.0 - 2.0 * in.depth_strength);
    }
    
}