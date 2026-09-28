class_name RealmAfflictions
extends RefCounted

const ALL = ["burn","poison","bleed","chill","freeze","stun","shock","slow","armor_break","weaken","wound","barrier","regeneration"]
const CONTROL = ["freeze","stun"]

static func state(m) -> Dictionary:
	if not m.s.fight.has("effects"): m.s.fight.effects = {"hero":{},"enemy":{},"next":int(m.s.time)+1000,"immune_hero":0,"immune_enemy":0}
	return m.s.fight.effects

static func has(m, side: String, id: String) -> bool:
	if m.s.fight.is_empty(): return false
	var effect = m.s.fight.get("effects",{}).get(side,{}).get(id,{})
	return not effect.is_empty() and int(effect.until)>int(m.s.time)

static func apply(m, side: String, id: String, power: int = 1):
	if id not in ALL or m.s.fight.is_empty(): return
	var effects = state(m)
	var boss = side=="enemy" and m.data.enemies[m.s.fight.enemy].boss
	var duration = 20000 if id=="chill" else 6000
	if id in CONTROL:
		if int(effects["immune_"+side])>m.s.time: return
		duration = 500 if boss else 1500
		effects["immune_"+side] = int(m.s.time)+duration+6000
	if side=="hero" and RealmCards.resistance(m,id)>0:
		duration = int(duration*(1.0-RealmCards.resistance(m,id)))
	if side=="hero" and id=="shock" and RealmPaths.has_item(m,"heirloom_helm"): duration = int(duration*.5)
	var previous = effects[side].get(id,{})
	var stacks = mini(3,int(previous.get("stacks",0))+1) if id in ["burn","poison","bleed","chill"] else 1
	effects[side][id] = {"until":int(m.s.time)+duration,"power":clampi(power,1,12),"stacks":stacks}
	if id=="chill" and stacks==3:
		effects[side].erase("chill")
		apply(m,side,"freeze")
	m.combat_event(id.replace("_"," ").capitalize(),side,"status")

static func tick(m):
	if not m.s.fight.has("effects"): return
	var effects = state(m)
	if effects.next>m.s.time: return
	effects.next = int(m.s.time)+1000
	for side in ["hero","enemy"]:
		for id in effects[side].keys():
			var e = effects[side][id]
			if int(e.until)<=m.s.time: effects[side].erase(id); continue
			if id in ["burn","poison","bleed"]:
				var damage = int(e.power)*int(e.stacks)
				if side=="hero" and RealmPaths.has_item(m,"heirloom_cuirass"): damage = maxi(1,ceili(damage*.75))
				if side=="hero": m.s.hp = maxi(0,int(m.s.hp)-damage)
				else: m.s.fight.hp = maxi(0,int(m.s.fight.hp)-damage)
				m.combat_event("%s %d" % [id.capitalize(),damage],side,"status")
			if id=="regeneration":
				if side=="hero": m.s.hp = mini(100,int(m.s.hp)+int(e.power))
				else: m.s.fight.hp = mini(int(m.data.enemies[m.s.fight.enemy].hp),int(m.s.fight.hp)+int(e.power))

static func cleanse(m, side: String):
	var effects = state(m)
	for id in ALL:
		if id not in ["barrier","regeneration"] and effects[side].has(id):
			effects[side].erase(id)
			m.combat_event("Cleansed",side,"status")
			return

static func delay(m, side: String, interval: int) -> int:
	return int(interval*(1.0+(.2 if has(m,side,"slow") or has(m,side,"chill") else 0.0)+(.1 if has(m,side,"shock") else 0.0)))

static func absorb(m, side: String, damage: int) -> int:
	if has(m,side,"freeze"): state(m)[side].erase("freeze")
	if not has(m,side,"barrier"): return damage
	var e = state(m)[side].barrier
	var blocked = mini(damage,int(e.power))
	e.power -= blocked
	if e.power<=0: state(m)[side].erase("barrier")
	return damage-blocked

static func proc(m, enemy: Dictionary, side: String, special: bool):
	if not special: return
	if side=="enemy":
		if RealmCharacters.rank(m)>=2:
			var effect = {"warden":"stun","ranger":"bleed","arcanist":"burn","reaver":"armor_break","apothecary":"poison","frostbound":"chill","penitent":"weaken","duskblade":"bleed"}.get(RealmCharacters.id(m),"")
			apply(m,"enemy",effect,2)
		var rune=RealmRuneforge.state(m).equipped
		if rune!="" and RealmRuneforge.RUNES[rune].has("proc"):
			var re=RealmRuneforge.RUNES[rune].proc
			apply(m,"hero" if re in ["barrier","regeneration"] else "enemy",re,2*RealmRuneforge.active_rank(m,rune))
		for effect in RealmMarches.effects(m):
			if effect in ["bleed","burn","chill","poison"]:apply(m,"enemy",effect,2)
			elif effect=="sustain":apply(m,"hero","regeneration",2)
		for card in RealmCards.active(m):
			var d = RealmCards.definitions()[card]
			var potency = {"Rare":1,"Epic":2,"Legendary":3,"Mythic":4}[d.rarity]
			if d.get("proc","")!="": apply(m,"enemy",d.proc,potency)
			if d.get("boon","")=="cleanse": cleanse(m,"hero")
			elif d.get("boon","")!="": apply(m,"hero",d.boon,potency*2)
	else:
		var effect = enemy.get("status","")
		if effect!="": apply(m,"hero",effect,1)

static func summary(m, side: String) -> String:
	if m.s.fight.is_empty(): return ""
	var words = []
	for id in m.s.fight.get("effects",{}).get(side,{}):
		if has(m,side,id): words.append("%s %ds" % [id.replace("_"," ").capitalize(),ceili((int(m.s.fight.effects[side][id].until)-int(m.s.time))/1000.0)])
	return " · ".join(words)

static func valid(f: Dictionary, now: int = 0) -> bool:
	if not f.has("effects"): return true
	var e = f.effects
	if not e is Dictionary: return false
	for key in ["next","immune_hero","immune_enemy"]:
		if not RealmSave.counter(e.get(key,-1)): return false
	if e.next<now: return false
	for side in ["hero","enemy"]:
		if not e.get(side) is Dictionary: return false
		for id in e[side]:
			if id not in ALL or not e[side][id] is Dictionary: return false
			var value = e[side][id]
			for key in ["until","power","stacks"]:
				if not RealmSave.counter(value.get(key,-1)): return false
			if value.power<1 or value.power>12 or value.stacks<1 or value.stacks>3: return false
	return true

static func element(enemy: Dictionary) -> String:
	return {"burn":"Fire","chill":"Frost","freeze":"Frost","shock":"Lightning","poison":"Poison","wound":"Shadow"}.get(str(enemy.get("status","")),"Physical")
