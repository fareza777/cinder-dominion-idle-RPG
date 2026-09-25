extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m: RealmModel

func _init(owner):
	app = owner
	m = app.model

func text(id: String, en: String) -> String:
	return app.tr2(id,en)

func heading(parent: Node, overline: String, title: String, subtitle: String = ""):
	var v = U.column(3)
	parent.add_child(v)
	v.add_child(U.label(overline,10,U.GOLD))
	var title_label = U.label(title,38,U.TEXT,true)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(title_label)
	if subtitle!="": v.add_child(U.para(subtitle,14))

func village(parent: Node):
	heading(parent,text("BAB I  /  SUAKA TERAKHIR","CHAPTER I  /  THE LAST REFUGE"),"Cinderwatch")
	preload("res://ui/chronicle.gd").new(app).home(parent)
	var scene = Control.new()
	scene.custom_minimum_size.y = 150
	scene.clip_contents = true
	parent.add_child(scene)
	var art = TextureRect.new()
	art.texture = load("res://assets/art/cinderwatch.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.add_child(art)
	var gradient = Gradient.new()
	gradient.set_color(0,Color(0,0,0,0))
	gradient.set_color(1,Color("0d1318"))
	var tex = GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill_from = Vector2(.5,0)
	tex.fill_to = Vector2(.5,1)
	var veil = TextureRect.new()
	veil.texture = tex
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene.add_child(veil)
	var particles = Control.new()
	particles.set_script(load("res://ui/atmosphere.gd"))
	particles.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	particles.motion = m.s.settings.motion
	scene.add_child(particles)
	var scene_text = U.column(4)
	scene_text.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	scene_text.offset_top = -74
	scene_text.offset_left = 16
	scene_text.offset_right = -16
	scene.add_child(scene_text)
	scene_text.add_child(U.label(text("DI ANTARA ABU, MASIH ADA HARAPAN","AMONG THE ASHES, HOPE REMAINS"),10,U.GOLD))
	scene_text.add_child(U.label(text("Jaga agar api tetap menyala.","Keep the last fire burning."),27,U.TEXT,true))
	var links = U.row(10)
	parent.add_child(links)
	for entry in [["skills",text("KUMPULKAN & TEMPA","GATHER & FORGE"),text("Keahlian","Skills")],["explore",text("DI BALIK GERBANG","BEYOND THE GATE"),text("Jelajah","Explore")]]:
		var c = U.card(links,12)
		c.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.add_child(U.label(entry[1],8,U.GOLD))
		c.add_child(U.button(entry[2]+" →",func(): app.set_page(entry[0])))
	var contracts = U.card(parent,14,U.GOLD.darkened(.6))
	contracts.add_child(U.label("A REFUGE WORTH FIGHTING FOR",10,U.GOLD))
	app.dynamic(contracts,func(): return "%d rewards ready · %d / 8 contracts claimed" % [RealmProgression.ready_count(m),m.progression().claimed.size()],15,U.TEXT)
	contracts.add_child(U.para("Earn supplies through optional milestones. Rebuild the forge, gates, and hearth for permanent upgrades.",13))
	contracts.add_child(U.button("Refuge contracts  →",app.contracts_dialog,true))
	contracts.add_child(U.button("Rebuild Cinderwatch  →",app.refuge_dialog))
	var refuge = U.card(parent)
	refuge.add_child(U.label(text("KEHIDUPAN DI SUAKA","LIFE AT THE REFUGE"),10,U.GOLD))
	refuge.add_child(U.para(text("Tungku menempa harapan baru. Pedagang menyiapkan perbekalan untuk perjalanan berikutnya.","The forge shapes new hope. The merchant prepares supplies for your next journey.")))
	refuge.add_child(U.button(text("Kunjungi pedagang","Visit the merchant"),app.merchant_dialog))
	app.dynamic(refuge,func(): return text("Mercusuar: menyala kembali" if m.s.beacon else "Mercusuar: menunggu kejatuhan Penjaga Lonceng","Beacon: rekindled" if m.s.beacon else "Beacon: silence the Bellkeeper to rekindle it"),12,U.GOLD)
	parent.add_child(U.label(text("CATATAN TERAKHIR","RECENT CHRONICLE"),10,U.MUTED))
	app.dynamic(parent,func(): return str(m.s.log[0]) if not m.s.log.is_empty() else text("Perjalananmu baru dimulai.","Your journey is just beginning."),14,U.MUTED)

func explore(parent: Node):
	var region = m.data.enemies.get(m.s.fight.get("enemy",""),{}).get("region","")
	if region!="": heading(parent,"EXPEDITION IN PROGRESS",RealmChronicle.REGIONS[region].name,"Repeat cleared tiers for relic fragments and iron loot. Clear the next tier to push deeper into the realm.")
	else: heading(parent,"CHAPTER I · THE OUTSKIRTS","Cinderwatch Outskirts","Choose an enemy and a number of fights. Combat runs automatically. Stock cooked food and equip upgrades first.")
	var battle = U.card(parent,12,U.GOLD.darkened(.55))
	var stage = Control.new()
	stage.set_script(preload("res://ui/battle_stage.gd"))
	stage.model = m
	battle.add_child(stage)
	stage.visible = not m.s.fight.is_empty()
	app.update_callbacks.append(func():
		if is_instance_valid(stage): stage.visible = not m.s.fight.is_empty())
	app.dynamic(battle,func(): return m.last_reward if m.last_reward!="" else "Your gear is safe on defeat. Stock cooked food before a long hunt.",13,U.GREEN)
	app.dynamic(battle,func():
		if m.s.fight.is_empty(): return "Ready when you are. Choose a target below."
		var f = m.s.fight
		if m.data.enemies[f.enemy].boss:
			var special = RealmCombat.move(m,m.data.enemies[f.enemy],3,int(m.stats().armor))
			return "%s in %.1fs" % [special.label,maxf(0,(int(f.enemy_at)-int(m.s.time))/1000.0)] if int(f.hits)%3==2 else "%s · in %d enemy attacks" % [special.label,3-int(f.hits)%3]
		return "Automatic combat · skills trigger every fourth attack.",13,U.GOLD)
	var retreat = U.button("Retreat & stop queue",func(): app.send({"type":"clear"}))
	battle.add_child(retreat)
	app.update_callbacks.append(func():
		if is_instance_valid(retreat): retreat.visible = not m.s.fight.is_empty())
	var prep = U.card(parent)
	app.dynamic(prep,func(): return "%s · %d ATK · %d DEF" % [RealmProgression.STANCES[m.progression().stance].name,int(m.stats().attack),int(m.stats().armor)],16,U.GOLD)
	app.dynamic(prep,func(): return "%s ×%d · heals %d HP at %d%% health" % [m.name_of(m.s.settings.food),m.count(m.s.settings.food),RealmCombat.food_heal(m,m.s.settings.food),int(m.s.settings.threshold*100)],13,U.GREEN)
	var actions = U.row(6)
	prep.add_child(actions)
	actions.add_child(U.button("Fighting style",app.tactics_dialog))
	actions.add_child(U.button("Equip best",func():
		if app.send({"type":"equip_best"}): app.toast("Best owned equipment equipped.")))
	prep.add_child(U.button("Prepare 10 × "+m.name_of(m.s.settings.food),func(): app.planner_dialog("craft_"+str(m.s.settings.food),10)))
	parent.add_child(U.button("World map · expedition tiers",app.world_dialog,true))
	for id in m.data.enemies:
		var d = m.data.enemies[id]
		if d.has("region"): continue
		var why = m.available(id)
		var card = U.card(parent,12,U.GOLD.darkened(.55) if d.boss else U.LINE)
		var r = U.row(12)
		card.add_child(r)
		r.add_child(U.portrait(int(d.portrait),Vector2(66,80)))
		var v = U.column(4)
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_child(v)
		v.add_child(U.para(m.local_name(d),19,U.GOLD if d.boss else U.TEXT))
		v.add_child(U.label("%d HP  ·  %d ATK  ·  %d DEF" % [int(d.hp),int(d.attack),int(d.armor)],11,U.MUTED))
		app.dynamic(v,func(): return "%d %s  ·  +%d gold" % [int(m.s.kills.get(id,0)),text("dikalahkan","defeated"),int(d.gold)],11,U.MUTED)
		var next_region = {"grave_thrall":"Cinder Bandit","cinder_bandit":"Chapel Guard","chapel_guard":"Ember Wraith","ember_wraith":"Bellkeeper"}.get(id,"")
		if next_region!="":
			app.dynamic(card,func(): return "%d / 5 victories · unlock %s%s" % [mini(5,int(m.s.kills.get(id,0))),next_region," + Smithing Lv.10" if id=="ember_wraith" else ""],12,U.GOLD)
			var route_bar = U.progress(m.s.kills.get(id,0),5,U.GOLD,4)
			card.add_child(route_bar)
			app.update_callbacks.append(func():
				if is_instance_valid(route_bar): route_bar.value = m.s.kills.get(id,0))
		elif id=="hollow_hound": card.add_child(U.para("OPTIONAL HUNT · Gather meat and melee XP.",12,U.GOLD))
		if why!="": card.add_child(U.para(why,12,U.MUTED))
		else:
			app.dynamic(card,func(): return m.encounter_advice(id),12,U.MUTED)
			card.add_child(U.button(text("Tantang boss" if d.boss else "Buru & kumpulkan loot","Challenge boss" if d.boss else "Hunt & gather loot"),func(): app.activity_dialog("hunt_"+id),d.boss))

func skills(parent: Node):
	heading(parent,text("TUMBUH MELALUI LATIHAN","GROW THROUGH PRACTICE"),text("Keahlian","Skills"),text("Setiap bahan memiliki tujuan. Setiap pekerjaan meninggalkan jejak.","Gather raw materials, turn them into supplies, then equip your upgrades. Choose a skill below to see its activities."))
	if app.skill=="":
		var grid = GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation",10)
		grid.add_theme_constant_override("v_separation",10)
		parent.add_child(grid)
		for id in ["woodcutting","mining","fishing","cooking","smithing","alchemy"]:
			var skill = m.data.skills[id]
			var c = U.card(grid,12)
			c.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var icon_id = {"woodcutting":"ash_axe","mining":"copper_pick","fishing":"iron_rod","cooking":"cooked_meat","smithing":"copper_sword","alchemy":"healing_draught"}[id]
			c.add_child(U.icon(icon_id,60))
			c.add_child(U.para(m.local_name(skill),18,U.TEXT))
			app.dynamic(c,func(): return "LEVEL %d  /  100" % m.level(id),10,U.GOLD)
			var bar = U.progress(0,1,U.GOLD)
			c.add_child(bar)
			app.update_callbacks.append(func():
				if is_instance_valid(bar):
					var l = m.level(id)
					bar.value = float(m.s.xp[id]-25*(l-1)*(l-1))/maxf(1,25*l*l-25*(l-1)*(l-1)))
			c.add_child(U.button(text("Latih  →","Train  →"),func():
				app.skill = id
				app.set_page("skills")))
	else:
		parent.add_child(U.button(text("← Semua keahlian","← All skills"),func():
			app.skill = ""
			app.set_page("skills")))
		var selected = app.skill
		app.dynamic(parent,func(): return "%s · Lv.%d" % [m.local_name(m.data.skills[selected]),m.level(selected)],26,U.GOLD)
		for aid in m.data.activities:
			var a = m.data.activities[aid]
			if a.skill!=selected or a.kind=="combat": continue
			var c = U.card(parent,12)
			var r = U.row(12)
			c.add_child(r)
			r.add_child(U.icon(a.output,58))
			var v = U.column(4)
			v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			r.add_child(v)
			v.add_child(U.para(m.name_of(a.output),18,U.TEXT))
			v.add_child(U.label("Lv.%d · %.1fs · +%d XP" % [int(a.level),m.duration(a)/1000.0,int(a.xp)],12,U.GOLD))
			app.dynamic(v,func(): return text("Dimiliki: ","Owned: ")+str(m.count(a.output)),12,U.MUTED)
			if not a.inputs.is_empty():
				app.dynamic(c,func():
					var parts = []
					for id in a.inputs: parts.append("%s %d/%d" % [m.name_of(id),m.count(id),int(a.inputs[id])])
					return " · ".join(parts),12)
			app.dynamic(c,func():
				var cycles = int(m.s.mastery.get(aid,0))
				return "MASTERY %d · %d%% faster%s" % [cycles,mini(10,int(cycles/100))," · next bonus in %d cycles" % (100-cycles%100) if cycles<1000 else " · MAX"],11,U.MUTED)
			c.add_child(U.button(text("Atur aktivitas","Set activity"),func(): app.activity_dialog(aid),m.level(selected)>=int(a.level)))

func inventory(parent: Node):
	heading(parent,text("HASIL DARI SETIAP PERJALANAN","SPOILS OF EVERY JOURNEY"),text("Perbekalan","Inventory"),"Open equipment to compare stats and equip it. Cooked food can be selected for auto-heal. Sources tells you where to find more.")
	var filters = U.row(6)
	parent.add_child(filters)
	var picker = OptionButton.new()
	var kinds = ["all","equipment","material","food","potion"]
	var names = [text("Semua","All"),text("Perlengkapan","Equipment"),text("Bahan","Materials"),text("Makanan","Food"),text("Ramuan","Potions")]
	for n in names: picker.add_item(n)
	picker.selected = maxi(0,kinds.find(app.filter))
	picker.custom_minimum_size.y = 48
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filters.add_child(picker)
	picker.item_selected.connect(func(i):
		app.filter = kinds[i]
		app.set_page("inventory"))
	filters.add_child(U.button("↻",func(): app.set_page("inventory",true)))
	var search = U.row(6)
	parent.add_child(search)
	var input = LineEdit.new()
	input.placeholder_text = text("Cari nama item…","Search items…")
	input.text = app.search_text
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.custom_minimum_size.y = 48
	input.add_theme_font_override("font",U.body_font)
	search.add_child(input)
	var search_action = func():
		app.search_text = input.text
		app.set_page("inventory")
	search.add_child(U.button(text("Cari","Find"),search_action))
	input.text_submitted.connect(func(_value): search_action.call())
	var shown = 0
	if app.filter in ["all","equipment"]:
		for g in m.s.gear:
			if app.search_text!="" and not m.name_of(g.id).to_lower().contains(app.search_text.to_lower()): continue
			shown += 1
			var c = U.card(parent,12,U.QUALITY[int(g.q)].darkened(.6))
			var r = U.row()
			c.add_child(r)
			r.add_child(U.icon(g.id,58))
			var v = U.column(3)
			v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			r.add_child(v)
			v.add_child(U.para(m.name_of(g.id),17,U.TEXT))
			var tags = m.data.rarities[int(g.q)]
			if g.uid in m.s.equipped.values(): tags += text(" · Terpasang"," · Equipped")
			if g.locked: tags += text(" · Terkunci"," · Locked")
			v.add_child(U.para(tags+" · ×%d" % int(g.count),11,U.QUALITY[int(g.q)]))
			r.add_child(U.button("›",func(): app.item_dialog(g.uid)))
	for id in m.s.bag:
		if m.count(id)<=0: continue
		var d = m.data.items[id]
		if app.filter!="all" and d.category!=app.filter: continue
		if app.search_text!="" and not m.name_of(id).to_lower().contains(app.search_text.to_lower()): continue
		shown += 1
		var c = U.card(parent,12)
		var r = U.row()
		c.add_child(r)
		r.add_child(U.icon(id,50))
		var v = U.column(3)
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_child(v)
		v.add_child(U.para(m.name_of(id),17,U.TEXT))
		app.dynamic(v,func(): return "×%d" % m.count(id),14,U.GOLD)
		var actions = U.row(5)
		c.add_child(actions)
		if d.category=="food": actions.add_child(U.button(text("Auto-heal","Auto-heal"),func():
			app.send({"type":"food","id":id})
			app.toast(text("Bekal auto-heal dipilih","Auto-heal food selected"))))
		if d.category=="potion": actions.add_child(U.button(text("Gunakan otomatis","Use automatically"),func():
			app.send({"type":"potion","id":id})
			app.toast(text("Ramuan otomatis aktif","Automatic potion enabled"))))
		actions.add_child(U.button(text("Sumber","Sources"),func(): app.sources_dialog(id)))
		actions.add_child(U.button(text("Jual 1","Sell 1"),func(): app.send({"type":"sell","id":id,"amount":1})))
	if shown==0: parent.add_child(U.para(text("Tidak ada item sesuai filter ini.","No items match this filter.")))
	if not m.s.overflow.is_empty(): parent.add_child(U.button(text("Ambil item kotak hasil","Retrieve overflow items"),func(): app.send({"type":"overflow"})))
	var salvage = []
	for g in m.s.gear:
		if not m.protected(g.uid) and g.q<=1: salvage.append(g.uid)
	if not salvage.is_empty(): parent.add_child(U.button(text("Tinjau peleburan item umum…","Review common item salvage…"),func(): app.salvage_dialog(salvage)))

func character(parent: Node):
	heading(parent,text("SUMPAH YANG BELUM PADAM","AN OATH STILL BURNING"),text("Penjaga Bara","The Emberkeeper"))
	var c = U.card(parent)
	var row = U.row(18)
	c.add_child(row)
	row.add_child(U.portrait(0,Vector2(112,146)))
	var v = U.column(8)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(v)
	v.add_child(U.label(text("Pengembara","Wanderer"),28,U.TEXT,true))
	app.dynamic(v,func(): return "HP %d / 100" % int(m.s.hp),18,U.GREEN)
	app.dynamic(v,func(): return "%d ATK  ·  %d DEF" % [int(m.stats().attack),int(m.stats().armor)],16,U.GOLD)
	v.add_child(U.para(text("Kekuatan tumbuh dari perjalanan, bukan pembelian.","Strength is earned through your journey."),12))
	for id in ["bladecraft","might","warding"]:
		app.dynamic(c,func(): return "%s   Lv.%d   ·   %d XP" % [m.local_name(m.data.skills[id]),m.level(id),int(m.s.xp[id])],15)
	var legacy = U.card(parent,14,U.GOLD.darkened(.5))
	legacy.add_child(U.label("OATHS & RELICS",10,U.GOLD))
	app.dynamic(legacy,func(): return "%d talent points available · %s" % [RealmChronicle.points_free(m),RealmChronicle.RELICS[RealmChronicle.state(m).relic].name if RealmChronicle.state(m).relic!="" else "No relic equipped"],14,U.TEXT)
	legacy.add_child(U.button("Talents · choose your strengths",app.talents_dialog,true))
	legacy.add_child(U.button("Relics · targeted progression",app.relics_dialog))
	var style = U.card(parent)
	style.add_child(U.label("YOUR FIGHTING STYLE",10,U.GOLD))
	app.dynamic(style,func(): return RealmProgression.STANCES[m.progression().stance].name,24,U.TEXT)
	app.dynamic(style,func(): return RealmProgression.STANCES[m.progression().stance].detail,14)
	style.add_child(U.button("Choose fighting style",app.tactics_dialog,true))
	style.add_child(U.button("Equip best owned gear",func():
		if app.send({"type":"equip_best"}): app.toast("Best owned equipment equipped.")))
	var food = U.card(parent)
	food.add_child(U.label(text("PERSEDIAAN TEMPUR","BATTLE SUPPLIES"),10,U.GOLD))
	app.dynamic(food,func(): return "%s ×%d" % [m.name_of(m.s.settings.food),m.count(m.s.settings.food)],17,U.TEXT)
	food.add_child(U.para(text("Makanan digunakan ketika HP turun ke ambang pilihanmu. HP nol tetap berarti kalah.","Food is used when HP drops to your chosen threshold. Zero HP still means defeat."),13))
	var threshold = HSlider.new()
	threshold.min_value = .1
	threshold.max_value = .9
	threshold.step = .1
	threshold.value = float(m.s.settings.threshold)
	threshold.custom_minimum_size.y = 40
	food.add_child(threshold)
	app.dynamic(food,func(): return text("Ambang auto-heal: ","Auto-heal threshold: ")+"%d%%" % int(m.s.settings.threshold*100),13,U.GOLD)
	threshold.value_changed.connect(func(value): app.send({"type":"setting","id":"threshold","value":value},false))
	app.dynamic(food,func(): return text("Ramuan: ","Potion: ")+(m.name_of(m.s.settings.potion) if m.s.settings.potion!="" else text("Tidak aktif","Disabled")),14)
	food.add_child(U.button(text("Nonaktifkan ramuan","Disable potion"),func(): app.send({"type":"potion","id":""})))
	food.add_child(U.button("Get more food · step-by-step",app.experience.survival))
	var presets = U.card(parent)
	presets.add_child(U.label(text("PRESET PERLENGKAPAN","EQUIPMENT PRESETS"),10,U.GOLD))
	for name in ["Guardian","Reaver"]:
		var r = U.row(8)
		presets.add_child(r)
		r.add_child(U.label(name,17))
		r.add_child(U.spacer())
		r.add_child(U.button(text("Simpan","Save"),func():
			app.send({"type":"preset_save","id":name})
			app.toast(text("Preset tersimpan","Preset saved"))))
		if m.s.presets.has(name): r.add_child(U.button(text("Pakai","Use"),func(): app.send({"type":"preset_load","id":name})))
	parent.add_child(U.button(text("Pengaturan & cadangan","Settings & backups"),app.settings_dialog))
