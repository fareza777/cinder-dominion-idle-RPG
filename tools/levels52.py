"""User-approved cap extension with actual 101-130 supply chains."""
from pathlib import Path
import json
p=Path(__file__).resolve().parents[1]/'data/catalog.json';c=json.loads(p.read_text(encoding='utf-8'))
assert 'herb_5' not in c['items']
def item(id,name,icon,category='material',**extra):
 c['items'][id]={'id':id,'name':name,'en':name,'category':category,'sell':100,'artisan_icon':icon,**extra}
def activity(id,skill,output,level,inputs,xp=4000):
 c['activities'][id]={'id':id,'kind':'craft' if inputs else 'gather','skill':skill,'output':output,'level':level,'inputs':inputs,'duration':40 if inputs else 22,'xp':xp,'side':'','hunt_materials':bool(inputs)}
for t,level,title in [(5,110,'Empyrean'),(6,125,'Eternal')]:
 for skill,product,label in [('herbalism','herb','Sage'),('hunting','hide','Hide'),('thieving','cache','Cache Salvage'),('crafting','binding','Binding'),('arcane_arts','essence','Essence'),('divinity','vow','Offering'),('runecarving','seal','Forge Seal')]:
  id=f'{product}_{t}';item(id,title+' '+label,18+t)
  inputs={}
  if product=='binding':inputs={f'hide_{t}':3,f'cache_{t}':2,f'log_{t}':2}
  if product=='essence':inputs={f'herb_{t}':3,f'flux_{t}':1}
  if product=='vow':inputs={f'essence_{t}':2,'scrap':5*(t+1)}
  if product=='seal':inputs={f'binding_{t}':2,f'vow_{t}':2,f'essence_{t}':2,f'ingot_{t}':2}
  activity('work_'+id,skill,id,level,inputs,4000 if t==5 else 9000)
 for skill,product,label,icon in [('woodcutting','log','Heartwood',12),('mining','ore','Ore',13),('fishing','fish','Deepfish',14)]:
  id=f'{product}_{t}';item(id,title+' '+label,icon);activity('work_'+id,skill,id,level,{},3500 if t==5 else 8000)
 for skill,product,label,icon,inputs in [('smithing','ingot','Ingot',15,{f'ore_{t}':3,'coal':10}),('alchemy','flux','Flux',16,{f'herb_{t}':2,'grave_moss':5}),('cooking','meal','Feast',17,{f'fish_{t}':2})]:
  id=f'{product}_{t}';item(id,title+' '+label,icon,'food' if product=='meal' else 'material',**({'heal':100} if product=='meal' else {}));activity('work_'+id,skill,id,level,inputs,4000 if t==5 else 9000)
for a in c['activities'].values():
 if a['output'].startswith('firmament'):
  r=int(a['output'][9]);a['level']=100+r*5
  if r>=3:a['inputs'][f'ingot_{5 if r<5 else 6}']=5+r
p.write_text(json.dumps(c,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('items',len(c['items']),'activities',len(c['activities']))
