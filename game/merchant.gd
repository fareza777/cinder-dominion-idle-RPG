class_name RealmMerchant
extends RefCounted

const INTERVAL = 8*60*60*1000

static func tier(m) -> int:
	if m.level("smithing")>=90 and int(m.s.kills.get("crown_5",0))>0: return 3
	if m.level("smithing")>=60 and int(m.s.kills.get("marsh_5",0))>0: return 2
	if m.level("smithing")>=30 and int(m.s.kills.get("wilds_5",0))>0: return 1
	return 0

static func pool(t: int, pricing: int = 1) -> Array:
	var out = [
		{"id":"scrap","qty":12,"price":180,"quality":1},
		{"id":"healing_draught","qty":3,"price":120,"quality":1},
		{"id":"guard_draught","qty":3,"price":150,"quality":1},
		{"id":"fury_draught","qty":3,"price":150,"quality":1}]
	if t>0:
		var metal = ["","steel","moonsteel","dawnsteel"][t]
		out.append({"id":metal+"_ingot","qty":8,"price":t*400,"quality":1})
		for family in ["necklace","belt","ring"]:
			out.append({"id":metal+"_"+family,"qty":1,"price":([0,1200,4800,12000] if pricing==0 else [0,60000,350000,1500000])[t],"quality":3})
		if pricing==1:
			out.append({"id":["","cooked_steel_fish","cooked_moonsteel_fish","cooked_dawnsteel_fish"][t],"qty":40,"price":[0,4000,12000,30000][t],"quality":1})
			out.append({"id":metal+"_sword","qty":1,"price":[0,120000,700000,3000000][t],"quality":4})
	if t>0:
		for enemy in ["ash_rat","hollow_hound","grave_thrall","cinder_bandit","chapel_guard","ember_wraith","bellkeeper"]:
			out.append({"id":"card_"+enemy,"qty":1,"price":100000,"quality":1})
	if t>1:
		for enemy in ["wilds_1","marsh_1","crown_1"]:
			out.append({"id":"card_"+enemy,"qty":1,"price":250000,"quality":1})
	return out

static func sync(m, now: int) -> Dictionary:
	if not m.s.has("merchant_stock"):
		m.s.merchant_stock = {"seen":maxi(0,now),"until":0,"revision":0,"tier":0,"offers":[]}
	var stock = m.s.merchant_stock
	stock.seen = maxi(int(stock.seen),now)
	if stock.offers.is_empty() or stock.seen>=stock.until:
		stock.pricing = 1
		stock.tier = tier(m)
		stock.revision += 1
		stock.until = stock.seen+INTERVAL
		var random = RandomNumberGenerator.new()
		random.seed = int(stock.seen)+int(stock.revision)*7919
		var all_choices = pool(int(stock.tier))
		var choices = all_choices.filter(func(o): return not str(o.id).begins_with("card_"))
		stock.offers = []
		for i in range(3):
			var index = random.randi_range(0,choices.size()-1)
			var offer = choices[index].duplicate()
			offer.bought = false
			stock.offers.append(offer)
			choices.remove_at(index)
		var cards = all_choices.filter(func(o): return str(o.id).begins_with("card_"))
		if not cards.is_empty() and random.randf()<.05:
			var offer = cards[random.randi_range(0,cards.size()-1)].duplicate()
			offer.bought = false
			stock.offers[2] = offer
	return stock

static func valid(stock) -> bool:
	if not stock is Dictionary: return false
	for key in ["revision","tier"]:
		if not RealmSave.counter(stock.get(key,-1)): return false
	for key in ["seen","until"]:
		var value = stock.get(key,-1)
		if typeof(value) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(value)) or value<0 or value>9e15 or floor(float(value))!=float(value): return false
	if stock.tier>3 or stock.revision<1 or stock.until<=stock.seen or stock.until-stock.seen>INTERVAL: return false
	if stock.get("pricing",0) not in [0,1]: return false
	if not stock.get("offers") is Array or stock.offers.size()!=3: return false
	var seen = []
	for offer in stock.offers:
		if not offer is Dictionary or not offer.get("bought") is bool: return false
		var matched = false
		for entry in pool(int(stock.tier),int(stock.get("pricing",0))):
			if offer.get("id","")==entry.id and offer.get("qty",0)==entry.qty and offer.get("price",0)==entry.price and offer.get("quality",-1)==entry.quality: matched = true
		if not matched or offer.id in seen: return false
		seen.append(offer.id)
	return true

static func buy(m, cmd: Dictionary) -> String:
	var stock = sync(m,int(cmd.get("now",m.s.wall)))
	if int(cmd.get("revision",-1))!=int(stock.revision): return "The merchant has new stock. Review the latest offers."
	var index = int(cmd.get("index",-1))
	if index<0 or index>=stock.offers.size(): return "Choose an available offer."
	var offer = stock.offers[index]
	if offer.bought: return "This offer is sold out."
	if m.s.gold<int(offer.price): return "Not enough coins. Complete hunts and contracts to earn more."
	if m.data.items[offer.id].category=="equipment" and m.s.gear.size()>=1000: return "Make room in your equipment bag first."
	m.s.gold -= int(offer.price)
	m.gain(offer.id,int(offer.qty),int(offer.quality))
	offer.bought = true
	m.note("Purchased %s ×%d from the merchant." % [m.name_of(offer.id),offer.qty])
	return ""

static func provisions(m) -> Dictionary:
	var t = tier(m)
	if t==0: return {}
	return {"id":["","cooked_steel_fish","cooked_moonsteel_fish","cooked_dawnsteel_fish"][t],"qty":20,"price":[0,2500,7500,20000][t]}

static func buy_provisions(m) -> String:
	var offer = provisions(m)
	if offer.is_empty(): return "Unlock a regional supply route first."
	if m.s.gold<offer.price: return "Need "+RealmEconomy.money(offer.price)+" for this food bundle."
	m.s.gold -= offer.price
	m.gain(offer.id,offer.qty)
	return ""

static func sell_price(m, g: Dictionary) -> int:
	return maxi(1,int(m.data.items[g.id].get("sell",1)))*[1,2,3,5,8,12,18,25][int(g.q)]

static func sell(m, uid: String) -> String:
	var g = m.gear(uid)
	if g.is_empty(): return "This item is no longer in your bag."
	if m.protected(uid): return "Equipped, locked, favorite and saved-loadout items cannot be sold."
	var price = sell_price(m,g)
	var name = m.name_of(g.id)
	if int(g.count)==1: m.s.gear.erase(g)
	else: g.count -= 1
	m.s.gold += price
	m.note("Sold one %s for %d gold." % [name,price])
	return ""
