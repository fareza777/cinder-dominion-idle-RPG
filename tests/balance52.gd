extends SceneTree
func _init():
	var results=[]
	for r in range(7):
		var m=preload("res://tests/balance50.gd").build("warden",5)
		for skill in m.s.xp:m.s.xp[skill]=RealmEconomy.threshold(100+r*5,skill)
		for uid in m.s.equipped.values():
			var g=m.gear(uid)
			if m.data.items[g.id].slot not in ["axe","pick","rod"]:g.q=7+r*2
		var result=preload("res://tests/balance34.gd").fight(m,"realm_%d_9" % r)
		result.region=r;results.append(result);print("REGION ",r," ",result)
	FileAccess.open("res://build/balance52.json",FileAccess.WRITE).store_string(JSON.stringify(results,"\t"))
	quit()
