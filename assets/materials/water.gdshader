shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_opaque, cull_disabled;
uniform sampler2D courtyard_screen : hint_screen_texture, filter_linear;
varying vec3 world_pos;
void vertex() { world_pos = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
void fragment() {
 vec2 p = world_pos.xz;
 float t = TIME * 0.36;
 float a = sin(p.x*31.0 + p.y*14.0 + t*2.0);
 float b = sin(p.x*17.0 - p.y*25.0 - t*1.4);
 float c = sin(p.x*6.0 + p.y*9.0 + t);
 vec2 distortion = vec2(a+b,b+c)*0.0014;
 vec3 beneath=texture(courtyard_screen,SCREEN_UV+distortion).rgb;
 float glint = pow(max(0.0, sin(p.x*32.0 + sin(p.y*18.0+t)*1.7+t)),22.0);
 float sunlight = (1.0-smoothstep(-4.8,1.0,p.y)) * smoothstep(-2.0,2.5,p.x);
 float reflected_light=pow(max(0.0,c*.5+.5),6.0)*.045;
 ALBEDO = beneath*vec3(.90,.97,.96)+vec3(.53,.68,.66)*reflected_light;
 EMISSION = vec3(.85,.72,.42)*glint*(sunlight*.12+.025);
 ALPHA = .78;
}
