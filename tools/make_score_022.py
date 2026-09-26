"""Original stereo dark-fantasy arrangements and Foley-like synthesized cues.
No external recordings, samples or services. Deterministic, reproducible assets.
"""
from pathlib import Path
import wave, json
import numpy as np
OUT=Path(__file__).resolve().parents[1]/'assets/audio'
RATE=32000
rng=np.random.default_rng(22026)
metrics={}
def write(name,a,peak=.48):
    a=np.asarray(a)
    if a.ndim==1: a=np.column_stack((a,a))
    a=a/max(float(np.max(np.abs(a))),.001)*peak
    with wave.open(str(OUT/(name+'.wav')),'wb') as f:
        f.setnchannels(2); f.setsampwidth(2); f.setframerate(RATE)
        f.writeframes((a*32767).astype('<i2').tobytes())
    metrics[name]={'seconds':len(a)/RATE,'peak_dbfs':round(20*np.log10(np.max(np.abs(a))),2),'rms_dbfs':round(20*np.log10(np.sqrt(np.mean(a*a))),2),'seam_delta':round(float(np.max(np.abs(a[0]-a[-1]))),6)}
def note(midi,duration,voice='bell'):
    t=np.arange(int(RATE*duration))/RATE
    hz=440*2**((midi-69)/12)
    if voice=='bow':
        a=sum(np.sin(2*np.pi*hz*h*t+.012*h*np.sin(2*np.pi*4.7*t))/h**1.7 for h in range(1,7))
        env=np.minimum(t/1.5,1)*np.minimum((duration-t)/1.5,1)
    elif voice=='pluck':
        a=np.sin(2*np.pi*hz*t)+.25*np.sin(2*np.pi*hz*2*t)+.1*np.sin(2*np.pi*hz*3*t)
        env=(1-np.exp(-t*180))*np.exp(-t*2.8)
    else:
        a=np.sin(2*np.pi*hz*t)+.28*np.sin(2*np.pi*hz*2.006*t)+.12*np.sin(2*np.pi*hz*3.98*t)
        env=(1-np.exp(-t*70))*np.exp(-t*1.3)
    return a*env*np.minimum((duration-t)/.04,1)
def add(track,a,start,volume,pan=0):
    a=np.column_stack((a*np.sqrt((1-pan)/2),a*np.sqrt((1+pan)/2)))*volume
    offset=int(start*RATE)%len(track)
    count=min(len(a),len(track)-offset)
    track[offset:offset+count]+=a[:count]
    if count<len(a): track[:len(a)-count]+=a[count:]
def drum(duration=.8):
    t=np.arange(int(RATE*duration))/RATE
    return np.sin(2*np.pi*(46*t+2.8*(1-np.exp(-t*24))))*np.exp(-t*6)*(1-np.exp(-t*160))
for index,name in enumerate(['hearth','wilds','sanctum','crown']):
    score=np.zeros((RATE*64,2))
    shift=[0,-2,3,-5][index]
    chords=[(45,52,60),(41,48,57),(38,45,53),(40,47,55)]*2
    for bar,chord in enumerate(chords):
        for j,midi in enumerate(chord): add(score,note(midi+shift,10,'bow'),bar*8,.052,[-.45,0,.45][j])
        add(score,note(chord[0]+12+shift,7,'bell'),bar*8+.5,.025,-.3)
        melody=[12,19,15,22,19,12,10,7]
        for beat in range(4):
            add(score,note(chord[0]+melody[(bar+beat)%8]+12+shift,3,'pluck'),bar*8+beat*2+1,.026 if index==0 else .018,.5 if beat%2 else -.5)
        if index>0:
            for beat in range(8):
                if index==2 and beat%2: continue
                add(score,drum(),bar*8+beat,.036 if beat%4==0 else .015,0)
                if index==3 and beat%2==1: add(score,note(52,1,'pluck'),bar*8+beat+.5,.012,.4)
    # Circular stereo reflections preserve the musical loop boundary.
    dry=score.copy()
    for delay,gain in [(.113,.15),(.237,.13),(.419,.10),(.683,.07),(.971,.04)]:
        score+=np.roll(dry[:,::-1],int(delay*RATE),axis=0)*gain
    write(name,score,.32 if index==0 else .38)
for name,midi in [('guide',69),('reward',76),('victory',64)]:
    a=np.zeros((RATE*3,2))
    for j,interval in enumerate([0,7,12]): add(a,note(midi+interval,2.2),j*.16,.13,[-.3,0,.3][j])
    write(name,a,.34)
for name,duration in [('action',.15),('equip',.48),('forge',1.0),('strike',.38),('hurt',.45),('defeat',2.2)]:
    t=np.arange(int(RATE*duration))/RATE
    noise=rng.normal(0,1,len(t))
    soft=np.convolve(noise,np.ones(9)/9,mode='same')
    if name=='action': a=(np.sin(2*np.pi*390*t)+soft*.25)*np.exp(-t*45)
    elif name=='equip': a=(np.sin(2*np.pi*240*t)*.4+np.sin(2*np.pi*489*t)*.2+soft*.3)*np.exp(-t*13)
    elif name=='forge': a=(np.sin(2*np.pi*183*t)*.5+np.sin(2*np.pi*413*t)*.25+np.sin(2*np.pi*827*t)*.12+soft*np.exp(-t*20)) *np.exp(-t*6)
    elif name=='strike': a=soft*np.exp(-((t-.05)/.032)**2)+np.sin(2*np.pi*145*t)*np.exp(-t*18)*.55
    elif name=='hurt': a=(soft*.3+np.sin(2*np.pi*(77*t+1.1*(1-np.exp(-t*18)))))*np.exp(-t*12)
    else: a=(np.sin(2*np.pi*82.4*t)+.4*np.sin(2*np.pi*98*t))*np.exp(-t*2)
    a*=np.minimum(t/.004,1)*np.minimum((duration-t)/.04,1)
    write(name,a,.32 if name not in ['strike','hurt'] else .22)
Path('build/audio-0.22-metrics.json').write_text(json.dumps(metrics,indent=2))
print('Four original 64-second stereo scores and nine cues generated; peak/RMS report saved.')
