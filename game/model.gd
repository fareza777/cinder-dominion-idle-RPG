class_name RealmModel
extends RefCounted

const MAX_OFFLINE = 86400000
const QUALITY = [0.8, 1.0, 1.1, 1.25, 1.5, 1.8, 2.2, 2.7]
var data: Dictionary
var s: Dictionary
var rng = RandomNumberGenerator.new()
var error = ""
var last_hit = ""
var battle_event = {"serial":0,"text":"","side":"enemy"}
var combat_events: Array = []
var last_reward = ""
var last_forged = ""

func progression() -> Dictionary:
	return RealmProgression.state(self)

func combat_event(message: String, side: String):
	battle_event = {"serial":int(battle_event.serial)+1,"text":message,"side":side,"time":int(s.time)}
	combat_events.append(battle_event)
	if combat_events.size()>8: combat_events.pop_front()

func _init():
	data = JSON.parse_string(FileAccess.get_file_as_string("res://data/catalog.json"))
	fresh()

func fresh(seed_value: int = 12345):
	combat_events.clear()
	last_reward = ""
	last_hit = ""
	last_forged = ""
	rng.seed = seed_value
	s = {"version":1,"revision":0,"time":0,"wall":0,"rng":str(rng.state),"gold":20,
		"bag":{"cooked_minnow":5},"gear":[],"overflow":[],"equipped":{},"next_uid":1,
		"xp":{},"mastery":{},"queue":[],"active":{},"fight":{},"hp":100,
		"regen_at":1000,"kills":{},"gains":{},"spent":{},"tutorial":false,"beacon":false,
		"presets":{},"log":[],"processed":[],"experience":{"version":2,"welcome_done":false},"settings":{"locale":"en","font":1.0,
		"motion":true,"battery":true,"music":0.35,"sfx":0.5,"food":"cooked_minnow",
		"threshold":0.5,"potion":"","potion_policy":"off"},"report":{}}
	for key in data.skills: s.xp[key] = 0
	for id in ["worn_sword","worn_shield","wood_axe","stone_pick","reed_rod"]:
		var uid = add_gear(id, 1)
		s.equipped[data.items[id].slot] = uid

func local_name(entry: Dictionary) -> String:
	return str(entry.get("en",entry.get("name","")))

func name_of(id: String) -> String:
	return local_name(data.items.get(id,{"name":id,"en":id}))

func level(skill: String) -> int:
	return mini(100, 1 + int(sqrt(float(s.xp.get(skill,0)) / 25.0)))

func count(id: String) -> int:
	if data.items.has(id) and data.items[id].category=="equipment":
		var total = 0
		for g in s.gear:
			if g.id==id: total += int(g.count)
		return total
	return int(s.bag.get(id,0))

func gear(uid: String) -> Dictionary:
	for g in s.gear:
		if g.uid == uid: return g
	return {}

func stats() -> Dictionary:
	var st = {"attack":4.0 + floor((level("might")-1)/5.0),"armor":floor((level("warding")-1)/5.0),"hp":100,"accuracy":minf(.99,.95+(level("bladecraft")-1)*.001)}
	for uid in s.equipped.values():
		var g = gear(str(uid))
		if g.is_empty(): continue
		var d = data.items[g.id]
		st.attack += float(d.get("attack",0))*QUALITY[int(g.q)]
		st.armor += float(d.get("armor",0))*QUALITY[int(g.q)]
	if not s.fight.is_empty() and s.fight.get("buff_until",0)>s.time:
		st[s.fight.buff] += 3
	var style = RealmProgression.STANCES[progression().stance]
	var legacy = RealmChronicle.state(self)
	st.attack += int(legacy.talents.power)
	st.armor += int(legacy.talents.guard)
	if legacy.relic=="fang": st.attack += int(legacy.relics.fang)*2
	if legacy.relic=="ward": st.armor += int(legacy.relics.ward)*2
	st.attack = maxi(1,int(st.attack*float(style.attack)))
	st.armor = maxi(0,int(st.armor)+int(style.armor)+int(progression().upgrades.ward))
	return st

func protected(uid: String) -> bool:
	var g = gear(uid)
	if g.is_empty(): return true
	if g.locked or g.favorite or uid in s.equipped.values(): return true
	for slots in s.presets.values():
		if uid in slots.values(): return true
	for build in RealmLoadouts.state(self).values():
		if uid in build.gear.values(): return true
	return false

func add_gear(id: String, quality: int) -> String:
	for g in s.gear:
		if g.id == id and int(g.q) == quality:
			g.count += 1
			return g.uid
	var uid = "eq_%d" % int(s.next_uid)
	s.next_uid += 1
	var g = {"uid":uid,"id":id,"q":quality,"count":1,"locked":false,"favorite":false}
	if s.gear.size() >= 1000: s.overflow.append(g)
	else: s.gear.append(g)
	return uid

func gain(id: String, amount: int, quality: int = 1):
	if data.items[id].category == "equipment":
		for i in range(amount): add_gear(id,quality)
	else: s.bag[id] = count(id)+amount
	s.gains[id] = int(s.gains.get(id,0))+amount

func spend(id: String, amount: int):
	s.bag[id] = count(id)-amount
	s.spent[id] = int(s.spent.get(id,0))+amount

func note(message: String):
	s.log.push_front(message)
	if s.log.size()>20: s.log.resize(20)

func available(enemy_id: String) -> String:
	var d = data.enemies[enemy_id]
	if d.has("region"):
		if not s.beacon: return "Defeat the Bellkeeper in Chapter I first"
		if d.unlock=="beacon" or int(s.kills.get(d.unlock,0))>=1: return ""
		return "Clear "+local_name(data.enemies[d.unlock])+" first"
	if d.unlock == "": return ""
	if d.unlock == "tutorial":
		return "Complete First Supplies (Journey steps 1–6)" if not s.tutorial else ""
	if int(s.kills.get(d.unlock,0))<5: return "Defeat %s 5 times" % local_name(data.enemies[d.unlock])
	if d.boss and level("smithing")<10: return "Reach Smithing level 10"
	return ""

func requirement(aid: String) -> String:
	if not data.activities.has(aid): return "Activity not found"
	var a = data.activities[aid]
	if a.kind=="combat":
		var locked = available(a.enemy)
		if locked!="": return locked
		if s.hp<=0: return "Recover HP outside combat before hunting"
	else:
		if level(a.skill)<int(a.level): return "%s Lv.%d" % [local_name(data.skills[a.skill]),int(a.level)]
		for id in a.inputs:
			if count(id)<int(a.inputs[id]): return "Need %s (owned %d / required %d)" % [name_of(id),count(id),int(a.inputs[id])]
	return ""

func command(cmd: Dictionary) -> bool:
	error = ""
	var cid = str(cmd.get("cid",""))
	if cid!="" and cid in s.processed: return true
	var action = str(cmd.get("type",""))
	var id = str(cmd.get("id",""))
	match action:
		"refine":
			var why = RealmWorkshop.command(self,id)
			if why!="": return fail(why)
		"loadout_save","loadout_load":
			var why = RealmLoadouts.command(self,cmd)
			if why!="": return fail(why)
		"rune_forge","rune_equip","research_claim":
			var why = RealmRuneforge.command(self,cmd)
			if why!="": return fail(why)
		"work_order":
			var plan = RealmProgression.order_plan(self,id,int(cmd.get("batches",1)))
			if plan.error!="": return fail(plan.error)
			s.queue.append_array(plan.steps)
			start_next()
		"talent","talent_reset","relic_upgrade","relic_equip","bounty_claim":
			var why = RealmChronicle.command(self,cmd)
			if why!="": return fail(why)
		"plan":
			var plan = RealmProgression.plan(self,id,int(cmd.get("amount",1)))
			if plan.error!="": return fail(plan.error)
			s.queue.append_array(plan.steps)
			start_next()
		"stance":
			if not s.fight.is_empty(): return fail("Retreat before changing your fighting style.")
			if not RealmProgression.STANCES.has(id): return fail("Unknown fighting style")
			progression().stance = id
		"equip_best":
			if not s.fight.is_empty(): return fail("Retreat before changing equipment.")
			for g in s.gear:
				var slot = data.items[g.id].slot
				var current = gear(str(s.equipped.get(slot,"")))
				if current.is_empty() or gear_score(g)>gear_score(current): s.equipped[slot] = g.uid
		"claim":
			var found = false
			for contract in RealmProgression.CONTRACTS:
				if contract.id!=id: continue
				if id in progression().claimed: return fail("Reward already claimed")
				if RealmProgression.value(self,contract)<int(contract.target): return fail("Complete this contract first")
				progression().claimed.append(id)
				s.gold += int(contract.gold)
				gain("cooked_minnow",int(contract.food))
				gain("scrap",int(contract.scrap))
				note("Contract complete: "+contract.title)
				found = true
			if not found: return fail("Unknown contract")
		"upgrade":
			if not RealmProgression.UPGRADES.has(id): return fail("Unknown refuge upgrade")
			var rank = int(progression().upgrades[id])
			if rank>=3: return fail("Maximum rank reached")
			var upgrade = RealmProgression.UPGRADES[id]
			if s.gold<int(upgrade.gold)*(rank+1) or count("scrap")<int(upgrade.scrap)*(rank+1): return fail("Earn gold and metal scraps through hunts, contracts, or salvage.")
			s.gold -= int(upgrade.gold)*(rank+1)
			spend("scrap",int(upgrade.scrap)*(rank+1))
			progression().upgrades[id] = rank+1
			note("%s upgraded to rank %d" % [upgrade.name,rank+1])
		"queue":
			if not data.activities.has(id): return fail("Unknown activity")
			if s.queue.size()>=20: return fail("Queue is full (20 steps). Cancel a step to make room.")
			var target = clampi(int(cmd.get("target",50)),1,1000000)
			var kind = str(cmd.get("kind","cycles"))
			if kind not in ["cycles","output","level"]: return fail("Invalid activity target")
			s.queue.append({"id":id,"target":mini(target,100) if kind=="level" else target,"kind":kind,"done":0,"output":0,"skip":bool(cmd.get("skip",false))})
			if s.active.is_empty() and s.fight.is_empty(): start_next()
		"cancel":
			var index = int(cmd.get("index",0))
			if index<0 or index>=s.queue.size(): return fail("The queue has changed. Open it again.")
			if index==0: refund_active()
			s.queue.remove_at(index)
			start_next()
		"up":
			var index = int(cmd.get("index",0))
			if index<2 or index>=s.queue.size(): return fail("The active task stays first. Reorder waiting tasks only.")
			var step = s.queue[index]
			s.queue.remove_at(index)
			s.queue.insert(index-1,step)
		"finish_hunt":
			if s.fight.is_empty() or s.queue.is_empty(): return fail("There is no battle to finish.")
			s.queue.resize(1)
			s.queue[0].kind = "cycles"
			s.queue[0].target = int(s.queue[0].done)+1
			note("One last fight, then home. The rest of the queue has been cancelled.")
		"clear":
			refund_active()
			s.queue.clear()
		"equip":
			if not s.fight.is_empty(): return fail("Retreat from combat before changing equipment.")
			var g = gear(id)
			if g.is_empty(): return fail("Item not found")
			s.equipped[data.items[g.id].slot] = id
		"lock","favorite":
			var g = gear(id)
			if g.is_empty(): return fail("Item not found")
			var field = "locked" if action=="lock" else "favorite"
			g[field] = not g[field]
		"salvage":
			var ids = cmd.get("ids",[])
			if ids.is_empty(): return fail("No equipment selected for salvage")
			var seen = {}
			for uid in ids:
				if seen.has(uid) or protected(uid): return fail("This item is equipped, locked, a favorite, or used in a preset.")
				seen[uid] = true
			var amount = 0
			for uid in ids:
				var g = gear(uid)
				amount += int(g.count)*([1,1,2,4,6,8,12,16][int(g.q)])
				s.gear.erase(g)
			gain("scrap",amount)
			note("Salvaged into %d metal scraps" % amount)
		"buy":
			if not data.merchant.has(id): return fail("This item is not sold here")
			var qty = clampi(int(cmd.get("amount",1)),1,100)
			var cost = int(data.merchant[id])*qty
			if s.gold<cost: return fail("Not enough gold. Hunt enemies to earn more.")
			s.gold -= cost
			gain(id,qty)
		"sell":
			if not data.items.has(id) or data.items[id].category=="equipment": return fail("Salvage equipment to recover metal scraps.")
			var qty = clampi(int(cmd.get("amount",1)),1,1000)
			if count(id)<qty: return fail("Not enough items")
			spend(id,qty)
			s.gold += qty
		"food":
			if not data.items.has(id) or data.items[id].category!="food": return fail("Choose a cooked food item")
			s.settings.food = id
		"potion":
			if id!="" and (not data.items.has(id) or data.items[id].category!="potion"): return fail("Invalid potion")
			s.settings.potion = id
			s.settings.potion_policy = "auto" if id!="" else "off"
		"preset_save":
			s.presets[id.left(24)] = s.equipped.duplicate(true)
		"preset_load":
			if not s.fight.is_empty(): return fail("Retreat from combat first")
			if not s.presets.has(id): return fail("This preset has not been saved yet")
			s.equipped = s.presets[id].duplicate(true)
		"overflow":
			var moved = []
			for g in s.overflow:
				if s.gear.size()>=1000: break
				s.gear.append(g)
				moved.append(g)
			for g in moved: s.overflow.erase(g)
		"setting":
			if not s.settings.has(id): return fail("Unknown setting")
			s.settings[id] = cmd.get("value")
		_:
			return fail("Unknown command")
	check_quest()
	if cid!="":
		s.processed.append(cid)
		if s.processed.size()>128: s.processed.pop_front()
	return true

func fail(message: String) -> bool:
	error = message
	return false

func refund_active():
	RealmHunts.finish(self,"Recalled")
	if not s.active.is_empty():
		for id in s.active.reserved:
			var qty = int(s.active.reserved[id])
			s.bag[id] = count(id)+qty
			s.spent[id] = int(s.spent.get(id,0))-qty
	s.active = {}
	s.fight = {}
	s.regen_at = int(s.time)+1000

func duration(a: Dictionary) -> int:
	var tool_slot = {"woodcutting":"axe","mining":"pick","fishing":"rod"}.get(a.skill,"")
	var discount = 0.0
	var g = gear(str(s.equipped.get(tool_slot,"")))
	if not g.is_empty(): discount = float(data.items[g.id].get("speed",0))
	discount += minf(.1,floor(float(s.mastery.get(a.id,0))/100.0)*.01)
	discount += int(progression().upgrades.forge)*.05
	return maxi(200,int(float(a.duration)*1000*(1-minf(.45,discount))))

func gear_score(g: Dictionary) -> float:
	var d = data.items[g.id]
	return (float(d.get("attack",0))+float(d.get("armor",0)))*QUALITY[int(g.q)]+float(d.get("speed",0))*100

func encounter_advice(id: String) -> String:
	var f = RealmCombat.forecast(self,id)
	if f.stalled: return "Outmatched · the enemy can recover faster than your current damage. Improve your weapon, talents or relic."
	return "%s · about %ds · roughly %d %s per fight" % [f.rating,int(f.seconds),int(f.meals),"meal" if int(f.meals)==1 else "meals"]

func step_complete(step: Dictionary) -> bool:
	if step.kind=="level": return level(data.activities[step.id].skill)>=int(step.target)
	return int(step.output if step.kind=="output" else step.done)>=int(step.target)

func start_next():
	if not s.active.is_empty() or not s.fight.is_empty(): return
	while not s.queue.is_empty():
		var step = s.queue[0]
		if step_complete(step):
			s.queue.pop_front()
			continue
		var why = requirement(step.id)
		if why!="":
			if step.skip:
				s.queue.pop_front()
				continue
			error = why
			return
		var a = data.activities[step.id]
		if a.kind=="combat":
			var enemy = data.enemies[a.enemy]
			RealmHunts.begin(self,a.enemy)
			s.fight = {"enemy":a.enemy,"hp":enemy.hp,"player_at":int(s.time)+2000,"enemy_at":int(s.time)+int(enemy.interval),"hits":0,"buff_until":0,"buff":"attack","potion_at":0,"spawn_at":0}
		else:
			for id in a.inputs: spend(id,int(a.inputs[id]))
			s.active = {"id":step.id,"started":s.time,"due":int(s.time)+duration(a),"reserved":a.inputs.duplicate(true)}
		return

func advance(ms: int):
	if ms<=0: return
	if not s.fight.is_empty(): RealmHunts.begin(self,s.fight.enemy)
	rng.state = int(s.rng)
	var target = int(s.time)+ms
	start_next()
	while int(s.time)<target:
		var due = target+1
		if not s.active.is_empty(): due = int(s.active.due)
		if not s.fight.is_empty():
			due = mini(int(s.fight.player_at),int(s.fight.enemy_at))
			if s.fight.buff_until>s.time: due = mini(due,int(s.fight.buff_until))
		else:
			if s.hp<100: due = mini(due,maxi(int(s.regen_at),int(s.time)))
		if due>target: break
		s.time = due
		if not s.fight.is_empty(): resolve_combat()
		else:
			if s.hp<100 and s.regen_at<=s.time:
				s.hp = mini(100,int(s.hp)+1+int(progression().upgrades.hearth))
				s.regen_at = int(s.time)+1000
			if not s.active.is_empty() and s.active.due<=s.time: finish_production()
		start_next()
	s.time = target
	s.rng = str(rng.state)

func quality_roll() -> int:
	var roll = rng.randf()
	return 3 if roll<.02 else (2 if roll<.15 else 1)

func finish_production():
	var a = data.activities[s.active.id]
	var previous_level = level(a.skill)
	var q = quality_roll() if data.items[a.output].category=="equipment" else 1
	gain(a.output,1,q)
	if a.side!="" and rng.randf()<.2: gain(a.side,1)
	s.xp[a.skill] = int(s.xp[a.skill])+int(a.xp)
	if level(a.skill)>previous_level: note("%s reached level %d. Check Skills for new recipes and resources." % [local_name(data.skills[a.skill]),level(a.skill)])
	s.mastery[a.id] = int(s.mastery.get(a.id,0))+1
	s.queue[0].done += 1
	s.queue[0].output += 1
	s.active = {}
	if q>=2: note("%s · %s" % [data.rarities[q],name_of(a.output)])
	check_quest()

func hit_damage(atk: int, armor: int) -> int:
	return maxi(1,int(floor(atk*100.0/(100+armor*5))))

func resolve_combat():
	var f = s.fight
	var d = data.enemies[f.enemy]
	if f.buff_until>0 and f.buff_until<=s.time: f.buff_until = 0
	var pot = str(s.settings.potion)
	if pot!="" and count(pot)>0 and f.potion_at<=s.time:
		var effect = data.items[pot].effect
		if effect!="heal" or s.hp<=50:
			spend(pot,1)
			RealmHunts.supplies(self,"potions",str(s.settings.potion))
			f.potion_at = int(s.time)+60000
			if effect=="heal": s.hp = mini(100,int(s.hp)+50)
			else:
				f.buff = effect
				f.buff_until = int(s.time)+60000
	var st = stats()
	if f.player_at<=s.time:
		f.player_at = int(s.time)+2000
		f.swings = int(f.get("swings",0))+1
		if rng.randf()<st.accuracy:
			var damage = RealmCombat.player_damage(self,d,int(f.swings))
			var special = int(f.swings)%4==0
			if special and progression().stance=="guard": s.hp = mini(100,int(s.hp)+8)
			var crit = rng.randf()<.05
			if crit: damage = int(damage*1.5)
			f.hp -= damage
			var skill_name = "SKILL "
			if RealmRuneforge.active_rank(self,"thorn")>0: skill_name = "PIERCE "
			elif RealmRuneforge.active_rank(self,"bell")>0: skill_name = "DIRGE "
			last_hit = (skill_name if special else ("CRIT " if crit else ""))+str(damage)
			combat_event(last_hit,"enemy")
		else:
			last_hit = "MISS"
			combat_event("MISS","enemy")
	if f.hp<=0:
		win(d)
		return
	if RealmTrials.second_phase(d,int(f.hp)) and int(f.get("phase",1))<2:
		f.phase = 2
		combat_event("PHASE II","enemy")
	if f.enemy_at<=s.time:
		f.enemy_at = int(s.time)+int(d.interval)
		f.hits += 1
		var move = RealmCombat.move(self,d,int(f.hits),int(st.armor),int(f.get("phase",1))==2)
		if move.heal>0:
			var restored = mini(int(move.heal),int(d.hp)-int(f.hp))
			f.hp = mini(int(d.hp),int(f.hp)+int(move.heal))
			if restored>0: combat_event("+%d HP" % restored,"enemy")
		if rng.randf()<.95:
			s.hp -= int(move.damage)
			combat_event("−%d HP" % int(move.damage),"hero")
		else: combat_event("MISS","hero")
		if s.hp<=0:
			s.hp = 0
			RealmHunts.finish(self,"Defeated")
			last_reward = "DEFEAT · No items lost. Rest, cook food, or upgrade equipment before returning."
			note("Defeated by %s. Equipment is safe. Recover and prepare food before trying again." % local_name(d))
			s.fight = {}
			s.queue.clear()
			s.regen_at = int(s.time)+1000
			return
		var food = str(s.settings.food)
		if s.hp<=100*float(s.settings.threshold) and count(food)>0:
			spend(food,1)
			RealmHunts.supplies(self,"meals",food)
			var restored_food = mini(100-int(s.hp),RealmCombat.food_heal(self,food))
			s.hp += restored_food
			combat_event("+%d HP" % restored_food,"hero")

func win(enemy: Dictionary):
	var before_gains = s.gains.duplicate(true)
	var before_gold = int(s.gold)
	var id = enemy.id
	var legacy = RealmChronicle.state(self)
	var fragment_id = RealmChronicle.fragments_for(enemy)
	var fragments = int(enemy.get("fragments",1))
	legacy.fragments[fragment_id] += fragments
	var reward_gold = int(enemy.gold)+int(legacy.talents.fortune)*2
	last_reward = "VICTORY · +%d gold · +%d XP · %s ×%d · +%d %s fragments" % [reward_gold,int(enemy.xp),name_of(enemy.drop),int(enemy.qty),fragments,RealmChronicle.RELICS[fragment_id].name]
	if enemy.get("trial",false) and int(s.kills.get(id,0))==0:
		gain("scrap",15)
		gain("cooked_minnow",20)
		gain(enemy.trial_reward,1,4)
		RealmHunts.equipment(self,enemy.trial_reward,4)
		legacy.fragments[fragment_id] += 120
		fragments += 120
		last_reward += " · TRIAL CONQUERED: Epic %s, 120 bonus fragments, 15 scraps & 20 meals" % name_of(enemy.trial_reward)
	elif enemy.has("region") and int(s.kills.get(id,0))==0:
		gain("scrap",5+int(enemy.tier))
		gain("cooked_minnow",10)
		last_reward += " · FIRST CLEAR: +10 meals & scraps"
		if int(enemy.tier)==5:
			gain("iron_sword",1,3)
			RealmHunts.equipment(self,"iron_sword",3)
			last_reward += " · Rare Iron Sword"
	s.kills[id] = int(s.kills.get(id,0))+1
	s.gold += reward_gold
	gain(enemy.drop,int(enemy.qty))
	var xp = int(enemy.xp)
	s.xp.bladecraft += xp-int(xp/3)*2
	s.xp.might += int(xp/3)
	s.xp.warding += int(xp/3)
	if rng.randf()<.05:
		var part = ["sword","shield","helm","chest","gloves","boots"][rng.randi_range(0,5)]
		var q = quality_roll()
		var metal = "iron_" if enemy.has("region") else "copper_"
		gain(metal+part,1,q)
		RealmHunts.equipment(self,metal+part,q)
		note("Loot: %s %s" % [data.rarities[q],name_of(metal+part)])
	if id=="bellkeeper" and not s.beacon:
		s.beacon = true
		gain("copper_sword",1,3)
		RealmHunts.equipment(self,"copper_sword",3)
		note("The bells fall silent. Cinderwatch burns bright again.")
	s.queue[0].done += 1
	s.queue[0].output += int(enemy.qty)
	s.fight = {}
	s.regen_at = int(s.time)+1000
	check_quest()
	RealmHunts.victory(self,enemy,before_gains,before_gold,fragments)
	if step_complete(s.queue[0]): RealmHunts.finish(self,"Completed")

func objective() -> Dictionary:
	return RealmJourney.current(self)

func check_quest():
	if s.tutorial: return
	var weapon = gear(str(s.equipped.get("weapon","")))
	if not weapon.is_empty() and weapon.id in ["copper_sword","iron_sword"] and int(s.kills.get("ash_rat",0))>=3 and int(s.gains.get("copper_sword",0))>=1 and int(s.gains.get("copper_ingot",0))>=2 and int(s.gains.get("copper_ore",0))>=4 and int(s.gains.get("ash_log",0))>=1:
		s.tutorial = true
		s.gold += 30
		gain("cooked_minnow",10)
		note("First Supplies complete · +30 gold · +10 grilled minnows")

func activity_name(id: String) -> String:
	var a = data.activities[id]
	if a.kind=="combat": return local_name(data.enemies[a.enemy])
	return name_of(a.output)

func sources(id: String) -> Array:
	var out = []
	for key in data.activities:
		var a = data.activities[key]
		if a.output==id or a.get("side","")==id: out.append(key)
	return out
