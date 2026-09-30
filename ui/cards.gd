extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m
var collection_page = 0
var collection_filter = "all"
func _init(owner): app = owner; m = owner.model

func collection(page: int = -1):
	if page<0: page=collection_page
	collection_page=page
	var v = app.modal("Monster Cards")
	v.add_child(U.para("Defeat monsters to discover their cards.",14))
	var known = []
	for id in RealmCards.definitions():
		if int(m.s.kills.get(RealmCards.definitions()[id].enemy,0))>0 or m.count(id)>0 or id in m.s.get("card_sockets",{}).values(): known.append(id)
	v.add_child(U.para("%d / %d discovered" % [known.size(),RealmCards.definitions().size()],14,U.GOLD))
	var choices=["all","owned","attached"]
	var picker=OptionButton.new();picker.custom_minimum_size.y=48;picker.fit_to_longest_item=false
	for name in ["All discovered cards","In your bag","Attached to equipment"]:picker.add_item(name)
	for place in RealmWorld.locations():
		if known.any(func(id):return RealmWorld.location(m.data.enemies[RealmCards.definitions()[id].enemy])==place.id):
			choices.append(place.id);picker.add_item(place.name)
	if collection_filter not in choices:collection_filter="all"
	picker.select(choices.find(collection_filter));v.add_child(picker)
	picker.item_selected.connect(func(index):collection_filter=choices[index];collection(0))
	known=known.filter(func(id):
		if collection_filter=="all":return true
		if collection_filter=="owned":return m.count(id)>0
		if collection_filter=="attached":return id in m.s.get("card_sockets",{}).values()
		return RealmWorld.location(m.data.enemies[RealmCards.definitions()[id].enemy])==collection_filter)
	var pages = maxi(1,ceili(known.size()/7.0))
	page = clampi(page,0,pages-1)
	v.add_child(U.para("%d cards · Page %d / %d" % [known.size(),page+1,pages],13))
	for id in known.slice(page*7,(page+1)*7):
		var d=RealmCards.definitions()[id]
		var accent=preload("res://ui/card_art.gd").accent(d.rarity)
		var entry=U.card(v,10,accent.darkened(.55))
		var row = U.row(12)
		entry.add_child(row)
		var art=U.icon(id,84);art.custom_minimum_size=Vector2(84,114);row.add_child(art)
		var words=U.column(5);words.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(words)
		var b = U.button(m.name_of(id).trim_suffix(" Card"),func(): detail(id))
		words.add_child(b)
		words.add_child(U.para(RealmCards.slot_text(id),12,U.MUTED))
		var attached=m.s.get("card_sockets",{}).values().count(id)
		words.add_child(U.para("%d in bag%s" % [m.count(id)," · %d attached" % attached if attached>0 else ""],12,U.GOLD))
	if known.is_empty(): v.add_child(U.para("No cards match this filter." if collection_filter!="all" else "Win your first hunt to reveal its card.",18))
	if page>0: v.add_child(U.button("Previous cards",func(): collection(page-1)))
	if page+1<pages: v.add_child(U.button("Next cards",func(): collection(page+1)))
	v.add_child(U.button("How cards work",help))

func detail(id: String, uid: String = ""):
	var d = RealmCards.definitions()[id]
	var v = app.modal(m.name_of(id))
	var art=U.icon(id,200);art.custom_minimum_size=Vector2(0,265);art.size_flags_horizontal=Control.SIZE_EXPAND_FILL;v.add_child(art)
	var role=str(d.get("role",""))
	if role!="" and role!="Build choice":v.add_child(U.para(role,18,preload("res://ui/card_art.gd").accent(d.rarity)))
	v.add_child(U.para(d.detail,17,U.TEXT))
	v.add_child(U.para(RealmCards.slot_text(id),15,U.GOLD))
	v.add_child(U.para("Owned %d · duplicates do not stack" % m.count(id),13))
	if uid!="":
		v.add_child(U.para("Attach to "+m.name_of(m.gear(uid).id)+". Removal needs a crafted Card Extractor.",14))
		var b = U.button("Attach card",func():
			if app.send({"type":"card_insert","id":id,"uid":uid}): socket(uid),true)
		b.disabled = m.count(id)<1 or not m.s.fight.is_empty() or not RealmCards.fits_card(m,uid,id)
		v.add_child(b)
	elif m.count(id)>0:
		v.add_child(U.button("Choose equipment",func(): choose_equipment(id),true))
		v.add_child(U.button("Review sale · %d gold" % RealmCards.sell_price(id),func(): sell(id)))
	if m.available(d.enemy)=="": v.add_child(U.button("Prepare this hunt",func(): app.activity_dialog("hunt_"+d.enemy,1)))
	v.add_child(U.button("Card collection",collection))

func choose_equipment(id: String, page: int = 0):
	var v = app.modal("Choose equipment")
	v.add_child(U.para("A card stays with its item when you change loadouts. Duplicate cards do not stack on one hero.",14))
	var choices = m.s.gear.filter(func(g): return RealmCards.fits_card(m,g.uid,id) and not m.s.get("card_sockets",{}).has(g.uid))
	choices.sort_custom(func(a,b): return (a.uid in m.s.equipped.values()) and not (b.uid in m.s.equipped.values()))
	var pages = maxi(1,ceili(choices.size()/20.0))
	page = clampi(page,0,pages-1)
	for g in choices.slice(page*20,(page+1)*20):
		v.add_child(U.button(m.data.rarities[int(g.q)]+" "+m.name_of(g.id)+(" · Equipped" if g.uid in m.s.equipped.values() else ""),func(): detail(id,g.uid)))
	if choices.is_empty(): v.add_child(U.para("No compatible empty sockets. Check this card's allowed slots, then craft or free a matching piece.",16))
	if page>0: v.add_child(U.button("Previous equipment",func(): choose_equipment(id,page-1)))
	if page+1<pages: v.add_child(U.button("Next equipment",func(): choose_equipment(id,page+1)))

func socket(uid: String):
	if m.gear(uid).is_empty(): return
	var v = app.modal("Equipment card")
	v.add_child(U.para(m.name_of(m.gear(uid).id),23,U.GOLD))
	var current = m.s.get("card_sockets",{}).get(uid,"")
	if current!="":
		v.add_child(U.icon(current,180))
		v.add_child(U.para(m.name_of(current),20,U.TEXT))
		v.add_child(U.para(RealmCards.description(current),15))
		v.add_child(U.para("Removal consumes one Card Extractor and returns the card intact. Socketed equipment is protected from sale and salvage.",14))
		var b = U.button("Remove card · 1 extractor",func():
			if app.send({"type":"card_remove","uid":uid}): socket(uid))
		b.disabled = m.count("card_extractor")<1 or not m.s.fight.is_empty()
		v.add_child(b)
		v.add_child(U.button("Craft an extractor · Smithing Lv.20",func(): app.planner_dialog("craft_card_extractor",1)))
	else:
		v.add_child(U.para("One empty socket. Only cards made for this equipment slot can be attached.",14))
		var found = false
		for id in RealmCards.definitions():
			if m.count(id)>0 and RealmCards.fits_card(m,uid,id):
				found = true
				v.add_child(U.button(m.name_of(id),func(): detail(id,uid)))
		if not found: v.add_child(U.para("No compatible cards in your Bag. Hunt for cards that fit this slot.",16))
	v.add_child(U.button("Card collection",collection))

func sell(id: String):
	var v = app.modal("Sell a monster card?")
	v.add_child(U.icon(id,160))
	v.add_child(U.para(m.name_of(id),22,U.GOLD))
	v.add_child(U.para("Sell one card for %d gold? This rare find will leave your bag. The sale cannot be undone." % RealmCards.sell_price(id),16))
	v.add_child(U.button("Keep card",func(): detail(id)))
	app.modal_action("Sell one card",func():
		if app.send({"type":"sell","id":id,"amount":1}): collection())

func help():
	var v = app.modal("Hunting & cards")
	for line in ["1. Pick an enemy and prepare food. Check its rewards, debuffs and recommended food before starting.","2. Hunt for experience, materials and monster cards.","3. Check the card's allowed slots, then attach it to a matching combat item from Hero or the card collection. Each item holds one; duplicates of the same card only apply once per hero.","4. Refine equipment to carry its card forward. Use a Card Extractor to move a card safely.","5. Move to stronger enemies for better XP, coins and materials. Return to earlier hunts when you need their cards or specific drops.","6. Buy occasional Rare or Epic cards from the merchant, or sell spare copies. Legendary and Mythic cards come from hunts."]:
		v.add_child(U.para(line,16))
	v.add_child(U.button("Combat effects explained",effects))

func effects():
	var v = app.modal("Combat effects")
	for line in ["Fire, Frost, Lightning and Poison strikes can apply matching debuffs. Physical strikes can bleed or break armor.","Burn, Poison, Bleed: damage each second; up to three stacks. Reapplying refreshes duration.","Chill: slower attacks; three stacks trigger Freeze. Freeze breaks on direct damage.","Freeze and Stun: briefly stop attacks. Boss duration is 0.5s; control is followed by 6s immunity.","Slow: attacks take 20% longer. Shock: attacks take 10% longer. Slow and Chill do not stack their delay.","Armor Break: 20% less armor. Weaken: 15% less attack. Wound: 35% less healing.","Barrier absorbs a small amount of direct damage. Regeneration restores HP each second. Cleanse removes one harmful effect.","Most effects last 6s; Chill lasts 20s to allow three stacks. Apothecary meals grant Regeneration from Bladecraft Lv.25. Cards can shorten matching debuffs and reduce matching special-strike damage. Damage-over-time cannot trigger more cards."]:
		v.add_child(U.para(line,15))
