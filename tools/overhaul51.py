"""One-time additive 0.51 content assembly; catalog is authoritative afterwards."""
from pathlib import Path
import json

root = Path(__file__).resolve().parents[1]
p = root / 'data/catalog.json'
c = json.loads(p.read_text(encoding='utf-8'))
if 'artisan_hammer_1' in c['items']:
    raise SystemExit('0.51 already assembled; edit authoritative catalog instead.')

def material(id, name, icon, **extra):
    c['items'][id] = dict(id=id, name=name, en=name, category='material', sell=0, icon='ore', artisan_icon=icon, **extra)

def recipe(id, level, inputs, skill='smithing', source=''):
    a = dict(id='craft_'+id, name=c['items'][id]['en'], en=c['items'][id]['en'], kind='craft', skill=skill,
             level=level, duration=12+level/2, inputs=inputs, output=id, xp=level*8+20, side='', hunt_materials=True)
    if source: a['artisan_source']=source
    c['activities'][a['id']]=a

tool_names={
 'hammer':['Ironwright Hammer','Runesmith Hammer','Sovereign Hammer','Blackstar Hammer'],
 'knife':['Camp Cook Knife','Provisioner Knife','Hearthkeeper Knife','Kingsfeast Knife'],
 'mortar':['Stone Alchemist Mortar','Silverleaf Mortar','Astral Mortar','Nightglass Mortar']}
metals=['iron_ingot','steel_ingot','dawnsteel_ingot','star_ingot']
for k,(kind,names) in enumerate(tool_names.items()):
    for tier,name in enumerate(names,1):
        id=f'artisan_{kind}_{tier}'
        material(id,name,k*4+tier-1,artisan_kind=kind,artisan_tier=tier)
        inputs={metals[tier-1]:[12,40,100,180][tier-1], 'scrap':[20,100,300,800][tier-1]}
        if tier>1: inputs[f'artisan_{kind}_{tier-1}']=1
        if tier==4: inputs.update({'keepsake_ash_rat':1,'depth_shard':100})
        # The existing Rat rare-material id is looked up, not assumed.
        if 'keepsake_ash_rat' in inputs:
            del inputs['keepsake_ash_rat']
            inputs[c['enemies']['ash_rat']['rare_material']]=1
        recipe(id,[10,35,75,100][tier-1],inputs)

gates=['bellkeeper','wilds_5','marsh_5','crown_5','secret_2','secret_6','frontier_0_5','frontier_1_5','march_0_8','march_2_8','march_4_8','march_5_8']
names=['Smuggler’s Catacombs','Thornroot Warrens','The Drowned Archive','The Bell Crypt','Forges Beneath','The Unlit Treasury','The Fallen Observatory','The Iron Ossuary','Rimeglass Vault','The Living Crucible','The Gloam Labyrinth','The Starless Reliquary']
materials=['Tarnished Clasp','Thornroot Amber','Drowned Vellum','Bellglass Shard','Forgeheart Slag','Unlit Obol','Eclipse Lens','Ossuary Rivet','Winterglass','Crucible Ember','Gloam Silk','Starless Prism']
gear_names=['Smuggler’s Edge','Rootwarden Bulwark','Archivist’s Seal','Bellwarden Pendant','Furnacebreaker','Unlit Aegis','Eclipse Signet','Ossuary Chain','Winterglass Sabre','Crucible Guard','Gloamweaver Ring','Starless Heart']
routes=[]
for i,gate in enumerate(gates):
    mid=f'journey_material_{i}'; material(mid,materials[i],12+i)
    slot=['weapon','shield','ring','necklace'][i%4]
    gid=f'journey_gear_{i}'
    c['items'][gid]=dict(id=gid,name=gear_names[i],en=gear_names[i],category='equipment',slot=slot,sell=300*(i+1)**3,icon='sword',artisan_icon=24+i,
        attack=(8+i*4 if slot=='weapon' else (1+i if slot in ['ring','necklace'] else 0)),armor=(6+i*3 if slot=='shield' else (1+i if slot in ['ring','necklace'] else 0)))
    recipe(gid,min(100,15+i*8),{mid:25+5*i,metals[min(3,i//3)]:8+i*3,'scrap':10+i*10},source=gate)
    routes.append(dict(id=f'journey_{i}',name=names[i],gate=gate,hours=[1,1,2,2,2,4,4,4,4,8,8,8][i],
        level=min(100,15+i*8),power=[18,35,50,70,95,130,170,210,270,350,430,510][i],
        fee=[100,500,2500,10000,25000,75000,150000,300000,600000,1000000,2000000,4000000][i],
        food=['cooked_minnow','cooked_perch','cooked_perch','cooked_steel_fish','cooked_moonsteel_fish','cooked_dusksteel_fish','cooked_dawnsteel_fish','cooked_dawnsteel_fish','cooked_dawnsteel_fish','cooked_dawnsteel_fish','cooked_dawnsteel_fish','cooked_dawnsteel_fish'][i],
        provisions=12+i*12,material=mid,gear=gid,art=i%6,
        stages=['Find the entrance','Cross the outer chambers','Secure the inner vault','Defeat the vault keeper']))

guardians=[f'secret_{i}' for i in range(7)]+[f'march_guard_{i}' for i in range(5)]
prefixes=['Drowned','Astral','Hollowforge','Silent','Thornbound','Glass','Unlit','Leviathan','Thornless','Anvil','Undertow','Nameless']
loot={}
for i,source in enumerate(guardians):
    loot[source]=[]
    for j,(part,slot,label) in enumerate([('edge','weapon','Edge'),('ward','shield','Ward'),('seal','ring','Seal'),('chain','necklace','Chain')]):
        id=f'trophygear_{i}_{part}';name=prefixes[i]+' '+label
        c['items'][id]=dict(id=id,name=name,en=name,category='equipment',slot=slot,sell=5000*(i+1),icon='sword',
            artisan_icon=36+(i%3)*4+j,loot_source=source,
            attack=(28+i*3 if slot=='weapon' else (7+i if slot in ['ring','necklace'] else 0)),
            armor=(28+i*3 if slot=='shield' else (7+i if slot in ['ring','necklace'] else 0)))
        loot[source].append(id)

actors={}
for i,(id,e) in enumerate(c['enemies'].items()):
    name=e['en'].lower();scale=1.0
    if any(x in name for x in ['rat','mite','tick','beetle','scarab']):scale=.52
    elif any(x in name for x in ['hound','prowler','crawler','crab','moth','leech','spider']):scale=.76
    elif any(x in name for x in ['colossus','titan','leviathan','giant','anvil','engine']):scale=1.28
    elif e.get('boss'):scale=1.12
    actors[id]={'sheet':i//12,'tile':(i%12)*2,'scale':scale}

for name,obj in [('catalog',c),('expeditions',{'routes':routes,'elite_loot':loot}),('battle_actors',actors)]:
    (root/f'data/{name}.json').write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(len(c['items']), 'items;',len(c['activities']), 'activities;', len(actors),'actors')
