class_name RealmSpoils
extends RefCounted

static func victory(m,e: Dictionary):
 var rng=RandomNumberGenerator.new()
 if m.s.has("spoils_rng"):rng.state=int(m.s.spoils_rng)
 else:rng.seed=m.rng.state^510731
 var tier=clampi(int(e.get("march",e.get("frontier",-1)))+2,0,7)
 var supplies={"wilds":["oak_log","grave_moss"],"marsh":["emberleaf","coal"],"crown":["iron_ore","scrap"]}.get(e.get("region",""),["copper_ore","ash_log","scrap"])
 if e.has("frontier") or e.has("march"):
  supplies=[["steel_ore","steel_log"],["moonsteel_ore","moonsteel_log"],["dusksteel_ore","dusksteel_log"],["dawnsteel_ore","dawnsteel_log"]][clampi(tier-2,0,3)]
 if e.has("realm"):
  supplies=["star_ingot","scrap"] if e.realm<3 else ["ore_"+str(5 if e.realm<5 else 6),"log_"+str(5 if e.realm<5 else 6)]
 var material=supplies[rng.randi_range(0,supplies.size()-1)]
 if not m.data.items.has(material):material="scrap"
 if rng.randf()<.25:m.gain(material,rng.randi_range(1,2+tier))
 var pool=RealmVoyages.data().elite_loot.get(e.id,[])
 if e.has("realm") and e.boss:
  pool=["firmament%d_sword" % int(e.realm),"firmament%d_shield" % int(e.realm),"firmament%d_ring" % int(e.realm)]
 if not pool.is_empty() and rng.randf()<.02:
  var id=pool[rng.randi_range(0,pool.size()-1)];var roll=rng.randf()
  var q=5 if roll<.0002 else (4 if roll<.1 else 3)
  # Separate loot stream cannot alter the timing/accuracy RNG of combat.
  var previous=m.rng.state;m.rng.state=rng.state
  RealmArtisan.award(m,id,q);rng.state=m.rng.state;m.rng.state=previous
  RealmHunts.equipment(m,id,q);m.note("Recovered: "+m.data.rarities[q]+" "+m.name_of(id)+".")
 m.s.spoils_rng=str(rng.state)
