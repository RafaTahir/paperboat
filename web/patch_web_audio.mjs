// Targeted adapter for Godot 4.6.3's MIT-licensed web Sample backend.
// Upstream SampleNodeBus.setVolume assigns AudioParam.value immediately:
// https://github.com/godotengine/godot/blob/4.6.3-stable/platform/web/js/libs/library_godot_audio.js#L268
// Keep the engine WASM and Sample playback; smooth only changes after a
// channel's initial gain, using the browser audio clock rather than frame time.
export function patchWebAudio(source) {
  if (source.includes('/* AFTER_RAIN_AUDIO_SMOOTHING_V1 */')) return source;
  const marker = 'setVolume(volume){if(volume.length!==GodotAudio.MAX_VOLUME_CHANNELS)';
  const start = source.indexOf(marker);
  const end = source.indexOf('clear(){this._bus=null;', start);
  if (start < 0 || end < 0 || source.indexOf(marker, start + 1) !== -1) {
    throw new Error('Web audio adapter requires the pinned Godot 4.6.3 SampleNodeBus layout.');
  }
  const replacement = `setVolume(volume){
    /* AFTER_RAIN_AUDIO_SMOOTHING_V1 */
    if(volume.length!==GodotAudio.MAX_VOLUME_CHANNELS)throw new Error('Invalid sample channel volume');
    const ctx=GodotAudio.ctx;
    const channels=[['_l','CHANNEL_L'],['_r','CHANNEL_R'],['_sl','CHANNEL_SL'],['_sr','CHANNEL_SR'],['_c','CHANNEL_C'],['_lfe','CHANNEL_LFE']];
    if(!this._afterRainTargets)this._afterRainTargets=Object.create(null);
    const now=ctx.currentTime;
    for(const [nodeKey,channelKey] of channels){
      const gain=this[nodeKey].gain;
      const value=volume[GodotAudio.GodotChannel[channelKey]]??0;
      const target=Number.isFinite(value)?Math.max(0,value):0;
      const previous=this._afterRainTargets[nodeKey];
      if(previous===undefined||ctx.state!=='running'){
        gain.cancelScheduledValues(now);
        gain.setValueAtTime(target,now);
      }else if(Math.abs(previous-target)>0.000001){
        if(typeof gain.cancelAndHoldAtTime==='function')gain.cancelAndHoldAtTime(now);
        else {const current=gain.value;gain.cancelScheduledValues(now);gain.setValueAtTime(current,now);}
        gain.setTargetAtTime(target,now,0.025);
      }
      this._afterRainTargets[nodeKey]=target;
    }
  }`;
  return source.slice(0, start) + replacement + source.slice(end);
}
