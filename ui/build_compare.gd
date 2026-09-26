extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
func _init(owner):
	app = owner
	m = app.model
func open(target: String = ""):
	var choices: Array[String] = []
	for id in m.data.enemies:
		if m.available(id)=="": choices.append(id)
	if choices.is_empty(): choices.append("ash_rat")
	if target not in choices: target = choices[0]
	var v = app.modal("Compare loadouts")
	v.add_child(U.para("Choose a hunt. Compare before you commit.",21,U.TEXT))
	var picker = OptionButton.new()
	picker.custom_minimum_size.y = 48
	for id in choices: picker.add_item(m.local_name(m.data.enemies[id]))
	picker.selected = choices.find(target)
	picker.item_selected.connect(func(index): open(choices[index]))
	v.add_child(picker)
	v.add_child(U.para("Estimates at opening, without potion buffs. Comparing does not equip gear or spend items.",13))
	var slots: Array[String] = [""]
	for id in RealmLoadouts.NAMES:
		if RealmLoadouts.state(m).has(id): slots.append(id)
	for id in slots:
		var result = RealmBuildCompare.preview(m,id,target)
		var card = U.card(v,12)
		card.add_child(U.para("Current build" if id=="" else RealmLoadouts.NAMES[id],21,U.GOLD))
		if result.error!="":
			card.add_child(U.para(result.error,14,U.RED))
			continue
		var f = result.forecast
		card.add_child(U.para("%d ATK · %d DEF\n%s\n%s" % [result.stats.attack,result.stats.armor,result.training,result.sets],14,U.TEXT))
		card.add_child(U.para("%s · ~%ds per fight\n~%d meals · strongest hit %d HP" % [f.rating,f.seconds,f.meals,f.burst],16,U.GREEN if not f.risk else U.GOLD))
		card.add_child(U.para("%s ×%d · restores up to %d HP" % [m.name_of(result.food),result.stock,mini(100,int(f.healing))],13))
		if id!="":
			var apply = U.button("Apply "+RealmLoadouts.NAMES[id],func():
				if app.send({"type":"loadout_load","id":id}): open(target))
			apply.disabled = not m.s.fight.is_empty()
			card.add_child(apply)
	if slots.size()==1: v.add_child(U.button("Save a loadout to compare",app.loadouts_dialog))
	app.modal_action("Plan this hunt",func(): app.hunt_plan_dialog(target))
