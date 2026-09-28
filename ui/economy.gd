extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
func _init(owner): app = owner; m = owner.model

func open():
	var v = app.modal("Hunting rewards & wallet")
	app.dynamic(v,func(): return RealmEconomy.money(int(m.s.gold)),24,U.GOLD)
	v.add_child(U.para("S · Silver    G · Gold    P · Platinum",13,U.TEXT))
	var path = "res://assets/art/currency-0.43.png"
	if ResourceLoader.exists(path):
		var art = TextureRect.new()
		art.texture = load(path)
		art.custom_minimum_size = Vector2(0,96)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		v.add_child(art)
	v.add_child(U.para("1,000 Silver = 1 Gold\n1,000 Gold = 1 Platinum",17,U.GOLD))
	v.add_child(U.para("Coins convert automatically. Prices use the same wallet; no exchange fee or separate balances.",14))
	var level = m.level("bladecraft")
	v.add_child(U.para("Bladecraft · Level %d / 100" % level,21,U.TEXT))
	if level<100:
		v.add_child(U.para("%d XP to level %d" % [RealmEconomy.threshold(level+1)-int(m.s.xp.bladecraft),level+1],15,U.GOLD))
	v.add_child(U.para("Stronger enemies offer better XP and coins. Earlier hunts remain useful for their cards and materials. Prepare food and improve equipment before moving on.",14))
	v.add_child(U.button("Compare available hunts",hunts,true))
	v.add_child(U.button("What to spend coins on",spending))
	v.add_child(U.button("Masterwork blueprints",func(): preload("res://ui/masterworks.gd").new(app).open()))
	v.add_child(U.button("Merchant",app.merchant_dialog))

func hunts():
	var v = app.modal("Choose a rewarding hunt")
	v.add_child(U.para("Estimates use your current build and route. Timed status effects and card procs are excluded; bring spare food.",14))
	var options = []
	for id in m.data.enemies:
		if m.available(id)!="": continue
		var e = m.data.enemies[id]
		var f = RealmCombat.forecast(m,id)
		options.append({"id":id,"e":e,"f":f,"rate":float(e.xp)/maxf(2,f.seconds)})
	options.sort_custom(func(a,b):
		if a.f.risk!=b.f.risk: return not a.f.risk
		return a.rate>b.rate)
	for option in options.slice(0,5):
		var id = option.id
		var e = option.e
		var f = option.f
		var c = U.card(v,12)
		c.add_child(U.para(m.local_name(e),20,U.GOLD))
		c.add_child(U.para("%s · ~%ds · ~%d meals" % [f.rating,ceili(f.seconds),int(f.meals)],14))
		c.add_child(U.para("%s · %d melee XP per victory" % [RealmEconomy.money(RealmHuntMastery.battle_gold(m,e)),RealmEconomy.hunt_xp(m,e)],15,U.GREEN))
		c.add_child(U.para(RealmEconomy.experience_note(m,e),13))
		c.add_child(U.button("Prepare hunt",func(): app.activity_dialog("hunt_"+id,1)))
	if options.is_empty(): v.add_child(U.para("Continue your first objectives to open a hunting route.",16))
	v.add_child(U.button("All unlocked enemies",func(): app.dismiss(); app.set_page("explore")))

func spending():
	var v = app.modal("Build for harder hunts")
	for line in ["Early journey: buy tools, rebuild the stronghold and refine copper or iron equipment.","Regional hunts: craft stronger metals, improve quality and choose a card for each equipment piece.","Late game: Dawnsteel refinement can cost Platinum. Ascended relic ranks and unique-relic tempering also need coins and materials from difficult enemies.","Long expeditions: gather and cook your own food, or spend coins on the merchant's regional meal bundles. Bought food is a convenience; crafting remains available."]:
		v.add_child(U.para(line,16))
	v.add_child(U.button("Ember Workshop",app.workshop_dialog))
	v.add_child(U.button("Relic ascension",app.relics_dialog))
	v.add_child(U.button("Merchant supplies",app.merchant_dialog))
