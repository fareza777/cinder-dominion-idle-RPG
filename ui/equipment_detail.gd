extends RefCounted

const U = preload("res://ui/style.gd")
const SLOTS = {"weapon":"Weapon","shield":"Shield","head":"Head","body":"Body","hands":"Hands","feet":"Feet","axe":"Woodcutting tool","pick":"Mining tool","rod":"Fishing tool"}
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func open(uid: String):
	var item = m.gear(uid)
	if item.is_empty(): return
	var data = m.data.items[item.id]
	var comparison = RealmEquipmentPreview.compare(m,uid)
	var v = app.modal(m.name_of(item.id))
	var hero = U.card(v,14,U.QUALITY[int(item.q)].darkened(.4))
	var row = U.row(14)
	hero.add_child(row)
	row.add_child(U.icon(item.id,86))
	var title = U.column(6)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	title.add_child(U.para(m.data.rarities[int(item.q)],23,U.QUALITY[int(item.q)]))
	title.add_child(U.para(SLOTS.get(data.slot,data.slot)+" · %d owned" % int(item.count),14))
	title.add_child(U.para("Equipped" if comparison.equipped else "In your bag",13,U.GOLD))
	var current = comparison.current
	v.add_child(U.para("Currently equipped: "+(m.data.rarities[int(current.q)]+" "+m.name_of(current.id) if not current.is_empty() else "Nothing in this slot"),14))
	var changes = U.card(v,14)
	changes.add_child(U.para("Your build with this item",21,U.TEXT))
	if comparison.has("activity"):
		changes.add_child(U.para("%s\n%.2fs → %.2fs per cycle" % [m.activity_name(comparison.activity),comparison.seconds_before,comparison.seconds_after],18,U.TEXT))
		changes.add_child(U.para("Includes current mastery and refuge bonuses. Tool speed is fixed by tool type; rarity does not increase it.",13))
	else:
		for stat in ["attack","armor"]:
			var before = float(comparison.before[stat])
			var after = float(comparison.after[stat])
			changes.add_child(U.para("%s   %.0f → %.0f   (%+.0f)" % [stat.capitalize(),before,after,after-before],18,U.GREEN if after>before else (U.RED if after<before else U.MUTED)))
		changes.add_child(U.para("Total stats with your current style, talents and relic. Small equipment gains may round to the same combat value.",13))
	if not m.s.fight.is_empty(): changes.add_child(U.para("Finish or leave combat before changing equipment. Temporary potion buffs are included in this preview.",13,U.GOLD))
	if RealmWorkshop.eligible(m,item): v.add_child(U.button("Preview a quality upgrade",func(): preload("res://ui/armory.gd").new(app).workshop(uid)))
	var protection = U.card(v,12)
	protection.add_child(U.para("Keep or salvage",17,U.TEXT))
	protection.add_child(U.para("Equipped, locked, favorite and saved-loadout items are protected from salvage.",13))
	protection.add_child(U.button("Unlock item" if item.locked else "Lock item",func():
		if app.send({"type":"lock","id":uid}): open(uid)))
	protection.add_child(U.button("Remove favorite" if item.favorite else "Add to favorites",func():
		if app.send({"type":"favorite","id":uid}): open(uid)))
	if not m.protected(uid): protection.add_child(U.button("Review salvage…",func(): app.salvage_dialog([uid])))
	var equip = app.modal_action("Already equipped" if comparison.equipped else "Equip item",func():
		if app.send({"type":"equip","id":uid}):
			open(uid)
			app.toast(m.name_of(item.id)+" equipped."))
	equip.disabled = comparison.equipped or not m.s.fight.is_empty()
	var ref = weakref(equip)
	app.dialog_callbacks.append(func():
		var button = ref.get_ref()
		if is_instance_valid(button): button.disabled = m.s.equipped.get(data.slot,"")==uid or not m.s.fight.is_empty())
