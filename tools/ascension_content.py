"""Additive 0.25 content, called by build_content.py; keeps all old IDs intact."""
import json
from pathlib import Path
TIERS=[('steel','Steel',25,12,3,'Blackpine','River trout',50),('moonsteel','Moonsteel',45,20,4,'Silver birch','Moon carp',65),('dusksteel','Dusksteel',65,30,5,'Nightwood','Cave eel',80),('dawnsteel','Dawnsteel',85,42,6,'Sunwood','Dawn salmon',95)]
def extend(doc,root):
    items,acts,enemies=doc['items'],doc['activities'],doc['enemies']
    contracts=[]
    def item(id,name,category,**kw):
        items[id]=dict(id=id,name=name,en=name,category=category,sell=1,**kw)
    def activity(id,kind,skill,output,level,inputs,xp,duration=6):
        acts[id]=dict(id=id,kind=kind,skill=skill,output=output,level=level,inputs=inputs,xp=xp,duration=duration,side='')
    parts=[('sword','Sword','weapon',0,2),('shield','Shield','shield',2,2),('helm','Helm','head',5,2),('chest','Cuirass','body',15,4),('gloves','Gauntlets','hands',5,1),('boots','Boots','feet',10,1)]
    for n,(metal,name,level,attack,armor,wood,fish,heal) in enumerate(TIERS):
        ore=metal+'_ore'; ingot=metal+'_ingot'; log=metal+'_log'; raw=metal+'_fish'; food='cooked_'+metal+'_fish'
        item(ore,'Magnetite' if n==0 else name+' ore','material',art_tile=n*4+2)
        item(ingot,name+' ingot','material',art_tile=n*4+3)
        item(log,wood+' log','material',icon_alias='oak_log')
        item(raw,'Raw '+fish.lower(),'material',icon_alias='raw_perch')
        item(food,'Roasted '+fish.lower(),'food',heal=heal,icon_alias='cooked_perch')
        for aid,skill,out in [('mine_'+metal,'mining',ore),('cut_'+metal,'woodcutting',log),('fish_'+metal,'fishing',raw)]: activity(aid,'gather',skill,out,level,{},80+n*70,6+n)
        activity('craft_'+ingot,'craft','smithing',ingot,level,{ore:2,'coal':1},110+n*90)
        activity('craft_'+food,'craft','cooking',food,level+5,{raw:1,log:1},100+n*80,5)
        for part,label,slot,offset,amount in parts:
            key=metal+'_'+part
            item(key,name+' '+label,'equipment',slot=slot,attack=attack if slot=='weapon' else 0,armor=0 if slot=='weapon' else armor*{'shield':2,'head':1,'body':3,'hands':1,'feet':1}[slot],icon_alias='iron_'+part,**({'art_tile':n*4+(0 if part=='sword' else 1)} if part in ['sword','shield'] else {}))
            activity('craft_'+key,'craft','smithing',key,min(100,level+offset),{ingot:amount,log:1},250+n*200,8+n)
        for tool,slot in [('axe','axe'),('pick','pick'),('rod','rod')]:
            key=metal+'_'+tool
            item(key,name+' '+tool,'equipment',slot=slot,attack=0,armor=0,speed=.15+n*.05,icon_alias={'axe':'ash_axe','pick':'copper_pick','rod':'iron_rod'}[tool])
            activity('craft_'+key,'craft','smithing',key,level+10,{ingot:2,log:2},220+n*180,8)
        contracts.append(dict(id='forge_'+metal,title=name+' in Your Hands',detail='Forge your first '+name+' Sword.',source='gains',key=metal+'_sword',target=1,gold=150*(n+1),food=10,scrap=10*(n+1),activity='craft_'+metal+'_sword'))
        contracts.append(dict(id='stock_'+metal,title='A Stock of '+name,detail='Gather 50 '+items[ore]['en']+'.',source='gains',key=ore,target=50,gold=100*(n+1),food=10,scrap=5*(n+1),activity='mine_'+metal))
    names=[['The Briar Marksman','Mossback Colossus','The Emberwood Elder'],['The Chainbound Diver','The Lantern Widow','Leviathan of the Choir'],['The Ash Executioner','Bishop of the Last Bell','The Cinder Sovereign']]
    for region_i,region in enumerate(['wilds','marsh','crown']):
        for j in range(3):
            key='apex_'+region+'_'+str(j+1)
            tier=j+1
            metal=TIERS[min(3,j+1)][0]
            base=enemies['trial_'+region]
            enemy=dict(base,id=key,name=names[region_i][j],en=names[region_i][j],hp=[650,1500,3200][j]+region_i*[180,300,500][j],attack=[28,42,62][j]+region_i*7,armor=[10,17,24][j]+region_i*3,gold=180+tier*100+region_i*60,xp=300+tier*150,drop=metal+'_ore',qty=3+j,unlock='trial_'+region if j==0 else 'apex_'+region+'_'+str(j),tier=7+j,apex=True,art_tile=region_i*3+j,loot_metal=metal+'_',fragments=60+tier*30,trial=False,lore_en='Apex hunt. Win to open the next challenge; repeat for rare ore, gold and relic fragments.')
            specials=[('Barbed volley',1.1,.3,0),('Stonefall',1.7,1,0),('Root renewal',1.2,1,.025),('Chain drag',1.3,.5,0),('Widow\'s prayer',1,1,.035),('Choirbreaker',1.9,1,0),('Execution stroke',2,1,0),('Ash communion',1,.8,.02),('Sovereign\'s judgment',2.2,1,0)]
            special=specials[region_i*3+j]
            enemy.update(special_name=special[0],special_attack=special[1],special_armor=special[2],special_heal=special[3],place_tile=3 if region_i==2 and j==2 else region_i)
            enemy['lore']=enemy['lore_en']
            enemy.pop('trial_reward',None)
            enemies[key]=enemy
            acts['hunt_'+key]=dict(id='hunt_'+key,kind='combat',enemy=key,skill='bladecraft',level=1,output=enemy['drop'],inputs={},duration=2,xp=enemy['xp'])
            contracts.append(dict(id=key,title='Bring Down '+names[region_i][j],detail='Defeat '+names[region_i][j]+' once.',source='kills',key=key,target=1,gold=400*tier,food=20,scrap=20*tier,activity='hunt_'+key))
    (root/'game/ascension_contracts.gd').write_text('extends RefCounted\nconst ALL = '+json.dumps(contracts,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f"Ascension: {len(items)} items, {len(acts)} activities, {len(enemies)} encounters; {len(contracts)} new contracts.")
