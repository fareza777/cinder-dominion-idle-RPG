class_name RealmMarches
extends RefCounted
static var catalog = {}
const ATTUNEMENTS = {
 "bleed":{"name":"Serrated","effect":"bleed","detail":"Fourth hits apply Bleed; +6% damage against bleeding enemies."},
 "burn":{"name":"Emberbound","effect":"burn","detail":"Fourth hits apply Burn; +6% damage against burning enemies."},
 "chill":{"name":"Rimebound","effect":"chill","detail":"Fourth hits apply Chill; +6% damage against chilled enemies."},
 "poison":{"name":"Venomwoven","effect":"poison","detail":"Fourth hits apply Poison; +6% damage against poisoned enemies."},
 "counter":{"name":"Resolute","effect":"","detail":"Third enemy strikes deal 6% less damage; fourth attacks gain 8% of armor as damage."},
 "execution":{"name":"Merciless","effect":"","detail":"Deal 12% more damage below 30% enemy HP; take 5% more direct damage."}}
static func data() -> Dictionary:
 if catalog.is_empty(): catalog=JSON.parse_string(FileAccess.get_file_as_string("res://data/marches.json"))
 return catalog
static func available(m,id: String) -> String:
 var e=m.data.enemies[id]
 if int(m.s.kills.get(e.unlock,0))<1: return "Defeat "+m.local_name(m.data.enemies[e.unlock])+" to open this route."
 if e.march==5 and int(m.s.kills.get("march_4_8",0))<1: return "Clear Gloamwood Crossing before entering the Starless Bastion."
 return ""
static func victory(m,e):
 if not RealmBlueprints.candidates(m,e.id).is_empty():m.gain("research_"+e.id,1)
static func effects(m) -> Array:
 var result=[]
 for uid in m.s.equipped.values():
  var g=m.gear(str(uid))
  if g.is_empty():continue
  var effect=str(m.data.items[g.id].get("build_effect",""))
  if effect!="" and effect not in result:result.append(effect)
  var attune=str(m.s.get("gear_attunements",{}).get(uid,""))
  if attune!="" and attune not in result:result.append(attune)
 var sets=RealmGearSets.counts(m)
 for family in ["rime","briar","cinder","hush","gloam","star"]:
  if sets.get(family,0)>=2:
   var effect={"rime":"chill","briar":"poison","cinder":"burn","hush":"sustain","gloam":"bleed","star":"execution"}[family]
   if effect not in result:result.append(effect)
 return result
static func outgoing(m,e,damage: int,special: bool) -> int:
 var active=effects(m)
 var multiplier=1.0
 for effect in ["bleed","burn","chill","poison"]:
  if effect in active and RealmAfflictions.has(m,"enemy",effect):multiplier+=.06
 if "execution" in active and not m.s.fight.is_empty() and m.s.fight.hp<e.hp*.3:multiplier+=.12
 if "counter" in active and special:damage+=int(m.stats().armor*.08)
 return maxi(1,int(damage*minf(1.24,multiplier)))
static func incoming(m,damage: int,third: bool) -> int:
 var active=effects(m)
 if "counter" in active and third:damage=ceili(damage*.94)
 if "execution" in active:damage=ceili(damage*1.05)
 return maxi(1,damage)
static func command(m,cmd) -> String:
 var id=str(cmd.get("id",""))
 match cmd.type:
  "blueprint_research":
   if not m.data.enemies.has(id) or int(m.s.kills.get(id,0))<1:return "Discover this hunt first."
   var choices=RealmBlueprints.candidates(m,id)
   if choices.is_empty():return "All blueprints from this hunt are already known."
   if m.count("research_"+id)<200 or m.s.gold<5*RealmEconomy.PLATINUM:return "Gather 200 field notes and 5 Platinum to restore a lost blueprint."
   m.spend("research_"+id,200);m.s.gold-=5*RealmEconomy.PLATINUM
   m.gain(RealmBlueprints.item(choices[0]),1)
   m.note("Blueprint restored: "+m.name_of(choices[0])+".")
  "gear_attune":
   if not m.s.fight.is_empty():return "Finish or leave combat before changing equipment."
   var uid=str(cmd.get("uid",""));var g=m.gear(uid)
   if g.is_empty() or m.data.items[g.id].slot!="weapon" or id not in ATTUNEMENTS:return "Choose a weapon and an attunement."
   if m.level("smithing")<65:return "Reach Smithing Lv.65."
   if m.s.get("gear_attunements",{}).get(uid,"")==id:return "This weapon already has that attunement."
   if g.count>1 and m.s.gear.size()>=1000:return "Make room in your equipment bag first."
   if m.s.gold<250000 or m.count("depth_shard")<10 or m.count("scrap")<100:return "Requires 250 Gold, 10 Hollow Shards and 100 scraps."
   m.s.gold-=250000;m.spend("depth_shard",10);m.spend("scrap",100)
   if g.count>1:
    var rest=g.duplicate(true);rest.uid="eq_%d" % int(m.s.next_uid);m.s.next_uid+=1;rest.count-=1;g.count=1;m.s.gear.append(rest)
   if not m.s.has("gear_attunements"):m.s.gear_attunements={}
   m.s.gear_attunements[uid]=id
  "march_claim":
   var r=int(cmd.get("region",-1))
   if r<0 or r>=6:return "Choose a region."
   if int(m.s.kills.get("march_%d_8" % r,0))<1:return "Defeat the region's ruler first."
   var claims=m.s.get("march_claimed",[])
   if r in claims:return "This expedition reward was already claimed."
   claims.append(r);m.s.march_claimed=claims
   m.s.gold+=(r+1)*500000;m.gain("depth_shard",20+r*5)
   m.note(data().regions[r].name+" secured. The supply road is open.")
 return ""
static func valid(s,data_catalog) -> bool:
 var claims=s.get("march_claimed",[])
 if not claims is Array or claims.size()>6:return false
 var seen=[]
 for r in claims:
  if not RealmSave.counter(r) or r>5 or r in seen or s.kills.get("march_%d_8" % int(r),0)<1:return false
  seen.append(r)
 var attuned=s.get("gear_attunements",{})
 if not attuned is Dictionary:return false
 for uid in attuned:
  if attuned[uid] not in ATTUNEMENTS:return false
  var found=false
  for g in s.gear:
   if g.uid==uid:found=g.count==1 and data_catalog.items[g.id].slot=="weapon"
  if not found:return false
 return true
