extends RefCounted
const U = preload("res://ui/style.gd")
const METALS = ["steel","moonsteel","dusksteel","dawnsteel"]
const LEVELS = [25,45,65,85]
const PLACES = ["Blackpine Foundry","Moonwater Reach","The Dusk Mines","The Dawn Forge"]
var app
var m
func _init(owner):
	app = owner
	m = app.model
func open(tier: int = 0):
	var v = app.modal("Ascension paths")
	var tabs = U.row(4)
	v.add_child(tabs)
	for i in range(4): tabs.add_child(U.button(["Steel","Moon","Dusk","Dawn"][i],func(): open(i),i==tier))
	var banner = TextureRect.new()
	banner.texture = U.atlas_tile("res://assets/art/ascension-places-0.25.png",tier,2,2)
	banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	banner.custom_minimum_size.y = 92
	v.add_child(banner)
	v.add_child(U.para(PLACES[tier],22,U.GOLD))
	v.add_child(U.para("Gather → Forge → Equip → Apex hunt",14,U.TEXT))
	v.add_child(U.button("Browse Apex hunts",hunts))
	var metal = METALS[tier]
	v.add_child(U.para(RealmGearSets.ALL[metal].name+" · Equip 2 armor pieces",18,U.GOLD))
	v.add_child(U.para(RealmGearSets.ALL[metal].effect,14))
	var needs = U.card(v,12)
	needs.add_child(U.para("Start this tier · Lv.%d" % LEVELS[tier],18,U.TEXT))
	for skill in ["mining","woodcutting","smithing"]:
		var row = U.row(6)
		needs.add_child(row)
		app.dynamic(row,func(): return "%s · %d / %d%s" % [m.local_name(m.data.skills[skill]),m.level(skill),LEVELS[tier]," · ✓" if m.level(skill)>=LEVELS[tier] else ""],14,U.TEXT)
		var train = U.button("Train",func(): preload("res://ui/gameplay.gd").new(app).training(skill,LEVELS[tier]))
		row.add_child(train)
		var update_train = func():
			if is_instance_valid(train): train.visible = m.level(skill)<LEVELS[tier]
		app.dialog_callbacks.append(update_train)
		update_train.call()
	var sword = m.data.items[metal+"_sword"]
	v.add_child(U.para("Common sword · %d ATK" % sword.attack,18,U.GOLD))
	for part in ["sword","shield","helm","chest","gloves","boots","axe","pick","rod"]:
		var id = metal+"_"+part
		var recipe = m.data.activities["craft_"+id]
		var c = U.card(v,12)
		var row = U.row(10)
		c.add_child(row)
		row.add_child(U.icon(id,58))
		app.dynamic(row,func(): return "%s\nSmithing Lv.%d · owned %d" % [m.name_of(id),recipe.level,m.count(id)],16,U.TEXT)
		var plan_button = U.button("Plan materials & craft",func(): app.planner_dialog("craft_"+id,1))
		plan_button.set_meta("ascension_recipe",id)
		c.add_child(plan_button)
		c.add_child(U.button("Track upgrade",func():
			if app.send({"type":"upgrade_goal","id":id}): preload("res://ui/upgrade_goal.gd").new(app).open()))
	var food = "cooked_"+metal+"_fish"
	v.add_child(U.para("Camp supplies · heals %d HP" % m.data.items[food].heal,18,U.GREEN))
	v.add_child(U.button("Prepare 10 "+m.name_of(food),func(): app.planner_dialog("craft_"+food,10)))
	v.add_child(U.button("Refine forged equipment",app.workshop_dialog))
	var next = app.modal_action("Next step",func(): follow_step(tier))
	var update_next = func():
		if is_instance_valid(next): next.text = next_step(tier).label
	app.dialog_callbacks.append(update_next)
	update_next.call()
func hunts():
	var v = app.modal("Apex hunts")
	v.add_child(U.para("Clear a Guardian Trial to open its Apex route. Repeat hunts for advanced ore and relic fragments.",15,U.TEXT))
	for id in m.data.enemies:
		var enemy = m.data.enemies[id]
		if not enemy.get("apex",false): continue
		var card = U.card(v,14)
		var row = U.row(12)
		card.add_child(row)
		row.add_child(U.enemy_portrait(enemy,Vector2(88,110)))
		var words = U.column(5)
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(words)
		words.add_child(U.para(m.local_name(enemy),20,U.GOLD))
		words.add_child(U.para("%d HP · %d ATK · %d DEF" % [enemy.hp,enemy.attack,enemy.armor],13))
		card.add_child(U.para("%s ×%d · %d fragments / win" % [m.name_of(enemy.drop),enemy.qty,RealmHuntMastery.fragments(m,enemy)],14,U.GREEN))
		card.add_child(U.para(RealmCombat.mechanic(enemy),13))
		var reason = m.available(id)
		if reason!="": card.add_child(U.para(reason,13,U.MUTED))
		else: card.add_child(U.button("Plan this hunt",func(): app.hunt_plan_dialog(id),true))
	app.modal_action("Prepare better equipment",open)

func weapon_attack(gear: Dictionary) -> float:
	return 0.0 if gear.is_empty() else float(m.data.items[gear.id].attack)*RealmModel.QUALITY[int(gear.q)]

func next_step(tier: int) -> Dictionary:
	if not m.s.queue.is_empty(): return {"kind":"queue","label":"View current work"}
	var id = METALS[tier]+"_sword"
	var current = m.gear(str(m.s.equipped.get("weapon","")))
	if weapon_attack(current)>=float(m.data.items[id].attack):
		for enemy in m.data.enemies.values():
			if enemy.get("apex",false) and m.available(enemy.id)=="": return {"kind":"hunts","label":"Review Apex hunts"}
		return {"kind":"journey","label":"Continue Journey · unlock Apex hunts"}
	var best = {}
	for gear in m.s.gear:
		if gear.id==id and (best.is_empty() or weapon_attack(gear)>weapon_attack(best)): best = gear
	if not best.is_empty():
		if weapon_attack(best)>weapon_attack(current): return {"kind":"equip","label":"Review & equip "+m.name_of(id),"id":best.uid}
		return {"kind":"refine","label":"Refine "+m.name_of(id),"id":best.uid}
	for skill in ["mining","woodcutting","smithing"]:
		if m.level(skill)<LEVELS[tier]: return {"kind":"train","label":"Train %s · Lv.%d" % [m.local_name(m.data.skills[skill]),LEVELS[tier]],"id":skill}
	return {"kind":"craft","label":"Plan "+m.name_of(id),"id":id}

func follow_step(tier: int):
	var step = next_step(tier)
	match step.kind:
		"queue": app.queue_dialog()
		"journey": app.guide_dialog()
		"hunts": hunts()
		"equip": app.item_dialog(step.id)
		"refine": preload("res://ui/armory.gd").new(app).workshop(step.id)
		"train": preload("res://ui/gameplay.gd").new(app).training(step.id,LEVELS[tier])
		"craft": app.planner_dialog("craft_"+step.id,1)
