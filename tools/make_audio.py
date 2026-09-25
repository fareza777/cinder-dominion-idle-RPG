"""Original subtle two-layer ambient bed. No samples or third-party assets."""
import math,struct,wave
from pathlib import Path
out=Path(__file__).resolve().parents[1]/'assets/audio'
out.mkdir(parents=True,exist_ok=True)
rate=22050; seconds=16
with wave.open(str(out/'refuge.wav'),'wb') as f:
    f.setnchannels(1); f.setsampwidth(2); f.setframerate(rate)
    samples=[]
    for i in range(rate*seconds):
        t=i/rate
        envelope=min(1,t/2,(seconds-t)/2)
        value=(math.sin(2*math.pi*55*t)*.25+math.sin(2*math.pi*82.5*t)*.13+math.sin(2*math.pi*110*t)*.05)*(0.8+.2*math.sin(2*math.pi*t/8))
        value+=math.sin(2*math.pi*220*t)*.025*math.sin(math.pi*t/seconds)**2
        samples.append(struct.pack('<h',int(value*envelope*11000)))
    f.writeframes(b''.join(samples))
print('Original ambient audio generated.')
with wave.open(str(out/'action.wav'),'wb') as f:
    f.setnchannels(1); f.setsampwidth(2); f.setframerate(rate)
    samples=[]
    for i in range(int(rate*.16)):
        t=i/rate
        value=(math.sin(2*math.pi*660*t)+.3*math.sin(2*math.pi*990*t))*math.exp(-t*35)*min(1,t/.004)
        samples.append(struct.pack('<h',int(value*4500)))
    f.writeframes(b''.join(samples))
