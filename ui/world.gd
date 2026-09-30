extends RefCounted
const U=preload("res://ui/style.gd")
const USES={"woodcutting":"Timber for weapons and tools","mining":"Ore for equipment and upgrades","fishing":"Supplies for cooking","cooking":"Food for longer hunts","smithing":"Weapons, armor and accessories","alchemy":"Potions for difficult battles","herbalism":"Sage for Arcane Arts","hunting":"Hides for Crafting","thieving":"Recover cache salvage for Crafting","crafting":"Bindings for new equipment and Forge Seals","arcane_arts":"Essences for offerings and Forge Seals","divinity":"Offerings for Runecarving","runecarving":"Forge Seals unlock higher equipment rarities"}
var app
var m
func _init(owner):app=owner;m=app.model
static func art(index: int) -> Texture2D:
	if ResourceLoader.exists("res://assets/art/realms-0.52.png"):
		var t=U.atlas_tile("res://assets/art/realms-0.52.png",index%9,3,3);t.region=t.region.grow(-3);return t
	return preload("res://ui/premium.gd").art(index%12)
static func location_art(place: Dictionary) -> Texture2D:
	var id=str(place.id)
	if id.begins_with("realm_"):return art(int(place.art))
	if id.begins_with("march_"):return U.atlas_tile("res://assets/art/march-places-0.50.png",int(id.trim_prefix("march_")),3,2)
	if id.begins_with("frontier_"):return preload("res://ui/premium.gd").art(9+int(id.trim_prefix("frontier_")))
	return U.atlas_tile("res://assets/art/page-environments-0.36.png",1,2,2) if id=="outskirts" else preload("res://ui/premium.gd").art({"wilds":4,"marsh":6,"crown":3,"guardians":10,"trials":11,"depths":9}.get(id,1))
func home(parent: Node):
	if not m.s.beacon:return
	var c=U.card(parent,12,U.GOLD.darkened(.5))
	c.add_child(U.para("The Shattered Realms",23,U.GOLD))
	var conquered=0
	for r in range(7):
		if m.s.kills.get("realm_%d_9" % r,0)>0:conquered+=1
	c.add_child(U.para("%d / 7 rulers defeated" % conquered,14,U.GOLD))
	if conquered==7:c.add_child(U.para("All realms conquered. Return for rare cards, materials and your next equipment build.",14))
	for r in range(7):
		if m.s.kills.get("realm_%d_9" % r,0)>0:continue
		c.add_child(U.para(data_name(r)+" · Bladecraft Lv.%d" % (100+r*5),15))
		c.add_child(U.para("Conquer its ruler to unlock equipment recipes, Forge Seals and two talent points.",13))
		break
	c.add_child(U.button("Choose a destination",func():app.explore_location="";app.set_page("explore"),true))
func data_name(r: int) -> String:return RealmWorld.data()[r].name
func open(parent: Node):
	U.scenic(parent,art(0),"CHOOSE YOUR DESTINATION","Explore",160)
	parent.add_child(U.para("Choose a location, prepare your gear, then select a hunt. Return to earlier grounds whenever you need their cards or materials.",14))
	preload("res://ui/voyages.gd").new(app).home(parent)
	var selector=OptionButton.new()
	for label in ["Open routes","All locations"]:selector.add_item(label)
	selector.custom_minimum_size.y=48;parent.add_child(selector)
	var list=U.column(12);parent.add_child(list)
	var render=func(all_routes: bool):
		for child in list.get_children():child.free()
		var locked_count=0
		for place in RealmWorld.locations():
			var ids=RealmWorld.encounters(m,place.id)
			if ids.is_empty():continue
			var visible=ids.filter(func(id):return RealmDiscovery.visible(m,id))
			var locked=visible.is_empty()
			if locked and not all_routes:locked_count+=1;continue
			var c=U.card(list,12,U.LINE if locked else U.GOLD.darkened(.5))
			if not locked:
				U.scenic(c,location_art(place),"",place.name,105)
			else:c.add_child(U.para(place.name,22,U.MUTED))
			if locked:c.add_child(U.para(m.available(ids[0]),13))
			else:
				var victories=ids.filter(func(id):return m.s.kills.get(id,0)>0).size()
				c.add_child(U.para("%d / %d encounters conquered" % [victories,ids.size()],13,U.GOLD))
				c.add_child(U.progress(victories,ids.size(),U.GOLD,4))
				c.add_child(U.button("Enter location",func():app.explore_location=place.id;app.set_page("explore",true),true))
		if locked_count>0:list.add_child(U.para("%d locations await discovery. Clear the next guardian to open more routes." % locked_count,14))
	render.call(false)
	selector.item_selected.connect(func(index):render.call(index==1))
func header(parent: Node):
	parent.add_child(U.button("← Choose another location",func():app.explore_location="";app.set_page("explore",true)))
	for place in RealmWorld.locations():
		if place.id!=app.explore_location:continue
		U.scenic(parent,location_art(place),"HUNTING GROUNDS",place.name,125)
		if place.has("story"):
			var details=U.disclosure(parent,"location story")
			details.add_child(U.para(place.story,15))
		break
	if not m.s.fight.is_empty() and RealmWorld.location(m.data.enemies[m.s.fight.enemy])!=app.explore_location:
		parent.add_child(U.para("Current hunt: "+m.local_name(m.data.enemies[m.s.fight.enemy])+". Your active battle continues while you browse.",14,U.GOLD))
