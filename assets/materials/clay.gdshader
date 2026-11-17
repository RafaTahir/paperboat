shader_type spatial;
render_mode diffuse_burley;
uniform vec4 clay_color : source_color = vec4(.42,.20,.11,1.);
varying vec3 local_pos;
float hash(vec3 p){return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453);}
float noise(vec3 p){vec3 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){local_pos=VERTEX;}
void fragment(){
  float broad=noise(local_pos*17.);float grain=noise(local_pos*290.);
  float patina=smoothstep(.57,.70,noise(local_pos*vec3(11.,7.,11.)));
  float thrown=sin(local_pos.y*650.+broad*7.)*.022;
  vec3 c=clay_color.rgb*(.85+grain*.24+thrown);
  c=mix(c,vec3(.46,.45,.31),patina*.65);
  c=mix(c,vec3(.16,.22,.085),(1.-smoothstep(0.,.19,local_pos.y))*.48);
  ALBEDO=c;ROUGHNESS=.48+grain*.20;SPECULAR=.35;
}
