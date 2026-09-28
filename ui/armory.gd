extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func workshop(uid: String = "", target: String = ""):
	var v = app.modal("The Ember Workshop")
	if not m.s.tutorial:
		v.add_child(U.para("Upgrade equipment quality",27,U.TEXT))
		v.add_child(U.para("Finish First Supplies to unlock refinement. Then turn forged metal equipment into dependable upgrades with ingots, scraps and earned coins. No failed rolls; no lost levels.",15))
		app.modal_action("Finish First Supplies",app.guide_dialog)
		return
	var g = m.gear(uid)
	if g.is_empty():
		v.add_child(U.para("Choose a piece to improve",26,U.TEXT))
		v.add_child(U.para("Refine one piece at a time through Fine, Rare, Epic and Legendary. Each step is guaranteed. Equipped pieces appear first.",14))
		var choices = m.s.gear.filter(func(item): return RealmWorkshop.eligible(m,item))
		choices.sort_custom(func(a,b):
			if (a.uid in m.s.equipped.values())!=(b.uid in m.s.equipped.values()): return a.uid in m.s.equipped.values()
			return m.gear_score(a)>m.gear_score(b))
		for item in choices:
			var card = U.card(v,12)
			var row = U.row(12)
			card.add_child(row)
			row.add_child(U.icon(item.id,56))
			var details = U.column(4)
			details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(details)
			details.add_child(U.para(m.name_of(item.id),18,U.TEXT))
			details.add_child(U.para(m.data.rarities[int(item.q)]+(" · Equipped" if item.uid in m.s.equipped.values() else " · In your bag"),12,U.QUALITY[int(item.q)]))
			card.add_child(U.button("Review refinement" if item.q<5 else "View finished piece",func(): workshop(item.uid),item.uid==m.s.equipped.get("weapon","")))
		if choices.is_empty(): v.add_child(U.button("Forge a copper sword first",func(): app.planner_dialog("craft_copper_sword",1),true))
		return
	var d = m.data.items[g.id]
	var rank = int(g.q)
	var hero = U.card(v,16,U.QUALITY[rank].darkened(.35))
	var row = U.row(14)
	hero.add_child(row)
	row.add_child(U.icon(g.id,88))
	var details = U.column(5)
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(details)
	details.add_child(U.para(m.name_of(g.id),24,U.TEXT))
	details.add_child(U.para(m.data.rarities[rank]+(" → "+m.data.rarities[rank+1] if rank<5 else " · Masterwork"),15,U.QUALITY[mini(rank+1,5)]))
	for stat in ["attack","armor"]:
		if d.get(stat,0)>0:
			var value = float(d[stat])*RealmModel.QUALITY[rank]
			hero.add_child(U.para("%s contribution   %.1f" % [stat.capitalize(),value] if rank>=5 else "%s contribution   %.1f → %.1f" % [stat.capitalize(),value,float(d[stat])*RealmModel.QUALITY[rank+1]],16,U.GREEN))
	if rank>=5:
		v.add_child(U.para("The forge can take this piece no further. Your skills, relic and rune can still shape what it becomes in battle.",16))
		app.modal_action("Return to the workshop",func(): workshop())
		return
	var price = RealmWorkshop.cost(g)
	v.add_child(U.para("Cost: %d gold · %d %s · %d scraps
Requires Smithing Lv.%d" % [int(price.gold),int(price.ingots),m.name_of(price.metal),int(price.scrap),int(price.level)],13,U.GOLD))
	preload("res://ui/upgrade_preview.gd").new(app).show_preview(v,uid,target,func(enemy): workshop(uid,enemy))
	var materials = U.card(v,14)
	materials.add_child(U.label("UPGRADE COST · OWNED / NEEDED",10,U.GOLD))
	app.dynamic(materials,func(): return "Coins  %s / %s" % [RealmEconomy.money(int(m.s.gold)),RealmEconomy.money(int(price.gold))],16)
	app.dynamic(materials,func(): return "%s  %d / %d" % [m.name_of(price.metal),m.count(price.metal),int(price.ingots)],16)
	app.dynamic(materials,func(): return "Metal scraps  %d / %d" % [m.count("scrap"),int(price.scrap)],16)
	app.dynamic(materials,func(): return "Smithing  Lv.%d / %d" % [m.level("smithing"),int(price.level)],13,U.GOLD)
	var copy_note = "Refines this piece." if g.count==1 else "Refines one of your %d copies; the rest keep their current quality." % int(g.count)
	v.add_child(U.para(copy_note+" Equipped slots and saved builds follow the upgrade. Locks and favorites are preserved.",13))
	var missing_gold = maxi(0,int(price.gold)-int(m.s.gold))
	var missing_scraps = maxi(0,int(price.scrap)-m.count("scrap"))
	if missing_gold>0 or missing_scraps>0:
		v.add_child(U.para("Still needed: %d gold · %d scraps" % [missing_gold,missing_scraps],14,U.GOLD))
		v.add_child(U.button("Check contract rewards",app.contracts_dialog))
		if m.s.beacon: v.add_child(U.button("Check field record rewards",app.journal_dialog))
		if missing_scraps>0: v.add_child(U.button("Review spare gear in Bag",func():
			app.dismiss()
			app.set_page("inventory")))
	if m.count(price.metal)<int(price.ingots): v.add_child(U.button("Plan missing ingots",func(): app.planner_dialog("craft_"+str(price.metal),int(price.ingots)-m.count(price.metal))))
	if m.level("smithing")<price.level: v.add_child(U.button("Train Smithing to level %d" % int(price.level),func(): preload("res://ui/gameplay.gd").new(app).training("smithing",int(price.level))))
	v.add_child(U.para("Scraps come from salvage, contracts, expedition first clears and field records. Check Bag for unprotected spare equipment.",13))
	v.add_child(U.button("Choose another piece",func(): workshop()))
	app.dynamic(app.dialog_footer,func(): return RealmWorkshop.reason(m,uid),12,U.GOLD)
	var refine = app.modal_action("Refine to "+m.data.rarities[rank+1],func():
		if app.send({"type":"refine","id":uid}):
			workshop(m.last_forged,target)
			app.toast(m.data.rarities[rank+1]+" "+m.name_of(g.id)+" is ready. One piece refined."))
	refine.disabled = RealmWorkshop.reason(m,uid)!=""
	var ref = weakref(refine)
	app.dialog_callbacks.append(func():
		var button = ref.get_ref()
		if is_instance_valid(button): button.disabled = RealmWorkshop.reason(m,uid)!="")

func loadouts():
	var v = app.modal("Your battle loadouts")
	v.add_child(U.button("Compare against a hunt",func(): preload("res://ui/build_compare.gd").new(app).open()))
	v.add_child(U.para("A different answer to every enemy.",26,U.TEXT))
	v.add_child(U.para("Save gear, style, training, specialization, sockets, talents, relic, rune and supplies together. Applying a build selects its supplies; it does not create or reserve them.",14))
	var saved = RealmLoadouts.state(m)
	for id in RealmLoadouts.NAMES:
		var card = U.card(v,14)
		card.add_child(U.para(RealmLoadouts.NAMES[id],25,U.GOLD))
		if saved.has(id):
			var build = saved[id]
			var relic = RealmChronicle.RELICS[build.relic].name if build.relic!="" else "No relic"
			var rune = RealmRuneforge.RUNES[build.rune].name if build.rune!="" else "No rune"
			card.add_child(U.para(RealmProgression.STANCES[build.stance].name+" · "+relic+" · "+rune,14,U.TEXT))
			card.add_child(U.para(RealmDoctrines.ALL[build.get("doctrine","none")].name,13,U.GOLD))
			var path = int(build.get("path",-1))
			var name = RealmPaths.ALL[RealmCharacters.id(m)][path][0] if path>=0 and RealmCharacters.id(m) in RealmPaths.ALL else "No specialization"
			card.add_child(U.para("%s · %d socket relics" % [name,build.get("sockets",[]).size()],13))
			card.add_child(U.para("%d gear slots · Blade %d · Bastion %d · Fortune %d\n%s at %d%% HP · %s" % [build.gear.size(),int(build.talents.power),int(build.talents.guard),int(build.talents.fortune),m.name_of(build.food),int(build.threshold*100),m.name_of(build.potion) if build.potion!="" else "No potion"],13))
			app.dynamic(card,func(): return "In your pack: %d meals%s" % [m.count(build.food)," · %d potions" % m.count(build.potion) if build.potion!="" else ""],12,U.GREEN)
			var apply = U.button("Apply this loadout",func():
				if app.send({"type":"loadout_load","id":id}):
					loadouts()
					app.toast(RealmLoadouts.NAMES[id]+" applied. Check food and potions before leaving."),true)
			apply.disabled = not m.s.fight.is_empty()
			card.add_child(apply)
		else: card.add_child(U.para("An empty slot. Shape your build in Hero, then save it here.",14))
		card.add_child(U.button("Replace with current build" if saved.has(id) else "Save current build",func():
			if app.send({"type":"loadout_save","id":id}):
				loadouts()
				app.toast("Current build saved as "+RealmLoadouts.NAMES[id]+".")))
	v.add_child(U.para("Equipment in a saved loadout is protected from salvage. Refinement updates saved references to the improved piece. Relic and rune upgrades use their current rank when you return to a build.",12,U.GREEN))
	if not m.s.fight.is_empty(): v.add_child(U.para("Retreat before applying another loadout.",13,U.RED))
	app.modal_action("Shape my build in Hero",func():
		app.dismiss()
		app.set_page("character"))

func hunt_reports():
	preload("res://ui/hunt_review.gd").new(app).open()
