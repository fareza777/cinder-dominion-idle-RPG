extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
func _init(owner):
	app = owner
	m = owner.model
func open():
	if RealmCharacters.id(m)=="":
		preload("res://ui/character_creation.gd").new(app).open(true)
		return
	var c = RealmCharacters.ALL[RealmCharacters.id(m)]
	var v = app.modal("Attributes & class skill")
	v.add_child(U.para(RealmCharacters.hero_name(m)+" · "+c.name,24,U.GOLD))
	v.add_child(U.para(c.trade,14))
	v.add_child(U.para("%d attribute points available" % RealmCharacters.points(m),20,U.TEXT))
	v.add_child(U.para("Start with 3 points. Earn 1 more every 5 Bladecraft levels. Reset for free outside combat.",13))
	for key in RealmCharacters.ATTRIBUTES:
		var card = U.card(v,12)
		card.add_child(U.para("%s · %d" % [RealmCharacters.ATTRIBUTES[key],RealmCharacters.allocated(m,key)],18,U.TEXT))
		card.add_child(U.para({"might":"+1 attack before class modifiers.","resolve":"+1 armor before class modifiers.","focus":"+3% fourth-attack damage once your class skill unlocks."}[key],13))
		var b = U.button("Add point",func():
			if app.send({"type":"attribute_add","id":key}): open())
		b.disabled = RealmCharacters.points(m)<=0 or not m.s.fight.is_empty()
		card.add_child(b)
	var rank = RealmCharacters.rank(m)
	v.add_child(U.para(c.skill+" · Rank %d / 4" % rank,21,U.GOLD))
	v.add_child(U.para(RealmCharacters.skill_description(RealmCharacters.id(m),rank),15,U.TEXT))
	v.add_child(U.para("Automatic in battle. Ranks unlock at Bladecraft levels 5, 25, 50 and 75. Gear, stance and rune bonuses still apply.",13))
	if rank==0: v.add_child(U.para("Not active yet · reach Bladecraft Lv.5.",14,U.GOLD))
	var reset = app.modal_action("Reset attributes · free",func():
		if app.send({"type":"attribute_reset"}): open())
	reset.disabled = not m.s.fight.is_empty()
