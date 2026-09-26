extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func section(parent, title: String, detail: String):
	var card = U.card(parent,12)
	card.add_child(U.para(title,20,U.TEXT))
	if detail!="": card.add_child(U.para(detail,14,U.GOLD))
	return card

func open(tab: String = "next"):
	var v = app.modal("Farm & upgrade")
	var tabs = U.row(5)
	v.add_child(tabs)
	for choice in [["next","Goal"],["farm","Farm"],["upgrade","Upgrade"]]:
		var button = U.button(choice[1],func(): open(choice[0]),tab==choice[0])
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabs.add_child(button)
	match tab:
		"next": next_step(v)
		"farm": farming(v)
		"upgrade": upgrades(v)

func next_step(v):
	var objective = m.objective()
	var goal = section(v,objective.title,"%d / %d" % [mini(int(objective.current),int(objective.goal)),int(objective.goal)])
	goal.add_child(U.progress(objective.current,objective.goal,U.GOLD,8))
	var focus = RealmChronicle.focus(m)
	if focus.kind!="story":
		var prep = section(v,focus.title,"")
		prep.add_child(U.button("Open",func(): preload("res://ui/chronicle.gd").new(app).act()))
	v.add_child(U.button("All objectives",app.guide_dialog))
	v.add_child(U.button("How to play",app.experience.handbook))
	app.modal_action(objective.action,app.experience.act_on_goal)

func farming(v):
	var food = section(v,"Food","%s ×%d" % [m.name_of(m.s.settings.food),m.count(m.s.settings.food)])
	food.add_child(U.button("Cook 15 meals",func(): app.planner_dialog("craft_"+str(m.s.settings.food),15)))
	var metal = section(v,"Ingots","Equipment & Workshop")
	metal.add_child(U.button("Make 10 copper ingots",func(): app.planner_dialog("craft_copper_ingot",10)))
	if m.level("mining")>=10 and m.level("smithing")>=10:
		metal.add_child(U.button("Make 10 iron ingots",func(): app.planner_dialog("craft_iron_ingot",10)))
	else: metal.add_child(U.para("Iron: Mining 10 + Smithing 10",12))
	var xp = section(v,"Smithing","Level %d / 100" % m.level("smithing"))
	xp.add_child(U.button("Train · 25 ingots",func(): app.planner_dialog("craft_copper_ingot",25)))
	if m.s.tutorial:
		for id in RealmChronicle.RELICS:
			var relic = RealmChronicle.RELICS[id]
			var card = section(v,relic.name,relic.detail)
			card.add_child(U.button("Farm fragments",func(): preload("res://ui/chronicle.gd").new(app).farms(id)))
	var scrap = section(v,"Scraps & gold","")
	scrap.add_child(U.button("Contracts",app.contracts_dialog))
	if m.s.beacon: scrap.add_child(U.button("Field rewards",app.journal_dialog))

func upgrades(v):
	var gear = section(v,"Equipment","%d ATK · %d DEF" % [int(m.stats().attack),int(m.stats().armor)])
	gear.add_child(U.button("Equip gear",func():
		app.dismiss()
		app.set_page("inventory")))
	gear.add_child(U.button("Workshop",app.workshop_dialog))
	var build = section(v,"Build bonuses","")
	build.add_child(U.button("Talents",app.talents_dialog))
	build.add_child(U.button("Relics",app.relics_dialog))
	if m.s.beacon: build.add_child(U.button("Runes",app.runeforge_dialog))
	v.add_child(U.button("Hunt reports",app.hunt_reports_dialog))
