import React, {useEffect, useState} from "react";
import {AbsoluteFill, CanvasImage, Composition, Still, Sequence, staticFile, useCurrentFrame, useVideoConfig, interpolate, Easing, delayRender, continueRender} from "remotion";
import {Audio, Video} from "@remotion/media";
import "./index.css";

const gold="#d8b578", ivory="#f4eee3", ink="#071017";
const clamp={extrapolateLeft:"clamp",extrapolateRight:"clamp"} as const;
type ShotProps={shot:number};
const shots=[
 {file:"01b-battle-focus.png",title:["ONE MORE","HUNT."],sub:"Fight. Loot. Forge. Go deeper.",tag:"DARK FANTASY IDLE RPG",crop:320},
 {file:"02-forge.png",title:["FORGE YOUR","NEXT VICTORY."],sub:"Upgrade across 21 equipment rarities.",tag:"THE RARITY FORGE",crop:210},
 {file:"03-cards.png",title:["EVERY ENEMY","HIDES A PRIZE."],sub:"190 monster cards. Unique equipment effects.",tag:"MONSTER CARDS",crop:215},
 {file:"04-skills.png",title:["MASTER","THE CRAFT."],sub:"Gather, craft and grow across 16 skills.",tag:"CONNECTED PROFESSIONS",crop:320},
 {file:"05-hero.png",title:["BUILD YOUR","OWN LEGEND."],sub:"Eight heroes. Gear, cards, talents and relics.",tag:"YOUR HERO. YOUR BUILD.",crop:310},
 {file:"06b-realms.png",title:["THE ROAD","GETS DARKER."],sub:"Explore 20 campaign locations.",tag:"A WORLD TO CONQUER",crop:320},
 {file:"07-journey.png",title:["GO AFK.","RETURN STRONGER."],sub:"Offline work. Dungeon journeys. Real progress.",tag:"PROGRESS WHILE AWAY",crop:210},
 {file:"08-relics.png",title:["THE END IS","ONLY DEEPER."],sub:"Reach level 130. Face optional guardians.",tag:"BUILT FOR THE LONG HUNT",crop:220},
];

const Fonts:React.FC=()=>{
 const [handle]=useState(()=>delayRender("Load local licensed fonts"));
 useEffect(()=>{
  Promise.all([document.fonts.load("600 90px CinderSerif"),document.fonts.load("500 36px CinderSans")]).then(()=>continueRender(handle));
 },[handle]);
 return null;
};

const Brand:React.FC<{large?:boolean}>=({large=false})=><div style={{color:ivory,fontFamily:"CinderSerif",textAlign:"center",lineHeight:.91}}>
 <div style={{fontSize:large?102:30,letterSpacing:large?5:3}}>CINDER</div>
 <div style={{fontSize:large?133:38,letterSpacing:large?2:2}}>DOMINION</div>
 <div style={{fontFamily:"CinderSans",fontSize:large?24:12,letterSpacing:large?9:5,color:gold,marginTop:large?22:10}}>IDLE RPG</div>
</div>;

const Sparks:React.FC=()=>{
 const f=useCurrentFrame();const {width,height}=useVideoConfig();
 return <AbsoluteFill style={{pointerEvents:"none"}}>{Array.from({length:22},(_,i)=><div key={i} style={{position:"absolute",left:(i*173+75)%width,top:height-((i*191+f*(.8+i%3*.25))%(height+100)),width:i%4===0?4:2,height:i%4===0?7:3,background:gold,opacity:.16+Math.sin(i+f/26)*.09,boxShadow:"0 0 9px #dd792888",rotate:"20deg"}} />)}</AbsoluteFill>;
};

const Backdrop:React.FC<{strong?:boolean}>=({strong=false})=>{
 const f=useCurrentFrame();const {width,height}=useVideoConfig();
 return <AbsoluteFill style={{background:ink,overflow:"hidden"}}>
  <CanvasImage name="Citadel key art" src={staticFile("art/citadel-original.png")} width={width} height={height} fit="cover" style={{opacity:strong?.92:.5,scale:interpolate(f,[0,900],[1.06,1.15],clamp)}} />
  <AbsoluteFill style={{background:strong?"linear-gradient(90deg,#07131de0 0%,#09192377 42%,transparent 80%)":"linear-gradient(180deg,#07131dcc 0%,#101a21dc 50%,#081019f5 100%)"}} />
  <Sparks />
 </AbsoluteFill>;
};

const GoldRule:React.FC=()=><div style={{display:"flex",alignItems:"center",gap:12,justifyContent:"center"}}><div style={{height:1,width:70,background:`linear-gradient(90deg,transparent,${gold})`}}/><div style={{width:5,height:5,background:gold,rotate:"45deg"}}/><div style={{height:1,width:70,background:`linear-gradient(90deg,${gold},transparent)`}}/></div>;

const StoreShot:React.FC<ShotProps>=({shot})=>{
 const data=shots[shot];
 return <AbsoluteFill style={{background:ink,color:ivory,fontFamily:"CinderSans",overflow:"hidden"}}>
  <Fonts/><Backdrop/>
  <div style={{position:"absolute",top:49,left:58,right:58,textAlign:"center"}}>
   <div style={{fontSize:19,letterSpacing:5,color:gold,fontWeight:650,marginBottom:13}}>{data.tag}</div>
   <div style={{fontFamily:"CinderSerif",fontSize:shot===6?86:94,fontWeight:600,lineHeight:.91,letterSpacing:-1}}>{data.title[0]}<br/>{data.title[1]}</div>
   <div style={{fontSize:31,lineHeight:1.32,color:"#e3dacb",marginTop:15}}>{data.sub}</div>
  </div>
  <div style={{position:"absolute",left:32,right:32,top:341,bottom:25,overflow:"hidden",border:"1px solid #b4945966",boxShadow:"0 18px 65px #0009"}}>
   <CanvasImage name="Actual game screenshot" src={staticFile(`game/${data.file}`)} width={1014} height={2028} style={{position:"absolute",top:-data.crop,left:0}} />
   <div style={{position:"absolute",left:0,right:0,bottom:0,height:24,background:"linear-gradient(transparent,#06101788)"}}/>
  </div>
 </AbsoluteFill>;
};

const FeatureGraphic:React.FC=()=> <AbsoluteFill style={{background:ink,overflow:"hidden"}}>
 <Fonts/><Backdrop strong/>
 <div style={{position:"absolute",left:68,top:115,width:590,color:ivory}}>
  <div style={{fontFamily:"CinderSerif",fontSize:57,fontWeight:600,lineHeight:.9,letterSpacing:2}}>CINDER<br/><span style={{fontSize:84,letterSpacing:0}}>DOMINION</span></div>
  <div style={{fontFamily:"CinderSans",fontSize:19,color:gold,letterSpacing:7,marginTop:19}}>IDLE RPG</div>
  <div style={{width:96,height:1,background:gold,marginTop:23}}/>
  <div style={{fontFamily:"CinderSans",fontSize:19,color:"#eee3d1",marginTop:17}}>Fight. Loot. Forge. Go deeper.</div>
 </div>
</AbsoluteFill>;

const Intro:React.FC=()=>{
 const f=useCurrentFrame();const {width,height}=useVideoConfig();const portrait=height>width;
 return <AbsoluteFill style={{background:ink,overflow:"hidden",color:ivory}}>
  <Backdrop strong/>
  <div style={{position:"absolute",left:portrait?70:120,right:portrait?70:120,top:portrait?height*.36:height*.3,opacity:interpolate(f,[0,7],[0,1],clamp),translate:interpolate(f,[0,28],["0px 22px","0px 0px"],{...clamp,easing:Easing.out(Easing.cubic)})}}>
   <div style={{fontFamily:"CinderSans",fontSize:portrait?24:25,letterSpacing:7,color:gold}}>YOUR NEXT VICTORY</div>
   <div style={{fontFamily:"CinderSerif",fontSize:portrait?113:155,fontWeight:600,lineHeight:.91,marginTop:19}}>STARTS WITH<br/>ONE MORE HUNT.</div>
  </div>
 </AbsoluteFill>;
};

const FeatureScene:React.FC<{shot:number;duration:number;live?:boolean}>=({shot,duration,live=false})=>{
 const f=useCurrentFrame();const {width,height}=useVideoConfig();const portrait=height>width;const d=shots[shot];
 const paneW=portrait?990:1100,paneH=portrait?1480:815;
 const mediaWidth=paneW;
 const top=portrait?363:132;
 const crop=portrait?shot===0?500:d.crop:shot===0?985:shot===4?365:shot===3||shot===5?347:240;
 return <AbsoluteFill style={{background:ink,color:ivory,overflow:"hidden",opacity:interpolate(f,[0,6,duration-6,duration],[0,1,1,0],clamp)}}>
  <Backdrop/>
  <div style={{position:"absolute",left:portrait?62:96,top:portrait?56:250,width:portrait?956:595,opacity:interpolate(f,[0,11],[0,1],clamp),translate:interpolate(f,[0,18],["0px 24px","0px 0px"],{...clamp,easing:Easing.out(Easing.cubic)})}}>
   <div style={{fontFamily:"CinderSans",fontSize:portrait?22:22,letterSpacing:4.5,color:gold,marginBottom:18}}>{d.tag}</div>
   <div style={{fontFamily:"CinderSerif",fontSize:portrait?98:shot===6?79:92,fontWeight:600,lineHeight:.91,letterSpacing:-1}}>{d.title[0]}<br/>{d.title[1]}</div>
   <div style={{fontFamily:"CinderSans",fontSize:portrait?32:32,lineHeight:1.4,color:"#e5dccc",marginTop:portrait?18:33}}>{d.sub}</div>
   {!portrait&&<div style={{marginTop:53,display:"inline-block"}}><GoldRule/></div>}
  </div>
  <div style={{position:"absolute",left:portrait?45:735,top,width:paneW,height:paneH,overflow:"hidden",border:"1px solid #cda55b77",boxShadow:"0 22px 100px #0009",scale:interpolate(f,[0,duration],[1,1.022],clamp)}}>
   {live ? <Video name="Actual hero battle" src={staticFile("game/battle.mp4")} trimBefore={45} muted style={{position:"absolute",width:mediaWidth,height:mediaWidth*2,top:-crop,left:0}} /> : <CanvasImage name={`Actual UI - ${d.tag}`} src={staticFile(`game/${d.file}`)} width={mediaWidth} height={mediaWidth*2} style={{position:"absolute",top:-crop,left:0}}/>}
   <div style={{position:"absolute",left:0,right:0,bottom:0,height:26,background:"linear-gradient(transparent,#08101755)"}}/>
  </div>
  {!portrait&&<div style={{position:"absolute",left:96,top:895,fontFamily:"CinderSans",fontSize:18,color:gold,letterSpacing:4}}>CINDER DOMINION <span style={{color:"#ddd0b8",marginLeft:18}}>IDLE RPG</span></div>}
 </AbsoluteFill>;
};

const End:React.FC=()=>{
 const f=useCurrentFrame();const {width,height}=useVideoConfig();const portrait=height>width;
 return <AbsoluteFill style={{background:ink,color:ivory,overflow:"hidden",opacity:interpolate(f,[0,9,65,75],[0,1,1,0],clamp)}}>
  <Backdrop strong/>
  <div style={{position:"absolute",left:portrait?140:130,top:portrait?280:145,width:portrait?800:615,height:portrait?800:615,overflow:"hidden",opacity:.8}}>
   <CanvasImage src={staticFile("art/crown-original.png")} width={portrait?800:615} height={portrait?800:615} style={{maskImage:"radial-gradient(ellipse at center,#000 38%,transparent 74%)"}} />
  </div>
  <div style={{position:"absolute",left:portrait?65:780,right:portrait?65:105,top:portrait?height*.59:height*.31,textAlign:"center"}}>
   <Brand large/><div style={{marginTop:38}}><GoldRule/></div>
   <div style={{fontFamily:"CinderSans",fontSize:portrait?32:30,color:"#eee0c8",marginTop:25}}>Your next hunt awaits.</div>
  </div>
 </AbsoluteFill>;
};

const Trailer:React.FC=()=>{
 const f=useCurrentFrame();
 return <AbsoluteFill style={{background:ink}}><Fonts/>
  <Sequence name="Hook - One more hunt" from={0} durationInFrames={45}><Intro/></Sequence>
  <Sequence name="Fight - Actual battle" from={45} durationInFrames={150}><FeatureScene shot={0} duration={150} live/></Sequence>
  <Sequence name="Forge - 21 rarities" from={195} durationInFrames={90}><FeatureScene shot={1} duration={90}/></Sequence>
  <Sequence name="Collect - Monster cards" from={285} durationInFrames={90}><FeatureScene shot={2} duration={90}/></Sequence>
  <Sequence name="Master - 16 skills" from={375} durationInFrames={90}><FeatureScene shot={3} duration={90}/></Sequence>
  <Sequence name="Build - Hero equipment" from={465} durationInFrames={90}><FeatureScene shot={4} duration={90}/></Sequence>
  <Sequence name="Explore - Campaign locations" from={555} durationInFrames={90}><FeatureScene shot={5} duration={90}/></Sequence>
  <Sequence name="Return - Offline journey" from={645} durationInFrames={90}><FeatureScene shot={6} duration={90}/></Sequence>
  <Sequence name="Grow - Relic progression" from={735} durationInFrames={90}><FeatureScene shot={7} duration={90}/></Sequence>
  <Sequence name="Brand - Your next hunt awaits" from={825} durationInFrames={75}><End/></Sequence>
  <Audio name="Original dark-fantasy game score" src={staticFile("audio/crown.ogg")} trimBefore={90} volume={interpolate(f,[0,12,780,899],[0,.65,.65,0],clamp)}/>
  <Sequence from={76} durationInFrames={30}><Audio name="Sword impact" src={staticFile("audio/strike.wav")} volume={.35}/></Sequence>
  <Sequence from={136} durationInFrames={30}><Audio name="Sword impact" src={staticFile("audio/strike.wav")} volume={.3}/></Sequence>
  <Sequence from={199} durationInFrames={30}><Audio name="Forge strike" src={staticFile("audio/forge.wav")} volume={.4}/></Sequence>
  <Sequence from={290} durationInFrames={90}><Audio name="Card reveal" src={staticFile("audio/reward.wav")} volume={.28}/></Sequence>
 </AbsoluteFill>;
};

export const RemotionRoot:React.FC=()=> <>
 <Composition id="PlayStoreTrailer" component={Trailer} durationInFrames={900} fps={30} width={1920} height={1080}/>
 <Composition id="PortraitTrailer" component={Trailer} durationInFrames={900} fps={30} width={1080} height={1920}/>
 <Still id="FeatureGraphic" component={FeatureGraphic} width={1024} height={500}/>
 <Still id="Screenshot01" component={StoreShot} width={1080} height={1920} defaultProps={{shot:0}}/>
 <Still id="Screenshot02" component={StoreShot} width={1080} height={1920} defaultProps={{shot:1}}/>
 <Still id="Screenshot03" component={StoreShot} width={1080} height={1920} defaultProps={{shot:2}}/>
 <Still id="Screenshot04" component={StoreShot} width={1080} height={1920} defaultProps={{shot:3}}/>
 <Still id="Screenshot05" component={StoreShot} width={1080} height={1920} defaultProps={{shot:4}}/>
 <Still id="Screenshot06" component={StoreShot} width={1080} height={1920} defaultProps={{shot:5}}/>
 <Still id="Screenshot07" component={StoreShot} width={1080} height={1920} defaultProps={{shot:6}}/>
 <Still id="Screenshot08" component={StoreShot} width={1080} height={1920} defaultProps={{shot:7}}/>
</>;
