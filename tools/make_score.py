"""Original procedural score and interaction cues. No third-party samples."""
from pathlib import Path
import array, math, random, wave

OUT = Path(__file__).resolve().parents[1] / 'assets/audio'
RATE = 22050
OUT.mkdir(exist_ok=True)

def write(name, samples):
    with wave.open(str(OUT / (name + '.wav')), 'wb') as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(array.array('h', (int(max(-.95, min(.95, v))*32767) for v in samples)).tobytes())

def ambience(name, root, intervals, seed):
    rng = random.Random(seed)
    noise = 0.0
    seconds = 32
    melody = [0, 7, 3, 10, 7, 12, 5, 3]
    notes = [root*4*2**(n/12) for n in melody]
    result = []
    for i in range(RATE*seconds):
        t = i/RATE
        fade = min(1, t/2, (seconds-t)/2)
        noise = noise*.992 + rng.uniform(-1,1)*.008
        pad = 0
        for j, semitones in enumerate(intervals):
            freq = root*2**(semitones/12)
            pad += math.sin(math.tau*freq*t + .18*math.sin(math.tau*t/16+j))*(.037/(1+j*.35))
        age = t%4
        bell = notes[int(t//4)]
        chiming = (math.sin(math.tau*bell*age)+.23*math.sin(math.tau*bell*2.006*age))*.025*math.exp(-age*1.4)*min(1,age/.06)
        result.append((pad*(.8+.2*math.sin(math.tau*t/32)) + chiming + noise*.075)*fade)
    write(name, result)

def cue(name, length, freqs, noise_level=0.0, attack=.005, decay=7):
    rng = random.Random(704)
    result = []
    for i in range(int(RATE*length)):
        t = i/RATE
        envelope = min(1,t/attack)*math.exp(-t*decay)*min(1,(length-t)/.04)
        value = sum(math.sin(math.tau*f*t)*a for f,a in freqs)
        value += rng.uniform(-1,1)*noise_level*math.exp(-t*25)
        result.append(value*envelope)
    write(name,result)

for spec in [('hearth',55,[0,7,12,15],1),('wilds',55,[0,5,12,19],2),('sanctum',65.406,[0,7,12,14],3),('crown',41.203,[0,7,12,13],4)]:
    ambience(*spec)
cue('forge',.75,[(180,.14),(367,.08),(741,.03)],.13,decay=8)
cue('equip',.3,[(310,.07),(625,.03)],.03,decay=15)
cue('victory',1.3,[(220,.055),(277.18,.035),(329.63,.045),(440,.025)],attack=.03,decay=2.8)
cue('defeat',1.2,[(82.4,.075),(116.54,.035),(164.8,.02)],attack=.05,decay=3.3)
cue('reward',.7,[(440,.06),(659.25,.04),(880,.02)],attack=.012,decay=6)
print('Generated four 32-second ambient scores and five action cues.')
