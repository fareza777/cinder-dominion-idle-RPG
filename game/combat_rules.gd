class_name RealmCombat
extends RefCounted

static func food_heal(m, id: String) -> int:
	var legacy = RealmChronicle.state(m)
	var remedy = 6+3*(RealmCharacters.rank(m)-1) if RealmCharacters.id(m)=="apothecary" and RealmCharacters.rank(m)>0 else 0
	var base = maxi(1,int(m.data.items[id].get("heal",0))+(RealmLegacyGrowth.relic_base(int(legacy.relics.heart),3) if legacy.relic=="heart" else 0)+(8 if RealmGearSets.active(m,"dawnsteel") else 0)+remedy+RealmPaths.food_bonus(m)+int(RealmLegacyGrowth.rank(m,"recovery")/2)+int(RealmLegacyGrowth.ascended(m,"heart")/5))
	base+=RealmLegacyGrowth.rank(m,"vitality")
	if "sustain" in RealmMarches.effects(m):base=int(base*1.08)
	if m.s.hp<=40 and RealmPaths.has_item(m,"heirloom_belt"): base = int(base*1.15)
	return maxi(1,int(base*(1.0+RealmCards.bonus(m,"healing"))*(1.1 if RealmPaths.has_item(m,"heirloom_pendant") else 1.0)*(.65 if RealmAfflictions.has(m,"hero","wound") else 1.0)))

static func move(m, enemy: Dictionary, strike: int, armor: int, second_phase: bool = false) -> Dictionary:
	var third = strike%3==0
	var attack = int(enemy.attack)
	var defense = armor
	var heal = 0
	var label = "Strike"
	if third:
		match enemy.get("region",""):
			"wilds":
				defense = int(armor*(.25 if second_phase else .5))
				label = "Bramble crush"
			"marsh":
				heal = maxi(1,int(enemy.hp*(.08 if second_phase else .05)))
				label = "Drowned hymn"
			"crown":
				attack = int(attack*(2.8 if second_phase else 2.2))
				label = "Final toll"
			_:
				if enemy.boss:
					attack = int(attack*1.8)
					label = "Third toll"
	if third and enemy.has("special_name"):
		attack = int(enemy.attack*float(enemy.special_attack))
		defense = int(armor*float(enemy.special_armor))
		heal = int(enemy.hp*float(enemy.special_heal))
		label = enemy.special_name
	heal = int(heal*(1.0-.25*RealmRuneforge.active_rank(m,"tide")))
	if RealmGearSets.active(m,"moonsteel"): heal = int(heal*.8)
	if RealmPaths.active(m)=="Blight": heal = int(heal*.65)
	if RealmPaths.has_item(m,"relic_4"): heal = int(heal*.75)
	var damage = m.hit_damage(attack,defense)
	if RealmRuneforge.active_rank(m,"bell")>0: damage = ceili(damage*1.1)
	damage = maxi(1,ceili(damage*RealmDoctrines.active(m).incoming))
	if third and RealmGearSets.active(m,"steel"): damage = maxi(1,ceili(damage*.85))
	if third and RealmCharacters.id(m)=="warden" and RealmCharacters.rank(m)>0:
		damage = maxi(1,ceili(damage*(.75-.05*(RealmCharacters.rank(m)-1))))
	damage = RealmPaths.incoming(m,strike,damage)
	damage = RealmEndgame.move(m,enemy,strike,damage,second_phase)
	if RealmAfflictions.has(m,"enemy","weaken"): damage = maxi(1,int(damage*.85))
	if RealmAfflictions.has(m,"enemy","wound"): heal = int(heal*.65)
	damage = maxi(1,ceili(RealmLegacyGrowth.incoming(m,enemy,strike,damage)*(1.0-RealmCards.bonus(m,"defense"))))
	if third: damage = maxi(1,ceili(damage*(1.0-RealmCards.resistance(m,str(enemy.get("status",""))))))
	if third and enemy.boss and RealmPaths.has_item(m,"heirloom_aegis"): damage = maxi(1,ceili(damage*.9))
	if strike<=3 and RealmPaths.has_item(m,"heirloom_boots"): damage = maxi(1,ceili(damage*.85))
	if RealmPaths.has_item(m,"heirloom_ember_ring"): damage = maxi(1,ceili(damage*1.05))
	damage=RealmMarches.incoming(m,damage,third)
	return {"damage":damage,"heal":heal,"label":label}

static func player_damage(m, enemy: Dictionary, swing: int) -> int:
	var special = swing%4==0
	var armor = int(enemy.armor*(1.0-RealmCards.bonus(m,"pierce")))
	if enemy.boss and RealmPaths.has_item(m,"heirloom_blade"): armor = int(armor*.9)
	if RealmAfflictions.has(m,"enemy","armor_break"): armor = int(armor*.8)
	if RealmPaths.active(m)=="Fracture": armor = int(armor*.8)
	if RealmPaths.has_item(m,"relic_5"): armor = int(armor*.9)
	if special and "fracture" in RealmPaths.sockets(m): armor = int(armor*.85)
	if special: armor = int(armor*(1.0-.25*RealmRuneforge.active_rank(m,"thorn")))
	if special: armor = int(armor*(1.0-RealmDoctrines.active(m).pierce))
	if special and RealmCharacters.id(m)=="arcanist" and RealmCharacters.rank(m)>0:
		armor = int(armor*(.6-.1*(RealmCharacters.rank(m)-1)))
	var damage = m.hit_damage(int(m.stats().attack)+RealmHuntMastery.rank(m,enemy.id),armor)
	if special:
		match m.progression().stance:
			"balanced": damage *= 2
			"reaver": damage = int(damage*2.5)
		var rank = RealmRuneforge.active_rank(m,"bell")
		if rank>0: damage = int(damage*(1.0+[.2,.35,.5][rank-1]))
	damage = maxi(1,int(damage*RealmDoctrines.active(m).outgoing))
	if special and RealmGearSets.active(m,"dusksteel"): damage = maxi(1,int(damage*1.15))
	if special and RealmCharacters.rank(m)>0:
		if RealmCharacters.id(m)=="ranger": damage = maxi(1,int(damage*(1.2+.1*(RealmCharacters.rank(m)-1))))
		if RealmCharacters.id(m)=="reaver" and enemy.boss: damage = maxi(1,int(damage*(1.25+.1*(RealmCharacters.rank(m)-1))))
		damage = maxi(1,int(damage*(1+.03*RealmCharacters.allocated(m,"focus"))))
	damage = RealmPaths.outgoing(m,enemy,swing,damage)
	damage = RealmLegacyGrowth.outgoing(m,enemy,swing,maxi(1,int(damage*(1-float(enemy.get("resist",0))))))
	var class_rank=RealmCharacters.rank(m)
	if class_rank>0:
		if RealmCharacters.id(m)=="frostbound" and special and RealmAfflictions.has(m,"enemy","chill"):damage=int(damage*(1.2+.1*(class_rank-1)))
		if RealmCharacters.id(m)=="penitent" and special:damage+=int(m.stats().armor*(.15+.05*(class_rank-1)))
		if RealmCharacters.id(m)=="duskblade" and not m.s.fight.is_empty() and m.s.fight.hp<enemy.hp*.3:damage=int(damage*(1.2+.05*(class_rank-1)))
	damage=RealmMarches.outgoing(m,enemy,damage,special)
	var card_bonus = RealmCards.bonus(m,"attack")+(RealmCards.bonus(m,"boss") if enemy.boss else 0.0)+(RealmCards.bonus(m,"special") if special else 0.0)
	card_bonus += RealmCards.conditional_damage(m)
	if special and RealmPaths.has_item(m,"heirloom_gauntlets"): damage = int(damage*1.08)
	if enemy.boss and RealmPaths.has_item(m,"heirloom_ember_ring"): damage = int(damage*1.08)
	if RealmPaths.has_item(m,"heirloom_glass_ring") and (RealmAfflictions.has(m,"enemy","chill") or RealmAfflictions.has(m,"enemy","weaken")): damage = int(damage*1.06)
	return maxi(1,int(damage*(1.0+minf(.40,card_bonus))))

static func mechanic(enemy: Dictionary) -> String:
	if enemy.get("secret",false) or (enemy.get("depth",false) or (enemy.has("frontier") or (enemy.has("march") or enemy.has("realm")))):
		var recovery = " Restores %.1f%% HP." % (float(enemy.special_heal)*100) if enemy.special_heal>0 else ""
		return "%s · Every third attack: %.2f× attack, ignores %d%% armor, +%d pressure damage.%s\nBelow half HP: +18%% damage, double pressure. Every 15 attacks: +12%% damage (cap +150%%). Resists %d%% of your damage." % [enemy.special_name,enemy.special_attack,roundi((1-float(enemy.special_armor))*100),enemy.pressure,recovery,roundi(float(enemy.get("resist",0))*100)]
	if enemy.has("special_name"):
		var parts = ["%.1f× attack" % float(enemy.special_attack)]
		if float(enemy.special_armor)<1: parts.append("ignores %d%% armor" % roundi((1-float(enemy.special_armor))*100))
		if float(enemy.special_heal)>0: parts.append("restores %.1f%% enemy HP" % (float(enemy.special_heal)*100))
		return enemy.special_name+" · Every third attack: "+", ".join(parts)+"."
	match enemy.get("region",""):
		"wilds": return "Bramble crush · Every third attack ignores half your armor. A stronger blade can shorten your exposure."
		"marsh": return "Drowned hymn · Every third attack restores 5% of the Oracle's maximum HP, even if her strike misses. Bring enough damage to overcome the healing."
		"crown": return "Final toll · Every third attack deals 2.2× attack damage before armor. Prepare armor and a generous healing threshold."
	return "Third toll · Every third attack deals 1.8× attack damage before armor." if enemy.boss else "No special attack."

# A bounded analytical forecast, not a second simulation and never a reward source.
static func forecast(m, id: String) -> Dictionary:
	var enemy = RealmEndgame.enemy(m,m.data.enemies[id])
	var stats = m.stats()
	var stance = m.progression().stance
	var cycle_damage = player_damage(m,enemy,1)*3+player_damage(m,enemy,4)
	var damage_per_second = cycle_damage*float(stats.accuracy)*1.025/8.0
	var ordinary = move(m,enemy,1,int(stats.armor))
	var late_special = move(m,enemy,3,int(stats.armor),bool(enemy.get("trial",false)) or enemy.get("secret",false) or (enemy.get("depth",false) or (enemy.has("frontier") or (enemy.has("march") or enemy.has("realm")))))
	var interval = float(enemy.interval)/1000.0
	# Trials use the stronger phase for a conservative recovery/risk estimate.
	var net_damage = damage_per_second-float(late_special.heal)/(interval*3.0)
	var stalled = net_damage<=0
	var seconds = 3600.0 if stalled else clampf(ceil(float(enemy.hp)/maxf(.01,net_damage)/2.0)*2.0,2,3600)
	if enemy.get("secret",false) or (enemy.get("depth",false) or (enemy.has("frontier") or (enemy.has("march") or enemy.has("realm")))):
		var late_strike = maxi(3,int(seconds/interval))
		late_strike += (3-late_strike%3)%3
		late_special = move(m,enemy,late_strike,int(stats.armor),true)
		ordinary = move(m,enemy,maxi(1,late_strike-1),int(stats.armor),true)
	var attacks = floor(seconds/interval)
	var average_hit = (ordinary.damage*2.0+late_special.damage)/3.0
	var incoming = attacks*average_hit*.95
	if stance=="guard": incoming = maxf(0,incoming-seconds*float(stats.accuracy))
	var heal = food_heal(m,m.s.settings.food)
	var effective_heal = minf(heal,100-float(m.s.settings.threshold)*100+average_hit)
	var meals = ceili(maxf(0,incoming-maxf(0,float(m.s.hp)-float(m.s.settings.threshold)*100))/maxf(1,effective_heal))
	var capacity = float(m.s.hp)+minf(m.count(m.s.settings.food),attacks)*effective_heal
	var risk = stalled or late_special.damage>=100 or incoming>=capacity*.9 or m.s.hp<=0
	var rating = "Outmatched" if stalled else ("High risk" if risk else ("Food advised" if meals>0 else "Favorable"))
	var fragments = RealmHuntMastery.fragments(m,enemy)
	return {"incoming":incoming,"effective_heal":effective_heal,"seconds":seconds,"meals":meals,"rating":rating,"risk":risk,"stalled":stalled,"fragments_per_minute":0.0 if stalled else fragments*60.0/seconds,"healing":heal,"burst":int(late_special.damage)}

static func farms(m, relic: String) -> Array:
	var choices = []
	for id in m.data.enemies:
		var enemy = m.data.enemies[id]
		if RealmChronicle.fragments_for(enemy)!=relic or m.available(id)!="": continue
		var forecast_data = forecast(m,id)
		choices.append({"id":id,"forecast":forecast_data,"fragments":RealmHuntMastery.fragments(m,enemy)})
	choices.sort_custom(func(a,b):
		if a.forecast.risk!=b.forecast.risk: return not a.forecast.risk
		return a.forecast.fragments_per_minute>b.forecast.fragments_per_minute)
	return choices
