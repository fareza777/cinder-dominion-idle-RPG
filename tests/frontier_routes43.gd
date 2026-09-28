extends SceneTree
const Build = preload("res://tests/balance43.gd")
const Audit = preload("res://tests/balance34.gd")

func _init():
	var results=[]
	for i in range(18):
		var m=Build.build("warden",true)
		# Remove every future kill and any equipment requiring its rare material.
		for j in range(i,18): m.s.kills.erase("frontier_%d_%d" % [int(j/6),j%6])
		for slot in m.s.equipped.keys():
			var uid=m.s.equipped[slot]
			var id=m.gear(uid).id
			if id not in RealmLegacyFinds.GEAR: continue
			var recipe=m.data.activities["craft_"+id]
			var available=true
			for e in m.data.enemies.values():
				if recipe.inputs.has(e.rare_material) and int(m.s.kills.get(e.id,0))==0: available=false
			if available: continue
			var family={"head":"helm","body":"chest","hands":"gloves","feet":"boots","necklace":"necklace","belt":"belt","ring_left":"ring","ring_right":"ring"}.get(slot,slot)
			var replacement=m.add_gear("dawnsteel_"+family,5)
			var card=m.s.card_sockets.get(uid,"")
			if card!="":m.s.card_sockets.erase(uid);m.s.card_sockets[replacement]=card
			m.s.equipped[slot]=replacement
		var id="frontier_%d_%d" % [int(i/6),i%6]
		var result=Audit.fight(m,id)
		result.enemy=id
		results.append(result)
	var file=FileAccess.open("res://build/frontier-routes43.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"\t"))
	print("FRONTIER ROUTES: ",results.filter(func(r):return r.get("win",false)).size()," / 18 wins with obtainable equipment")
	quit()
