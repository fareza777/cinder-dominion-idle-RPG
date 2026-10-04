import path from 'node:path';
import fs from 'node:fs/promises';
import {bundle} from '@remotion/bundler';
import {getCompositions,openBrowser,renderStill,renderMedia} from '@remotion/renderer';

const root=process.cwd();
const out=path.resolve(root,'../../build/store-kit-2026-10-04');
await fs.mkdir(out,{recursive:true});
const serveUrl=await bundle({entryPoint:path.join(root,'src/index.ts'),rspack:true,outDir:path.resolve(root,'../../build/store-remotion-bundle')});
const browser=await openBrowser('chrome');
try{
 const compositions=await getCompositions(serveUrl,{puppeteerInstance:browser});
 const mode=process.argv[2]??'stills';
 if(mode==='stills'){
  for(const id of ['FeatureGraphic','Screenshot01','Screenshot02','Screenshot03','Screenshot04','Screenshot05','Screenshot06','Screenshot07','Screenshot08']){
   const composition=compositions.find(c=>c.id===id);
   const file=id==='FeatureGraphic'?'feature-graphic-1024x500.png':`screenshot-${id.slice(-2)}.png`;
   await renderStill({composition,serveUrl,output:path.join(out,file),imageFormat:'png',puppeteerInstance:browser,inputProps:composition.props});
   console.log('EXPORTED',file);
  }
  const trailer=compositions.find(c=>c.id==='PlayStoreTrailer');
  for(const frame of [21,100,225,320,415,500,590,690,775,866]){
   await renderStill({composition:trailer,serveUrl,frame,output:path.resolve(root,`../../build/trailer-preview-${frame}.png`),imageFormat:'png',puppeteerInstance:browser});
  }
  const portrait=compositions.find(c=>c.id==='PortraitTrailer');
  for(const frame of [21,100,320,500,690,866]){
   await renderStill({composition:portrait,serveUrl,frame,output:path.resolve(root,`../../build/portrait-preview-${frame}.png`),imageFormat:'png',puppeteerInstance:browser});
  }
 }else if(mode==='audio'){
  const composition=compositions.find(c=>c.id==='PlayStoreTrailer');
  await renderMedia({composition,serveUrl,codec:'wav',audioCodec:'pcm-16',outputLocation:path.resolve(root,'../../build/trailer-score.wav'),puppeteerInstance:browser});
  console.log('EXPORTED full Remotion score');
 }else{
  for(const id of mode==='videos'?['PlayStoreTrailer','PortraitTrailer']:[mode]){
  const composition=compositions.find(c=>c.id===id);
  if(!composition)throw new Error('Unknown composition '+id);
  let last=-1;
  await renderMedia({composition,serveUrl,codec:'h264',crf:18,pixelFormat:'yuv420p',audioCodec:'aac',outputLocation:path.join(out,id==='PortraitTrailer'?'trailer-portrait-1080x1920.mp4':'trailer-landscape-1920x1080.mp4'),puppeteerInstance:browser,concurrency:3,onProgress:p=>{
   const percent=Math.floor(p.progress*10)*10;if(percent!==last){last=percent;console.log(id,percent+'%');}
  }});
  }
 }
}finally{await browser.close({silent:true});}
