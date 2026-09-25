class_name RealmCombat
extends RefCounted

static func food_heal(m, id: String) -> int:
	var legacy = RealmChronicle.state(m)
	return int(m.data.items[id].get("heal",0))+(int(legacy.relics.heart)*3 if legacy.relic=="heart" else 0)

static func move(m, enemy: Dictionary, strike: int, armor: int) -> Dictionary:
	var third = strike%3==0
	var attack = int(enemy.attack)
	var defense = armor
	var heal = 0
	var label = "Strike"
	if third:
		match enemy.get("region",""):
			"wilds":
				defense = int(armor/2)
				label = "Bramble crush"
			"marsh":
				heal = maxi(1,int(enemy.hp*.05))
				label = "Drowned hymn"
			"crown":
				attack = int(attack*2.2)
				label = "Final toll"
			_:
				if enemy.boss:
					attack = int(attack*1.8)
					label = "Third toll"
	return {"damage":m.hit_damage(attack,defense),"heal":heal,"label":label}

static func mechanic(enemy: Dictionary) -> String:
	match enemy.get("region",""):
		"wilds": return "Bramble crush · Every third attack ignores half your armor. A stronger blade can shorten your exposure."
		"marsh": return "Drowned hymn · Every third attack restores 5% of the Oracle's maximum HP, even if her strike misses. Bring enough damage to overcome the healing."
		"crown": return "Final toll · Every third attack deals 2.2× attack damage before armor. Prepare armor and a generous healing threshold."
	return "Third toll · Every third attack deals 1.8× attack damage before armor." if enemy.boss else "No special attack. Your style skill is attempted every fourth attack."

# A bounded analytical forecast, not a second simulation and never a reward source.
static func forecast(m, id: String) -> Dictionary:
	var enemy = m.data.enemies[id]
	var stats = m.stats()
	var stance = m.progression().stance
	var multiplier = 1.25 if stance=="balanced" else (1.375 if stance=="reaver" else 1.0)
	var hit = m.hit_damage(int(stats.attack),int(enemy.armor))
	var damage_per_second = hit*multiplier*float(stats.accuracy)*1.025/2.0
	var ordinary = move(m,enemy,1,int(stats.armor))
	var special = move(m,enemy,3,int(stats.armor))
	var interval = float(enemy.interval)/1000.0
	var net_damage = damage_per_second-float(special.heal)/(interval*3.0)
	var stalled = net_damage<=0
	var seconds = 3600.0 if stalled else clampf(ceil(float(enemy.hp)/maxf(.01,net_damage)/2.0)*2.0,2,3600)
	var attacks = floor(seconds/interval)
	var average_hit = (ordinary.damage*2.0+special.damage)/3.0
	var incoming = attacks*average_hit*.95
	if stance=="guard": incoming = maxf(0,incoming-seconds*float(stats.accuracy))
	var heal = food_heal(m,m.s.settings.food)
	var effective_heal = minf(heal,100-float(m.s.settings.threshold)*100+average_hit)
	var meals = ceili(maxf(0,incoming-maxf(0,float(m.s.hp)-float(m.s.settings.threshold)*100))/maxf(1,effective_heal))
	var capacity = float(m.s.hp)+minf(m.count(m.s.settings.food),attacks)*effective_heal
	var risk = stalled or special.damage>=100 or incoming>=capacity*.9 or m.s.hp<=0
	var rating = "Outmatched" if stalled else ("High risk" if risk else ("Food advised" if meals>0 else "Favorable"))
	var fragments = int(enemy.get("fragments",1))
	return {"seconds":seconds,"meals":meals,"rating":rating,"risk":risk,"stalled":stalled,"fragments_per_minute":0.0 if stalled else fragments*60.0/seconds,"healing":heal,"burst":int(special.damage)}

static func farms(m, relic: String) -> Array:
	var choices = []
	for id in m.data.enemies:
		var enemy = m.data.enemies[id]
		if RealmChronicle.fragments_for(enemy)!=relic or m.available(id)!="": continue
		var forecast_data = forecast(m,id)
		choices.append({"id":id,"forecast":forecast_data,"fragments":int(enemy.get("fragments",1))})
	choices.sort_custom(func(a,b):
		if a.forecast.risk!=b.forecast.risk: return not a.forecast.risk
		return a.forecast.fragments_per_minute>b.forecast.fragments_per_minute)
	return choices
