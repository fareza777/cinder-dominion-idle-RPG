extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
func _init(owner):
	app = owner
	m = app.model
func open():
	var v = app.modal("Armor sets")
	v.add_child(U.para("Two pieces. A new advantage.",23,U.TEXT))
	v.add_child(U.para("Equip any two armor pieces of the same metal. Shields count; weapons and tools do not. Extra pieces do not increase the bonus. You can combine two sets.",14))
	for id in RealmGearSets.ALL:
		var d = RealmGearSets.ALL[id]
		var card = U.card(v,12)
		var row = U.row(10)
		card.add_child(row)
		row.add_child(U.icon(id+"_shield",56))
		row.add_child(U.para(d.name,21,U.GOLD))
		app.dynamic(card,func(): return "ACTIVE · %d pieces equipped" % RealmGearSets.counts(m)[id] if RealmGearSets.active(m,id) else "%d / 2 pieces equipped" % RealmGearSets.counts(m)[id],14,U.GREEN if RealmGearSets.active(m,id) else U.MUTED)
		card.add_child(U.para(d.effect,14))
		card.add_child(U.button("Browse "+id.capitalize()+" equipment",func(): preload("res://ui/ascension.gd").new(app).open(RealmGearSets.ALL.keys().find(id))))
	app.modal_action("Compare battle loadouts",func(): preload("res://ui/build_compare.gd").new(app).open())
