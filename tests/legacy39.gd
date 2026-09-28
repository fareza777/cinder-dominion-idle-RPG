extends "res://tests/capture31.gd"

func capture():
	var m = RealmModel.new()
	m.s.tutorial = true
	var c = RealmChronicle.state(m)
	var save = RealmSave.new()
	for skill in m.s.xp: m.s.xp[skill] = 245025
	assert(RealmChronicle.points_earned(m)==10,"Weak-enemy XP alone cannot unlock later points")
	assert(not save.decode(save.encode(m.s),m.data).is_empty(),"Legacy talent keys remain valid")
	assert(not m.command({"type":"talent","id":"technique"}))
	for enemy in RealmLegacyGrowth.GATES: m.s.kills[enemy] = 1
	assert(RealmChronicle.points_earned(m)==60)
	for i in range(10): assert(m.command({"type":"talent","id":"technique"}))
	assert(not m.command({"type":"talent","id":"technique"}),"Rank cap enforced")
	assert(RealmLegacyGrowth.outgoing(m,m.data.enemies.ash_rat,4,1000)==1050)
	assert(RealmLegacyGrowth.outgoing(m,m.data.enemies.ash_rat,3,1000)==1000)
	assert(m.command({"type":"loadout_save","id":"journey"}))
	assert(not save.decode(save.encode(m.s),m.data).is_empty())
	assert(m.command({"type":"talent_reset"}))
	assert(RealmChronicle.points_free(m)==60)
	assert(m.command({"type":"loadout_load","id":"journey"}))
	assert(RealmLegacyGrowth.rank(m,"technique")==10)
	c.relics.fang = 10
	c.relic = "fang"
	c.fragments.fang = 100000
	var before = m.s.duplicate(true)
	assert(not m.command({"type":"relic_upgrade","id":"fang"}))
	assert(m.s==before,"Missing essence cannot partially debit fragments")
	m.gain("essence_fang",2000)
	assert(m.command({"type":"relic_upgrade","id":"fang"}))
	assert(c.relics.fang==11 and m.count("essence_fang")==1998)
	assert(RealmLegacyGrowth.relic_base(40,2)==20,"Late ranks do not quadruple base armor/attack")
	c.relics.fang = 20
	assert(not m.command({"type":"relic_upgrade","id":"fang"}),"Trial ascension is gated")
	m.s.kills.trial_wilds = 1
	assert(m.command({"type":"relic_upgrade","id":"fang"}))
	c.relics.fang = 30
	m.s.kills.secret_4 = 1
	assert(not m.command({"type":"relic_upgrade","id":"fang"}),"Final ascension requires a guardian core")
	m.gain("core_4",10)
	for i in range(10): assert(m.command({"type":"relic_upgrade","id":"fang"}))
	assert(c.relics.fang==40 and m.count("core_4")==0)
	assert(not m.command({"type":"relic_upgrade","id":"fang"}))
	assert(not save.decode(save.encode(m.s),m.data).is_empty())
	assert(RealmLegacyGrowth.essence(m.data.enemies.ash_rat)==0)
	assert(RealmLegacyGrowth.essence(m.data.enemies.wilds_3)==1)
	assert(RealmLegacyGrowth.essence(m.data.enemies.trial_wilds)==2)
	assert(RealmLegacyGrowth.essence(m.data.enemies.secret_4)==3)
	var a = RealmModel.new()
	a.s = m.s.duplicate(true)
	a.s.beacon = true
	a.s.kills.wilds_2 = 1
	a.gain("cooked_dawnsteel_fish",100)
	a.s.settings.food = "cooked_dawnsteel_fish"
	assert(a.command({"type":"queue","id":"hunt_wilds_3","target":2}))
	var b = RealmModel.new()
	b.s = a.s.duplicate(true)
	a.advance(180000)
	for i in range(180): b.advance(1000)
	assert(a.s==b.s,"Ascended combat, rewards and essence agree across time chunks")
	assert(a.count("essence_fang")>m.count("essence_fang"))
	print("PASS late talent milestones, loadouts, relic gates/costs, bounded bonuses and offline combat")
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.model.s = m.s.duplicate(true)
	scene.talents_dialog()
	scene.toast_label.hide()
	await snap("legacy-talents-0.39")
	scene.relics_dialog()
	await snap("legacy-relics-0.39")
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	scene.model.s.chronicle.relics.fang = 10
	scene.relics_dialog()
	await snap("legacy-relics-narrow-0.39")
	preload("res://ui/relic_farm.gd").new(scene).open("fang")
	await snap("legacy-farm-narrow-0.39")
	print("PASS late progression phone captures")
	quit()
