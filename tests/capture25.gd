extends "res://tests/capture.gd"
func tagged(node: Node,key: String,value):
	if node.has_meta(key) and node.get_meta(key)==value: return node
	for child in node.get_children():
		var found = tagged(child,key,value)
		if found!=null: return found
	return null
func scroll_of(node: Node):
	if node is ScrollContainer: return node
	for child in node.get_children():
		var found = scroll_of(child)
		if found!=null: return found
	return null
func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	var m = scene.model
	var paths = preload("res://ui/ascension.gd").new(scene)
	scene.skill = "smithing"
	scene.set_page("skills")
	await snap("ascension-skill-filter-0.25")
	paths.open()
	await snap("ascension-locked-0.25")
	for skill in m.data.skills: m.s.xp[skill] = 245025
	m.s.tutorial = true
	m.s.beacon = true
	paths.open(3)
	await snap("ascension-dawn-0.25")
	tagged(scene.dialog,"ascension_recipe","dawnsteel_sword").emit_signal("pressed")
	await snap("ascension-material-plan-0.25")
	scene.dialog_footer.get_children()[0].emit_signal("pressed")
	m.advance(300000)
	assert(m.count("dawnsteel_sword")==1)
	var uid = ""
	for gear in m.s.gear:
		if gear.id=="dawnsteel_sword": uid = gear.uid
	scene.item_dialog(uid)
	scene.toast_label.hide()
	await snap("ascension-sword-0.25")
	scene.dialog_footer.get_children()[0].emit_signal("pressed")
	assert(m.s.equipped.weapon==uid)
	scene.toast_label.hide()
	paths.hunts()
	await snap("ascension-apex-0.25")
	scroll_of(scene.dialog).scroll_vertical = 2500
	await snap("ascension-crown-0.25")
	scene.dismiss()
	for part in ["shield","helm","chest","gloves","boots"]: m.gain("dawnsteel_"+part,1,3)
	m.command({"type":"equip_best"})
	m.s.bag.cooked_dawnsteel_fish = 100
	m.s.settings.food = "cooked_dawnsteel_fish"
	m.s.gains.merge({"copper_ore":4,"copper_ingot":2,"ash_log":1,"copper_sword":1},true)
	for enemy in m.data.enemies: m.s.kills[enemy] = 5
	m.s.kills.apex_crown_3 = 0
	m.s.kills.apex_crown_2 = 1
	m.command({"type":"queue","id":"hunt_apex_crown_3","target":1})
	m.advance(1000)
	scene.set_page("explore")
	scene.refresh()
	scene.toast_label.hide()
	await snap("ascension-battle-0.25")
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	paths.open(1)
	await snap("ascension-narrow-0.25")
	print("UI: new tier plans, crafts and equips a sword; Apex route/battle and 130% text captured.")
	quit()
