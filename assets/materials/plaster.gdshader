shader_type spatial;
uniform vec4 paint : source_color = vec4(.32,.48,.42,1.);
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(hash(i),hash(i+vec2(1.,0.)),f.x),mix(hash(i+vec2(0.,1.)),hash(i+vec2(1.)),f.x),f.y);}
void fragment(){
  float n=noise(UV*vec2(47.,22.));float fine=noise(UV*vec2(360.,160.));
  float worn=smoothstep(.57,.72,n);
  vec3 base=mix(paint.rgb,vec3(.55,.51,.39),worn*.73);
  base*=.87+.20*fine;
  ALBEDO=base;ROUGHNESS=.88;SPECULAR=.18;
}
