"""Read sprite alpha; emit source rectangles, never modify image pixels."""
from pathlib import Path
import json
import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parents[1]

def measure(path, count, split=None):
    im = Image.open(path)
    alpha = np.array(list(im.getdata()), dtype=np.uint8).reshape(im.height, im.width, 4)[:, :, 3]
    labels, _ = ndimage.label(alpha > 12)
    # One raised club touches the boot above at the source row boundary.
    if split:
        x, y, seam = split
        label = labels[y, x]
        if not label:
            label = int(np.bincount(labels[:seam, x-20:x+20].ravel())[1:].argmax()) + 1
        yy=np.arange(im.height)[:,None];xx=np.arange(im.width)[None,:]
        lower=(labels==label)&((yy>=seam)|((yy>=251)&(xx<340)))
        labels[lower] = labels.max() + 1
    counts = np.bincount(labels.ravel()); counts[0] = 0
    objects = ndimage.find_objects(labels)
    ids = np.argsort(counts)[-count:].tolist()
    boxes = {}
    for label in ids:
        sy, sx = objects[label-1]
        boxes[label] = [sx.start, sy.start, sx.stop, sy.stop]
    ids.sort(key=lambda i: (boxes[i][1]+boxes[i][3])/2)
    ordered = []
    for r in range(count//4):
        ordered += sorted(ids[r*4:r*4+4], key=lambda i: (boxes[i][0]+boxes[i][2])/2)
    assignment = {i:i for i in ids}
    for label, slices in enumerate(objects, 1):
        if slices is None or label in assignment: continue
        sy, sx = slices
        cx, cy = (sx.start+sx.stop)/2, (sy.start+sy.stop)/2
        def distance(i):
            x0,y0,x1,y1=boxes[i]
            gap=max(x0-cx,0,cx-x1)**2+max(y0-cy,0,cy-y1)**2
            return gap + .015*((cx-(x0+x1)/2)**2+(cy-(y0+y1)/2)**2)
        owner = min(ids, key=distance)
        if counts[label]>=16 or distance(owner)<100: assignment[label]=owner
    lookup=np.zeros(len(counts),dtype=np.int32)
    for label,owner in assignment.items():lookup[label]=owner
    owned=lookup[labels]
    result=[]
    for owner in ordered:
        ys,xs=np.where(owned==owner)
        x0,y0,x1,y1=max(0,int(xs.min())-2),max(0,int(ys.min())-2),min(im.width,int(xs.max())+3),min(im.height,int(ys.max())+3)
        foreign=int(np.count_nonzero((owned[y0:y1,x0:x1]!=owner)&(owned[y0:y1,x0:x1]!=0)))
        # Clip neighboring figures at runtime with a UV mesh; PNGs stay intact.
        pieces=[]; active={}
        for y in range(y0,y1):
            allowed=(owned[y,x0:x1]==owner)|(owned[y,x0:x1]==0)
            edges=np.flatnonzero(np.diff(np.r_[False,allowed,False]))
            spans=[(int(edges[i])+x0,int(edges[i+1])+x0) for i in range(0,len(edges),2)]
            current={}
            for left,right in spans:
                key=(left,right)
                if key in active:
                    index=active[key];pieces[index][3]+=1
                else:
                    index=len(pieces);pieces.append([left,y,right-left,1])
                current[key]=index
            active=current
        result.append({'rect':[x0,y0,x1-x0,y1-y0], 'pieces':pieces, 'foreign_pixels':foreign})
    return result

if __name__=='__main__':
    atlas={}
    for sheet in range(10):
        frames=measure(ROOT/f'assets/art/enemy-actors-{sheet}-0.51.png',24,(400,150,259) if sheet==3 else None)
        atlas[str(sheet)]=frames
        print(sheet,'foreign',[(i,f['foreign_pixels']) for i,f in enumerate(frames) if f['foreign_pixels']>20])
    (ROOT/'data/battle_frame_bounds.json').write_text(json.dumps(atlas,indent=2)+'\n',encoding='utf-8')
    heroes={}
    for key,path,count in [('original','hero-combat-0.37.png',20),('march','march-combat-0.50.png',12)]:
        heroes[key]=measure(ROOT/'assets/art'/path,count)
    (ROOT/'data/hero_frame_bounds.json').write_text(json.dumps(heroes,indent=2)+'\n',encoding='utf-8')
