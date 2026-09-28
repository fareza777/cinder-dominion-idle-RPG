extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func open():
	var stock = RealmMerchant.sync(m,app.now_ms())
	app.persist()
	var v = app.modal("Cinderwatch merchant")
	app.dynamic(v,func(): return "%d gold" % int(m.s.gold),21,U.GOLD)
	v.add_child(U.para("Limited stock",25,U.TEXT))
	app.dynamic(v,func():
		var left = maxi(0,int(stock.until)-maxi(int(stock.seen),app.now_ms()))
		return "New offers ready · reopen the merchant" if left==0 else "New offers in %dh %dm" % [int(left/3600000),int(left/60000)%60],14)
	v.add_child(U.para("Three offers per visit cycle. Each bundle can be bought once. Later stock unlocks through Smithing and regional boss victories.",13))
	if int(stock.tier)<3:
		var next = int(stock.tier)+1
		v.add_child(U.para("Next stock tier: Smithing Lv.%d and defeat %s. Unlocks apply on the next refresh." % [[0,30,60,90][next],m.local_name(m.data.enemies[["","wilds_5","marsh_5","crown_5"][next]])],13,U.GOLD))
	for index in range(stock.offers.size()):
		var offer = stock.offers[index]
		var card = U.card(v,14)
		var row = U.row(12)
		card.add_child(row)
		row.add_child(U.icon(offer.id,56))
		var text = U.column(4)
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text)
		text.add_child(U.para(m.name_of(offer.id),20,U.TEXT))
		var gear = m.data.items[offer.id].category=="equipment"
		text.add_child(U.para((m.data.rarities[int(offer.quality)]+" · " if gear else "")+"%d in bundle" % int(offer.qty),13,U.GOLD))
		if m.data.items[offer.id].category=="card":
			card.add_child(U.para(RealmCards.description(offer.id),14))
			card.add_child(U.button("Inspect card",func(): preload("res://ui/cards.gd").new(app).detail(offer.id)))
		if gear:
			var item = m.data.items[offer.id]
			card.add_child(U.para("Gear bonus: +%.1f ATK · +%.1f DEF" % [float(item.get("attack",0))*RealmModel.QUALITY[int(offer.quality)],float(item.get("armor",0))*RealmModel.QUALITY[int(offer.quality)]],13))
		var b = U.button("Sold out" if offer.bought else "Buy bundle · %d gold" % int(offer.price),func():
			app.send({"type":"merchant_buy","index":index,"revision":stock.revision,"now":app.now_ms()})
			open(),true)
		b.disabled = offer.bought or m.s.gold<int(offer.price)
		card.add_child(b)
		var ref = weakref(b)
		app.dialog_callbacks.append(func():
			var button = ref.get_ref()
			if is_instance_valid(button): button.disabled = offer.bought or m.s.gold<int(offer.price))
	v.add_child(U.button("Sell spare equipment",sell_list))
	v.add_child(U.button("Sell supplies in Bag",func():
		app.dismiss()
		app.set_page("inventory")))
	v.add_child(U.para("Everyday supplies",25,U.TEXT))
	for id in m.data.merchant:
		var qty = 10 if id=="empty_vial" else 1
		v.add_child(U.button("%s ×%d · %d gold" % [m.name_of(id),qty,int(m.data.merchant[id])*qty],func():
			app.send({"type":"buy","id":id,"amount":qty})
			open()))

func sell_list(page: int = 0):
	var v = app.modal("Sell spare equipment")
	v.add_child(U.para("Equipped, locked, favorite and saved-loadout equipment is protected. Each sale removes one piece.",14))
	var candidates = m.s.gear.filter(func(g): return not m.protected(g.uid))
	var pages = maxi(1,ceili(candidates.size()/20.0))
	page = clampi(page,0,pages-1)
	v.add_child(U.para("Page %d / %d · %d available items" % [page+1,pages,candidates.size()],13,U.GOLD))
	for g in candidates.slice(page*20,(page+1)*20):
		var card = U.card(v,12)
		card.add_child(U.para(m.name_of(g.id),20,U.TEXT))
		card.add_child(U.para("%s · %d owned" % [m.data.rarities[int(g.q)],g.count],13,U.GOLD))
		card.add_child(U.button("Review sale · %d gold" % RealmMerchant.sell_price(m,g),func(): confirm_sale(g.uid)))
	if candidates.is_empty(): v.add_child(U.para("No spare equipment available to sell.",18))
	if page>0: v.add_child(U.button("Previous page",func(): sell_list(page-1)))
	if page+1<pages: v.add_child(U.button("Next page",func(): sell_list(page+1)))
	app.modal_action("Back to merchant",open)

func confirm_sale(uid: String):
	var g = m.gear(uid)
	if g.is_empty():
		sell_list()
		return
	var v = app.modal("Confirm equipment sale")
	v.add_child(U.icon(g.id,80))
	v.add_child(U.para(m.data.rarities[int(g.q)]+" "+m.name_of(g.id),23,U.TEXT))
	v.add_child(U.para("Sell one piece for %d gold? This cannot be undone." % RealmMerchant.sell_price(m,g),16))
	v.add_child(U.button("Keep item",sell_list))
	app.modal_action("Sell one piece",func():
		app.send({"type":"merchant_sell","id":uid})
		sell_list())
