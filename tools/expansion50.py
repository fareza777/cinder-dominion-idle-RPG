"""Additive expansion. Existing IDs and recipes are never rewritten."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(name):return json.loads((ROOT/'data'/name).read_text(encoding='utf-8'))
c=read('catalog.json');cards=read('cards.json');items=c['items'];acts=c['activities'];enemies=c['enemies']
if "march_0_0" in enemies:raise SystemExit("Expansion already present. Edit the reviewed catalog instead of regenerating it.")
regions=[
 ('rime','Rimeglass Reach','Frostbound caravan roads','chill',['Rime Beetle','Snowbound Prowler','Icebound Pilgrim','Glassback Crab','Hoarfrost Sentry','White Bell Ringer','Frozen Castellan','Rimeglass Colossus','The Winter Abbot']),
 ('briar','Briarheart Fen','Overgrown waterways','poison',['Mire Tick','Thornback Hound','Reed Stalker','Briarbound Knight','Fen Leech','Spore Carrier','Thorn Matron','Rootbound Warden','The Briar Regent']),
 ('cinder','Cinderfall Foundry','Abandoned furnace halls','burn',['Coal Mite','Cinder Carapace','Furnace Drudge','Slagbound Keeper','Ash Sifter','Crucible Walker','Kiln Overseer','Ironfire Sentinel','The Furnace Witness']),
 ('hush','The Hushed Coast','Saltbound watchtowers','weaken',['Salt Crawler','Tidebound Hound','Drowned Ferryman','Netbound Sentinel','Brine Hermit','Silent Harpooner','Blackwake Keeper','Anchorbound Giant','The Tidemarked King']),
 ('gloam','Gloamwood Crossing','Twilight forest shrines','bleed',['Gloam Moth','Barkhide Prowler','Shrouded Huntsman','Needleback Spider','Hollowwood Knight','Dusk Weaver','Veilbound Keeper','Blackbriar Herald','The Last Huntsman']),
 ('star','The Starless Bastion','The fortress beyond the rift','shock',['Starfall Scarab','Voidbound Hound','Eclipsed Sentry','Chainless Knight','Astral Husk','Nullfire Keeper','Starless Adjudicator','Crownless Titan','The Night Without End'])]
parts=[('sword','Blade','weapon'),('shield','Shield','shield'),('helm','Helm','head'),('chest','Cuirass','body'),('gloves','Gauntlets','hands'),('boots','Boots','feet'),('necklace','Pendant','necklace'),('belt','Belt','belt'),('ring','Ring','ring'),('signet','Signet','ring'),('axe','Axe','axe'),('pick','Pickaxe','pick'),('rod','Rod','rod'),('spear','Spear','weapon')]
def item(id,name,category,**kw):items[id]=dict(id=id,name=name,en=name,category=category,**({"sell":1}|kw))
def recipe(id,out,level,inputs,xp=350,seconds=12):acts[id]=dict(id=id,kind='craft',skill='smithing',output=out,level=level,inputs=inputs,xp=xp,duration=seconds,side='')
def enemy(id,name,n,r,unlock,boss=False,optional=False):
 effect=regions[r][3];power=[65,85,108,130,151,182][r]
 d=dict(id=id,name=name,en=name,march=r,march_tile=n,unlock=unlock,boss=boss,hp=int((1800+r*2200)*(1.7 if boss else 1)*(1+(n%9)*.065)),attack=int(power*(1.12 if boss else 1)),armor=18+r*7,interval=2800 if boss else 3000,xp=1800+r*1500+(n%9)*180,gold=11000+r*13000+(n%9)*2000,drop='trophy_'+id,qty=2 if boss else 1,fragments=6+r*2,status=effect,rare_material='keepsake_'+id,rare_chance=.0001,loot_metal=regions[r][0]+'_',special_name=['Rime Spear','Briar Grasp','Furnace Breath','Blackwake Toll','Severing Thread','Starfall'][r],special_attack=1.35,special_armor=.82,special_heal=.004 if r==1 else 0,pressure=2+r,resist=.05+r*.01,march_guardian=optional)
 enemies[id]=d
 item(d['drop'],name+' Remnant','material',expansion_icon=18+r,sell=30+r*15)
 item(d['rare_material'],['Winter','Briar','Ember','Tidal','Gloam','Astral'][r]+' Heart of '+name,'material',expansion_icon=24+r,sell=0)
 acts['hunt_'+id]=dict(id='hunt_'+id,kind='combat',skill='bladecraft',enemy=id,output=d['drop'],level=1,inputs={},xp=d['xp'],duration=0,side='')
 card='card_'+id;item(card,name+' Card','card',enemy_art=id,sell=50000)
 effects=[{'resist':effect,'defense':.012},{'proc':effect,'attack':.015},{'vs_'+('chill' if effect=='weaken' else effect):.035},{'healing':.035},{'boss':.035},{'material':.025},{'pierce':.035},{'boon':'barrier'},{'special':.04}]
 e=effects[n%9];slots=[['body','shield'],['weapon','hands'],['ring','necklace'],['belt','necklace'],['weapon','ring'],['feet','head'],['hands','weapon'],['shield','body'],['weapon','necklace']][n%9]
 descriptions=[f'Take 1.2% less direct damage. {effect.replace("_"," ").title()} lasts 25% less time; matching special strikes deal 25% less damage.',f'+1.5% attack damage. Every fourth hit applies {effect.title()}.',f'+3.5% damage against enemies affected by {("Chill" if effect=="weaken" else effect.title())}.','Meals restore 3.5% more HP.','Deal 3.5% more damage to bosses.','Gain 2.5% more ordinary hunt materials.','Ignore 3.5% of enemy armor.','Every fourth hit grants a small Barrier.','Every fourth attack deals 4% more damage.']
 cards[card]=dict(enemy=id,tile=0,rarity='Mythic' if optional else ('Legendary' if boss else 'Epic'),chance=.000025 if boss else .00008,detail=descriptions[n%9],role='Build choice',build_hint='Choose equipment that fits this card and complements your build.',slots=slots,**e)
new_regions=[];contracts=[];master=[];enemy_names=[]
for r,(key,name,desc,effect,names) in enumerate(regions):
 gate='crown_5' if r==0 else ('frontier_2_5' if r==5 else f'march_{r-1}_8')
 new_regions.append(dict(id=key,name=name,detail=desc,gate=gate,theme=effect,level=min(100,65+r*7),boss=f'march_{r}_8'))
 for j,name_e in enumerate(names):
  id=f'march_{r}_{j}';enemy(id,name_e,r*9+j,r,gate if j==0 else f'march_{r}_{j-1}',j in [4,8]);enemy_names.append(name_e)
 item(key+'_ingot',key.title()+' Alloy','material',expansion_icon=12+r,sell=150)
 recipe('craft_'+key+'_ingot',key+'_ingot',min(100,65+r*7),{'trophy_march_'+str(r)+'_0':2,'dawnsteel_ingot':1})
 for j,(suffix,label,slot) in enumerate(parts):
  id=key+'_'+suffix
  attack=(36+r*7) if slot=='weapon' else (2+r if slot in ['ring','necklace'] else 0)
  armor=(6+r*2)*({'body':3,'shield':2}.get(slot,1)) if slot not in ['weapon','axe','pick','rod'] else 0
  extra={'speed':.88-r*.02} if slot in ['axe','pick','rod'] else {}
  item(id,key.title()+' '+label,'equipment',slot=slot,attack=attack,armor=armor,expansion_icon=j%12,forge_metal=key,family=key,**extra)
  # Earlier monsters remain relevant through guaranteed materials, without rare mandatory gates.
  old=['raw_meat','copper_ore','coal','iron_ore','ash_log','oak_log'][r]
  recipe('craft_'+id,id,min(100,65+r*7),{key+'_ingot':3+(j%4),old:20+r*10,'trophy_march_'+str(r)+'_'+str(min(7,j%8)):5},500+r*100)
 for j in range(5):
  eid=f'march_{r}_{[1,3,4,6,8][j]}'
  contracts.append(dict(id='contract_'+eid,title=['Clear the Crossing','Secure the Supply Route','Silence the Watch','Recover the Lost Stores','Break the Siege'][j]+' · '+name,detail=f'Defeat {enemies[eid]["en"]} '+str([5,8,3,10,1][j])+' times.',source='kills',key=eid,target=[5,8,3,10,1][j],gold=(r+1)*100000,food=0,scrap=30,activity='hunt_'+eid))
guardians=['The Glass Leviathan','The Thornless Sovereign','The Unquenched Anvil','The Pale Undertow','The Keeper of No Names']
for j,name in enumerate(guardians):
 enemy('march_guard_'+str(j),name,54+j,j+1,f'march_{j+1}_8',True,True);enemy_names.append(name)
 enemies['march_guard_'+str(j)]['hp']*=2
 contracts.append(dict(id='contract_guard_'+str(j),title='An Unbroken Seal · '+name,detail='Defeat '+name+'.',source='kills',key='march_guard_'+str(j),target=1,gold=1000000*(j+1),food=0,scrap=80,activity='hunt_march_guard_'+str(j)))
enemy('march_wanderer','The Lanternless Wayfarer',59,0,'bellkeeper',False);enemy_names.append('The Lanternless Wayfarer')
# Fourteen optional effects add to ten existing masterworks.
master_names=['Winterwake','Briar Oath','Cinderwake','Blackwater Promise','Gloam Requiem','Starless Mercy','The Unbroken Watch','Saltbound Vow','Last Shelter','Ashen Benediction','Nightglass','The Hollow Thread','Dawnless Accord','The Quiet Crown']
for j,name in enumerate(master_names):
 r=j%6;slot=['weapon','body','hands','ring','feet','weapon','shield','necklace','belt','head','ring','body','shield','head'][j];id='master_'+str(j)
 effect=['chill','poison','burn','sustain','bleed','execution','counter'][j%7]
 item(id,name,'equipment',slot=slot,attack=58+r*6 if slot=='weapon' else (5 if slot in ['ring','necklace'] else 0),armor=0 if slot=='weapon' else (42 if slot=='body' else 23),expansion_icon=30+j,build_effect=effect,unique_effect={'chill':'Fourth hits apply Chill. Deal 8% more damage to chilled enemies.','poison':'Fourth hits apply Poison. Deal 8% more damage to poisoned enemies.','burn':'Fourth hits apply Burn. Deal 8% more damage to burning enemies.','sustain':'Meals restore 8% more HP; fourth hits grant Regeneration.','bleed':'Fourth hits apply Bleed. Deal 8% more damage to bleeding enemies.','execution':'Deal 15% more damage below 30% enemy HP; take 5% more damage.','counter':'Third enemy strikes deal 8% less damage; fourth attacks gain damage from armor.'}[effect])
 source='march_guard_'+str(j%5) if j>=6 else f'march_{r}_8'
 old=list(x['rare_material'] for x in enemies.values() if 'march' not in x and x.get('rare_material'))
 recipe('craft_'+id,id,90+min(10,j),{regions[r][0]+'_ingot':40,'keepsake_'+source:1,old[j%len(old)]:1,'masterwork_commission':2+j//4},2500,35)
 acts['craft_'+id]['blueprint']=source
 item('blueprint_'+id,name+' Blueprint','material',masterwork_tile=7,blueprint_for=id,sell=0)
 master.append(id)
for j in range(2):
 id='march_oath_'+str(j);item(id,['Wayfarer\'s Seal','Watchkeeper\'s Chain'][j],'equipment',slot=['ring','necklace'][j],attack=5,armor=8,expansion_icon=9+j)
 recipe('craft_'+id,id,75,{'trophy_march_wanderer':30,'dawnsteel_ingot':10},700)
(ROOT/'data/catalog.json').write_text(json.dumps(c,indent=2)+'\n',encoding='utf-8')
(ROOT/'data/cards.json').write_text(json.dumps(cards,indent=2)+'\n',encoding='utf-8')
(ROOT/'data/marches.json').write_text(json.dumps(dict(regions=new_regions,contracts=contracts,masterworks=master,enemy_names=enemy_names),indent=2)+'\n',encoding='utf-8')
print('Expansion:',len(items),'items',len(enemies),'enemies',len(cards),'cards',len([a for a in acts.values() if a['kind']=='craft']),'recipes')

