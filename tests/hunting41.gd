extends "res://tests/capture31.gd"

func capture():
	var m = RealmModel.new()
	var save = RealmSave.new()
	assert(not save.decode(save.encode(m.s),m.data).is_empty())
	assert(RealmCards.definitions().size()==60)
	for enemy in m.data.enemies: assert(RealmCards.definitions().has("card_"+enemy))
	var uid = m.add_gear("copper_sword",1)
	m.add_gear("copper_sword",1)
	m.gain("card_ember_wraith",1)
	assert(m.command({"type":"card_insert","uid":uid,"id":"card_ember_wraith"}))
	assert(m.gear(uid).count==1 and m.count("card_ember_wraith")==0)
	assert(m.protected(uid) and not m.command({"type":"merchant_sell","id":uid}))
	assert(m.command({"type":"equip","id":uid}))
	assert(RealmCards.active(m)==["card_ember_wraith"])
	m.s.tutorial = true
	m.s.xp.smithing = 245025
	m.s.gold = 10000
	m.gain("scrap",100)
	m.gain("copper_ingot",100)
	assert(RealmWorkshop.command(m,uid)=="")
	uid = m.last_forged
	assert(m.s.card_sockets[uid]=="card_ember_wraith")
	assert(not m.command({"type":"card_remove","uid":uid}))
	m.gain("card_extractor",1)
	assert(m.command({"type":"card_remove","uid":uid}))
	assert(m.count("card_ember_wraith")==1 and m.count("card_extractor")==0)
	assert(m.command({"type":"card_insert","uid":uid,"id":"card_ember_wraith"}))
	assert(not save.decode(save.encode(m.s),m.data).is_empty())
	assert(m.command({"type":"queue","id":"hunt_ash_rat","target":2}))
	for effect in RealmAfflictions.ALL: RealmAfflictions.apply(m,"enemy",effect,1)
	assert(RealmAfflictions.valid(m.s.fight))
	var immunity = int(m.s.fight.effects.immune_enemy)
	RealmAfflictions.apply(m,"enemy","stun")
	assert(m.s.fight.effects.immune_enemy==immunity,"Control cannot chain during immunity")
	assert(not save.decode(save.encode(m.s),m.data).is_empty())
	var b = RealmModel.new()
	b.s = m.s.duplicate(true)
	m.advance(120000)
	for i in range(120): b.advance(1000)
	assert(m.s==b.s,"Effects, card RNG, and rewards agree across offline chunks")
	assert(not save.decode(save.encode(m.s),m.data).is_empty())
	# Independent card RNG must not mutate the combat RNG stream.
	var rng_before = m.s.rng
	for i in range(1000): RealmCards.drop(m,"ash_rat")
	assert(m.s.rng==rng_before)
	assert(RealmCards.definitions().card_ash_rat.chance==.0002)
	assert(RealmCards.definitions().card_secret_6.chance==.00002)
	var probe = RandomNumberGenerator.new()
	probe.seed = 41
	var found = false
	for i in range(100000):
		var before_roll = probe.state
		if probe.randf()<.0002:
			m.s.card_rng = str(before_roll)
			var count_before = m.count("card_ash_rat")
			assert(RealmCards.drop(m,"ash_rat")=="card_ash_rat")
			assert(m.count("card_ash_rat")==count_before+1)
			found = true
			break
	assert(found,"Exercise an actual successful rare roll without altering production odds")
	var shop = RealmModel.new()
	var tempered = RealmModel.new()
	tempered.s.gold = 1000000
	var relic_uid = tempered.add_gear("relic_0",1)
	tempered.gain("card_ash_rat",1)
	assert(tempered.command({"type":"card_insert","uid":relic_uid,"id":"card_ash_rat"}))
	tempered.gain("dread_token",100)
	tempered.gain("depth_shard",100)
	assert(tempered.command({"type":"end_temper","id":relic_uid}))
	assert(tempered.s.card_sockets.size()==1 and not tempered.s.card_sockets.has(relic_uid))
	var new_uid = tempered.s.card_sockets.keys()[0]
	assert(tempered.gear(new_uid).q==2 and tempered.s.card_sockets[new_uid]=="card_ash_rat")
	assert(not save.decode(save.encode(tempered.s),tempered.data).is_empty())
	shop.s.gold = 1000000
	shop.s.xp.smithing = 245025
	shop.s.kills.crown_5 = 1
	var stock = RealmMerchant.sync(shop,1790600000000)
	var offer = RealmMerchant.pool(3).filter(func(o): return o.id=="card_ash_rat")[0].duplicate()
	offer.bought = false
	stock.offers[2] = offer
	# Remove a possible naturally selected duplicate from this explicit purchase fixture.
	stock.offers[0] = {"id":"scrap","qty":12,"price":180,"quality":1,"bought":false}
	stock.offers[1] = {"id":"healing_draught","qty":3,"price":120,"quality":1,"bought":false}
	assert(RealmMerchant.valid(stock))
	assert(shop.command({"type":"merchant_buy","index":2,"revision":stock.revision,"now":1790600000000}))
	assert(shop.count("card_ash_rat")==1 and shop.s.gold==900000)
	assert(shop.command({"type":"sell","id":"card_ash_rat","amount":1}))
	assert(shop.s.gold==920000 and shop.count("card_ash_rat")==0)
	print("PASS 60-card coverage, ownership, refinement, extraction, status save and offline equivalence")
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.model.s = m.s.duplicate(true)
	scene.model.s.kills.ember_wraith = 1
	preload("res://ui/cards.gd").new(scene).detail("card_ember_wraith")
	scene.toast_label.hide()
	await snap("card-detail-0.41")
	preload("res://ui/cards.gd").new(scene).socket(uid)
	await snap("card-socket-0.41")
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	preload("res://ui/cards.gd").new(scene).collection()
	await snap("card-collection-narrow-0.41")
	scene.dismiss()
	scene.model.command({"type":"clear"})
	scene.model.command({"type":"queue","id":"hunt_ash_rat","target":1})
	RealmAfflictions.apply(scene.model,"enemy","burn",1)
	RealmAfflictions.apply(scene.model,"hero","barrier",2)
	scene.set_page("explore")
	scene.toast_label.hide()
	await snap("battle-effects-narrow-0.41")
	print("PASS hunting phone captures")
	quit()
