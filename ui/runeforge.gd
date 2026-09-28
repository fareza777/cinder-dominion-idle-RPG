extends RefCounted

const U = preload("res://ui/style.gd")
const R = preload("res://game/runeforge.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func rune_art(id: String, size: int = 100) -> TextureRect:
	var t = TextureRect.new()
	t.custom_minimum_size = Vector2(size,size)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/runestones.png"):
		var atlas = AtlasTexture.new()
		atlas.atlas = load("res://assets/art/runestones.png")
		var width = atlas.atlas.get_width()/3.0
		atlas.region = Rect2(R.RUNES.keys().find(id)*width,0,width,atlas.atlas.get_height())
		atlas.filter_clip = true
		t.texture = atlas
	return t

func forge(selected: String = "thorn"):
	var v = app.modal("The Runeforge")
	if not m.s.beacon:
		v.add_child(U.para("Some inscriptions sleep until the beacon burns again.",25,U.TEXT))
		v.add_child(U.para("Defeat the Bellkeeper to reach the expedition guardians. Their fragments can be forged into runes that change how you fight. Your current journey comes first.",15))
		app.modal_action("Follow my journey",app.guide_dialog)
		return
	var s = R.state(m)
	var d = R.RUNES[selected]
	var rank = int(s.ranks[selected])
	var tabs = U.row(5)
	v.add_child(tabs)
	for id in R.RUNES:
		var tab = U.button(R.RUNES[id].name,func(): forge(id),selected==id)
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.add_theme_font_size_override("font_size",int(13*U.scale))
		tabs.add_child(tab)
	var hero = U.card(v,16,Color(d.color).darkened(.45))
	var row = U.row(12)
	hero.add_child(row)
	row.add_child(rune_art(selected))
	var title = U.column(6)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	title.add_child(U.para(d.name,26,Color(d.color)))
	title.add_child(U.para("NOT YET INSCRIBED" if rank==0 else "RANK %d / 3%s" % [rank," · EQUIPPED" if s.equipped==selected else ""],12,U.GOLD))
	hero.add_child(U.para(d.lore,14))
	if rank>0:
		hero.add_child(U.para("CURRENT INSCRIPTION",10,U.GOLD))
		hero.add_child(U.para(R.effect(selected,rank),15,U.TEXT))
	if rank<3:
		v.add_child(U.para("Inscription I" if rank==0 else "Next inscription · rank "+str(rank+1),22,U.TEXT))
		v.add_child(U.para(R.effect(selected,rank+1),15,Color(d.color)))
	var comparison = U.card(v,12)
	comparison.add_child(U.label("BEFORE YOU COMMIT",10,U.GOLD))
	var enemy = m.data.enemies[d.region+"_1"]
	var proposed = RealmModel.new()
	proposed.s = m.s.duplicate(true)
	R.state(proposed).ranks[selected] = mini(3,rank+1)
	R.state(proposed).equipped = selected
	comparison.add_child(U.para("Against "+m.local_name(enemy)+", with your current equipment and style:",12))
	var old_strike = RealmCombat.player_damage(m,enemy,4)
	var new_strike = RealmCombat.player_damage(proposed,enemy,4)
	var old_move = RealmCombat.move(m,enemy,3,int(m.stats().armor))
	var new_move = RealmCombat.move(proposed,enemy,3,int(proposed.stats().armor))
	comparison.add_child(U.para("Fourth-strike damage   %d → %d" % [old_strike,new_strike],14,U.GREEN if new_strike>old_strike else U.MUTED))
	if selected=="tide": comparison.add_child(U.para("Enemy recovery   %d → %d HP" % [int(old_move.heal),int(new_move.heal)],14,U.GREEN))
	comparison.add_child(U.para("Enemy special hit   %d → %d damage" % [int(old_move.damage),int(new_move.damage)],14,U.RED if new_move.damage>old_move.damage else U.MUTED))
	comparison.add_child(U.para("Current rune → selected inscription equipped. Damage shown on a hit, before criticals. No materials are spent by this preview.",11))
	if rank<3:
		var price = R.cost(rank)
		var materials = U.card(v,12)
		materials.add_child(U.label("MATERIALS · OWNED / NEEDED",10,U.GOLD))
		app.dynamic(materials,func(): return "%s fragments   %d / %d" % [RealmChronicle.RELICS[d.relic].name,int(RealmChronicle.state(m).fragments[d.relic]),int(price.fragments)],14)
		app.dynamic(materials,func(): return "Metal scraps   %d / %d    ·    Coins   %s / %s" % [m.count("scrap"),int(price.scrap),RealmEconomy.money(int(m.s.gold)),RealmEconomy.money(int(price.gold))],14)
		v.add_child(U.para("Spend these materials once to inscribe the rune permanently. Fragments are shared with relic upgrades; choose what helps your next hunt.",13))
		v.move_child(comparison.get_parent(),v.get_child_count()-1)
	v.add_child(U.para("ONE ACTIVE RUNE\nA rune works alongside your fighting style and relic. Forging does not equip it. Switch or remove it freely outside combat.",13,U.GREEN))
	if rank==0 and R.victories(m,d.region)<1: v.add_child(U.para("Discover this inscription by defeating any guardian in "+RealmChronicle.REGIONS[d.region].name+".",14,U.GOLD))
	v.add_child(U.button("Field journal · hunts & supplies",func(): journal(d.region)))
	v.add_child(U.button("Find "+RealmChronicle.RELICS[d.relic].name+" fragments",func(): preload("res://ui/chronicle.gd").new(app).farms(d.relic)))
	v.add_child(U.para("Scraps come from expedition first clears, field records, stronghold contracts and salvaging unprotected spare equipment in Bag.",12))
	if rank<3:
		if R.forge_reason(m,selected)!="": app.dynamic(app.dialog_footer,func(): return R.forge_reason(m,selected),12,U.GOLD)
		var button = app.modal_action("Inscribe "+d.name if rank==0 else "Deepen inscription · rank "+str(rank+1),func():
			if app.send({"type":"rune_forge","id":selected}):
				forge(selected)
				app.toast(d.name+" strengthened. "+("Its new rank is already active." if s.equipped==selected else "Equip it to bring its power into battle.")),rank==0 or s.equipped==selected)
		button.disabled = R.forge_reason(m,selected)!=""
		var ref = weakref(button)
		app.dialog_callbacks.append(func():
			var b = ref.get_ref()
			if is_instance_valid(b): b.disabled = R.forge_reason(m,selected)!="")
	if rank>0:
		var equip = app.modal_action("Remove equipped rune" if s.equipped==selected else "Equip "+d.name,func():
			if app.send({"type":"rune_equip","id":"" if s.equipped==selected else selected}):
				forge(selected)
				app.toast(d.name+" equipped." if s.equipped==selected else "Rune removed. Your fighting style and relic are unchanged."),s.equipped!=selected)
		equip.disabled = not m.s.fight.is_empty()
	if not m.s.fight.is_empty(): v.add_child(U.para("Retreat before forging or changing your rune.",13,U.RED))

func journal(region: String = "wilds"):
	var v = app.modal("The field journal")
	var tabs = U.row(5)
	v.add_child(tabs)
	for entry in [["wilds","Wilds"],["marsh","Sanctum"],["crown","Crown"]]:
		var b = U.button(entry[1],func(): journal(entry[0]),entry[0]==region)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabs.add_child(b)
	var d = RealmChronicle.REGIONS[region]
	var enemy = m.data.enemies[region+"_1"]
	var card = U.card(v,14,Color(d.color).darkened(.4))
	var row = U.row(14)
	card.add_child(row)
	row.add_child(U.enemy_portrait(enemy,Vector2(72,102)))
	var detail = U.column(8)
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(detail)
	detail.add_child(U.para(m.local_name(enemy).split(" · ")[0],23,Color(d.color)))
	app.dynamic(detail,func(): return "%d victories across tiers and trials" % R.victories(m,region),13)
	var tactics = U.column(10)
	tactics.add_child(U.para(RealmCombat.mechanic(enemy),14,U.TEXT))
	var tips = {"wilds":"Thornscript helps your fourth strike find a gap in armored enemies. Against the Sentinel, shorter battles also mean fewer armor-piercing attacks.","marsh":"Stillwater weakens the Oracle's recovery. It can turn a stalled hunt into a winnable one; your weapon still needs to finish the fight.","crown":"Dirge makes your fourth strike more dangerous, but every enemy hit also hurts more. Compare your food needs before committing to a long hunt."}
	tactics.add_child(U.para(tips[region],13))
	card.add_child(U.button("Study guardian tactics ▾",func(): tactics.visible = not tactics.visible))
	card.add_child(tactics)
	tactics.hide()
	v.add_child(U.para("Your field records",24,U.TEXT))
	v.add_child(U.para("All tiers and trials count, including past hunts and offline victories. Each record pays once. Progress never expires.",13))
	var ready_target = 0
	for i in range(R.MILESTONES.size()):
		var target = R.MILESTONES[i]
		var key = region+"_"+str(target)
		var claimed = key in R.state(m).claimed
		if not claimed and m.s.beacon and R.victories(m,region)>=target and ready_target==0: ready_target = target
		var record = U.card(v,12,U.GREEN.darkened(.55) if claimed else U.LINE)
		record.add_child(U.para(R.TITLES[i]+(" · CLAIMED" if claimed else ""),19,U.TEXT))
		app.dynamic(record,func(): return "%d / %d victories" % [mini(target,R.victories(m,region)),target],13,Color(d.color))
		var prize = R.reward(i)
		record.add_child(U.para("%d %s fragments · %d scraps · %d gold" % [int(prize.fragments),RealmChronicle.RELICS[d.relic].name,int(prize.scrap),int(prize.gold)],13,U.GOLD))
		if not claimed:
			var claim = U.button("Collect field supplies",func():
				if app.send({"type":"research_claim","id":region,"target":target}): journal(region),true)
			claim.disabled = not m.s.beacon or R.victories(m,region)<target
			record.add_child(claim)
			var ref = weakref(claim)
			app.dialog_callbacks.append(func():
				var button = ref.get_ref()
				if is_instance_valid(button): button.disabled = not m.s.beacon or R.victories(m,region)<target)
	var choices = RealmCombat.farms(m,d.relic).filter(func(c): return m.data.enemies[c.id].get("region","")==region)
	if ready_target>0:
		app.modal_action("Collect completed record · %d victories" % ready_target,func():
			if app.send({"type":"research_claim","id":region,"target":ready_target}):
				journal(region)
				app.toast("Field supplies received. Put them toward your next inscription or relic rank."))
	elif not choices.is_empty():
		var remaining = 10
		for target in R.MILESTONES:
			if R.victories(m,region)<target:
				remaining = target-R.victories(m,region)
				break
		var id = choices[0].id
		v.add_child(U.para("SUGGESTED HUNT\n"+m.local_name(m.data.enemies[id])+" · "+m.encounter_advice(id),13,U.GOLD))
		app.modal_action("Plan %d %s" % [remaining,"victory" if remaining==1 else "victories"],func(): app.activity_dialog("hunt_"+id,remaining))
	else: app.modal_action("Open world map",app.world_dialog)
	var rune_id = {"wilds":"thorn","marsh":"tide","crown":"bell"}[region]
	v.add_child(U.button("Visit the Runeforge · "+R.RUNES[rune_id].name,func(): forge(rune_id)))
