extends SceneTree
const Audit=preload("res://tests/balance34.gd")
static func build(character: String,region: int):
 var m=preload("res://tests/balance43.gd").build(character,false)
 var key=["rime","briar","cinder","hush","gloam","star"][region]
 for part in ["sword","shield","helm","chest","gloves","boots","necklace","belt","ring","signet"]:
  var uid=m.add_gear(key+"_"+part,5)
  m.command({"type":"equip","id":uid,"slot":"ring_right" if part=="signet" else ("ring_left" if part=="ring" else m.data.items[key+"_"+part].slot)})
 m.s.hero.attributes={"might":10,"resolve":8,"focus":4}
 return m
func _init():
 var results=[]
 for hero in RealmCharacters.ALL:
  for encounter in ["march_0_8","march_5_8","march_guard_4"]:
   var m=build(hero,0 if encounter=="march_0_8" else 5)
   var result=Audit.fight(m,encounter)
   result.hero=hero;result.enemy=encounter;results.append(result)
 var adjusted=build("duskblade",5)
 RealmEndgame.state(adjusted).route="safe"
 RealmChronicle.state(adjusted).relic="ward"
 var counter=Audit.fight(adjusted,"march_guard_4")
 counter.hero="duskblade";counter.enemy="march_guard_4";counter.adjustment="safe route + ward relic";results.append(counter)
 var f=FileAccess.open("res://build/balance50.json",FileAccess.WRITE);f.store_string(JSON.stringify(results,"\t"))
 print("BALANCE50 ",results.size()," fights; ",results.filter(func(r):return r.get("win",false)).size()," wins")
 quit()
