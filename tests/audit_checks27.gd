extends SceneTree
func _init():
	var m = RealmModel.new()
	var save = RealmSave.new()
	assert(not m.command({"type":"doctrine","id":"blood"}))
	assert(m.command({"type":"upgrade_goal","id":"steel_sword"}))
	assert(RealmUpgradeGoal.status(m).kind=="train")
	for skill in m.data.skills: m.s.xp[skill] = 245025
	assert(RealmUpgradeGoal.status(m).kind=="craft")
	assert(m.command({"type":"plan","id":"craft_steel_sword","amount":1}))
	m.advance(300000)
	assert(RealmUpgradeGoal.status(m).kind=="equip")
	m.command({"type":"equip_best"})
	assert(RealmUpgradeGoal.status(m).kind=="ready")
	assert(not save.decode(save.encode(m.s),m.data).is_empty())
	for metal in ["steel","moonsteel","dusksteel","dawnsteel"]:
		assert(RealmProgression.order_plan(m,metal,1).error=="")
	m.s.settings.food = "cooked_dawnsteel_fish"
	assert(RealmProgression.order_plan(m,"selected_food",1).error=="")
	m.s.kills.apex_wilds_1 = 12
	m.s.kills.wilds_1 = 3
	assert(RealmRuneforge.victories(m,"wilds")==15)
	var enemy = m.data.enemies.apex_crown_3
	var baseline = RealmCombat.player_damage(m,enemy,1)
	var incoming = RealmCombat.move(m,enemy,3,10).damage
	assert(m.command({"type":"doctrine","id":"blood"}))
	assert(RealmCombat.player_damage(m,enemy,1)>baseline and RealmCombat.move(m,enemy,3,10).damage>incoming)
	assert(m.command({"type":"doctrine","id":"bastion"}))
	assert(RealmCombat.player_damage(m,enemy,1)<baseline and RealmCombat.move(m,enemy,3,10).damage<incoming)
	m.s.tutorial = true
	m.s.beacon = true
	m.s.kills.apex_crown_2 = 1
	for part in ["sword","shield","helm","chest","gloves","boots"]: m.gain("dawnsteel_"+part,1,3)
	m.command({"type":"equip_best"})
	m.s.bag.cooked_dawnsteel_fish = 100000
	m.command({"type":"queue","id":"hunt_apex_crown_3","target":1000})
	var copy = RealmModel.new()
	copy.s = save.decode(save.encode(m.s),copy.data)
	var start = Time.get_ticks_msec()
	m.advance(86400000)
	print("Desktop 24h Apex simulation ms: ",Time.get_ticks_msec()-start)
	var left = 86400000
	while left>0: left -= copy.advance(left,4000)
	assert(save.decode(save.encode(m.s),m.data)==save.decode(save.encode(copy.s),copy.data))
	print("AUDIT 27: pinned upgrade, tier supply plans, Apex field progress, doctrine tradeoffs, save round-trip and offline chunk equivalence PASS")
	quit()
