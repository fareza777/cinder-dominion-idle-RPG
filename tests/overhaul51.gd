extends SceneTree
var failures=0
func check(ok: bool,label: String):
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures+=1
static func prepared():
 var m=preload("res://tests/balance50.gd").build("warden",5)
 m.s.gold=100000000
 for id in m.data.items:
  if m.data.items[id].category!="equipment":m.s.bag[id]=10000
 return m
func _init():
 var m=RealmModel.new();var save=RealmSave.new()
 check(m.data.items.size()==682 and RealmVoyages.data().routes.size()==12,"expanded item and route counts")
 var actors=JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_actors.json"))
 var complete=actors.size()==m.data.enemies.size()
 for id in m.data.enemies:
  complete=complete and actors.has(id) and FileAccess.file_exists("res://assets/art/enemy-actors-%d-0.51.png" % actors[id].sheet)
 check(complete and actors.ash_rat.scale<actors.march_guard_0.scale,"all 120 enemies mapped to pose sheets and logical scale")
 var refs=true
 for a in m.data.activities.values():
  refs=refs and m.data.items.has(a.output)
  for item in a.inputs:refs=refs and m.data.items.has(item)
 for r in RealmVoyages.data().routes:refs=refs and m.data.enemies.has(r.gate) and m.data.items.has(r.food) and m.data.items.has(r.material)
 check(refs,"new recipes and travel references resolve")
 check(not save.decode(save.encode(m.s),m.data).is_empty(),"legacy-shaped state still loads")
 check(RealmArtisan.craft_quality(m,0.00001)<5,"no Legendary roll without Blackstar Hammer")
 m=prepared();m.command({"type":"artisan_select","id":"artisan_hammer_4"})
 check(RealmArtisan.craft_quality(m,.00001)==5 and RealmArtisan.craft_quality(m,.00006)==4,"Legendary threshold and special hammer gate")
 check(RealmArtisan.craft_quality(m,.03)==3 and RealmArtisan.craft_quality(m,.2)==2 and RealmArtisan.craft_quality(m,.8)==1,"quality tiers have distinct roll bands")
 var before=m.s.duplicate(true)
 check(not m.command({"type":"artisan_select","id":"not_a_hammer"}) and m.s==before,"invalid artisan selection is atomic")
 var uid=RealmArtisan.award(m,"star_sword",4,false,["ember","sunder"])
 var plain=m.add_gear("star_sword",4)
 check(uid!=plain and m.gear(uid).count==1,"affixed equipment cannot merge with ordinary stacks")
 m.command({"type":"equip","id":uid});m.command({"type":"queue","id":"hunt_march_5_0","target":1})
 RealmArtisan.procs(m)
 check(RealmAfflictions.has(m,"enemy","burn") and RealmAfflictions.has(m,"enemy","armor_break"),"equipment traits apply real combat effects")
 m.command({"type":"clear"})
 check(m.command({"type":"refine","id":uid}) and m.gear(m.last_forged).affixes==["ember","sunder"],"Legendary refinement preserves traits and gear references")
 var tool=m.gear(m.s.equipped.pick);var cycle=m.duration(m.data.activities.mine_copper)
 check(m.command({"type":"tool_upgrade","id":tool.uid}) and tool.tool_rank==1 and m.duration(m.data.activities.mine_copper)<cycle,"tool rank improves actual cycle duration")
 var total=0
 for i in range(50):total+=RealmArtisan.extra_yield(m,m.data.activities.mine_copper)
 check(total==1,"tool yield accumulates predictably without changing rare drops")
 check(save.valid(m.s,m.data),"affixes and upgraded tools preserve valid save")
 var corrupt=m.s.duplicate(true);corrupt.gear.filter(func(g):return g.uid==m.last_forged)[0].affixes=["ember","ember"]
 check(save.decode(save.encode(corrupt),m.data).is_empty(),"duplicate trait corruption rejected")
 m=prepared();var r=RealmVoyages.route("journey_0")
 var gold=m.s.gold;var food=m.count(r.food)
 check(m.command({"type":"voyage_start","id":r.id}),"prepared hero starts a long journey")
 check(m.s.gold==gold-r.fee and m.count(r.food)==food-r.provisions,"departure charges once")
 check(not m.command({"type":"queue","id":"mine_copper","target":1}) and m.s.queue.is_empty(),"hero cannot gather while away")
 check(not m.command({"type":"voyage_start","id":r.id}) and m.s.gold==gold-r.fee,"second departure cannot double charge")
 var online=RealmModel.new();online.s=m.s.duplicate(true)
 var offline=RealmModel.new();offline.s=save.decode(save.encode(m.s),m.data)
 online.advance(3600000)
 for i in range(60):offline.advance(60000)
 check(save.decode(save.encode(online.s),online.data)==save.decode(save.encode(offline.s),offline.data) and not RealmVoyages.busy(online) and online.s.voyages.ready.complete,"journey stages and rewards match offline chunks and save reload")
 check(online.s.voyages.ready.stage==4 and online.s.voyages.ready.cargo[r.material]>0,"all four stages secure route-specific supplies")
 check(save.valid(online.s,online.data),"completed unclaimed journey persists")
 check(online.command({"type":"voyage_claim"}) and not online.command({"type":"voyage_claim"}),"cargo claim pays exactly once")
 check(online.s.voyages.clears[r.id]==1,"completed journey increments route record")
 var recalled=prepared();recalled.command({"type":"voyage_start","id":"journey_0"});recalled.advance(900000)
 check(recalled.command({"type":"voyage_recall"}) and not recalled.s.voyages.ready.complete and recalled.s.voyages.ready.stage==1,"recall preserves only completed caches")
 check(recalled.s.voyages.ready.gear.is_empty() and not recalled.s.voyages.ready.cargo.has("depth_shard"),"recall cannot claim the final vault")
 var travel_bad=recalled.s.duplicate(true);travel_bad.voyages.ready.cargo["card_ash_rat"]=1
 check(not save.valid(travel_bad,recalled.data),"invalid cargo is rejected")
 var blocked=RealmModel.new();blocked.s.gold=1000000;blocked.s.bag[r.food]=1000
 var old_gold=blocked.s.gold
 check(not blocked.command({"type":"voyage_start","id":r.id}) and blocked.s.gold==old_gold,"undiscovered route cannot spend provisions")
 var routes_ok=true
 for route in RealmVoyages.data().routes:
  var traveller=prepared();traveller.s.kills[route.gate]=1
  if not traveller.command({"type":"voyage_start","id":route.id}):
   routes_ok=false;print("ROUTE BLOCKED ",route.id," ",traveller.error);continue
  traveller.advance(int(route.hours)*3600000)
  routes_ok=routes_ok and save.valid(traveller.s,traveller.data) and traveller.command({"type":"voyage_claim"})
 check(routes_ok,"all twelve routes resolve and claim valid rewards")
 var crafter=prepared();crafter.command({"type":"artisan_select","id":"artisan_hammer_4"})
 crafter.command({"type":"queue","id":"craft_copper_sword","target":50})
 var resumed=RealmModel.new();resumed.s=save.decode(save.encode(crafter.s),crafter.data)
 crafter.advance(3600000)
 for i in range(60):resumed.advance(60000)
 check(save.decode(save.encode(crafter.s),crafter.data)==save.decode(save.encode(resumed.s),resumed.data),"craft qualities and traits match offline save/reload")
 check(crafter.s.gear.any(func(g):return g.id=="copper_sword" and not g.get("affixes",[]).is_empty()),"real production awards affixed equipment")
 var forged=prepared();var late=forged.add_gear("dawnsteel_pick",5);forged.command({"type":"equip","id":late})
 RealmProgression.state(forged).upgrades.forge=3
 var old_time=forged.duration(forged.data.activities.mine_copper)
 check(forged.command({"type":"tool_upgrade","id":late}) and forged.duration(forged.data.activities.mine_copper)<old_time,"tool ranks remain useful beyond the base speed cap")
 print("OVERHAUL51 ","PASS" if failures==0 else "FAIL"," failures=",failures)
 quit(failures)
