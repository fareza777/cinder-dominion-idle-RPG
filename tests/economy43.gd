extends "res://tests/capture31.gd"

func capture():
	var m = RealmModel.new()
	var save = RealmSave.new()
	assert(m.data.enemies.size()==60 and m.data.items.size()==267 and RealmCards.definitions().size()==60)
	assert(RealmEconomy.money(5000)=="5G" and RealmEconomy.money(1001001)=="1P 1G 1S")
	assert(RealmEconomy.text_value("+1000001 gold")=="+1P 1S")
	var used = {}
	for id in RealmLegacyFinds.GEAR:
		for material in m.data.activities["craft_"+id].inputs: used[material]=true
	for e in m.data.enemies.values():
		assert(used.has(e.rare_material) and m.data.items.has(e.rare_material))
		assert(RealmCards.definitions().has("card_"+e.id))
		assert("hunt_"+e.id in m.sources(e.rare_material))
	var legacy = m.s.duplicate(true)
	legacy.erase("economy_revision")
	legacy.stamina = {"value":0,"rest":0,"paused":true}
	legacy.gold=1234567
	for skill in RealmEconomy.COMBAT: legacy.xp[skill]=25*74*74+500
	var migrated = save.decode(save.encode(legacy),m.data)
	assert(not migrated.is_empty() and not migrated.has("stamina") and migrated.gold==legacy.gold)
	for skill in RealmEconomy.COMBAT: assert(RealmEconomy.level(migrated.xp[skill],skill)==75)
	var again = save.decode(save.encode(migrated),m.data)
	assert(not again.is_empty())
	for skill in migrated.xp: assert(int(again.xp[skill])==int(migrated.xp[skill]),"Migration values are idempotent across JSON int/float decoding")
	assert(RealmEconomy.threshold(100)==2293025 and RealmEconomy.threshold(100,"smithing")==245025)
	# Legacy observed stock retains exact price until its original expiry.
	var stock = RealmMerchant.sync(m,1000)
	stock.erase("pricing")
	stock.tier=3
	stock.offers=[]
	for entry in RealmMerchant.pool(3,0).slice(4,7):
		var offer=entry.duplicate();offer.bought=false;stock.offers.append(offer)
	assert(RealmMerchant.valid(stock))
	assert(not save.decode(save.encode(m.s),m.data).is_empty())
	# No stamina or elapsed-hunt cap: 1,000 starter hunts complete without a resume.
	var farm = RealmModel.new()
	farm.s.tutorial=true
	farm.s.gold=0
	for skill in farm.s.xp: farm.s.xp[skill]=RealmEconomy.threshold(100,skill)
	var sword=farm.add_gear("dawnsteel_sword",5)
	farm.command({"type":"equip","id":sword})
	farm.command({"type":"queue","id":"hunt_ash_rat","target":1000})
	farm.advance(3000000)
	assert(farm.s.kills.get("ash_rat",0)==1000 and farm.s.gold==5000)
	assert(not farm.s.has("stamina") and farm.s.queue.is_empty())
	# Exercise an actual successful rare-material roll at authored odds.
	var random=RandomNumberGenerator.new();random.seed=43
	var found=false
	var combat_rng=farm.s.rng
	var card_rng=farm.s.card_rng
	for i in range(200000):
		var before=random.state
		if random.randf()<.0001:
			farm.s.legacy_rng=str(before)
			assert(RealmLegacyFinds.drop(farm,farm.data.enemies.ash_rat)=="keepsake_fang")
			found=true;break
	assert(found and farm.s.rng==combat_rng and farm.s.card_rng==card_rng)
	# Recipe consumes rare finds once and produces guaranteed Legendary gear.
	var craft=RealmModel.new();craft.s.tutorial=true;craft.s.beacon=true
	craft.s.xp.smithing=245025
	for id in craft.data.enemies: craft.s.kills[id]=1
	for id in RealmLegacyFinds.GEAR:
		var recipe=craft.data.activities["craft_"+id]
		for input in recipe.inputs: craft.gain(input,int(recipe.inputs[input]))
		assert(craft.command({"type":"queue","id":recipe.id,"target":1}))
		craft.advance(60000)
		var pieces=craft.s.gear.filter(func(g): return g.id==id)
		assert(pieces.size()==1 and pieces[0].q==5)
	assert(not save.decode(save.encode(craft.s),craft.data).is_empty())
	craft.s.gold=0
	var empty_wallet=craft.s.duplicate(true)
	assert(not craft.command({"type":"merchant_provisions"}) and craft.s==empty_wallet)
	craft.s.gold=1020000
	var meals_before=craft.count("cooked_dawnsteel_fish")
	assert(craft.command({"type":"merchant_provisions"}))
	assert(craft.s.gold==1000000 and craft.count("cooked_dawnsteel_fish")==meals_before+20)
	assert(craft.command({"type":"buy","id":"masterwork_commission","amount":1}))
	assert(craft.s.gold==0 and not craft.command({"type":"sell","id":"masterwork_commission","amount":1}))
	craft.gain("keepsake_fang",1)
	assert(not craft.command({"type":"sell","id":"keepsake_fang","amount":1}))
	var frontier=RealmModel.new()
	assert(frontier.available("frontier_0_0")!="")
	frontier.s.kills.secret_6=1
	assert(frontier.available("frontier_0_0")=="" and frontier.available("frontier_0_1")!="")
	assert(not frontier.command({"type":"frontier_claim","region":0,"stage":0}))
	frontier.s.kills.frontier_0_0=1;frontier.s.kills.frontier_0_1=1
	var balance=frontier.s.gold
	assert(frontier.command({"type":"frontier_claim","region":0,"stage":0}))
	assert(frontier.s.gold==balance+100000 and not frontier.command({"type":"frontier_claim","region":0,"stage":0}))
	assert(not save.decode(save.encode(frontier.s),frontier.data).is_empty())
	assert(not RealmStory.unlocked(frontier,10))
	frontier.s.kills.frontier_2_5=1
	assert(RealmStory.unlocked(frontier,10) and RealmStory.CHAPTERS.size()==11)
	# New effects and higher combat XP retain deterministic offline event ordering.
	var online = RealmModel.new();online.s=craft.s.duplicate(true)
	online.s.bag.cooked_dawnsteel_fish=1000;online.s.settings.food="cooked_dawnsteel_fish"
	online.command({"type":"queue","id":"hunt_ash_rat","target":100})
	var offline=RealmModel.new();offline.s=online.s.duplicate(true)
	for i in range(120): online.advance(1000)
	offline.advance(120000)
	assert(online.s==offline.s)
	print("PASS 60-enemy content coverage, currency, migration, 1000 unlimited hunts, independent rare drop, ten Legendary crafts, frontier quests and offline equivalence")
	root.size=Vector2i(360,800)
	var scene=PreviewApp.new();root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);scene.set_process(false)
	scene.U.scale=1.3;scene.model.s=craft.s.duplicate(true);scene.model.s.gold=1234567
	scene.set_page("explore")
	preload("res://ui/economy.gd").new(scene).open()
	scene.toast_label.hide();await snap("wallet-narrow-0.43")
	preload("res://ui/masterworks.gd").new(scene).recipe("heirloom_blade")
	await snap("masterwork-recipe-narrow-0.43")
	preload("res://ui/masterworks.gd").new(scene).open(1)
	await snap("masterworks-narrow-0.43")
	preload("res://ui/frontiers.gd").new(scene).open(2)
	await snap("frontier-narrow-0.43")
	preload("res://ui/cards.gd").new(scene).detail("card_frontier_2_5")
	await snap("frontier-card-narrow-0.43")
	preload("res://ui/merchant.gd").new(scene).open()
	await snap("merchant-narrow-0.43")
	preload("res://ui/economy.gd").new(scene).hunts()
	await snap("hunt-rewards-narrow-0.43")
	print("PASS seven phone captures")
	quit()
