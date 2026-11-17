shader_type spatial;
render_mode diffuse_burley;
uniform vec3 teal : source_color = vec3(0.08,0.19,0.18);
uniform vec3 clay : source_color = vec3(0.30,0.14,0.085);
uniform vec3 ivory : source_color = vec3(0.39,0.36,0.28);
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
void fragment() {
  vec2 pos=UV*vec2(24.,36.);
  vec2 cell=floor(pos);vec2 p=fract(pos)-.5;
  float alt=mod(cell.x+cell.y,2.);
  vec3 base=mix(teal,clay,alt*.62);
  float r=length(p);float a=atan(p.y,p.x);
  float flower=1.-smoothstep(.0,.018,r-(.19+.065*cos(a*8.)));
  float center=1.-smoothstep(.055,.075,r);
  float border=1.-smoothstep(.014,.029,abs(max(abs(p.x),abs(p.y))-.414));
  float motif=max(flower*(1.-center),border*.48);
  base=mix(base,ivory,motif*.66);
  float wear=hash(cell);
  base*=.96+wear*.065;
  float seam=smoothstep(.475,.492,max(abs(p.x),abs(p.y)));
  ALBEDO=mix(base,vec3(.065,.085,.068),seam*.75);
  ROUGHNESS=.56;SPECULAR=.27;
}
