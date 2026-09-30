"""Deterministic authored expansion. Existing keys are never replaced."""
import json, copy
from pathlib import Path
root=Path(__file__).resolve().parents[1]
def read(name): return json.loads((root/'data'/name).read_text(encoding='utf-8'))
def write(name,data): (root/'data'/name).write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
c=read('catalog.json'); cards=read('cards.json'); actors=read('battle_actors.json')
assert 'herbalism' not in c['skills'], 'Expansion already applied'
c['rarities'] += ['Exalted','Sovereign','Fabled','Ancient','Astral','Empyrean','Celestial','Seraphic','Primordial','Transcendent','Immortal','Eternal','Worldforged']
professions=[('herbalism','Herbalism','herb'),('hunting','Hunting','hide'),('thieving','Thieving','cache'),('crafting','Crafting','binding'),('arcane_arts','Arcane Arts','essence'),('divinity','Divinity','vow'),('runecarving','Runecarving','seal')]
prefix=['Ashen','Silver','Gloaming','Astral','Sovereign']
for skill,name,product in professions:
 c['skills'][skill]={'name':name,'en':name,'tag':product}
 for t,level in enumerate([1,20,40,65,90]):
  id=f'{product}_{t}'; label=f'{prefix[t]} '+{'herb':'Sage','hide':'Hide','cache':'Cache Salvage','binding':'Binding','essence':'Essence','vow':'Offering','seal':'Forge Seal'}[product]
  c['items'][id]={'id':id,'name':label,'en':label,'category':'material','sell':2*(t+1)**3,'artisan_icon':12+t if product in ['herb','hide','cache'] else 18+t}
  inputs={}
  if product=='binding': inputs={f'hide_{t}':3,f'cache_{t}':2}
  if product=='essence': inputs={f'herb_{t}':3,'grave_moss':t+1}
  if product=='vow': inputs={f'essence_{t}':2,'scrap':5*(t+1)}
  if product=='seal': inputs={f'binding_{t}':2,f'vow_{t}':2,f'essence_{t}':2}
  aid=f'work_{id}'
  c['activities'][aid]={'id':aid,'kind':'craft' if inputs else 'gather','skill':skill,'output':id,'level':level,'duration':8+t*6,'xp':10+40*t*t,'inputs':inputs,'side':''}
realms=['Drowned Cathedral','Glassfire Caldera','Winter Observatory','Silverroot Abyss','Broken Constellation','Pale Dominion','The Last Firmament']
titles=['Drowned','Glassfire','Winterbound','Silverroot','Starbroken','Pale','Firmament']
types=['Scavenger','Stalker','Revenant','Warden','Ravager','Acolyte','Knight','Harbinger','Sentinel','Sovereign']
world=[]
for r,name in enumerate(realms):
 gate='march_5_8' if r==0 else f'realm_{r-1}_9'
 world.append({'id':f'realm_{r}','name':name,'gate':gate,'art':r%9,'seal':min(4,r//2),'recommended_quality':6+r*2,'story':['The tide has buried the old bells. Recover their silver from the drowned guardians.','The caldera still feeds an abandoned forge. Its keepers will not yield the crucible.','At the summit, the observatory counts stars that no longer exist.','Roots have swallowed the old road. Follow their silver veins beneath the earth.','Fragments of a fallen sky turn above an empty sanctuary.','Beyond the pale gates, the last court still guards its oath.','There are no roads beyond this citadel. Break its final seal.'][r]})
 for n in range(10):
  id=f'realm_{r}_{n}'; source=f'march_{r%6}_{min(n,8)}'; e=copy.deepcopy(c['enemies'][source])
  for key in ['march','march_guardian','rare_material','rare_chance','loot_metal']: e.pop(key,None)
  e.update(id=id,name=f'{titles[r]} {types[n]}',en=f'{titles[r]} {types[n]}',realm=r,unlock=gate if n==0 else f'realm_{r}_{n-1}',boss=n==9,hp=int((10000+2400*n)*1.4**r),attack=int((195+9*n)*1.30**r),armor=int((50+n*4)*1.2**r),xp=int((18000+2500*n)*1.65**r),gold=int((85000+8000*n)*1.40**r),drop=f'trophy_{id}',qty=2 if n==9 else 1,loot_metal="star_",pressure=8+int(r*.65),special_name=['Undertow','Cinderfall','Whiteout','Rootfall','Starfall','Last Oath','Skybreak'][r],special_attack=1.45+r*.04,special_armor=.85,special_heal=0)
  c['enemies'][id]=e;actors[id]=copy.deepcopy(actors[source])
  c['items'][e['drop']]={'id':e['drop'],'name':f'{e["en"]} Remnant','en':f'{e["en"]} Remnant','category':'material','sell':1000*(r+1),'artisan_icon':12+r}
  card=f'card_{id}';c['items'][card]={'id':card,'name':e['en']+' Card','en':e['en']+' Card','category':'card','sell':100000*(r+1),'enemy_art':id}
  spec=copy.deepcopy(cards[f'card_{source}']);spec['enemy']=id;cards[card]=spec
  aid='hunt_'+id;c['activities'][aid]={'id':aid,'kind':'combat','skill':'bladecraft','enemy':id,'output':e['drop'],'level':1,'inputs':{},'xp':e['xp'],'duration':0,'side':''}
 # Entire gear set requires region trophies rather than replacing old cards/uniques.
 for n,slot in enumerate(['sword','shield','head','body','hands','feet','necklace','belt','ring']):
  source='star_'+slot
  if source not in c['items']: source=next(k for k,v in c['items'].items() if k.startswith('star_') and v.get('slot')==slot)
  id=f'firmament{r}_{slot}';item=copy.deepcopy(c['items'][source]);item.update(id=id,name=f'{titles[r]} {slot.title()}',en=f'{titles[r]} {slot.title()}')
  item.pop('family',None);item.pop('forge_metal',None)
  for stat in ['attack','armor']:item[stat]=int(item.get(stat,0)*(1.06+.08*r))
  c['items'][id]=item
  aid='craft_'+id;c['activities'][aid]={'id':aid,'kind':'craft','skill':'smithing','output':id,'level':100,'duration':45+r*10,'xp':1800+r*300,'inputs':{f'trophy_realm_{r}_{n}':30+r*10,f'trophy_realm_{r}_9':5+r,'star_ingot':10+r*5,f'binding_{min(4,r//2)}':10},'side':'','artisan_source':f'realm_{r}_9'}
for a in c['activities'].values():
 if a['kind']=='craft' and (a['skill'] in ['crafting','arcane_arts','divinity','runecarving'] or a['output'].startswith('firmament')):a['hunt_materials']=True
write('catalog.json',c);write('cards.json',cards);write('battle_actors.json',actors);write('realms.json',world)
print('items',len(c['items']),'enemies',len(c['enemies']),'skills',len(c['skills']),'rarities',len(c['rarities']))
