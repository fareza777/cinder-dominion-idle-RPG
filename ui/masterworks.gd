extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
var collection_page = 0
func _init(owner): app=owner; m=owner.model

func open(page: int = -1):
	if page<0: page=collection_page
	collection_page=page
	var v = app.modal("Masterwork blueprints")
	var known=RealmLegacyFinds.GEAR.filter(func(id): return RealmBlueprints.learned(m,id))
	v.add_child(U.para("%d blueprint%s discovered" % [known.size(),"" if known.size()==1 else "s"],19,U.GOLD))
	if known.is_empty():
		v.add_child(U.para("Rare blueprints can be found on difficult hunts or among the merchant’s rarest offers.",16))
		return
	page=clampi(page,0,maxi(0,ceili(known.size()/5.0)-1))
	v.add_child(U.para("Craft with rare monster finds and guardian materials.",14))
	for id in known.slice(page*5,(page+1)*5):
		var a = m.data.activities["craft_"+id]
		var c = U.card(v,12)
		var heading = U.row(12)
		c.add_child(heading)
		heading.add_child(U.icon(id,72))
		heading.add_child(U.para(m.name_of(id),21,U.GOLD))
		c.add_child(U.para(m.data.items[id].unique_effect,15,U.TEXT))
		c.add_child(U.para("Smithing Lv.%d · %s commission fee" % [a.level,RealmEconomy.money(int(a.inputs.masterwork_commission)*RealmEconomy.PLATINUM)],13))
		c.add_child(U.button("Materials & sources",func(): recipe(id)))
	if page>0: v.add_child(U.button("Previous blueprints",func(): open(page-1)))
	if (page+1)*5<known.size(): v.add_child(U.button("More blueprints",func(): open(page+1)))

func recipe(id: String):
	if not RealmBlueprints.learned(m,id):
		open()
		return
	var a = m.data.activities["craft_"+id]
	var v = app.modal(m.name_of(id))
	v.add_child(U.icon(id,160))
	v.add_child(U.para(m.data.items[id].unique_effect,17,U.GOLD))
	v.add_child(U.para("Legendary · 1 card socket",14))
	for material in a.inputs:
		var row = U.row(8)
		v.add_child(row)
		row.add_child(U.icon(material,44))
		var b = U.button("%s · %d / %d" % [m.name_of(material),m.count(material),a.inputs[material]],func(): app.sources_dialog(material))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	v.add_child(U.button("Review & craft",func(): app.activity_dialog("craft_"+id,1),true))
	v.add_child(U.button("All masterworks",open))
