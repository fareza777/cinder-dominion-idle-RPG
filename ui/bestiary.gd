extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
func _init(owner):
	app = owner
	m = app.model
func open(region: String = "all"):
	var v = app.modal("Bestiary")
	v.add_child(U.para("New enemies appear as you clear hunts and open routes.",14))
	var picker = OptionButton.new()
	var regions = ["all","wilds","marsh","crown"]
	for id in regions: picker.add_item("All regions" if id=="all" else RealmChronicle.REGIONS[id].name)
	picker.selected = regions.find(region)
	picker.custom_minimum_size.y = 48
	picker.item_selected.connect(func(index): open(regions[index]))
	v.add_child(picker)
	for id in m.data.enemies:
		if not RealmDiscovery.visible(m,id): continue
		var e = m.data.enemies[id]
		if region!="all" and e.get("region","")!=region: continue
		var c = U.card(v,12)
		var row = U.row(10)
		c.add_child(row)
		row.add_child(U.enemy_portrait(e,Vector2(64,80)))
		row.add_child(U.para(m.local_name(e),18,U.TEXT))
		app.dynamic(c,func(): return "%d victories · mastery %d / 4" % [m.s.kills.get(id,0),RealmHuntMastery.rank(m,id)],13,U.GOLD)
		c.add_child(U.para("%s ×%d · %d base XP" % [m.name_of(e.drop),e.qty,e.xp],14,U.GREEN))
		c.add_child(U.para(RealmCombat.mechanic(e),13))
		var reason = m.available(id)
		if reason!="": c.add_child(U.para(reason,13,U.MUTED))
		else:
			c.add_child(U.para(m.encounter_advice(id),13))
			c.add_child(U.button("Plan this hunt",func(): app.hunt_plan_dialog(id)))
