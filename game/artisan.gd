class_name RealmArtisan
extends RefCounted

const AFFIXES={
 "ember":{"name":"Emberforged","detail":"Fourth hits inflict Burn.","proc":"burn"},
 "venom":{"name":"Venomkissed","detail":"Fourth hits inflict Poison.","proc":"poison"},
 "dread":{"name":"Dreadbound","detail":"Fourth hits weaken enemy attack.","proc":"weaken"},
 "sunder":{"name":"Sundering","detail":"Fourth hits break enemy armor.","proc":"armor_break"},
 "frost":{"name":"Frostveined","detail":"Fourth hits apply Chill.","proc":"chill"},
 "rending":{"name":"Rending","detail":"Fourth hits inflict Bleed.","proc":"bleed"},
 "guarded":{"name":"Guarded","detail":"Fourth hits grant a protective barrier.","proc":"barrier"},
 "mending":{"name":"Mending","detail":"Fourth hits grant Regeneration.","proc":"regeneration"},
 "keen":{"name":"Keen","detail":"Adds attack, scaled by item quality."},
 "stalwart":{"name":"Stalwart","detail":"Adds armor, scaled by item quality."},
 "swift":{"name":"Swift","detail":"Improves this tool's gathering speed."},
 "bountiful":{"name":"Bountiful","detail":"Builds progress toward extra gathered supplies."}}
const KINDS={"smithing":"hammer","cooking":"knife","alchemy":"mortar"}
const TOOLS=["axe","pick","rod"]

static func selected(m,kind: String) -> String:return str(m.s.get("artisan_tools",{}).get(kind,""))
static func tier(m,kind: String) -> int:
 var id=selected(m,kind)
 return int(m.data.items.get(id,{}).get("artisan_tier",0)) if id!="" and m.count(id)>0 else 0
static func pool(slot: String) -> Array:
 if slot in TOOLS:return ["swift","bountiful"]
 if slot in ["weapon","hands"]:return ["ember","venom","dread","sunder","frost","rending","keen"]
 if slot in ["necklace","ring","belt"]:return ["keen","stalwart","mending","guarded","dread","frost"]
 return ["guarded","mending","stalwart"]
static func affixes(m,id: String,q: int) -> Array:
 var out=[];var options=pool(m.data.items[id].slot).duplicate()
 for i in range(mini(options.size(),0 if q<2 else (3 if q>=5 else (2 if q==4 else 1)))):
  var index=m.rng.randi_range(0,options.size()-1);out.append(options[index]);options.remove_at(index)
 return out
static func craft_quality(m,roll: float = -1.0) -> int:
 if roll<0:roll=m.rng.randf()
 var hammer=tier(m,"hammer");var skill=float(m.level("smithing"))/100.0
 if hammer==4 and m.level("smithing")>=90 and roll<.00005:return 5
 if roll<.001+skill*.003+hammer*.001:return 4
 if roll<.025+skill*.025+hammer*.008:return 3
 if roll<.18+skill*.07+hammer*.02:return 2
 return 1
static func award(m,id: String,q: int,rolled: bool = true,explicit: Array = []) -> String:
 var traits=affixes(m,id,q) if rolled else explicit.duplicate()
 var uid=m.add_gear(id,q,not traits.is_empty())
 for g in m.s.gear+m.s.overflow:
  if g.uid==uid:
   if not traits.is_empty():g.affixes=traits
   break
 m.s.gains[id]=int(m.s.gains.get(id,0))+1
 return uid
static func bonus(m,id: String) -> float:
 var value=0.0
 for uid in m.s.equipped.values():
  var g=m.gear(str(uid))
  if id in g.get("affixes",[]):value+=.01*clampi(int(g.q)-1,1,4)
 return minf(.15,value)
static func procs(m):
 var effects={}
 for uid in m.s.equipped.values():
  var g=m.gear(str(uid))
  for id in g.get("affixes",[]):
   var effect=str(AFFIXES[id].get("proc",""))
   if effect!="":effects[effect]=mini(6,int(effects.get(effect,0))+maxi(1,int(g.q)-1))
 for effect in effects:RealmAfflictions.apply(m,"hero" if effect in ["barrier","regeneration"] else "enemy",effect,effects[effect])
static func tool_speed(g: Dictionary) -> float:
 if g.is_empty():return 0
 return maxf(0,int(g.q)-1)*.01+int(g.get("tool_rank",0))*.015+(.02 if "swift" in g.get("affixes",[]) else 0)
static func extra_yield(m,a: Dictionary) -> int:
 var rate=0
 var slot={"woodcutting":"axe","mining":"pick","fishing":"rod"}.get(a.skill,"")
 if slot!="":
  var g=m.gear(str(m.s.equipped.get(slot,"")))
  rate=int(g.get("tool_rank",0))*2+(5 if "bountiful" in g.get("affixes",[]) else 0)
 elif a.skill in KINDS and a.skill!="smithing":rate=tier(m,KINDS[a.skill])*3
 if rate==0:return 0
 if not m.s.has("artisan_yield"):m.s.artisan_yield={}
 var progress=int(m.s.artisan_yield.get(a.skill,0))+rate
 m.s.artisan_yield[a.skill]=progress%100
 return int(progress/100)
static func copy_traits(g: Dictionary,target: Dictionary):
 if g.has("affixes"):target.affixes=g.affixes.duplicate()
 if g.has("tool_rank"):target.tool_rank=g.tool_rank
static func has_traits(g: Dictionary) -> bool:return not g.get("affixes",[]).is_empty() or int(g.get("tool_rank",0))>0
static func tool_cost(m,g: Dictionary) -> Dictionary:
 var rank=int(g.get("tool_rank",0));var family=str(m.data.items[g.id].get("forge_metal",str(g.id).get_slice("_",0)))
 var metal=family+"_ingot"
 if not m.data.items.has(metal):metal="copper_ingot"
 return {"gold":int(pow(rank+1,3))*maxi(100,int(m.data.items[g.id].get("sell",0))*3),"metal":metal,"ingots":(rank+1)*5,"scrap":(rank+1)*10,"level":10+rank*15}
static func tool_reason(m,g: Dictionary) -> String:
 if g.is_empty() or m.data.items[g.id].slot not in TOOLS:return "Choose an axe, pickaxe or fishing rod."
 if not m.s.fight.is_empty() or not m.s.active.is_empty():return "Finish your current activity before improving a tool."
 if int(g.get("tool_rank",0))>=6:return "This tool has reached rank 6."
 var c=tool_cost(m,g)
 if m.level("smithing")<c.level:return "Requires Smithing Lv.%d." % c.level
 if m.s.gold<c.gold or m.count(c.metal)<c.ingots or m.count("scrap")<c.scrap:return "Gather the coins, ingots and scraps shown below."
 if g.count>1 and m.s.gear.size()>=1000:return "Make room in your equipment bag first."
 return ""
static func command(m,cmd: Dictionary) -> String:
 var id=str(cmd.get("id",""))
 if cmd.type=="artisan_select":
  if not m.s.active.is_empty() or not m.s.fight.is_empty():return "Finish your current activity before changing artisan tools."
  var d=m.data.items.get(id,{})
  if not d.has("artisan_kind") or m.count(id)<1:return "Craft this artisan tool first."
  if not m.s.has("artisan_tools"):m.s.artisan_tools={}
  m.s.artisan_tools[d.artisan_kind]=id
 else:
  var g=m.gear(id);var why=tool_reason(m,g)
  if why!="":return why
  var c=tool_cost(m,g);m.s.gold-=c.gold;m.spend(c.metal,c.ingots);m.spend("scrap",c.scrap)
  if g.count>1:
   var rest=g.duplicate(true);rest.uid="eq_%d" % m.s.next_uid;m.s.next_uid+=1;rest.count-=1;g.count=1;m.s.gear.append(rest)
  g.tool_rank=int(g.get("tool_rank",0))+1
  m.note(m.name_of(g.id)+" improved to tool rank %d." % g.tool_rank)
 return ""
static func valid(s: Dictionary,data: Dictionary) -> bool:
 if not s.get("artisan_tools",{}) is Dictionary or not s.get("artisan_yield",{}) is Dictionary:return false
 for kind in s.get("artisan_tools",{}):
  var id=s.artisan_tools[kind]
  if kind not in KINDS.values() or not id is String or data.items.get(id,{}).get("artisan_kind","")!=kind:return false
 for skill in s.get("artisan_yield",{}):
  if skill not in data.skills or not RealmSave.counter(s.artisan_yield[skill]) or s.artisan_yield[skill]>99:return false
 for g in s.gear+s.overflow:
  var traits=g.get("affixes",[])
  if not traits is Array or traits.size()>mini(3,pool(data.items[g.id].slot).size()):return false
  if not traits.is_empty() and (g.count!=1 or g.q<2 or traits.size()>(3 if g.q>=5 else (2 if g.q==4 else 1))):return false
  var seen=[]
  for id in traits:
   if id not in pool(data.items[g.id].slot) or id in seen:return false
   seen.append(id)
  if not RealmSave.counter(g.get("tool_rank",0)) or g.get("tool_rank",0)>6:return false
  if g.get("tool_rank",0)>0 and (data.items[g.id].slot not in TOOLS or g.count!=1):return false
 return true
