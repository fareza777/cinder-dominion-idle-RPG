extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m
func _init(owner):
	app = owner
	m = owner.model

func action(parent, title: String, cmd: Dictionary, reopen: Callable, primary: bool = false):
	parent.add_child(U.button(title,func():
		if app.send(cmd): reopen.call(),primary))

func open():
	var v = app.modal("Beyond the beacon")
	v.add_child(U.para("Choose a relic. Find its guardian. Learn the fight, then return for materials.",18,U.TEXT))
	var target = RealmEndgame.target_status(m)
	if not target.is_empty():
		var c = U.card(v,12)
		c.add_child(U.para(m.name_of(target.item),20,U.GOLD))
		app.dynamic(c,func(): return RealmEndgame.target_status(m).get("text",""),14)
	v.add_child(U.button("Optional expeditions",locations,true))
	v.add_child(U.button("Relic forge & targets",forge))
	v.add_child(U.button("Hollow Depths",depths))
	v.add_child(U.button("Hunting routes",routes))
	v.add_child(U.button("Contracts & weekly hunt",contracts))
	v.add_child(U.button("Rewarded queue assistance",assistance))
	v.add_child(U.para("Level 130 is the skill cap. Forge higher rarities, perfect relics and conquer the Shattered Realms.",14))

func locations():
	var v = app.modal("Optional expeditions")
	var revealed = 0
	for id in RealmEndgame.IDS:
		if m.available(id)!="" and m.s.kills.get(id,0)==0: break
		revealed += 1
		var e = m.data.enemies[id]
		var c = U.card(v,12,U.GOLD.darkened(.5))
		var portrait = U.enemy_portrait(e,Vector2(0,180))
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		c.add_child(portrait)
		c.add_child(U.para(e.location,21,U.GOLD))
		c.add_child(U.para(e.en,17,U.TEXT))
		c.add_child(U.para(RealmCombat.mechanic(e),14))
		c.add_child(U.para("First win: blueprint + 3 cores. Repeats: 1 core. Each win: 2 Dread Seals. Unique relics may also drop.",14))
		c.add_child(U.para("%d victories · %s" % [m.s.kills.get(id,0),m.name_of("relic_"+str(int(e.secret_tile)))],14,U.GOLD))
		c.add_child(U.button("Prepare hunt",func(): app.activity_dialog("hunt_"+id),true))
		action(c,"Track this relic",{"type":"end_target","id":"relic_"+str(int(e.secret_tile))},forge)
	if revealed<7:
		var c = U.card(v,12)
		c.add_child(U.para("Uncharted · %d locations remain" % (7-revealed),18,U.MUTED))
		c.add_child(U.para("Defeat the final Crown Apex guardian to find the first location." if revealed==0 else "Defeat the latest optional guardian to reveal the next location.",14))
	app.modal_action("Back",open,false)

func forge():
	var v = app.modal("Relic forge")
	v.add_child(U.para("Forge an unfinished component, then complete its relic. Eight victories also unlock a guaranteed purchase for 16 Dread Seals.",16))
	app.dynamic(v,func(): return "%d Dread Seals · %d Hollow Shards" % [m.count("dread_token"),m.count("depth_shard")],16,U.GOLD)
	for i in range(7):
		var boss = "secret_%d" % i
		if m.available(boss)!="" and m.s.kills.get(boss,0)==0: continue
		var id = "relic_%d" % i
		var c = U.card(v,12)
		c.add_child(U.para(m.name_of(id),21,U.GOLD))
		c.add_child(U.para(m.data.items[id].get("unique_effect",""),14))
		action(c,"Track relic" if RealmEndgame.state(m).target!=id else "Tracking this relic",{"type":"end_target","id":id},forge)
		if m.s.kills.get(boss,0)<1:
			c.add_child(U.para("Defeat this guardian to learn its blueprint.",14))
			continue
		c.add_child(U.button("1 · Forge unfinished component",func(): app.planner_dialog("craft_blank_%d" % i,1)))
		c.add_child(U.button("2 · Complete relic",func(): app.planner_dialog("craft_"+id,1)))
		action(c,"Guaranteed relic · 16 seals · %d/8 wins" % mini(8,int(m.s.kills.get(boss,0))),{"type":"end_trade","id":id},forge)
		for g in m.s.gear:
			if g.id!=id or int(g.q)>=3: continue
			var cost = 10*(int(g.q)+1)
			action(c,"Temper %s · %s + %d seals + %d shards" % [m.data.rarities[int(g.q)],RealmEconomy.money(RealmEconomy.temper_fee(int(g.q))),cost,cost],{"type":"end_temper","id":g.uid},forge)
	v.add_child(U.para("Unique relics reach Rare quality through tempering. Their special effects work only while equipped.",14))
	app.modal_action("Back",open,false)

func builds():
	var v = app.modal("Specialization & sockets")
	var character = RealmCharacters.id(m)
	if character not in RealmPaths.ALL:
		v.add_child(U.para("Choose your character from the hero screen first.",17))
		return
	v.add_child(U.para("One specialization at a time. Change it freely between hunts from Bladecraft Lv.25.",16))
	for i in range(2):
		var path = RealmPaths.ALL[character][i]
		var c = U.card(v,12)
		c.add_child(U.para(path[0],21,U.GOLD))
		c.add_child(U.para(path[1],15))
		action(c,"Selected" if m.s.get("path_choice",-1)==i else "Choose "+path[0],{"type":"path_choose","choice":i},builds)
	v.add_child(U.para("Socket relics · %d / %d equipped" % [RealmPaths.sockets(m).size(),RealmPaths.slots(m)],20,U.GOLD))
	v.add_child(U.para("Slots unlock at the beacon, Bladecraft Lv.75, and the fifth optional guardian. Each relic can be used once per build.",14))
	for id in RealmPaths.SOCKETS:
		var c = U.card(v,12)
		c.add_child(U.para(RealmPaths.SOCKETS[id][0],19,U.TEXT))
		c.add_child(U.para(RealmPaths.SOCKETS[id][1],14))
		if m.count("socket_"+id)>0:
			action(c,"Remove" if id in RealmPaths.sockets(m) else "Socket",{"type":"socket_toggle","id":id},builds)
		else: c.add_child(U.button("Forge relic",func(): app.planner_dialog("craft_socket_"+id,1)))

func routes():
	var v = app.modal("Hunting routes")
	v.add_child(U.para("Choose a route for your next hunts, including offline combat.",16))
	for id in RealmEndgame.ROUTES:
		var c = U.card(v,12)
		c.add_child(U.para({"safe":"Sheltered route","resource":"Standard route","elite":"Dangerous route","mastery":"Training route"}[id],21,U.GOLD))
		c.add_child(U.para(RealmEndgame.ROUTES[id],15))
		action(c,"Selected" if RealmEndgame.route(m)==id else "Choose route",{"type":"end_route","id":id},routes)
	app.modal_action("Back",open,false)

func depths():
	var v = app.modal("Hollow Depths")
	var d = RealmEndgame.state(m).depth
	v.add_child(U.enemy_portrait(m.data.enemies.hollow_depth,Vector2(0,140)))
	v.add_child(U.para("Clear one room, then bank your shards or risk the next. Defeat loses unbanked shards. Banked rewards and equipment stay safe.",16))
	app.dynamic(v,func(): return "Next depth %d · Best %d\n%d unbanked Hollow Shards" % [d.floor if d.active else mini(1000,int(d.get("checkpoint",0))+1),d.best,d.stash],21,U.GOLD)
	v.add_child(U.para("Rooms rotate through Fire, Frost, Bleed and Weaken threats. Every fifth room has a stronger guardian and saves a checkpoint. Bank your shards before risking the next stretch.",14))
	if m.s.kills.get("secret_2",0)<1:
		v.add_child(U.para("Defeat the third optional guardian to discover this expedition.",16,U.GOLD))
	else:
		var preview = RealmModel.new()
		preview.s = m.s.duplicate(true)
		RealmEndgame.state(preview).depth.risk = "steady"
		RealmEndgame.state(preview).depth.floor = d.floor if d.active else mini(1000,int(d.get("checkpoint",0))+1)
		RealmEndgame.state(preview).depth.active = true
		var outlook = RealmCombat.forecast(preview,"hollow_depth")
		v.add_child(U.para("Steady risk · %s\nAbout %ds · roughly %d meals · heavy hit up to %d HP" % [outlook.rating,outlook.seconds,outlook.meals,outlook.burst],15,U.GOLD))
		action(v,"Continue · steady risk" if d.active else "Enter · steady risk",{"type":"end_depth","id":"steady"},depths,true)
		action(v,"Perilous · enemy attack +20%, extra shard per room",{"type":"end_depth","id":"perilous"},depths)
		if d.active: action(v,"Bank shards & leave",{"type":"end_bank"},depths)
	app.modal_action("Back",open,false)

func contracts():
	var v = app.modal("Contracts & weekly hunt")
	v.add_child(U.para("Choose three contracts. Unfinished contracts carry over; a completed board refreshes on a later day. No streak resets.",16))
	var s = RealmEndgame.state(m)
	for id in RealmEndgame.CONTRACTS:
		var def = RealmEndgame.CONTRACTS[id]
		var c = U.card(v,12)
		c.add_child(U.para(def[0],20,U.GOLD))
		var selected = id in s.board.selected
		if selected:
			if id=="frontline":
				var target=str(s.board.target)
				c.add_child(U.para(m.local_name(m.data.enemies[target]),16))
				c.add_child(U.button("Prepare commissioned hunt",func():app.activity_dialog("hunt_"+target,6)))
			var reward=RealmEndgame.contract_reward(m,id)
			c.add_child(U.para(RealmEconomy.money(reward.gold)+" · 5 scraps"+(" · %d %s" % [reward.amount,m.name_of(reward.material)] if reward.material!="" else ""),13,U.GREEN))
			app.dynamic(c,func(): return "%d / %d" % [mini(def[1],RealmEndgame.totals(m)[id]-s.board.baseline[id]),def[1]],16)
			if id in s.board.claimed: c.add_child(U.para("Reward collected",14))
			else: action(c,"Collect commission rewards",{"type":"end_claim","id":id},contracts)
		else: action(c,"Choose · %d required" % def[1],{"type":"end_contract","id":id},contracts)
	var c = U.card(v,12)
	c.add_child(U.para("Weekly guardian",21,U.GOLD))
	if s.weekly_enemy!="":
		c.add_child(U.para(m.data.enemies[s.weekly_enemy].en,17))
		app.dynamic(c,func(): return "%d / 3 victories" % mini(3,int(m.s.kills.get(s.weekly_enemy,0))-int(s.weekly_base)),15)
		var reward=RealmEndgame.weekly_reward(m)
		c.add_child(U.para("%s · %d Dread Seals · %d Hollow Shards" % [RealmEconomy.money(reward.gold),reward.seals,reward.shards],13,U.GREEN))
		if not s.weekly_claimed: action(c,"Collect weekly rewards",{"type":"end_week_claim"},contracts)
	c.add_child(U.para("A rotating target from guardians you have beaten. An accepted hunt carries over until you finish it.",14))
	action(c,"Accept this week's hunt",{"type":"end_week"},contracts)
	app.modal_action("Back",open,false)

func assistance():
	app.ensure_ads()
	var v = app.modal("Rewarded queue assistance")
	var s = RealmAutomation.state(m)
	v.add_child(U.para("A completed rewarded ad unlocks four hours of assistance. It prepares at least 30 selected meals (more for demanding hunts), works toward your tracked relic, then repeats your chosen hunt.",16))
	v.add_child(U.para("Uses normal materials and time. Stops for unsafe or undiscovered hunts. Manual queues stay available without ads. The four hours also pass while you are away.",14))
	app.dynamic(v,func(): return "%d min remaining · %s" % [maxi(0,ceili((int(RealmAutomation.state(m).until)-int(m.s.time))/60000.0)),"On" if RealmAutomation.state(m).enabled else "Off"],20,U.GOLD)
	app.dynamic(v,func(): return str(RealmAutomation.state(m).status),14)
	preload("res://ui/ad_rewards.gd").new(app).reward_button(v,"automation")
	app.dynamic(v,func(): return str(app.ads.status),13)
	v.add_child(U.para("This preview uses Android test ads. No reward is granted when an ad is unavailable or closed early.",13))
	action(v,"Enable · tracked relic only",{"type":"assist_start","id":""},assistance)
	var hunts=m.data.enemies.keys().filter(func(id):return id!="hollow_depth" and m.available(id)=="" and int(m.s.kills.get(id,0))>0)
	if not hunts.is_empty():
		var picker=OptionButton.new();picker.custom_minimum_size.y=48;picker.fit_to_longest_item=false
		for id in hunts:picker.add_item(m.local_name(m.data.enemies[id]))
		picker.select(maxi(0,hunts.find(s.hunt)));v.add_child(picker)
		v.add_child(U.button("Enable selected hunt",func():
			if app.send({"type":"assist_start","id":hunts[picker.selected]}):assistance()))
	action(v,"Stop assistance",{"type":"assist_stop"},assistance)
	app.modal_action("Back",open,false)
