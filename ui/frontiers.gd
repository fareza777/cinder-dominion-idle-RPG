extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
func _init(owner): app=owner; m=owner.model

func open(region: int = 0, selected: int = -1):
	var v = app.modal("Beyond the Sovereign")
	var select = OptionButton.new()
	select.fit_to_longest_item = false
	select.custom_minimum_size.y = 48
	for name in RealmFrontiers.REGIONS: select.add_item(name)
	select.select(region)
	select.item_selected.connect(func(index): open(index))
	v.add_child(select)
	U.scenic(v,preload("res://ui/premium.gd").art(9+region),"",RealmFrontiers.REGIONS[region],145)
	var first = "frontier_%d_0" % region
	if m.available(first)!="":
		v.add_child(U.para(m.available(first),17,U.GOLD))
		return

	var path = preload("res://ui/route_view.gd").new()
	path.backdrop=preload("res://ui/premium.gd").art(9+region)
	for n in range(6):
		var id = "frontier_%d_%d" % [region,n]
		var known = RealmDiscovery.visible(m,id)
		path.entries.append({"title":m.local_name(m.data.enemies[id]) if known else "Undiscovered encounter","done":int(m.s.kills.get(id,0))>0,"locked":not known})
		if selected<0 and known and int(m.s.kills.get(id,0))==0: selected=n
	if selected<0: selected=5
	path.selected=selected
	path.changed=func(index): open(region,index)
	v.add_child(path)
	var target="frontier_%d_%d" % [region,selected]
	if RealmDiscovery.visible(m,target):
		var encounter=U.row(10)
		v.add_child(encounter)
		encounter.add_child(U.enemy_portrait(m.data.enemies[target],Vector2(64,80)))
		var label=U.para(m.local_name(m.data.enemies[target]),22,U.TEXT)
		label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		encounter.add_child(label)
		app.modal_action("Prepare hunt",func(): app.activity_dialog("hunt_"+target,1))
	for stage in range(3):
		var c = U.card(v,12)
		c.add_child(U.para(RealmFrontiers.QUESTS[stage],20,U.GOLD))
		var completed = 0
		for n in [stage*2,stage*2+1]:
			if int(m.s.kills.get("frontier_%d_%d" % [region,n],0))>0: completed+=1
		c.add_child(U.para("%d / 2 encounters · %s + %d Hollow Shards" % [completed,RealmEconomy.money(RealmFrontiers.reward(region,stage)),5*(stage+1)],14))
		var claimed = "%d_%d" % [region,stage] in m.s.get("frontier_claimed",[])
		var b = U.button("Claimed" if claimed else "Claim objective reward",func():
			if app.send({"type":"frontier_claim","region":region,"stage":stage}): open(region))
		b.disabled = claimed or completed<2
		c.add_child(b)
	v.add_child(U.button("Masterwork blueprints",func(): preload("res://ui/masterworks.gd").new(app).open()))
