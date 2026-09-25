"""Reproducible first-region content; runtime reads the generated JSON only."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
data=root/'data'; data.mkdir(exist_ok=True)
items={}
def item(key,idname,en,category,**kw):
    items[key]=dict(id=key,name=idname,en=en,category=category,sell=1,**kw)
materials=[('ash_log','Kayu Abu','Ash log','wood'),('oak_log','Kayu Ek','Oak log','wood'),('copper_ore','Bijih Tembaga','Copper ore','ore'),('iron_ore','Bijih Besi','Iron ore','ore'),('coal','Batu Bara','Coal','ore'),('copper_ingot','Ingot Tembaga','Copper ingot','ingot'),('iron_ingot','Ingot Besi','Iron ingot','ingot'),('raw_minnow','Ikan Kecil','Raw minnow','fish'),('raw_perch','Ikan Perch','Raw perch','fish'),('raw_meat','Daging Mentah','Raw meat','meat'),('emberleaf','Daun Bara','Emberleaf','herb'),('grave_moss','Lumut Makam','Grave moss','herb'),('empty_vial','Botol Kaca','Empty vial','potion'),('scrap','Serpihan Logam','Metal scrap','ore')]
for key,n,en,icon in materials:item(key,n,en,'material',icon=icon)
for key,n,en,heal in [('cooked_minnow','Ikan Panggang','Grilled minnow',20),('cooked_perch','Perch Panggang','Grilled perch',35),('cooked_meat','Daging Panggang','Roasted meat',30)]:item(key,n,en,'food',heal=heal,icon='food')
for key,n,en,effect in [('healing_draught','Ramuan Pemulihan','Healing draught','heal'),('guard_draught','Ramuan Penjaga','Guard draught','armor'),('fury_draught','Ramuan Amarah','Fury draught','attack')]:item(key,n,en,'potion',effect=effect,icon='potion')
slots=[('sword','Pedang','Sword','weapon',4),('shield','Perisai','Shield','shield',2),('helm','Helm','Helm','head',1),('chest','Zirah','Cuirass','body',3),('gloves','Sarung Tangan','Gauntlets','hands',1),('boots','Sepatu','Boots','feet',1)]
for metal,local,mult in [('copper','Tembaga',1),('iron','Besi',2)]:
    for part,n,en,slot,value in slots:item(f'{metal}_{part}',f'{n} {local}',f'{metal.title()} {en}','equipment',slot=slot,attack=value*mult if slot=='weapon' else 0,armor=0 if slot=='weapon' else value*mult,icon=part)
for key,n,en,slot,attack,armor,speed in [('worn_sword','Pedang Usang','Worn sword','weapon',0,0,0),('worn_shield','Perisai Usang','Worn shield','shield',0,1,0),('wood_axe','Kapak Kayu','Wood axe','axe',0,0,0),('stone_pick','Beliung Batu','Stone pick','pick',0,0,0),('reed_rod','Pancing Buluh','Reed rod','rod',0,0,0),('ash_axe','Kapak Bara','Ash axe','axe',0,0,.1),('copper_pick','Beliung Tembaga','Copper pick','pick',0,0,.1),('iron_rod','Pancing Besi','Iron rod','rod',0,0,.1)]:item(key,n,en,'equipment',slot=slot,attack=attack,armor=armor,speed=speed,icon={'weapon':'sword','axe':'axe','pick':'pick','rod':'fish'}.get(slot,slot))
skills={k:dict(name=n,en=en,tag=tag) for k,n,en,tag in [('woodcutting','Penebangan','Woodcutting','axe'),('mining','Pertambangan','Mining','pick'),('fishing','Memancing','Fishing','fish'),('cooking','Memasak','Cooking','food'),('smithing','Penempaan','Smithing','anvil'),('alchemy','Alkimia','Alchemy','potion'),('bladecraft','Keahlian Pedang','Bladecraft','sword'),('might','Kekuatan','Might','shield'),('warding','Pertahanan','Warding','shield')]}
activities={}
for aid,skill,out,level,dur,xp,side in [('cut_ash','woodcutting','ash_log',1,3,5,'emberleaf'),('cut_oak','woodcutting','oak_log',5,4,10,'grave_moss'),('mine_copper','mining','copper_ore',1,3,5,''),('mine_coal','mining','coal',5,4,10,''),('mine_iron','mining','iron_ore',10,5,15,''),('fish_minnow','fishing','raw_minnow',1,3,5,''),('fish_perch','fishing','raw_perch',5,4,10,'')]:activities[aid]=dict(id=aid,kind='gather',skill=skill,output=out,level=level,duration=dur,xp=xp,inputs={},side=side)
recipes=[('copper_ingot','smithing',1,{'copper_ore':2},3,8),('iron_ingot','smithing',10,{'iron_ore':2,'coal':1},5,18),('cooked_minnow','cooking',1,{'raw_minnow':1},2,5),('cooked_perch','cooking',5,{'raw_perch':1},3,10),('cooked_meat','cooking',1,{'raw_meat':1},3,8),('healing_draught','alchemy',1,{'emberleaf':2,'empty_vial':1},4,10),('guard_draught','alchemy',5,{'grave_moss':2,'empty_vial':1},5,15),('fury_draught','alchemy',8,{'emberleaf':2,'grave_moss':1,'empty_vial':1},6,20)]
for metal,start,wood in [('copper',1,'ash_log'),('iron',10,'oak_log')]:
    for part,off,count,dur,xp in [('sword',0,2,5,15),('shield',1,2,5,15),('helm',2,2,5,15),('chest',4,4,8,25),('gloves',1,1,4,10),('boots',1,1,4,10)]:
        inputs={metal+'_ingot':count}
        if part in ['sword','shield']:inputs[wood]=1 if part=='sword' else 2
        recipes.append((metal+'_'+part,'smithing',start+off,inputs,dur+(2 if metal=='iron' else 0),xp+(15 if metal=='iron' else 0)))
for out,skill,lvl,inputs,dur,xp in recipes:activities['craft_'+out]=dict(id='craft_'+out,kind='craft',skill=skill,output=out,level=lvl,inputs=inputs,duration=dur,xp=xp,side='')
enemies={}
rows=[('ash_rat','Tikus Abu','Ash Rat',18,2,0,2500,3,6,'raw_meat',1,'','Hewan liar yang memakan sisa-sisa Cinderwatch.'),('hollow_hound','Anjing Hampa','Hollow Hound',35,4,0,2200,5,10,'raw_meat',1,'tutorial','Giginya masih tajam. Yang tersisa hanya rasa lapar.'),('grave_thrall','Budak Makam','Grave Thrall',50,5,1,2800,7,14,'grave_moss',1,'tutorial','Bangkit bersama bunyi lonceng dari kapel tua.'),('cinder_bandit','Bandit Bara','Cinder Bandit',65,6,2,2400,9,18,'copper_ore',2,'grave_thrall','Mereka merampas apa pun yang masih berharga.'),('chapel_guard','Penjaga Kapel','Chapel Guard',85,7,4,3000,12,24,'scrap',2,'cinder_bandit','Zirah kosong yang tak pernah melupakan tugasnya.'),('ember_wraith','Arwah Bara','Ember Wraith',70,8,1,2000,14,26,'emberleaf',2,'chapel_guard','Sesuatu bergerak di antara abu dan cahaya api.'),('bellkeeper','Sang Penjaga Lonceng','The Bellkeeper',240,12,5,3000,80,100,'iron_ingot',3,'ember_wraith','Setiap dentang ketiga membawa pukulan yang mengerikan.')]
english_lore=['Wild scavengers feed on what remains of Cinderwatch.','Its teeth are sharp. Hunger is all that remains.','The old chapel bell wakes those buried beneath it.','They take anything the ash has spared.','Empty armor, still bound to a forgotten duty.','A restless shape flickers between ash and fire.','Every third toll brings a devastating strike.']
for i,(key,n,en,hp,atk,armor,interval,gold,xp,drop,qty,unlock,lore) in enumerate(rows):
    enemies[key]=dict(id=key,name=n,en=en,hp=hp,attack=atk,armor=armor,interval=interval,gold=gold,xp=xp,drop=drop,qty=qty,unlock=unlock,portrait=i+1,lore=lore,lore_en=english_lore[i],boss=i==6)
    activities['hunt_'+key]=dict(id='hunt_'+key,kind='combat',enemy=key,skill='bladecraft',level=1,output=drop,inputs={},duration=2,xp=xp)
# Repeatable post-story encounters. Portraits deliberately reuse the original cast.
expeditions=[('wilds','Ashen Wilds','Thornbound Sentinel',3,100,9,3,'grave_moss','fang'),('marsh','Drowned Sanctum','Drowned Oracle',6,170,13,5,'emberleaf','heart'),('crown','Obsidian Crown','Crowned Bellkeeper',7,280,17,7,'iron_ingot','ward')]
for region_index,(region,region_name,title,portrait,hp,attack,armor,drop,relic) in enumerate(expeditions):
    for tier in range(1,6):
        key=f'{region}_{tier}'
        gate='beacon' if region_index==0 and tier==1 else (f'{expeditions[region_index-1][0]}_5' if tier==1 else f'{region}_{tier-1}')
        name=f'{title} · Tier {tier}'
        enemy=dict(id=key,name=name,en=name,hp=int(hp*(1+.4*(tier-1))),attack=int(attack*(1+.22*(tier-1))),armor=armor+tier-1,interval=2800,gold=25+region_index*20+tier*8,xp=40+region_index*25+tier*15,drop=drop,qty=2+tier,unlock=gate,portrait=portrait,lore=f'{region_name}: a stronger echo of the fallen.',lore_en=f'{region_name}: a stronger echo of the fallen. Every third strike is empowered. First victory opens the next tier.',boss=True,region=region,tier=tier,relic=relic,fragments=tier+1)
        enemies[key]=enemy
        activities['hunt_'+key]=dict(id='hunt_'+key,kind='combat',enemy=key,skill='bladecraft',level=1,output=drop,inputs={},duration=2,xp=enemy['xp'])

region_lore={
    'wilds':'Roots have taken hold inside the armor of a forgotten watchman. Beneath the dead canopy, he still guards a road that leads nowhere.',
    'marsh':'Pilgrims once crossed these bridges to hear the oracle speak. Now her voice rises from beneath the water, calling the faithful home.',
    'crown':'The bell in Cinderwatch has fallen silent. Beyond the volcanic ridge, another answers from a throne of black stone.'
}
for enemy in enemies.values():
    if 'region' in enemy: enemy['lore_en']=region_lore[enemy['region']]
    enemy['name']=enemy['en']
    enemy['lore']=enemy['lore_en']
for entry in list(items.values())+list(skills.values()): entry['name']=entry['en']

doc=dict(items=items,skills=skills,activities=activities,enemies=enemies,merchant={'empty_vial':2,'ash_axe':30,'copper_pick':40,'iron_rod':60},rarities=['Worn','Common','Fine','Rare','Epic','Legendary','Mythic','Relic'])
assert len(items)==40 and len(recipes)==20 and len(enemies)==22
(data/'catalog.json').write_text(json.dumps(doc,ensure_ascii=False,indent=2),encoding='utf-8')
print('Content: 40 items, 20 recipes, 9 trained skills, 7 story enemies + 15 expedition tiers.')
