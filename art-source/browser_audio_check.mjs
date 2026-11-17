// Produces one temporary, instrumented copy of the actual web export.
// It observes output samples and ramp calls without changing audio signals.
// Remove dist/audio-check.html after the focused check; do not publish it.
import fs from 'node:fs';
const bootstrap = `<script>
(()=>{
 const metrics={windows:0,nonzero:0,clipped:0,peak:0,ramps:0,rms:0,states:[]};
 const meters=new Map(),attached=new WeakSet();
 const connect=AudioNode.prototype.connect;
 AudioNode.prototype.connect=function(destination,...args){
  const result=connect.call(this,destination,...args);
  if(destination===this.context.destination&&!attached.has(this)){
   let meter=meters.get(this.context);
   if(!meter){const analyser=this.context.createAnalyser();analyser.fftSize=2048;meter={analyser,data:new Float32Array(2048)};meters.set(this.context,meter);}
   connect.call(this,meter.analyser);attached.add(this);
  }
  return result;
 };
 const ramp=AudioParam.prototype.setTargetAtTime;
 AudioParam.prototype.setTargetAtTime=function(...args){if(args[2]===.025)metrics.ramps++;return ramp.apply(this,args);};
 setInterval(()=>{
  let energy=0,count=0;
  for(const meter of meters.values()){
   meter.analyser.getFloatTimeDomainData(meter.data);
   for(const value of meter.data){const magnitude=Math.abs(value);metrics.peak=Math.max(metrics.peak,magnitude);if(magnitude>=.999)metrics.clipped++;energy+=value*value;count++;}
  }
  metrics.rms=Math.sqrt(energy/Math.max(1,count));metrics.windows++;
  if(metrics.rms>.00001)metrics.nonzero++;
  metrics.states=[...meters.keys()].map(c=>c.state);
 },100);
 setInterval(()=>console.info('AUDIO_CHECK '+JSON.stringify(metrics)),5000);
})();
</script>`;
const html=fs.readFileSync('dist/index.html','utf8');
fs.writeFileSync('dist/audio-check.html',html.replace('<script src="index.js">',bootstrap+'<script src="index.js">'));
console.log('Temporary browser audio-check page prepared.');
