import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { patchWebAudio } from './patch_web_audio.mjs';
const root=process.cwd();
const src=path.join(root,'builds/web'),dest=path.join(root,'dist');
// Apply to both the standard download and the bounded-file hosting package.
const engineScript=path.join(src,'index.js');
fs.writeFileSync(engineScript,patchWebAudio(fs.readFileSync(engineScript,'utf8')));
fs.mkdirSync(dest,{recursive:true});
fs.writeFileSync(path.join(dest,'.gdignore'),'');
for(const name of fs.readdirSync(dest))if(name.endsWith('.import'))fs.unlinkSync(path.join(dest,name));
for(const name of fs.readdirSync(src)){if(/\.(html|js|wasm|pck|png)$/.test(name))fs.copyFileSync(path.join(src,name),path.join(dest,name));}
const wasm=fs.readFileSync(path.join(dest,'index.wasm'));
const parts=[];
for(let offset=0;offset<wasm.length;offset+=20*1024*1024){const name=`engine-${parts.length}.bin`;fs.writeFileSync(path.join(dest,name),wasm.subarray(offset,offset+20*1024*1024));parts.push(name);}
let html=fs.readFileSync(path.join(dest,'index.html'),'utf8');
html=html.replace('<!-- WASM_PARTS -->',`<script>window.AFTER_RAIN_WASM_PARTS=${JSON.stringify(parts)};</script>`);
fs.writeFileSync(path.join(dest,'index.html'),html);
fs.unlinkSync(path.join(dest,'index.wasm'));
fs.writeFileSync(path.join(dest,'release.json'),JSON.stringify({title:'AFTER THE RAIN',version:'1.0.1',engine:'4.6.3.stable.official.7d41c59c4',audio:'sample-gain-smoothing-v1',wasm_sha256:crypto.createHash('sha256').update(wasm).digest('hex'),parts},null,2));
for(const file of ['GODOT_COPYRIGHT.txt','GODOT_LICENSE.txt','CREDITS.txt']){
 fs.copyFileSync(path.join(root,'web',file),path.join(dest,file));
 fs.copyFileSync(path.join(root,'web',file),path.join(src,file));
}
console.log(JSON.stringify({packaged:dest,wasmBytes:wasm.length,parts,files:fs.readdirSync(dest)}));
