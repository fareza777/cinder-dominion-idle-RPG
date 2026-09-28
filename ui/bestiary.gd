extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
func _init(owner):
	app = owner
	m = app.model
func open(region: String = "all", page: int = 0):
	var v = app.modal("Bestiary")
	v.add_child(U.para("Your discovered enemies",14))
	var picker = OptionButton.new()
	var regions = ["all","wilds","marsh","crown","frontier_0","frontier_1","frontier_2"]
	for id in regions:
		var title = "All regions" if id=="all" else (RealmFrontiers.REGIONS[int(id.trim_prefix("frontier_"))] if id.begins_with("frontier_") else RealmChronicle.REGIONS[id].name)
		picker.add_item(title)
	picker.selected = regions.find(region)
	picker.custom_minimum_size.y = 48
	picker.item_selected.connect(func(index): open(regions[index]))
	v.add_child(picker)
	var known = []
	for id in m.data.enemies:
		if not RealmDiscovery.visible(m,id): continue
		var e = m.data.enemies[id]
		var area = "frontier_"+str(int(e.frontier)) if e.has("frontier") else str(e.get("region",""))
		if region!="all" and area!=region: continue
		known.append(id)
	var pages = maxi(1,ceili(known.size()/8.0))
	page = clampi(page,0,pages-1)
	v.add_child(U.para("%d enemies · Page %d / %d" % [known.size(),page+1,pages],13,U.GOLD))
	for id in known.slice(page*8,(page+1)*8):
		var e = m.data.enemies[id]
		var c = U.card(v,12)
		var row = U.row(10)
		c.add_child(row)
		row.add_child(U.enemy_portrait(e,Vector2(64,80)))
		row.add_child(U.para(m.local_name(e),18,U.TEXT))
		app.dynamic(c,func(): return "Wins %d · Mastery %d / 4" % [m.s.kills.get(id,0),RealmHuntMastery.rank(m,id)],13,U.GOLD)
		c.add_child(U.para("%s ×%d · %d base XP" % [m.name_of(e.drop),e.qty,e.xp],14,U.GREEN))
		var reason = m.available(id)
		if reason!="": c.add_child(U.para(reason,13,U.MUTED))
		else:
			c.add_child(U.button("Inspect & hunt",func(): app.activity_dialog("hunt_"+id,1)))
	if known.is_empty(): v.add_child(U.para("No enemies discovered here yet.",16))
	if page>0: v.add_child(U.button("Previous enemies",func(): open(region,page-1)))
	if page+1<pages: v.add_child(U.button("Next enemies",func(): open(region,page+1)))
