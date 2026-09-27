extends SceneTree
const Audit = preload("res://tests/balance34.gd")
var failed = 0
var passed = 0
func check(value: bool, label: String):
	if value: passed += 1
	else: failed += 1; push_error(label)

class AdApp extends Node:
	var model = RealmModel.new()
	var saves = 0
	func persist(): saves += 1
	func toast(_text): pass
class DemoAd extends RefCounted:
	var full_screen_content_callback
	var listener
	func show(value): listener = value
	func destroy(): pass

func _init(): call_deferred("run")
func run():
	var store = RealmSave.new()
	var fresh = RealmModel.new()
	check(not fresh.command({"type":"assist_start","id":"ash_rat"}),"No free queue assistance")
	check(RealmDiscovery.enemies(fresh)==["ash_rat"],"Secret enemies hidden on new game")
	check(fresh.requirement("craft_relic_0").contains("blueprint"),"Blueprint cannot bypass guardian")
	check(not store.decode(store.encode(fresh.s),fresh.data).is_empty(),"Legacy/new save with optional assistance")
	var m = Audit.build("warden","max")
	m.s.kills.secret_0 = 0
	var before_tokens = m.count("dread_token")
	var outcome = Audit.fight(m,"secret_0")
	check(outcome.win and m.count("core_0")==3 and m.count("dread_token")==before_tokens+2,"First clear grants blueprint cores and seals")
	check(m.last_reward.contains("×3") and m.last_reward.contains("Blueprint learned"),"First-clear reward text matches inventory")
	check(m.available("secret_1")=="","Next guardian discovered")
	m.s.kills.secret_0 = 7
	m.s.bag.dread_token = 16
	check(not m.command({"type":"end_trade","id":"relic_0"}) and m.count("dread_token")==16,"Pity cannot be bought early")
	m.s.kills.secret_0 = 8
	check(m.command({"type":"end_trade","id":"relic_0"}) and m.count("dread_token")==0,"Eight wins guarantee named relic")
	for key in ["blank_0","relic_0"]:
		var recipe = m.data.activities["craft_"+key]
		for id in recipe.inputs: m.gain(id,int(recipe.inputs[id]))
		var before = m.count(key)
		m.command({"type":"queue","id":recipe.id,"target":1})
		m.advance(30000)
		check(m.count(key)==before+1,"Two-stage crafting "+key)
	check(m.command({"type":"path_choose","choice":0}),"Choose specialization")
	m.gain("socket_shelter",1)
	check(m.command({"type":"socket_toggle","id":"shelter"}),"Socket third relic after guardian five")
	check(not m.command({"type":"sell","id":"socket_shelter"}),"Cannot sell last equipped socket relic")
	m.command({"type":"loadout_save","id":"journey"})
	m.command({"type":"socket_toggle","id":"shelter"})
	m.command({"type":"path_choose","choice":1})
	check(m.command({"type":"loadout_load","id":"journey"}) and m.s.path_choice==0 and "shelter" in m.s.sockets,"Loadout restores path and sockets")
	check(not store.decode(store.encode(m.s),m.data).is_empty(),"Endgame build saves through JSON")
	var wrong = m.s.duplicate(true)
	wrong.sockets = ["ember","ember"]
	check(not store.valid(wrong,m.data),"Duplicate socket rejected")
	var unique = m.s.gear.filter(func(g): return g.id=="relic_0" and g.q==1)[0]
	m.s.bag.dread_token = 100
	m.s.bag.depth_shard = 100
	m.command({"type":"equip","id":unique.uid})
	m.command({"type":"loadout_save","id":"journey"})
	check(m.command({"type":"end_temper","id":unique.uid}) and m.gear(m.s.equipped.weapon).q==2 and m.s.loadouts.journey.gear.weapon==m.s.equipped.weapon,"Tempering preserves loadout references")
	var d = RealmEndgame.state(m).depth
	d.active = true
	d.floor = 1
	m.command({"type":"queue","id":"hunt_hollow_depth","target":1})
	check(not m.command({"type":"end_bank"}),"Cannot bank during battle")
	m.advance(600000)
	check(d.floor==2 and d.stash==2 and m.count("depth_shard")==80,"Depth rewards stay unbanked")
	check(m.command({"type":"end_bank"}) and m.count("depth_shard")==82 and not d.active,"Bank credits once and ends expedition")
	m.command({"type":"end_bank"})
	check(m.count("depth_shard")==82,"Bank cannot duplicate shards")
	d.active = true; d.floor = 50; d.stash = 9
	m.command({"type":"queue","id":"hunt_hollow_depth","target":1})
	m.advance(600000)
	check(not d.active and d.stash==0 and m.count("depth_shard")==82,"Deep defeat loses escrow only")
	check(m.last_reward.contains("Unbanked shards lost"),"Depth defeat explains loss")
	var contracts = RealmModel.new()
	contracts.s.wall = 1790000000000
	check(contracts.command({"type":"end_contract","id":"gather"}),"Select contract")
	contracts.s.mastery.mine_copper = 60
	check(contracts.command({"type":"end_claim","id":"gather"}) and not contracts.command({"type":"end_claim","id":"gather"}),"Contract claimed once")
	contracts.command({"type":"end_contract","id":"craft"})
	contracts.s.wall += 86400000
	check("craft" in RealmEndgame.state(contracts).board.selected,"Incomplete contract carries over")
	contracts.command({"type":"end_contract","id":"hunt"})
	contracts.s.mastery.craft_copper_ingot = 25
	contracts.s.kills.ash_rat = 12
	contracts.command({"type":"end_claim","id":"craft"})
	contracts.command({"type":"end_claim","id":"hunt"})
	contracts.s.wall += 86400000
	check(contracts.command({"type":"end_contract","id":"gather"}) and RealmEndgame.state(contracts).board.selected==["gather"],"Completed board rotates on later day")
	contracts.s.kills.secret_0 = 1
	check(contracts.command({"type":"end_week"}),"Accept weekly guardian")
	contracts.s.kills.secret_0 += 3
	check(contracts.command({"type":"end_week_claim"}) and not contracts.command({"type":"end_week_claim"}),"Weekly reward exactly once")
	var mastery = RealmModel.new()
	mastery.s.mastery.mine_copper = 249
	mastery.command({"type":"queue","id":"mine_copper","target":1})
	mastery.advance(3000)
	check(mastery.count("copper_ore")==2,"250 mastery bonus yields extra material")
	mastery.s.mastery.mine_copper = 1004
	mastery.command({"type":"queue","id":"mine_copper","target":1})
	mastery.advance(3000)
	check(mastery.count("copper_ore")==4,"1000 mastery bonus every fifth completion")
	var assisted = RealmModel.new()
	RealmAutomation.earned(assisted) # Fixture only: real UI has no grant command.
	assisted.s.bag.cooked_minnow = 1000
	check(assisted.command({"type":"assist_start","id":"ash_rat"}),"Earned lease enables assistance")
	var copy = RealmModel.new()
	copy.s = store.decode(store.encode(assisted.s),copy.data)
	assisted.advance(600000)
	for i in range(600): copy.advance(1000)
	check(store.decode(store.encode(assisted.s),assisted.data)==store.decode(store.encode(copy.s),copy.data),"Assistance offline/chunk/save equivalence")
	var lease = RealmAutomation.state(assisted)
	lease.until = int(assisted.s.time)+1000
	assisted.advance(60000)
	check(not lease.enabled and assisted.s.queue.is_empty(),"Lease expiry finishes cycle then stops")
	var owner = AdApp.new()
	root.add_child(owner)
	var ads = preload("res://services/admob.gd").new()
	ads.app = owner
	owner.add_child(ads)
	ads.request("rewarded","automation")
	check(RealmAutomation.state(owner.model).until==0,"Unavailable desktop ad grants nothing")
	ads.reward_placement = "automation"
	ads.request_journey = owner.model.s
	var ad = DemoAd.new()
	ads.show_fullscreen(ad,true,ads.generation)
	ad.listener.on_user_earned_reward.call(null)
	ad.listener.on_user_earned_reward.call(null)
	check(owner.saves==1 and RealmAutomation.state(owner.model).until==14400000,"Earned callback granted once, duplicates ignored")
	ad.full_screen_content_callback.on_ad_dismissed_full_screen_content.call()
	ads.request_journey = owner.model.s
	var stale = DemoAd.new()
	ads.show_fullscreen(stale,true,ads.generation)
	owner.model.fresh()
	stale.listener.on_user_earned_reward.call(null)
	check(RealmAutomation.state(owner.model).until==0,"Stale ad callback cannot reward new journey")
	stale.full_screen_content_callback.on_ad_dismissed_full_screen_content.call()
	owner.queue_free()
	print("ENDGAME 34: ",passed," passed, ",failed," failed")
	quit(1 if failed else 0)
