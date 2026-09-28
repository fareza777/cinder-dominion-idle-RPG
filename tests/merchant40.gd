extends "res://tests/capture31.gd"

func capture():
	var m = RealmModel.new()
	var save = RealmSave.new()
	var now = 1790600000000
	var combat_rng = m.s.rng
	var stock = RealmMerchant.sync(m,now)
	assert(m.s.rng==combat_rng and RealmMerchant.valid(stock))
	assert(stock.offers.size()==3 and stock.tier==0)
	var original = stock.duplicate(true)
	assert(RealmMerchant.sync(m,now-100000)==original,"Clock rollback cannot reroll stock")
	m.s.gold = 0
	assert(not m.command({"type":"merchant_buy","index":0,"revision":stock.revision,"now":now}))
	assert(not stock.offers[0].bought)
	m.s.gold = 100000
	var price = int(stock.offers[0].price)
	assert(m.command({"type":"merchant_buy","index":0,"revision":stock.revision,"now":now}))
	assert(m.s.gold==100000-price)
	assert(not m.command({"type":"merchant_buy","index":0,"revision":stock.revision,"now":now}))
	var restored = save.decode(save.encode(m.s),m.data)
	assert(not restored.is_empty() and restored.merchant_stock.offers[0].bought)
	m.s = restored
	assert(RealmMerchant.sync(m,now+1000).offers[0].bought)
	var revision = int(m.s.merchant_stock.revision)
	m.s.xp.smithing = 245025
	m.s.kills.crown_5 = 1
	assert(RealmMerchant.sync(m,now+2000).tier==0,"Unlocks do not reroll active offers")
	var later = now+RealmMerchant.INTERVAL*4
	stock = RealmMerchant.sync(m,later)
	assert(stock.tier==3 and stock.until==later+RealmMerchant.INTERVAL)
	assert(not m.command({"type":"merchant_buy","index":0,"revision":revision,"now":later}),"Stale purchase cannot buy a new offer")
	assert(not save.decode(save.encode(m.s),m.data).is_empty())
	for entry in RealmMerchant.pool(3):
		if m.data.items[entry.id].category=="equipment":
			assert(RealmMerchant.sell_price(m,{"id":entry.id,"q":entry.quality})<entry.price)
	var uid = m.add_gear("steel_ring",3)
	assert(m.command({"type":"equip","id":uid,"slot":"ring_left"}))
	assert(not m.command({"type":"merchant_sell","id":uid}))
	m.s.equipped.erase("ring_left")
	m.gear(uid).favorite = true
	assert(not m.command({"type":"merchant_sell","id":uid}))
	m.gear(uid).favorite = false
	var gold_before = int(m.s.gold)
	var sale = RealmMerchant.sell_price(m,m.gear(uid))
	assert(m.command({"type":"merchant_sell","id":uid}))
	assert(m.gear(uid).is_empty() and m.s.gold==gold_before+sale)
	assert(not m.command({"type":"merchant_sell","id":uid}))
	print("PASS merchant persistence, stock limits, stale orders, clock rollback, progression gates and protected sales")
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.model.s = m.s.duplicate(true)
	# Presentation fixture: real pool entry shown independently of random stock selection.
	scene.model.s.merchant_stock.offers = []
	for entry in RealmMerchant.pool(3).slice(4,7):
		var offer = entry.duplicate(true)
		offer.bought = false
		scene.model.s.merchant_stock.offers.append(offer)
	scene.model.s.merchant_stock.seen = scene.now_ms()
	scene.model.s.merchant_stock.until = scene.now_ms()+RealmMerchant.INTERVAL
	scene.merchant_dialog()
	scene.toast_label.hide()
	await snap("merchant-stock-0.40")
	var ingots = scene.model.count("dawnsteel_ingot")
	button_text(scene.dialog,"Buy bundle · 1200 gold").emit_signal("pressed")
	assert(scene.model.count("dawnsteel_ingot")==ingots+8)
	assert(scene.model.s.merchant_stock.offers[0].bought and not scene.model.s.merchant_stock.offers[1].bought,"UI buys the selected offer")
	scene.U.scale = 1.3
	root.size = Vector2i(360,800)
	scene.merchant_dialog()
	await snap("merchant-stock-narrow-0.40")
	uid = scene.model.add_gear("steel_ring",3)
	preload("res://ui/merchant.gd").new(scene).confirm_sale(uid)
	await snap("merchant-sale-narrow-0.40")
	button_text(scene.dialog,"Sell one piece").emit_signal("pressed")
	assert(scene.model.gear(uid).is_empty(),"Sale confirmation is wired to the chosen item")
	print("PASS merchant phone captures")
	quit()
