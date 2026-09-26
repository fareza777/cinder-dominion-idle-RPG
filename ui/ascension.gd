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
	banner.custom_minimum_size.y = 150
	v.add_child(banner)
	v.add_child(U.para(PLACES[tier],25,U.GOLD))
	v.add_child(U.para("Gather → Forge → Equip → Apex hunt",14,U.TEXT))
	var metal = METALS[tier]
	var needs = U.card(v,12)
	needs.add_child(U.para("Start this tier · Lv.%d" % LEVELS[tier],18,U.TEXT))
	for skill in ["mining","woodcutting","smithing"]:
		var row = U.row(6)
		needs.add_child(row)
		row.add_child(U.para("%s · %d / %d" % [m.local_name(m.data.skills[skill]),m.level(skill),LEVELS[tier]],14,U.GREEN if m.level(skill)>=LEVELS[tier] else U.MUTED))
		if m.level(skill)<LEVELS[tier]: row.add_child(U.button("Train",func(): preload("res://ui/gameplay.gd").new(app).training(skill,LEVELS[tier])))
	var sword = m.data.items[metal+"_sword"]
	v.add_child(U.para("Common sword · %d ATK" % sword.attack,18,U.GOLD))
	for part in ["sword","shield","helm","chest","gloves","boots","axe","pick","rod"]:
		var id = metal+"_"+part
		var recipe = m.data.activities["craft_"+id]
		var c = U.card(v,12)
		var row = U.row(10)
		c.add_child(row)
		row.add_child(U.icon(id,58))
		row.add_child(U.para("%s\nSmithing Lv.%d · owned %d" % [m.name_of(id),recipe.level,m.count(id)],16,U.TEXT))
		var plan_button = U.button("Plan materials & craft",func(): app.planner_dialog("craft_"+id,1))
		plan_button.set_meta("ascension_recipe",id)
		c.add_child(plan_button)
	var food = "cooked_"+metal+"_fish"
	v.add_child(U.para("Camp supplies · heals %d HP" % m.data.items[food].heal,18,U.GREEN))
	v.add_child(U.button("Prepare 10 "+m.name_of(food),func(): app.planner_dialog("craft_"+food,10)))
	v.add_child(U.button("Refine forged equipment",app.workshop_dialog))
	app.modal_action("View Apex hunts",hunts)
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
