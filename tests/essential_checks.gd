extends SceneTree

var failed = 0
func check(ok: bool, label: String):
	if not ok:
		failed += 1
		push_error(label)
	else: print("PASS ",label)

func _init():
	var m = RealmModel.new()
	check(m.data.items.size()==40,"40 item definitions")
	m.command({"type":"queue","id":"mine_copper","target":4})
	m.advance(12000)
	check(m.count("copper_ore")==4,"gather four ore")
	m.command({"type":"queue","id":"craft_copper_ingot","target":2})
	m.advance(6000)
	check(m.count("copper_ore")==0 and m.count("copper_ingot")==2,"craft consumes once")
	m.command({"type":"queue","id":"craft_copper_sword","target":1})
	check(m.count("copper_ingot")==2,"missing ingredient cannot partially debit")
	m.command({"type":"clear"})
	var a = RealmModel.new()
	a.command({"type":"queue","id":"hunt_ash_rat","target":100})
	var b = RealmModel.new()
	b.s = a.s.duplicate(true)
	a.advance(60000)
	for i in range(60): b.advance(1000)
	check(a.s==b.s,"combat offline/chunks agree")
	var store = RealmSave.new()
	m.s.wall = 1790000000000
	check(store.valid(m.s,m.data),"valid current timestamp")
	var restored = store.decode(store.encode(m.s),m.data)
	check(not restored.is_empty() and restored.rng==m.s.rng,"save roundtrip retains RNG")
	var bad = m.s.duplicate(true)
	bad.bag.copper_ore = -1
	check(store.decode(store.encode(bad),m.data).is_empty(),"reject corrupted negative inventory")
	var once = RealmModel.new()
	var buy = {"type":"buy","id":"empty_vial","amount":1,"cid":"same"}
	once.command(buy)
	once.command(buy)
	check(once.count("empty_vial")==1 and once.s.gold==18,"duplicate command is idempotent")
	var guided = RealmModel.new()
	check(guided.s.settings.locale=="en" and guided.objective().key=="ore","English default with concrete first objective")
	for activity in [["mine_copper",4,12000],["craft_copper_ingot",2,6000],["cut_ash",1,3000],["craft_copper_sword",1,5000]]:
		guided.command({"type":"queue","id":activity[0],"target":activity[1]})
		guided.advance(activity[2])
	check(guided.objective().key=="equip","guided crafts lead to explicit equip step")
	for g in guided.s.gear:
		if g.id=="copper_sword": guided.command({"type":"equip","id":g.uid})
	guided.command({"type":"queue","id":"hunt_ash_rat","target":3})
	guided.advance(90000)
	check(guided.s.tutorial and guided.objective().key=="thralls","tutorial continues toward enemy unlocks, not straight to boss")
	var old_save = guided.s.duplicate(true)
	old_save.erase("experience")
	old_save.erase("chronicle")
	old_save.erase("progression")
	old_save.erase("runeforge")
	old_save.erase("loadouts")
	old_save.erase("hunts")
	check(not store.decode(store.encode(old_save),guided.data).is_empty(),"0.1 saves remain readable")
	var planned = RealmModel.new()
	var chain = RealmProgression.plan(planned,"craft_copper_sword",1)
	check(chain.error=="" and chain.steps.size()==4 and planned.s.queue.is_empty(),"planner previews dependencies without spending stock")
	planned.command({"type":"plan","id":"craft_copper_sword","amount":1})
	planned.advance(26000)
	check(planned.s.gains.get("copper_sword",0)==1 and planned.count("copper_ore")==0 and planned.count("copper_ingot")==0 and planned.s.queue.is_empty(),"planned sword gathers and crafts with exact input accounting")
	planned.s.gains.copper_ore = 20
	planned.command({"type":"claim","id":"ore"})
	var gold_after = planned.s.gold
	var duplicate = planned.command({"type":"claim","id":"ore"})
	planned.command({"type":"upgrade","id":"forge"})
	check(not duplicate and planned.s.gold==gold_after-40 and planned.progression().upgrades.forge==1 and not store.decode(store.encode(planned.s),planned.data).is_empty(),"contract pays once and purchased upgrade survives save validation")
	var guarded = RealmModel.new()
	guarded.command({"type":"stance","id":"guard"})
	guarded.command({"type":"queue","id":"hunt_ash_rat","target":100})
	var chunked = RealmModel.new()
	chunked.s = guarded.s.duplicate(true)
	guarded.advance(180000)
	for i in range(180): chunked.advance(1000)
	check(guarded.s==chunked.s and guarded.stats().armor==5,"Warden skills remain deterministic online and offline")
	var legacy = RealmModel.new()
	legacy.s.tutorial = true
	legacy.s.xp.might = 500
	legacy.command({"type":"talent","id":"power"})
	RealmChronicle.state(legacy).fragments.fang = 5
	legacy.command({"type":"relic_upgrade","id":"fang"})
	check(legacy.stats().attack==7 and RealmChronicle.state(legacy).fragments.fang==0 and RealmChronicle.points_free(legacy)==1,"talent and equipped relic change combat stats with exact cost")
	RealmChronicle.sync_day(legacy,20000*86400000)
	legacy.s.mastery.mine_copper = 30
	legacy.command({"type":"bounty_claim","id":"gather"})
	var paid = legacy.s.gold
	var repeated = legacy.command({"type":"bounty_claim","id":"gather"})
	RealmChronicle.sync_day(legacy,20001*86400000)
	check(not repeated and legacy.s.gold==paid and legacy.s.chronicle.daily.day==20000,"bounty cannot double-pay and unfinished board carries over")
	legacy.s.mastery.craft_copper_ingot = 10
	legacy.s.kills.ash_rat = 8
	legacy.command({"type":"bounty_claim","id":"craft"})
	legacy.command({"type":"bounty_claim","id":"hunt"})
	RealmChronicle.sync_day(legacy,20001*86400000)
	check(legacy.s.chronicle.daily.day==20001 and RealmChronicle.bounty_value(legacy,"gather")==0 and not store.decode(store.encode(legacy.s),legacy.data).is_empty(),"completed bounty rotates once with fresh baseline and valid legacy state")
	var expedition = RealmModel.new()
	expedition.s.beacon = true
	expedition.s.tutorial = true
	for part in ["sword","shield","helm","chest","gloves","boots"]: expedition.gain("iron_"+part,1,3)
	expedition.command({"type":"equip_best"})
	expedition.s.bag.cooked_minnow = 100
	expedition.command({"type":"queue","id":"hunt_wilds_1","target":2})
	var twin = RealmModel.new()
	twin.s = expedition.s.duplicate(true)
	expedition.advance(300000)
	for i in range(300): twin.advance(1000)
	check(expedition.s==twin.s and expedition.s.kills.get("wilds_1",0)==2 and expedition.count("scrap")==6 and expedition.available("wilds_2")=="" and expedition.available("marsh_1")!="","expedition rewards first clear once, gates tiers, and matches offline simulation")
	var order = RealmModel.new()
	var preview = RealmProgression.order_plan(order,"forge",1)
	order.command({"type":"work_order","id":"forge","batches":1})
	order.advance(5000000)
	check(preview.steps.size()==2 and order.count("copper_ingot")==500 and order.count("copper_ore")==0 and order.s.xp.smithing==4000 and order.s.queue.is_empty(),"long work order gathers inputs, earns XP and finishes while offline")
	var wild = RealmCombat.move(expedition,expedition.data.enemies.wilds_1,3,20)
	var plain = RealmCombat.move(expedition,expedition.data.enemies.wilds_1,1,20)
	var oracle = RealmCombat.move(expedition,expedition.data.enemies.marsh_1,3,20)
	var crown = RealmCombat.move(expedition,expedition.data.enemies.crown_1,3,20)
	check(wild.damage>plain.damage and oracle.heal==8 and crown.damage>RealmCombat.move(expedition,expedition.data.enemies.crown_1,1,20).damage,"guardians have distinct armor-piercing, recovery and burst attacks")
	check(RealmCombat.forecast(expedition,"wilds_1").fragments_per_minute>RealmCombat.forecast(expedition,"ash_rat").fragments_per_minute,"unlocked expedition improves predicted relic yield over starter rats")
	var healer = RealmModel.new()
	healer.s.tutorial = true
	RealmChronicle.state(healer).relics.heart = 2
	healer.s.chronicle.relic = "heart"
	healer.s.hp = 30
	healer.command({"type":"queue","id":"hunt_ash_rat","target":1})
	healer.s.fight.enemy_at = 1
	healer.advance(1)
	check(RealmCombat.food_heal(healer,"cooked_minnow")==26 and healer.s.hp>=55 and healer.count("cooked_minnow")==4,"displayed relic healing matches food consumed in combat")
	var marsh = RealmModel.new()
	marsh.s = expedition.s.duplicate(true)
	marsh.command({"type":"clear"})
	marsh.s.kills.wilds_5 = 1
	marsh.s.hp = 100
	marsh.s.bag.cooked_minnow = 100
	marsh.command({"type":"queue","id":"hunt_marsh_1","target":3})
	var marsh_chunks = RealmModel.new()
	marsh_chunks.s = marsh.s.duplicate(true)
	marsh.advance(180000)
	for i in range(180): marsh_chunks.advance(1000)
	check(marsh.s==marsh_chunks.s,"Oracle healing stays deterministic during offline combat")
	var rune = RealmModel.new()
	rune.s.beacon = true
	rune.s.tutorial = true
	rune.s.kills.wilds_1 = 5
	rune.s.gold = 50
	rune.s.bag.scrap = 3
	RealmChronicle.state(rune).fragments.fang = 19
	RealmRuneforge.state(rune)
	var before_rune = rune.s.duplicate(true)
	var refused = not rune.command({"type":"rune_forge","id":"thorn"})
	check(refused and rune.s==before_rune,"inscription with missing materials cannot partially spend resources")
	rune.s.chronicle.fragments.fang = 20
	var forged = rune.command({"type":"rune_forge","id":"thorn","cid":"forge-once"})
	rune.command({"type":"rune_forge","id":"thorn","cid":"forge-once"})
	check(forged and rune.s.runeforge.ranks.thorn==1 and rune.s.runeforge.equipped=="" and rune.s.gold==0 and rune.count("scrap")==0 and rune.s.chronicle.fragments.fang==0,"inscription spends exact costs once and requires explicit equip")
	rune.command({"type":"research_claim","id":"wilds","target":5})
	var claimed_rune = rune.s.duplicate(true)
	var repeated_claim = not rune.command({"type":"research_claim","id":"wilds","target":5})
	check(repeated_claim and rune.s==claimed_rune and rune.s.gold==40 and rune.count("scrap")==2 and rune.s.chronicle.fragments.fang==10,"field records count previous victories and never pay twice")
	rune.command({"type":"rune_equip","id":"thorn"})
	var saved_rune = store.decode(store.encode(rune.s),rune.data)
	var corrupted_rune = rune.s.duplicate(true)
	corrupted_rune.runeforge.ranks.thorn = 4
	check(not saved_rune.is_empty() and saved_rune.runeforge.equipped=="thorn" and store.decode(store.encode(corrupted_rune),rune.data).is_empty(),"rune ranks and equipped state persist with invalid rank rejection")
	var effects = RealmModel.new()
	for part in ["sword","shield","helm","chest","gloves","boots"]: effects.gain("iron_"+part,1,3)
	effects.command({"type":"equip_best"})
	var target_enemy = effects.data.enemies.crown_3
	var base_skill = RealmCombat.player_damage(effects,target_enemy,4)
	var base_incoming = RealmCombat.move(effects,target_enemy,1,20).damage
	var runes = RealmRuneforge.state(effects)
	runes.ranks = {"thorn":3,"tide":3,"bell":3}
	runes.equipped = "thorn"
	var piercing = RealmCombat.player_damage(effects,target_enemy,4)>base_skill
	runes.equipped = "tide"
	var suppressed = RealmCombat.move(effects,effects.data.enemies.marsh_1,3,20).heal==2
	runes.equipped = "bell"
	check(piercing and suppressed and RealmCombat.player_damage(effects,target_enemy,4)>base_skill and RealmCombat.move(effects,target_enemy,1,20).damage>base_incoming,"runes apply armor penetration, recovery suppression and damage tradeoff")
	var consistent = true
	for id in RealmRuneforge.RUNES:
		var online = RealmModel.new()
		online.s = effects.s.duplicate(true)
		online.s.beacon = true
		online.s.tutorial = true
		online.s.kills.wilds_5 = 1
		online.s.bag.cooked_minnow = 100
		online.s.runeforge.equipped = id
		online.command({"type":"queue","id":"hunt_marsh_1","target":3})
		var offline = RealmModel.new()
		offline.s = online.s.duplicate(true)
		consistent = consistent and not online.command({"type":"rune_equip","id":""})
		offline.advance(180000)
		for i in range(180): online.advance(1000)
		consistent = consistent and online.s==offline.s
	check(consistent,"all three runes preserve offline combat and cannot be swapped mid-fight")
	var smith = RealmModel.new()
	smith.s.tutorial = true
	smith.s.xp.smithing = 225
	smith.s.gold = 100
	smith.s.bag.scrap = 10
	smith.s.bag.copper_ingot = 1
	smith.gain("copper_sword",3,1)
	smith.command({"type":"equip_best"})
	var original_uid = str(smith.s.equipped.weapon)
	smith.gear(original_uid).locked = true
	smith.gear(original_uid).favorite = true
	smith.command({"type":"preset_save","id":"Guardian"})
	smith.command({"type":"loadout_save","id":"journey"})
	var before_refine = smith.s.duplicate(true)
	check(not smith.command({"type":"refine","id":original_uid}) and smith.s==before_refine,"refinement with insufficient ingots makes no partial changes")
	smith.s.bag.copper_ingot = 10
	smith.command({"type":"refine","id":original_uid,"cid":"one-refinement"})
	smith.command({"type":"refine","id":original_uid,"cid":"one-refinement"})
	var new_uid = str(smith.last_forged)
	var refined = smith.gear(new_uid)
	check(smith.count("copper_sword")==3 and smith.gear(original_uid).count==2 and refined.count==1 and refined.q==2 and refined.locked and refined.favorite and smith.s.gold==60 and smith.count("copper_ingot")==8 and smith.count("scrap")==8 and smith.s.equipped.weapon==new_uid and smith.s.presets.Guardian.weapon==new_uid and smith.s.loadouts.journey.gear.weapon==new_uid,"refinement splits one copy, charges once and follows all protected references")
	smith.command({"type":"refine","id":original_uid})
	check(smith.count("copper_sword")==3 and smith.gear(original_uid).count==1 and smith.gear(new_uid).count==2 and smith.s.gold==20,"refinement safely merges into an existing higher-quality stack")
	smith.s.xp.might = 750
	smith.progression().stance = "guard"
	RealmChronicle.state(smith).talents = {"power":1,"guard":2,"fortune":0}
	smith.s.chronicle.relics.fang = 1
	smith.s.chronicle.relic = "fang"
	RealmRuneforge.state(smith).ranks.thorn = 1
	smith.s.runeforge.equipped = "thorn"
	smith.s.settings.food = "cooked_meat"
	smith.s.settings.potion = "healing_draught"
	smith.s.settings.threshold = .8
	smith.command({"type":"loadout_save","id":"guardian"})
	var full_build = RealmLoadouts.snapshot(smith)
	smith.progression().stance = "reaver"
	smith.s.chronicle.talents.guard = 0
	smith.s.settings.threshold = .3
	smith.command({"type":"loadout_load","id":"guardian"})
	check(RealmLoadouts.snapshot(smith)==full_build and smith.s.settings.potion_policy=="auto" and smith.protected(new_uid) and not store.decode(store.encode(smith.s),smith.data).is_empty(),"complete loadout restores all build choices, protects gear and survives saves")
	smith.command({"type":"queue","id":"hunt_ash_rat","target":3})
	var build_during_fight = RealmLoadouts.snapshot(smith)
	check(not smith.command({"type":"loadout_load","id":"journey"}) and RealmLoadouts.snapshot(smith)==build_during_fight,"loadout cannot partially apply during combat")
	var logged_offline = RealmModel.new()
	logged_offline.s = smith.s.duplicate(true)
	smith.advance(60000)
	for i in range(60): logged_offline.advance(1000)
	var report = RealmHunts.state(smith).history[0]
	check(smith.s==logged_offline.s and report.result=="Completed" and report.wins==3 and report.fragments==3 and report.gold>0 and report.loot.get("raw_meat",0)==3 and not store.decode(store.encode(smith.s),smith.data).is_empty(),"hunt ledger records exact completed rewards and agrees across offline chunks")
	var recalled = RealmModel.new()
	recalled.command({"type":"queue","id":"hunt_ash_rat","target":20})
	recalled.advance(1000)
	recalled.command({"type":"clear"})
	var lost = RealmModel.new()
	lost.s.hp = 1
	lost.s.bag.cooked_minnow = 0
	lost.command({"type":"queue","id":"hunt_ash_rat","target":20})
	lost.advance(6000)
	check(recalled.s.hunts.history[0].result=="Recalled" and recalled.s.hunts.history[0].wins==0 and lost.s.hunts.history[0].result=="Defeated" and lost.s.hunts.history[0].ending_hp==0,"retreat and defeat produce separate honest hunt outcomes")
	var invalid_build = smith.s.duplicate(true)
	invalid_build.loadouts.guardian.gear.weapon = "missing-gear"
	var invalid_report = smith.s.duplicate(true)
	invalid_report.hunts.history[0].wins = -1
	check(store.decode(store.encode(invalid_build),smith.data).is_empty() and store.decode(store.encode(invalid_report),smith.data).is_empty(),"save validation rejects broken loadout references and negative hunt accounting")
	var trial_m = RealmModel.new()
	trial_m.s.beacon = true
	trial_m.s.tutorial = true
	check(trial_m.available("trial_wilds")!="", "trials require the regional fifth tier")
	trial_m.s.kills.wilds_5 = 1
	trial_m.s.bag.cooked_minnow = 1000
	trial_m.s.settings.threshold = .8
	for part in ["sword","shield","helm","chest","gloves","boots"]: trial_m.gain("iron_"+part,1,5)
	trial_m.command({"type":"equip_best"})
	trial_m.command({"type":"queue","id":"hunt_trial_wilds","target":2})
	var trial_copy = RealmModel.new()
	trial_copy.s = trial_m.s.duplicate(true)
	trial_m.advance(600000)
	for i in range(600): trial_copy.advance(1000)
	var trial_report = trial_m.s.hunts.history[0]
	check(trial_m.s==trial_copy.s and trial_report.wins==2 and trial_report.fragments==216 and trial_report.loot.scrap==15 and trial_report.equipment.get("iron_gloves|4",0)==1, "two trial victories pay one Epic bonus, exact fragments and identical offline rewards")
	check(RealmRuneforge.victories(trial_m,"wilds")==3 and not store.decode(store.encode(trial_m.s),trial_m.data).is_empty(), "trial victories count toward field records and persist")
	var phase_m = RealmModel.new()
	phase_m.s.beacon = true
	phase_m.s.kills.marsh_5 = 1
	phase_m.command({"type":"queue","id":"hunt_trial_marsh","target":1})
	phase_m.s.fight.hp = 325
	phase_m.s.fight.hits = 2
	phase_m.s.fight.player_at = 4000
	phase_m.advance(3000)
	check(phase_m.s.fight.phase==2 and phase_m.s.fight.hp==377 and RealmTrials.active_phase(phase_m,phase_m.data.enemies.trial_marsh), "phase II stays active when the Oracle heals above half health")
	var phase_save = phase_m.s.duplicate(true)
	check(not store.decode(store.encode(phase_save),phase_m.data).is_empty(), "an awakened trial resumes safely from save")
	phase_save.fight.phase = 3
	check(store.decode(store.encode(phase_save),phase_m.data).is_empty(), "unknown combat phases are rejected")
	var last_fight = RealmModel.new()
	last_fight.command({"type":"queue","id":"hunt_ash_rat","target":30})
	last_fight.command({"type":"queue","id":"mine_copper","target":10})
	var battle_before = last_fight.s.fight.duplicate(true)
	check(last_fight.command({"type":"finish_hunt"}) and last_fight.s.queue.size()==1 and last_fight.s.queue[0].target==1 and last_fight.s.fight==battle_before, "return after battle preserves combat and cancels remaining tasks")
	var last_copy = RealmModel.new()
	last_copy.s = store.decode(store.encode(last_fight.s),last_fight.data)
	last_fight.advance(60000)
	for i in range(60): last_copy.advance(1000)
	check(store.decode(store.encode(last_fight.s),last_fight.data)==store.decode(store.encode(last_copy.s),last_copy.data) and last_fight.s.queue.is_empty() and last_fight.s.kills.ash_rat==1 and last_fight.s.hunts.history[0].result=="Completed", "last fight completes once across save and offline chunks")
	check(not last_fight.command({"type":"finish_hunt"}), "return-after-battle rejects idle state without inventing rewards")
	var ration_model = RealmModel.new()
	var ration_forecast = RealmCombat.forecast(ration_model,"ash_rat")
	check(RealmHuntPlan.meals(ration_model,ration_forecast,100)>int(ration_forecast.meals)*100, "long hunt budgets health once rather than assuming full recovery after every fight")
	var training = RealmModel.new()
	training.s.xp.smithing = 1900
	var ingots_needed = RealmJourney.smithing_batch(training)
	check(ingots_needed==16 and 1900+(ingots_needed-1)*8<2025 and 1900+ingots_needed*8>=2025, "Smithing goal computes the minimum ingots needed for level ten")
	check(trial_report.consumed.get("cooked_minnow",0)==trial_report.meals and trial_report.meals>0, "hunt report records the exact cooked food consumed")
	var bad_consumption = trial_m.s.duplicate(true)
	bad_consumption.hunts.history[0].consumed.cooked_minnow += 1
	check(store.decode(store.encode(bad_consumption),trial_m.data).is_empty(), "save rejects item consumption that disagrees with hunt totals")
	var earlier_report = trial_report.duplicate(true)
	earlier_report.ended = int(earlier_report.started)+120000
	earlier_report.wins = 2
	earlier_report.meals = 6
	var incomplete_report = earlier_report.duplicate(true)
	incomplete_report.result = "Recalled"
	incomplete_report.wins = 0
	var other_report = earlier_report.duplicate(true)
	other_report.enemy = "ash_rat"
	var previous_report = RealmHuntReview.previous([trial_report,incomplete_report,other_report,earlier_report],0)
	check(previous_report==earlier_report and RealmHuntReview.metrics(previous_report).per_win==60 and RealmHuntReview.metrics(previous_report).meals_per_win==3 and not RealmHuntReview.metrics(incomplete_report).comparable, "hunt comparisons normalize by wins and skip incomplete or different enemies")
	var preview_model = RealmModel.new()
	preview_model.s.tutorial = true
	preview_model.s.gold = 1000
	preview_model.s.bag.scrap = 100
	preview_model.s.bag.copper_ingot = 100
	preview_model.s.xp.smithing = 1000
	var preview_uid = preview_model.add_gear("copper_sword",2)
	var untouched = preview_model.s.duplicate(true)
	var forecast_upgrade = RealmWorkshop.preview(preview_model,preview_uid,"ash_rat")
	check(preview_model.s==untouched and not forecast_upgrade.equipped and forecast_upgrade.after.attack>forecast_upgrade.before.attack, "upgrade preview is read-only and explicitly models equipping bagged gear")
	preview_model.command({"type":"equip","id":preview_uid})
	forecast_upgrade = RealmWorkshop.preview(preview_model,preview_uid,"ash_rat")
	preview_model.command({"type":"refine","id":preview_uid})
	check(preview_model.stats()==forecast_upgrade.after and RealmCombat.forecast(preview_model,"ash_rat")==forecast_upgrade.hunt_after, "upgrade preview matches actual refined equipped stats and combat estimate")
	var max_uid = preview_model.add_gear("iron_sword",6)
	check(RealmWorkshop.preview(preview_model,max_uid,"ash_rat").is_empty(), "Workshop does not preview downgrades for equipment above its refinement cap")
	var story_model = RealmModel.new()
	check(RealmStory.count(story_model)==1 and not RealmStory.unlocked(story_model,1), "story starts with only the opening chapter unlocked")
	story_model.s.tutorial = true
	story_model.s.beacon = true
	for region in ["wilds","marsh","crown"]: story_model.s.kills[region+"_5"] = 1
	check(RealmStory.count(story_model)==6 and not RealmStory.unlocked(story_model,6), "regional story chapters follow actual milestones without unlocking the finale early")
	for id in RealmTrials.IDS: story_model.s.kills[id] = 1
	var story_copy = RealmModel.new()
	story_copy.s = store.decode(store.encode(story_model.s),story_model.data)
	check(RealmStory.count(story_copy)==7 and "Iron ingot" in RealmStory.unlocks(story_model,"smithing",9,10) and RealmStory.unlocks(story_model,"smithing",10,10).is_empty(), "story unlocks survive save reload and level rewards use catalog requirements")
	var repair_m = RealmModel.new()
	repair_m.s.bag.copper_ore = 2
	repair_m.command({"type":"queue","id":"craft_copper_ingot","target":5})
	repair_m.command({"type":"queue","id":"cut_ash","target":2})
	repair_m.advance(3000)
	var repair_before = repair_m.s.duplicate(true)
	var recovery_plan = RealmQueueRepair.plan(repair_m)
	check(recovery_plan.error=="" and recovery_plan.steps[0].target==8 and repair_m.s==repair_before, "queue repair previews only missing materials without changing progress")
	repair_m.command({"type":"repair_queue"})
	var repair_copy = RealmModel.new()
	repair_copy.s = repair_m.s.duplicate(true)
	repair_m.advance(120000)
	for i in range(120): repair_copy.advance(1000)
	check(repair_m.s==repair_copy.s and repair_m.count("copper_ingot")==5 and repair_m.count("ash_log")==2 and repair_m.s.queue.is_empty(), "repair preserves completed cycles and following tasks across offline chunks")
	var full_queue = RealmModel.new()
	for i in range(20): full_queue.command({"type":"queue","id":"craft_copper_ingot","target":1})
	var full_before = full_queue.s.duplicate(true)
	check(not full_queue.command({"type":"repair_queue"}) and full_queue.s==full_before, "repair rejects insufficient queue capacity without partial changes")
	var low_smith = RealmModel.new()
	check(RealmJourney.smithing_batch(low_smith)>100 and RealmProgression.plan(low_smith,"craft_copper_ingot",clampi(RealmJourney.smithing_batch(low_smith),1,100)).error=="", "long Smithing goals can open a planner-compatible batch")
	var equipment_m = RealmModel.new()
	var equipment_uid = equipment_m.add_gear("copper_sword",3)
	var equipment_before = equipment_m.s.duplicate(true)
	var equipment_result = RealmEquipmentPreview.compare(equipment_m,equipment_uid)
	check(equipment_before==equipment_m.s and equipment_result.after.attack>equipment_result.before.attack, "equipment comparison leaves player state untouched")
	equipment_m.command({"type":"equip","id":equipment_uid})
	check(equipment_m.stats()==equipment_result.after, "equipment comparison matches actual equipped build")
	var tool_uid = equipment_m.add_gear("copper_pick",1)
	var tool_result = RealmEquipmentPreview.compare(equipment_m,tool_uid)
	equipment_m.command({"type":"equip","id":tool_uid})
	check(tool_result.seconds_after<tool_result.seconds_before and equipment_m.duration(equipment_m.data.activities.mine_copper)/1000.0==tool_result.seconds_after, "tool comparison uses the real gathering duration")
	var return_m = RealmModel.new()
	return_m.s.wall = 1000
	return_m.command({"type":"queue","id":"mine_copper","target":100})
	var return_report = store.resume(return_m,601000)
	check(return_report.away==600000 and not return_report.capped and return_report.levels.mining.before==1 and return_report.levels.mining.after==return_m.level("mining") and return_report.queued_before==1, "return report records actual level gains and previous queued work")
	var repeat_return = store.resume(return_m,601000)
	check(repeat_return.elapsed==0 and repeat_return.xp==0 and repeat_return.gains.is_empty(), "reopening at the same time does not duplicate offline rewards")
	var capped_m = RealmModel.new()
	capped_m.s.wall = 1000
	var capped_report = store.resume(capped_m,1000+RealmModel.MAX_OFFLINE*2)
	check(capped_report.capped and capped_report.elapsed==RealmModel.MAX_OFFLINE and capped_report.away==RealmModel.MAX_OFFLINE*2 and capped_report.xp==0 and capped_report.gains.is_empty(), "return report distinguishes capped elapsed time from idle reward generation")
	var relic_goal = RealmRelicGoal.plan(2,6,8)
	check(relic_goal.missing==39 and relic_goal.wins==5 and relic_goal.batch==5, "relic targets round up partial fragment wins")
	var long_relic_goal = RealmRelicGoal.plan(9,0,1)
	check(long_relic_goal.wins==500 and long_relic_goal.batch==100, "relic farming keeps the full goal separate from the queue batch limit")
	check(RealmRelicGoal.plan(0,5,1).state=="ready" and RealmRelicGoal.plan(0,5,1).wins==0 and RealmRelicGoal.plan(10,0,1).state=="maximum" and RealmRelicGoal.plan(10,0,1).batch==0, "ready and maximum relics do not invent another upgrade hunt")
	var mastery_m = RealmModel.new()
	mastery_m.s.kills.ash_rat = 24
	var rat_enemy = mastery_m.data.enemies.ash_rat
	var predicted_mastery = RealmHuntMastery.rewards(mastery_m,rat_enemy,2)
	var old_gold = mastery_m.s.gold
	var old_fragments = RealmChronicle.state(mastery_m).fragments.fang
	mastery_m.command({"type":"queue","id":"hunt_ash_rat","target":2})
	var mastery_copy = RealmModel.new()
	mastery_copy.s = store.decode(store.encode(mastery_m.s),mastery_copy.data)
	mastery_m.advance(60000)
	for i in range(60): mastery_copy.advance(1000)
	check(mastery_m.s.kills.ash_rat==26 and mastery_m.s.gold-old_gold==predicted_mastery.gold and RealmChronicle.state(mastery_m).fragments.fang-old_fragments==predicted_mastery.fragments, "mastery reward forecast matches real victories across a rank threshold")
	check(store.decode(store.encode(mastery_m.s),mastery_m.data)==store.decode(store.encode(mastery_copy.s),mastery_copy.data), "mastery threshold remains deterministic across offline chunks and save reload")
	var mastery_plain = RealmModel.new()
	var mastery_other = RealmCombat.player_damage(mastery_plain,mastery_plain.data.enemies.hollow_hound,1)
	var mastery_rat = RealmCombat.player_damage(mastery_plain,mastery_plain.data.enemies.ash_rat,1)
	mastery_plain.s.kills.ash_rat = 150
	check(RealmCombat.player_damage(mastery_plain,mastery_plain.data.enemies.ash_rat,1)>mastery_rat and RealmCombat.player_damage(mastery_plain,mastery_plain.data.enemies.hollow_hound,1)==mastery_other and RealmHuntMastery.rank(mastery_plain,"ash_rat")==4, "mastery bonuses are enemy-specific and existing victories receive their rank")
	var target_mastery = RealmModel.new()
	target_mastery.s.kills.ash_rat = 24
	check(RealmHuntMastery.wins_for_fragments(target_mastery,target_mastery.data.enemies.ash_rat,5)==3 and RealmHuntMastery.rewards(target_mastery,target_mastery.data.enemies.ash_rat,3).fragments==5, "fragment goals use the minimum wins including a newly unlocked mastery bonus")
	print("ESSENTIAL CHECKS: ","PASS" if failed==0 else "FAIL")
	quit(1 if failed else 0)
