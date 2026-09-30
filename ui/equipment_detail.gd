extends RefCounted

const U = preload("res://ui/style.gd")
const SLOTS = {"weapon":"Weapon","shield":"Shield","head":"Head","body":"Body","hands":"Hands","feet":"Feet","axe":"Woodcutting tool","pick":"Mining tool","rod":"Fishing tool"}
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func open(uid: String, requested_slot: String = ""):
	var item = m.gear(uid)
	if item.is_empty(): return
	var data = m.data.items[item.id]
	var slot = RealmEquipmentSlots.target(m,uid) if requested_slot=="" else requested_slot
	var comparison = RealmEquipmentPreview.compare(m,uid,slot)
	if comparison.is_empty(): return
	var v = app.modal(m.name_of(item.id))
	if item.id=="copper_sword": app.dialog.set_meta("coach_equip",true)
	var hero = U.card(v,14,U.QUALITY[int(item.q)].darkened(.4))
	var row = U.row(14)
	hero.add_child(row)
	row.add_child(U.icon(item.id,86))
	var title = U.column(6)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	title.add_child(U.para(m.data.rarities[int(item.q)],23,U.QUALITY[int(item.q)]))
	title.add_child(U.para(RealmEquipmentSlots.NAMES.get(slot,slot)+" · %d owned" % int(item.count),14))
	title.add_child(U.para("Equipped" if comparison.equipped else ("Worn on other hand — equipping moves this ring" if uid in m.s.equipped.values() else "In your bag"),13,U.GOLD))
	for affix in item.get("affixes",[]):
		hero.add_child(U.para(RealmArtisan.AFFIXES[affix].name+" · "+RealmArtisan.AFFIXES[affix].detail,14,U.GOLD))
	if data.slot in RealmArtisan.TOOLS:v.add_child(U.button("Improve tool · Rank %d / 6" % item.get("tool_rank",0),func():preload("res://ui/artisan.gd").new(app).upgrade(uid)))
	if data.has("unique_effect"):
		hero.add_child(U.para("Unique effect · "+data.unique_effect,15,U.GOLD))
		if item.id in RealmLegacyFinds.GEAR: hero.add_child(U.button("Masterwork blueprints",func(): preload("res://ui/masterworks.gd").new(app).open()))
		else: hero.add_child(U.button("Relic forge & tempering",func(): preload("res://ui/endgame.gd").new(app).forge()))
	if data.slot=="ring":
		v.add_child(U.para("Each ring occupies one hand. Choose which ring to replace.",13))
		for hand in ["ring_left","ring_right"]:
			if hand!=slot: v.add_child(U.button("Compare in "+RealmEquipmentSlots.NAMES[hand].to_lower(),func(): open(uid,hand)))
	var current = comparison.current
	v.add_child(U.para("Currently equipped: "+(m.data.rarities[int(current.q)]+" "+m.name_of(current.id) if not current.is_empty() else "Nothing in this slot"),14))
	var changes = U.card(v,14)
	changes.add_child(U.para("Your build with this item",21,U.TEXT))
	if comparison.has("activity"):
		changes.add_child(U.para("%s\n%.2fs → %.2fs per cycle" % [m.activity_name(comparison.activity),comparison.seconds_before,comparison.seconds_after],18,U.TEXT))
		changes.add_child(U.para("Includes rarity, tool rank, traits, mastery and stronghold bonuses. Tool improvements shorten the remaining cycle, even at maximum stronghold speed.",13))
	else:
		for stat in ["attack","armor"]:
			var before = float(comparison.before[stat])
			var after = float(comparison.after[stat])
			changes.add_child(U.para("%s   %.0f → %.0f   (%+.0f)" % [stat.capitalize(),before,after,after-before],18,U.GREEN if after>before else (U.RED if after<before else U.MUTED)))
		changes.add_child(U.para("Total stats with your current style, talents and relic. Card damage percentages apply during combat and are not added to these ATK/DEF totals.",13))
		changes.add_child(U.para("Armor sets\nBefore: %s\nAfter: %s" % [comparison.sets_before,comparison.sets_after],14,U.GOLD))
	if RealmFusion.eligible(m,item):v.add_child(U.button("Rarity forge · tier %d / 21" % (int(item.q)+1),func():preload("res://ui/fusion.gd").new(app).open(uid)))
	var metal = RealmGearSets.metal(item.id)
	if metal!="" and data.slot in RealmGearSets.SLOTS:
		var set_info = RealmGearSets.ALL[metal]
		v.add_child(U.para(set_info.name+" · 2 armor pieces",19,U.GOLD))
		v.add_child(U.para(set_info.effect,14))
		v.add_child(U.button("View armor sets",func(): preload("res://ui/gear_sets.gd").new(app).open()))
	if not m.s.fight.is_empty(): changes.add_child(U.para("Finish or leave combat before changing equipment. Temporary potion buffs are included in this preview.",13,U.GOLD))
	if RealmWorkshop.eligible(m,item): v.add_child(U.button("Preview a quality upgrade",func(): preload("res://ui/armory.gd").new(app).workshop(uid)))
	if RealmCards.fits(m,uid): v.add_child(U.button("Monster card · "+("Attached" if m.s.get("card_sockets",{}).has(uid) else "Empty socket"),func(): preload("res://ui/cards.gd").new(app).socket(uid)))
	var attunement=str(m.s.get("gear_attunements",{}).get(uid,""))
	if attunement!="":v.add_child(U.para(RealmMarches.ATTUNEMENTS[attunement].name+" · "+RealmMarches.ATTUNEMENTS[attunement].detail,14,U.GOLD))
	if attunement!="" and int(item.q)>=5:v.add_child(U.para(RealmBuildDepth.milestone_text(m,item),13,U.GOLD))
	if data.slot=="weapon":v.add_child(U.button("Weapon attunement",func():preload("res://ui/marches.gd").new(app).attune(uid)))
	var protection = U.card(v,12)
	protection.add_child(U.para("Keep or salvage",17,U.TEXT))
	protection.add_child(U.para("Equipped, locked, favorite and saved-loadout items are protected from salvage.",13))
	protection.add_child(U.button("Unlock item" if item.locked else "Lock item",func():
		if app.send({"type":"lock","id":uid}): open(uid,slot)))
	protection.add_child(U.button("Remove favorite" if item.favorite else "Add to favorites",func():
		if app.send({"type":"favorite","id":uid}): open(uid,slot)))
	if not m.protected(uid): protection.add_child(U.button("Review salvage…",func(): app.salvage_dialog([uid])))
	var equip = app.modal_action("Already equipped" if comparison.equipped else "Equip item",func():
		if app.send({"type":"equip","id":uid,"slot":slot}):
			open(uid,slot)
			app.toast(m.name_of(item.id)+" equipped."))
	equip.set_meta("coach_target","equip")
	equip.disabled = comparison.equipped or not m.s.fight.is_empty()
	var ref = weakref(equip)
	app.dialog_callbacks.append(func():
		var button = ref.get_ref()
		if is_instance_valid(button): button.disabled = m.s.equipped.get(slot,"")==uid or not m.s.fight.is_empty())
