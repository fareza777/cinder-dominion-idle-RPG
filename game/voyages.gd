class_name RealmVoyages
extends RefCounted

static var catalog={}
static func data() -> Dictionary:
 if catalog.is_empty():catalog=JSON.parse_string(FileAccess.get_file_as_string("res://data/expeditions.json"))
 return catalog
static func route(id: String) -> Dictionary:
 for r in data().routes:
  if r.id==id:return r
 return {}
static func state(m) -> Dictionary:
 if not m.s.has("voyages"):m.s.voyages={"active":{},"ready":{},"clears":{}}
 return m.s.voyages
static func busy(m) -> bool:return not m.s.get("voyages",{}).get("active",{}).is_empty()
static func next_event(m) -> int:return int(m.s.voyages.active.next) if busy(m) else 9000000000000000
static func reason(m,id: String,risk: String = "steady") -> String:
 var r=route(id)
 if r.is_empty() or risk not in ["steady","perilous"]:return "Choose a journey and its danger."
 if busy(m):return "Your hero is already on a journey."
 if not m.s.get("voyages",{}).get("ready",{}).is_empty():return "Collect the previous journey's rewards first."
 if not m.s.queue.is_empty() or not m.s.fight.is_empty() or not m.s.active.is_empty():return "Finish or clear your work queue before departing."
 if m.s.kills.get(r.gate,0)<1:return "Defeat "+m.local_name(m.data.enemies[r.gate])+" to discover this route."
 if m.level("bladecraft")<r.level:return "Requires Bladecraft Lv.%d." % r.level
 var st=m.stats();var power=int(r.power*(1.3 if risk=="perilous" else 1.0))
 if st.attack+st.armor<power:return "Requires %d combined attack and armor; your build has %d." % [power,st.attack+st.armor]
 var amount=int(r.provisions)*(2 if risk=="perilous" else 1)
 if m.s.gold<r.fee or m.count(r.food)<amount:return "Prepare the provisions and travel fee shown below."
 return ""
static func command(m,cmd: Dictionary) -> String:
 var id=str(cmd.get("id",""))
 if cmd.type=="voyage_start":
  var why=reason(m,id,str(cmd.get("risk","steady")))
  if why!="":return why
 elif not m.s.has("voyages"):return "No journey rewards are waiting."
 var s=state(m)
 match cmd.type:
  "voyage_start":
   var risk=str(cmd.get("risk","steady"));var why=reason(m,id,risk)
   if why!="":return why
   var r=route(id);m.s.gold-=r.fee;m.spend(r.food,r.provisions*(2 if risk=="perilous" else 1))
   RealmAutomation.stop(m,"Journey underway.")
   var duration=int(r.hours)*3600000
   s.active={"id":id,"risk":risk,"started":int(m.s.time),"next":int(m.s.time)+int(duration/4),"due":int(m.s.time)+duration,"stage":0,"gold":0,"cargo":{},"gear":[],"complete":false}
   m.note("Departed for "+r.name+". Provisions are packed for the whole journey.")
  "voyage_recall":
   if s.active.is_empty():return "No journey is underway."
   s.ready=s.active;s.active={};m.note("Journey recalled. Collected caches are ready; the final vault remains sealed.")
  "voyage_claim":
   if s.ready.is_empty():return "No journey rewards are waiting."
   var reward=s.ready
   for item in reward.cargo:m.gain(item,int(reward.cargo[item]))
   for g in reward.gear:RealmArtisan.award(m,g.id,int(g.q),false,g.affixes)
   m.s.gold+=int(reward.gold)
   if reward.complete:s.clears[reward.id]=int(s.clears.get(reward.id,0))+1
   s.ready={};m.note("Journey supplies collected.")
 return ""
static func tick(m):
 if not busy(m) or next_event(m)>m.s.time:return
 var s=state(m);var a=s.active;var r=route(a.id);var index=data().routes.find(r)
 a.stage+=1
 var multiplier=2 if a.risk=="perilous" else 1
 a.cargo[r.material]=int(a.cargo.get(r.material,0))+(2+index)*multiplier
 a.cargo.scrap=int(a.cargo.get("scrap",0))+(1+int(index/2))*multiplier
 a.gold+=maxi(10,int(r.fee*.3))*multiplier
 if a.stage==4:
  a.complete=true
  a.cargo.depth_shard=int(a.cargo.get("depth_shard",0))+maxi(1,index)*multiplier
  var rng=RandomNumberGenerator.new()
  if m.s.has("voyage_rng"):rng.state=int(m.s.voyage_rng)
  else:rng.seed=m.rng.state^510913
  if rng.randf()<(.5 if a.risk=="perilous" else .3):
   var q=4 if rng.randf()<.08 else 3
   var previous=m.rng.state;m.rng.state=rng.state
   a.gear.append({"id":r.gear,"q":q,"affixes":RealmArtisan.affixes(m,r.gear,q)})
   rng.state=m.rng.state;m.rng.state=previous
  m.s.voyage_rng=str(rng.state)
  s.ready=a;s.active={};m.note(r.name+" cleared. Your hero has returned with the expedition's cargo.")
 else:
  a.next=int(a.started)+int((a.due-a.started)*(a.stage+1)/4)
  m.note(r.name+" · "+r.stages[a.stage-1]+" completed. Supplies secured.")
static func valid(s: Dictionary,items: Dictionary) -> bool:
 for key in ["spoils_rng","voyage_rng"]:
  if s.has(key) and (not s[key] is String or not s[key].is_valid_int()):return false
 if not s.has("voyages"):return true
 var v=s.voyages
 if not v is Dictionary:return false
 for key in ["active","ready","clears"]:
  if not v.get(key) is Dictionary:return false
 if not v.active.is_empty() and (not v.ready.is_empty() or not s.queue.is_empty() or not s.active.is_empty() or not s.fight.is_empty()):return false
 for id in v.clears:
  if route(id).is_empty() or not RealmSave.counter(v.clears[id]):return false
 for key in ["active","ready"]:
  var a=v[key]
  if a.is_empty():continue
  var r=route(str(a.get("id","")))
  if r.is_empty() or a.get("risk","") not in ["steady","perilous"] or not a.get("complete") is bool:return false
  for field in ["started","next","due","stage","gold"]:
   if not RealmSave.counter(a.get(field,-1)):return false
  if a.stage>4 or a.due-a.started!=r.hours*3600000 or a.started>s.time:return false
  if key=="active" and (a.complete or a.stage>=4 or a.next<s.time or a.next!=a.started+(a.due-a.started)*(a.stage+1)/4):return false
  if a.complete and (a.stage!=4 or a.due>s.time):return false
  if not a.complete and a.stage>=4:return false
  if a.started+(a.due-a.started)*a.stage/4>s.time:return false
  if not a.get("cargo") is Dictionary or not a.get("gear") is Array or a.gear.size()>1:return false
  for id in a.cargo:
   if id not in [r.material,"scrap","depth_shard"] or not items.has(id) or not RealmSave.counter(a.cargo[id]):return false
  var index=data().routes.find(r);var multiplier=2 if a.risk=="perilous" else 1
  if a.gold!=maxi(10,int(r.fee*.3))*multiplier*a.stage:return false
  if a.cargo.get(r.material,0)!=(2+index)*multiplier*a.stage:return false
  if a.cargo.get("scrap",0)!=(1+int(index/2))*multiplier*a.stage:return false
  if a.cargo.get("depth_shard",0)!=(maxi(1,index)*multiplier if a.complete else 0):return false
  if not a.complete and not a.gear.is_empty():return false
  for g in a.gear:
   if not g is Dictionary or g.get("id","")!=r.gear or g.get("q",0) not in [3,4] or not g.get("affixes") is Array:return false
   if g.affixes.size()>(2 if g.q==4 else 1):return false
   var seen=[]
   for affix in g.affixes:
    if affix not in RealmArtisan.pool(items[g.id].slot) or affix in seen:return false
    seen.append(affix)
 return true
