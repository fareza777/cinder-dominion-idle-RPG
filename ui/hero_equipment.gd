extends RefCounted

const U = preload("res://ui/style.gd")
const NAMES = RealmEquipmentSlots.NAMES
var app
var m
func _init(owner):
	app = owner
	m = app.model

func home(parent):
	var stage = preload("res://ui/hero_stage.gd").new()
	stage.app = app
	stage.equipment = self
	parent.add_child(stage)
	var c = U.card(parent,12)
	app.dynamic(c,func(): return "%d ATK  ·  %d DEF  ·  %d / 100 HP" % [m.stats().attack,m.stats().armor,m.s.hp],17,U.GOLD)
	app.dynamic(c,func(): return RealmGearSets.summary(m),14,U.TEXT)
	c.add_child(U.para("Tap a slot to choose equipment. The portrait is your hero's base appearance.",12))
	var tools = U.row(6)
	parent.add_child(tools)
	for slot in ["pick","axe","rod"]:
		var b = U.button(NAMES[slot],func(): open_slot(slot))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tools.add_child(b)
	parent.add_child(U.button("Specialization & socket relics",func(): preload("res://ui/endgame.gd").new(app).builds()))
	parent.add_child(U.button("Save & switch loadouts",app.loadouts_dialog))

func open_slot(slot: String):
	var v = app.modal("Equipment · "+NAMES[slot])
	var current = m.gear(str(m.s.equipped.get(slot,"")))
	v.add_child(U.para("Equipped: "+(m.name_of(current.id) if not current.is_empty() else "Empty slot"),19,U.GOLD))
	if not m.s.fight.is_empty(): v.add_child(U.para("Finish or leave your hunt before changing equipment.",14,U.GOLD))
	var choices = m.s.gear.filter(func(g): return RealmEquipmentSlots.accepts(slot,str(m.data.items[g.id].slot)))
	choices.sort_custom(func(a,b): return m.gear_score(a)>m.gear_score(b))
	if slot in ["necklace","belt","ring_left","ring_right"]:
		v.add_child(U.para("Forge accessories in Skills at Smithing Lv.30, 60 and 90. Refine their quality at the workshop.",13))
	if choices.is_empty():
		v.add_child(U.para("No equipment for this slot yet. Craft a piece or find one on a hunt.",16))
		for id in m.data.activities:
			var a = m.data.activities[id]
			if a.kind=="combat": continue
			var fits = RealmEquipmentSlots.accepts(slot,str(m.data.items[a.output].get("slot","")))
			if fits and a.level<=m.level(a.skill):
				v.add_child(U.button("Plan "+m.activity_name(id),func(): app.planner_dialog(id,1)))
		v.add_child(U.button("Explore gear paths",func(): preload("res://ui/ascension.gd").new(app).open()))
	for item in choices:
		var c = U.card(v,12,U.QUALITY[int(item.q)].darkened(.4))
		var r = U.row(10)
		c.add_child(r)
		r.add_child(U.icon(item.id,54))
		var text = U.column(4)
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_child(text)
		text.add_child(U.para(m.name_of(item.id),17,U.TEXT))
		var equipped = m.s.equipped.get(slot,"")==item.uid
		var location = "Equipped" if equipped else ("Worn on other hand" if item.uid in m.s.equipped.values() else "In bag")
		text.add_child(U.para(m.data.rarities[int(item.q)]+" · "+location,12,U.QUALITY[int(item.q)]))
		var d = m.data.items[item.id]
		var summary = "%d ATK · %d DEF" % [roundi(d.get("attack",0)*RealmModel.QUALITY[int(item.q)]),roundi(d.get("armor",0)*RealmModel.QUALITY[int(item.q)])]
		if d.has("speed"): summary = "%d%% faster gathering" % roundi(d.speed*100)
		c.add_child(U.para(summary,14,U.MUTED))
		c.add_child(U.button("Compare & equip" if not equipped else "Inspect equipped item",func(): preload("res://ui/equipment_detail.gd").new(app).open(item.uid,slot),not equipped))
	app.modal_action("Back to hero",func():
		app.dismiss()
		app.set_page("character"))
