extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
func _init(owner): app=owner; m=owner.model

func open(region: int = 0):
	var v = app.modal("Beyond the Sovereign")
	for r in range(3): v.add_child(U.button(RealmFrontiers.REGIONS[r],func(): open(r),r==region))
	var first = "frontier_%d_0" % region
	if m.available(first)!="":
		v.add_child(U.para(m.available(first),17,U.GOLD))
		return
	v.add_child(U.para(RealmFrontiers.STORIES[region],16))
	for stage in range(3):
		var c = U.card(v,12)
		c.add_child(U.para(RealmFrontiers.QUESTS[stage],20,U.GOLD))
		var completed = 0
		for n in [stage*2,stage*2+1]:
			var id = "frontier_%d_%d" % [region,n]
			if int(m.s.kills.get(id,0))>0: completed+=1
			if not RealmDiscovery.visible(m,id): continue
			var e = m.data.enemies[id]
			var row = U.row(10)
			c.add_child(row)
			row.add_child(U.enemy_portrait(e,Vector2(68,86)))
			var details = U.column(4)
			details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(details)
			details.add_child(U.para(m.local_name(e),18,U.TEXT))
			details.add_child(U.para("Defeated" if int(m.s.kills.get(id,0))>0 else "Next encounter",12,U.GOLD))
			c.add_child(U.button("Prepare hunt",func(): app.activity_dialog("hunt_"+id,1)))
		c.add_child(U.para("%d / 2 encounters · %s + %d Hollow Shards" % [completed,RealmEconomy.money(RealmFrontiers.reward(region,stage)),5*(stage+1)],14))
		var claimed = "%d_%d" % [region,stage] in m.s.get("frontier_claimed",[])
		var b = U.button("Claimed" if claimed else "Claim objective reward",func():
			if app.send({"type":"frontier_claim","region":region,"stage":stage}): open(region))
		b.disabled = claimed or completed<2
		c.add_child(b)
	v.add_child(U.button("Masterwork blueprints",func(): preload("res://ui/masterworks.gd").new(app).open()))
