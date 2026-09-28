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
	U.scenic(parent,page_art(0),"YOUR STRONGHOLD","Cinderwatch",210)
	preload("res://ui/chronicle.gd").new(app).home(parent)
	preload("res://ui/upgrade_goal.gd").new(app).home(parent)
	preload("res://ui/chronicle.gd").new(app).services(parent)

func explore(parent: Node):
	var region = m.data.enemies.get(m.s.fight.get("enemy",""),{}).get("region","")
	var current_enemy = m.data.enemies.get(m.s.fight.get("enemy",""),{})
	if current_enemy.has("secret_tile"): heading(parent,"OPTIONAL EXPEDITION",current_enemy.location,"")
	elif current_enemy.get("trial",false): heading(parent,"GUARDIAN TRIAL",m.local_name(current_enemy),"")
	elif region!="": heading(parent,"EXPEDITION IN PROGRESS",RealmChronicle.REGIONS[region].name,"")
	else:
		if m.s.fight.is_empty(): U.scenic(parent,page_art(1),"CHAPTER I · HUNTING GROUNDS","Cinderwatch Outskirts",160)
		else: heading(parent,"CHAPTER I · THE OUTSKIRTS","Cinderwatch Outskirts","")
	var battle = U.card(parent,12,U.GOLD.darkened(.55))
	var battle_panel = battle.get_parent()
	battle_panel.visible = not m.s.fight.is_empty() or m.last_reward!=""
	app.update_callbacks.append(func():
		if is_instance_valid(battle_panel): battle_panel.visible = not m.s.fight.is_empty() or m.last_reward!="")
	var stage = Control.new()
	stage.set_script(preload("res://ui/battle_stage.gd"))
	stage.model = m
	battle.add_child(stage)
	stage.visible = not m.s.fight.is_empty()
	app.update_callbacks.append(func():
		if is_instance_valid(stage): stage.visible = not m.s.fight.is_empty())
	var result_label = app.dynamic(battle,func(): return m.last_reward if m.last_reward!="" else "",13,U.GREEN)
	app.update_callbacks.append(func():
		if is_instance_valid(result_label): result_label.add_theme_color_override("font_color",U.RED if m.last_reward.begins_with("DEFEAT") else U.GREEN))
	app.dynamic(battle,func():
		if m.s.fight.is_empty(): return "Choose a target"
		var f = m.s.fight
		if m.data.enemies[f.enemy].boss:
			var special = RealmCombat.move(m,m.data.enemies[f.enemy],3,int(m.stats().armor),RealmTrials.active_phase(m,m.data.enemies[f.enemy]))
			return "%s in %.1fs" % [special.label,maxf(0,(int(f.enemy_at)-int(m.s.time))/1000.0)] if int(f.hits)%3==2 else "%s · in %d enemy attacks" % [special.label,3-int(f.hits)%3]
		return "Automatic combat · skills trigger every fourth attack.",13,U.GOLD)
	app.dynamic(battle,func():
		if m.s.fight.is_empty(): return ""
		var enemy = m.data.enemies[m.s.fight.enemy]
		if enemy.get("secret",false) or enemy.get("depth",false):
			return "PHASE II · Heavy-strike pressure doubled. Finish the fight before danger builds." if RealmTrials.active_phase(m,enemy) else "PHASE I · Danger rises every 15 enemy attacks."
		if not enemy.get("trial",false): return ""
		return "PHASE II · "+RealmTrials.phase_text(enemy) if RealmTrials.active_phase(m,enemy) else "PHASE I · The guardian awakens at half health.",13,U.RED)
	var retreat = U.button("Retreat & stop queue",func(): app.send({"type":"clear"}))
	var finish = U.button("Return after this fight",app.finish_hunt_dialog)
	battle.add_child(finish)
	app.update_callbacks.append(func():
		if is_instance_valid(finish): finish.visible = not m.s.fight.is_empty())
	battle.add_child(retreat)
	app.update_callbacks.append(func():
		if is_instance_valid(retreat): retreat.visible = not m.s.fight.is_empty())
	battle.add_child(U.button("Hunt reports",app.hunt_reports_dialog))
	var prep = U.card(parent,14)
	U.section(prep,"HUNT PREPARATION")
	app.dynamic(prep,func(): return "%s · %d ATK · %d DEF" % [RealmProgression.STANCES[m.progression().stance].name,int(m.stats().attack),int(m.stats().armor)],16,U.GOLD)
	app.dynamic(prep,func(): return "%s ×%d · heals %d HP at %d%% health" % [m.name_of(m.s.settings.food),m.count(m.s.settings.food),RealmCombat.food_heal(m,m.s.settings.food),int(m.s.settings.threshold*100)],13,U.GREEN)
	var preparation_actions = U.row(6)
	prep.add_child(preparation_actions)
	for entry in [["Prepare for a hunt",hunt_preparation],["More hunts",hunt_routes]]:
		var action = U.button(entry[0],entry[1])
		action.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		preparation_actions.add_child(action)
	U.section(parent,"DISCOVERED ENEMIES")
	for id in m.data.enemies:
		var d = m.data.enemies[id]
		if d.has("region"): continue
		if not RealmDiscovery.visible(m,id): continue
		var why = m.available(id)
		var card = U.card(parent,12,U.GOLD.darkened(.55) if d.boss else U.LINE)
		var r = U.row(12)
		card.add_child(r)
		r.add_child(U.enemy_portrait(d,Vector2(82,100)))
		var v = U.column(4)
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_child(v)
		v.add_child(U.para(m.local_name(d),19,U.GOLD if d.boss else U.TEXT))
		v.add_child(U.para("%d HP  ·  %d ATK  ·  %d DEF" % [int(d.hp),int(d.attack),int(d.armor)],11,U.MUTED))
		app.dynamic(v,func(): return "%d %s  ·  +%d gold" % [int(m.s.kills.get(id,0)),text("dikalahkan","defeated"),RealmHuntMastery.gold(m,d)],11,U.MUTED)
		var next_region = {"grave_thrall":"the next hunt","cinder_bandit":"the next hunt","chapel_guard":"the next hunt","ember_wraith":"the next hunt"}.get(id,"")
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
			card.add_child(U.button(text("Tantang boss" if d.boss else "Buru & kumpulkan loot","Challenge boss" if d.boss else "Hunt & gather loot"),func(): app.activity_dialog("hunt_"+id),true))

func skills(parent: Node):
	U.scenic(parent,page_art(2),"GATHER · CRAFT · ADVANCE","Skills",156)
	parent.add_child(U.button("Gear paths · level 25–100",func(): preload("res://ui/ascension.gd").new(app).open()))
	preload("res://ui/training.gd").new(app).home(parent)
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
			c.add_child(U.icon(icon_id,72))
			c.add_child(U.para(m.local_name(skill),18,U.TEXT))
			c.add_child(U.para({"woodcutting":"Timber & logs","mining":"Ore & minerals","fishing":"Fresh supplies","cooking":"Food for hunts","smithing":"Weapons & armor","alchemy":"Combat potions"}[id],12))
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
		preload("res://ui/level_progress.gd").show_progress(app,parent,selected)
		var visibility = U.row(6)
		parent.add_child(visibility)
		for choice in [[false,"Available"],[true,"All recipes"]]:
			visibility.add_child(U.button(choice[1],func():
				app.show_locked_recipes = choice[0]
				app.set_page("skills",true),app.show_locked_recipes==choice[0]))
		for aid in m.data.activities:
			var a = m.data.activities[aid]
			if a.skill!=selected or a.kind=="combat": continue
			if not app.show_locked_recipes and m.level(selected)<int(a.level): continue
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
	U.scenic(parent,page_art(3),"EQUIPMENT · MATERIALS · SUPPLIES","Inventory",150)
	parent.add_child(U.para("Select an item to equip it, use it or find its source.",13))
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
		app.inventory_page = 0
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
		app.inventory_page = 0
		app.set_page("inventory")
	search.add_child(U.button(text("Cari","Find"),search_action))
	input.text_submitted.connect(func(_value): search_action.call())
	var options = U.row(6)
	parent.add_child(options)
	var sorter = OptionButton.new()
	for label in ["Equipped first","Name","Highest quality","Highest stats"]: sorter.add_item(label)
	sorter.selected = app.inventory_sort
	sorter.custom_minimum_size.y = 48
	sorter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sorter.item_selected.connect(func(index):
		app.inventory_sort = index
		app.inventory_page = 0
		app.set_page("inventory"))
	options.add_child(sorter)
	var slots = ["all","weapon","shield","head","body","hands","feet","necklace","belt","ring","axe","pick","rod"]
	var slot_picker = OptionButton.new()
	for slot in slots: slot_picker.add_item("All slots" if slot=="all" else slot.capitalize())
	slot_picker.selected = maxi(0,slots.find(app.inventory_slot))
	slot_picker.custom_minimum_size.y = 48
	slot_picker.item_selected.connect(func(index):
		app.inventory_slot = slots[index]
		app.inventory_page = 0
		app.set_page("inventory"))
	options.add_child(slot_picker)
	var shown = 0
	if app.filter in ["all","equipment"]:
		var gear_list = m.s.gear.filter(func(g): return (app.search_text=="" or m.name_of(g.id).to_lower().contains(app.search_text.to_lower())) and (app.inventory_slot=="all" or m.data.items[g.id].slot==app.inventory_slot))
		gear_list.sort_custom(func(a,b):
			match app.inventory_sort:
				0:
					var ae = a.uid in m.s.equipped.values()
					var be = b.uid in m.s.equipped.values()
					if ae!=be: return ae
				2:
					if a.q!=b.q: return a.q>b.q
				3:
					if m.gear_score(a)!=m.gear_score(b): return m.gear_score(a)>m.gear_score(b)
			return m.name_of(a.id)<m.name_of(b.id) if a.id!=b.id else a.uid<b.uid)
		var last_page = maxi(0,ceili(gear_list.size()/30.0)-1)
		app.inventory_page = mini(app.inventory_page,last_page)
		if last_page>0:
			var pager = U.row(6)
			parent.add_child(pager)
			pager.add_child(U.button("Previous",func():
				app.inventory_page = maxi(0,app.inventory_page-1)
				app.set_page("inventory")))
			pager.add_child(U.para("%d / %d" % [app.inventory_page+1,last_page+1],14))
			pager.add_child(U.button("Next",func():
				app.inventory_page = mini(last_page,app.inventory_page+1)
				app.set_page("inventory")))
		if not gear_list.is_empty(): U.section(parent,"EQUIPMENT")
		var gear_grid = item_grid(parent)
		for g in gear_list.slice(app.inventory_page*30,(app.inventory_page+1)*30):
			shown += 1
			var c = U.card(gear_grid,10,U.QUALITY[int(g.q)].darkened(.65))
			c.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
			c.add_child(U.icon(g.id,70))
			c.add_child(U.para(m.name_of(g.id),16,U.TEXT))
			var tags = m.data.rarities[int(g.q)]
			if g.uid in m.s.equipped.values(): tags += " · Equipped"
			if g.locked: tags += " · Locked"
			c.add_child(U.para(tags+" · ×%d" % int(g.count),11,U.QUALITY[int(g.q)]))
			c.add_child(U.spacer())
			c.add_child(U.button("Inspect",func(): app.item_dialog(g.uid)))
	var supply_grid = item_grid(parent)
	for id in m.s.bag:
		if m.count(id)<=0: continue
		var d = m.data.items[id]
		if app.filter!="all" and d.category!=app.filter: continue
		if app.search_text!="" and not m.name_of(id).to_lower().contains(app.search_text.to_lower()): continue
		shown += 1
		var c = U.card(supply_grid,10)
		c.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.add_child(U.icon(id,64))
		c.add_child(U.para(m.name_of(id),16,U.TEXT))
		app.dynamic(c,func(): return "×%d" % m.count(id),14,U.GOLD)
		c.add_child(U.spacer())
		c.add_child(U.button("Details",func(): supply_details(id)))
	if shown==0: parent.add_child(U.para(text("Tidak ada item sesuai filter ini.","No items match this filter.")))
	if not m.s.overflow.is_empty(): parent.add_child(U.button(text("Ambil item kotak hasil","Retrieve overflow items"),func(): app.send({"type":"overflow"})))
	var salvage = []
	for g in m.s.gear:
		if not m.protected(g.uid) and g.q<=1: salvage.append(g.uid)
	if not salvage.is_empty(): parent.add_child(U.button(text("Tinjau peleburan item umum…","Review common item salvage…"),func(): app.salvage_dialog(salvage)))

func character(parent: Node):
	heading(parent,"EQUIPMENT & BUILD",RealmCharacters.hero_name(m))
	preload("res://ui/hero_equipment.gd").new(app).home(parent)
	parent.add_child(U.button("Attributes & class skill" if RealmCharacters.id(m)!="" else "Choose your character · keep progress",func(): preload("res://ui/character_stats.gd").new(app).open(),true))
	var c = U.card(parent)
	c.add_child(U.label("COMBAT SKILLS",11,U.GOLD))
	for id in ["bladecraft","might","warding"]:
		app.dynamic(c,func(): return "%s   Lv.%d   ·   %d XP" % [m.local_name(m.data.skills[id]),m.level(id),int(m.s.xp[id])],15)
	var legacy = U.card(parent,14,U.GOLD.darkened(.5))
	legacy.add_child(U.label("OATHS & RELICS",10,U.GOLD))
	app.dynamic(legacy,func(): return "%d talent points available · %s" % [RealmChronicle.points_free(m),RealmChronicle.RELICS[RealmChronicle.state(m).relic].name if RealmChronicle.state(m).relic!="" else "No relic equipped"],14,U.TEXT)
	legacy.add_child(U.button("Talents · choose your strengths",app.talents_dialog,true))
	legacy.add_child(U.button("Relics · targeted progression",app.relics_dialog))
	legacy.add_child(U.button("Runeforge · refine your build",app.runeforge_dialog))
	app.dynamic(legacy,func(): return "Rune: "+(RealmRuneforge.RUNES[RealmRuneforge.state(m).equipped].name if RealmRuneforge.state(m).equipped!="" else "None equipped"),13,U.GREEN)
	var style = U.card(parent)
	style.add_child(U.label("YOUR FIGHTING STYLE",10,U.GOLD))
	app.dynamic(style,func(): return RealmProgression.STANCES[m.progression().stance].name,24,U.TEXT)
	app.dynamic(style,func(): return RealmProgression.STANCES[m.progression().stance].detail,14)
	style.add_child(U.button("Choose fighting style",app.tactics_dialog,true))
	style.add_child(U.button("Save & switch complete loadouts",app.loadouts_dialog))
	app.dynamic(style,func(): return RealmGearSets.summary(m),14,U.GOLD)
	style.add_child(U.button("Armor sets · choose your bonuses",func(): preload("res://ui/gear_sets.gd").new(app).open()))
	style.add_child(U.button("Refine equipment at the workshop",app.workshop_dialog))
	style.add_child(U.button("Equip highest-stat gear",func():
		if app.send({"type":"equip_best"}): app.toast("Highest-stat equipment equipped. Review armor sets before your next hunt.")))
	style.add_child(U.para("Auto-equip compares base stats. It may break an armor set.",12))
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
	presets.add_child(U.label("LEGACY GEAR PRESETS",10,U.GOLD))
	presets.add_child(U.para("Older gear-only presets remain available. Use complete loadouts above to save your entire build.",12))
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

func page_art(index: int) -> Texture2D:
	return U.atlas_tile("res://assets/art/page-environments-0.36.png",index,2,2)

func item_grid(parent: Node) -> GridContainer:
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation",10)
	grid.add_theme_constant_override("v_separation",10)
	parent.add_child(grid)
	return grid

func supply_details(id: String):
	var d = m.data.items[id]
	var v = app.modal(m.name_of(id))
	v.add_child(U.icon(id,104))
	app.dynamic(v,func(): return "%d in your bag" % m.count(id),20,U.GOLD)
	if d.category=="food":
		v.add_child(U.para("Restores %d HP when your health falls below the auto-heal threshold." % RealmCombat.food_heal(m,id),15))
		v.add_child(U.button("Use for auto-heal",func():
			app.send({"type":"food","id":id})
			app.toast("Auto-heal food selected"),true))
	if d.category=="potion":
		v.add_child(U.button("Use automatically",func():
			app.send({"type":"potion","id":id})
			app.toast("Automatic potion enabled"),true))
	v.add_child(U.button("Where to find it",func(): app.sources_dialog(id)))
	var sell = U.button("Sell 1",func(): app.send({"type":"sell","id":id,"amount":1}))
	v.add_child(sell)
	var ref = weakref(sell)
	app.dialog_callbacks.append(func():
		var button = ref.get_ref()
		if is_instance_valid(button): button.disabled = m.count(id)<=0)

func hunt_preparation():
	var prep = app.modal("Hunt preparation")
	app.dynamic(prep,func(): return "%s · %d ATK · %d DEF" % [RealmProgression.STANCES[m.progression().stance].name,int(m.stats().attack),int(m.stats().armor)],19,U.GOLD)
	app.dynamic(prep,func(): return "%s ×%d · heals %d HP at %d%% health" % [m.name_of(m.s.settings.food),m.count(m.s.settings.food),RealmCombat.food_heal(m,m.s.settings.food),int(m.s.settings.threshold*100)],15,U.GREEN)
	prep.add_child(U.button("Prepare 10 × "+m.name_of(m.s.settings.food),func(): app.planner_dialog("craft_"+str(m.s.settings.food),10),true))
	prep.add_child(U.button("Fighting style",app.tactics_dialog))
	prep.add_child(U.button("Equip highest-stat gear",func():
		if app.send({"type":"equip_best"}): app.toast("Highest-stat equipment equipped. Review armor sets before your next hunt.")))
	prep.add_child(U.para("Auto-equip compares base stats. It may break an armor set.",12))

func hunt_routes():
	var parent = app.modal("Hunts & progression")
	parent.add_child(U.button("Ascension · gear & apex hunts",func(): preload("res://ui/ascension.gd").new(app).open()))
	parent.add_child(U.button("Hunt mastery",func(): preload("res://ui/hunt_mastery.gd").new(app).open()))
	if m.s.beacon:
		var routes = U.row(6)
		parent.add_child(routes)
		routes.add_child(U.button("World map",app.world_dialog,true))
		routes.add_child(U.button("Trials",app.trials_dialog))
