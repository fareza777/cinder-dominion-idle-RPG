"""Read alpha only. Emit runtime bounds; original generated PNGs are untouched."""
from pathlib import Path
import json
from measure_battle_bounds import measure
root=Path(__file__).resolve().parents[1]
bounds=json.loads((root/'data/battle_frame_bounds.json').read_text(encoding='utf-8'))
actors=json.loads((root/'data/battle_actors.json').read_text(encoding='utf-8'))
for r in range(7):
 path=root/f'assets/art/realm-actors-{r}-0.53.png'
 if not path.exists():continue
 frames=measure(path,20)
 assert len(frames)==20
 for i,f in enumerate(frames):
  x,y,w,h=f['rect']
  assert 20<w<520 and 30<h<510,(r,i,f['rect'])
 bounds[str(10+r)]=frames
 for n in range(10):
  actors[f'realm_{r}_{n}']={'sheet':10+r,'tile':n*2,'path':f'res://assets/art/realm-actors-{r}-0.53.png','scale':[.66,.78,.92,1.04,.85,.90,.98,1.06,1.14,1.2][n]}
 print(r,'measured',len(frames),'poses; foreign regions',[(i,f['foreign_pixels']) for i,f in enumerate(frames) if f['foreign_pixels']>20])
(root/'data/battle_frame_bounds.json').write_text(json.dumps(bounds,indent=2)+'\n',encoding='utf-8')
(root/'data/battle_actors.json').write_text(json.dumps(actors,indent=2)+'\n',encoding='utf-8')
