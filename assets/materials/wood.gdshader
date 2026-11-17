shader_type spatial;
uniform vec4 wood_color : source_color = vec4(.25,.17,.11,1.);
varying vec3 wp;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
  float grain=sin(wp.x*420.+sin(wp.z*7.)*3.+sin(wp.y*9.)*2.);
  float fleck=hash(floor(wp.xz*240.));
  ALBEDO=wood_color.rgb*(.89+grain*.07+fleck*.14);ROUGHNESS=.67+fleck*.12;SPECULAR=.22;
}
