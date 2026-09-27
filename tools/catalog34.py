import json
from pathlib import Path

p=Path('data/catalog.json')
c=json.loads(p.read_text(encoding='utf-8-sig'))
names=['The Drowned Castellan','The Astral Engine','The Hollow Forgemaster','The Silent Monarch','The Thorn Colossus','The Glass Sentinel','The Unlit Sovereign']
places=['The Sunken Vault','The Ashen Observatory','The Hollow Forge','The Silent Crown','The Rootless Garden','The Glass Sepulchre','The Unlit Throne']
loot=['Cinderfang','Ironwake Shield','Furnace Grips','Fieldkeeper Mantle','Stillwater Crown','Glassstep Boots','Nightfall Edge']
slots=['weapon','shield','hands','body','head','feet','weapon']
effects=['Every fourth attack adds 10 damage.','Third enemy attacks deal 15% less damage.','Deal 12% more damage against bosses.','Meals restore 8 extra HP.','Enemy healing is reduced by 25%.','Ignore 10% of enemy armor.','Every fourth attack deals 15% more damage.']
for i in range(7):
    eid=f'secret_{i}'
    for key,name in [(f'core_{i}',f'{names[i]} Core'),(f'blank_{i}',f'Unfinished {loot[i]}')]:
        c['items'][key]={'id':key,'name':name,'en':name,'category':'material','sell':1,'icon_alias':'scrap'}
    item=f'relic_{i}'
    c['items'][item]={'id':item,'name':loot[i],'en':loot[i],'category':'equipment','sell':1,'slot':slots[i],'attack':48+i*2 if slots[i]=='weapon' else 0,'armor':0 if slots[i]=='weapon' else 19+i,'icon_alias':{'weapon':'iron_sword','shield':'iron_shield','hands':'iron_gloves','body':'iron_chest','head':'iron_helm','feet':'iron_boots'}[slots[i]],'unique_effect':effects[i]}
    for output,inputs in [(f'blank_{i}',{'dawnsteel_ingot':8+i*2,'scrap':30+i*5,f'core_{i}':2}),(item,{f'blank_{i}':1,f'core_{i}':6+i,'dawnsteel_ingot':10+i*2})]:
        aid='craft_'+output
        c['activities'][aid]={'id':aid,'kind':'craft','skill':'smithing','output':output,'level':85+i*2,'inputs':inputs,'xp':1000,'duration':30,'side':'','blueprint':eid}
    c['enemies'][eid]={'id':eid,'name':names[i],'en':names[i],'hp':6000+i*1500,'attack':110+i*13,'armor':45+i*5,'interval':3000,'gold':650+i*100,'xp':850+i*100,'drop':f'core_{i}','qty':1,'unlock':'apex_crown_3' if i==0 else f'secret_{i-1}','portrait':7,'boss':True,'secret':True,'secret_tile':i,'location':places[i],'relic':['ward','heart','fang'][i%3],'fragments':120,'loot_metal':'dawnsteel_','lore':f'An optional superboss in {places[i]}.','lore_en':f'An optional superboss in {places[i]}.','pressure':3+i//2,'special_name':['Undertow','Astral Pulse','Furnace Break','Silent Decree','Root Crush','Glassfall','Last Eclipse'][i],'special_attack':[1.5,1.45,1.7,1.55,1.5,1.6,1.65][i],'special_armor':[.8,.7,.85,.75,.65,.7,.8][i],'special_heal':.003 if i in [0,3,4] else 0,'resist':.06+i*.025}
    aid='hunt_'+eid
    c['activities'][aid]={'id':aid,'kind':'combat','skill':'bladecraft','enemy':eid,'output':f'core_{i}','level':1,'inputs':{},'xp':0,'duration':3,'side':''}
for key,name in [('dread_token','Dread Seal'),('depth_shard','Hollow Shard')]:
    c['items'][key]={'id':key,'name':name,'en':name,'category':'material','sell':1,'icon_alias':'scrap'}
for i,key in enumerate(['ember','fracture','echo','shelter']):
    item='socket_'+key
    c['items'][item]={'id':item,'name':key.title()+' Socket Relic','en':key.title()+' Socket Relic','category':'material','sell':1,'icon_alias':'fury_draught'}
    aid='craft_'+item
    c['activities'][aid]={'id':aid,'kind':'craft','skill':'alchemy','output':item,'level':25+i*15,'inputs':{'scrap':25+i*10,'goldleaf':5} if 'goldleaf' in c['items'] else {'scrap':25+i*10,'copper_ingot':10+i*5},'xp':150,'duration':20,'side':''}
e=dict(c['enemies']['secret_0'])
e.update(id='hollow_depth',name='Hollow Sentinel',en='Hollow Sentinel',hp=6000,attack=125,armor=55,pressure=4,drop='depth_shard',secret=False,depth=True,secret_tile=7,location='The Hollow Depths',unlock='secret_2',resist=.1,special_heal=0,special_name='Depth Crush')
c['enemies']['hollow_depth']=e
a=dict(c['activities']['hunt_secret_0']); a.update(id='hunt_hollow_depth',enemy='hollow_depth',output='depth_shard');c['activities'][a['id']]=a
p.write_text(json.dumps(c,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
