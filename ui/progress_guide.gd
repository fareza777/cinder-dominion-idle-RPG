extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func section(parent, title: String, detail: String):
	var card = U.card(parent,14)
	card.add_child(U.para(title,21,U.TEXT))
	card.add_child(U.para(detail,14))
	return card

func open(tab: String = "next"):
	var v = app.modal("Progress & farming")
	var tabs = U.row(5)
	v.add_child(tabs)
	for choice in [["next","Next step"],["farm","Farm"],["upgrade","Upgrade"]]:
		var button = U.button(choice[1],func(): open(choice[0]),tab==choice[0])
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabs.add_child(button)
	match tab:
		"next": next_step(v)
		"farm": farming(v)
		"upgrade": upgrades(v)

func next_step(v):
	var objective = m.objective()
	var goal = section(v,"Current goal",objective.title+"\n"+objective.detail)
	goal.add_child(U.para("%d / %d · %s" % [mini(int(objective.current),int(objective.goal)),int(objective.goal),objective.route],13,U.GOLD))
	var focus = RealmChronicle.focus(m)
	if focus.kind!="story":
		var prep = section(v,"Do this first",focus.title+"\n"+focus.why)
		prep.add_child(U.button("Open recommended action",func(): preload("res://ui/chronicle.gd").new(app).act()))
	var loop = section(v,"How to make progress","1. Gather the materials for an upgrade.\n2. Craft and equip it. Cook food for combat.\n3. Try the next enemy or tier once.\n4. If it costs too much food, repeat an easier hunt and improve your build.")
	loop.add_child(U.button("Choose what to farm",func(): open("farm")))
	section(v,"What unlocks next","Complete the first six Journey steps: talents, relics and more enemies.\n5 victories against each main enemy: the next route.\nSmithing 10 + Bellkeeper defeated: 3 expedition regions.\nOne victory per expedition tier: the next tier.\nTier 5 in a region: its Guardian Trial.")
	section(v,"Before you leave","Queue food, materials or a hunt you can sustain. The queue runs one task at a time and progresses for up to 24 hours while away. When you return, review the results, spend your rewards and choose the next task.")
	app.modal_action(objective.action,app.experience.act_on_goal)

func farming(v):
	v.add_child(U.para("Choose the upgrade first. Farm what it needs.",22,U.TEXT))
	var food = section(v,"Food for longer hunts","Cooked food heals you during combat. Raw fish and meat cannot heal you. Start with 15 meals, then use a hunt's report to check how much food your build actually uses.")
	food.add_child(U.para("Selected food: %s · %d owned" % [m.name_of(m.s.settings.food),m.count(m.s.settings.food)],13,U.GOLD))
	food.add_child(U.button("Plan 15 more meals",func(): app.planner_dialog("craft_"+str(m.s.settings.food),15)))
	var metal = section(v,"Ingots for equipment","Mine ore, then smelt it. Use ingots to craft equipment or improve its quality in the Workshop. The material planner includes missing ore automatically.")
	metal.add_child(U.button("Plan 10 copper ingots",func(): app.planner_dialog("craft_copper_ingot",10)))
	if m.level("mining")>=10 and m.level("smithing")>=10:
		metal.add_child(U.button("Plan 10 iron ingots",func(): app.planner_dialog("craft_iron_ingot",10)))
	else: metal.add_child(U.para("Iron production requires Mining 10 and Smithing 10. Mine copper to train Mining; smelt ingots to train Smithing.",13,U.GOLD))
	var xp = section(v,"Levels and talent points","Gathering trains its own skill. Smelting and forging train Smithing. Hunts train Bladecraft, Might and Warding. Every 250 combined melee XP earns a talent point, up to 10 points.")
	xp.add_child(U.para("Smithing Lv.100 · maximum level" if m.level("smithing")==100 else "Smithing Lv.%d · %d XP to the next level" % [m.level("smithing"),maxi(0,25*m.level("smithing")*m.level("smithing")-int(m.s.xp.smithing))],13,U.GOLD))
	xp.add_child(U.button("Plan 25 ingots for Smithing XP",func(): app.planner_dialog("craft_copper_ingot",25)))
	if m.s.tutorial:
		for id in RealmChronicle.RELICS:
			var relic = RealmChronicle.RELICS[id]
			var card = section(v,relic.name+" fragments",relic.detail+" Spend fragments on this relic or its regional rune. Both use the same supply.")
			card.add_child(U.button("Compare unlocked hunts",func(): preload("res://ui/chronicle.gd").new(app).farms(id)))
	else: section(v,"Relic fragments","Complete the first six Journey steps, ending with 3 Ash Rats, to unlock relics. Each enemy drops fragments for one specific relic.")
	var scrap = section(v,"Scraps and gold","Hunts give gold. Contracts, expedition first clears and field records give scraps. You can also salvage spare equipment in Bag. Keep gear used by your loadouts.")
	scrap.add_child(U.button("View contract rewards",app.contracts_dialog))
	if m.s.beacon: scrap.add_child(U.button("View field record rewards",app.journal_dialog))
	app.modal_action("Review upgrades",func(): open("upgrade"))

func upgrades(v):
	v.add_child(U.para("Improve one part of your build, then try the fight again.",22,U.TEXT))
	var gear = section(v,"1. Equip better gear","Crafted and looted equipment goes to Bag. It only changes your stats after you equip it. A stronger weapon shortens fights; armor reduces damage and food use.")
	gear.add_child(U.button("Open equipment bag",func():
		app.dismiss()
		app.set_page("inventory")))
	var workshop = section(v,"2. Improve equipment quality","After First Supplies, the Workshop can improve copper and iron equipment up to Legendary. Each upgrade costs gold, ingots and scraps. Check the required Smithing level before farming materials.")
	workshop.add_child(U.button("Check Workshop costs",app.workshop_dialog))
	var build = section(v,"3. Choose your combat bonuses","Spend talent points. Upgrade a relic, then equip it. After regional hunts, forge and equip a rune. Only one relic and one rune are active at a time.")
	build.add_child(U.button("Review talents",app.talents_dialog))
	build.add_child(U.button("Review relics",app.relics_dialog))
	if m.s.beacon: build.add_child(U.button("Review runes",app.runeforge_dialog))
	var retry = section(v,"4. Check the result","Try one fight with the new build. Open Hunt reports to compare food spent and time taken. Repeat an easier hunt if the next tier is still too costly.")
	retry.add_child(U.button("Open Hunt reports",app.hunt_reports_dialog))
	app.modal_action("Return to my next step",func(): open("next"))
