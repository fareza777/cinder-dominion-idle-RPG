class_name RealmEconomy
extends RefCounted

const COMBAT = ["bladecraft","might","warding"]
const GOLD = 1000
const PLATINUM = 1000000
static var currency_pattern: RegEx

static func text_value(value: String) -> String:
	if currency_pattern==null:
		currency_pattern = RegEx.new()
		currency_pattern.compile("([+-]?[0-9]+) gold\\b")
	var matches = currency_pattern.search_all(value)
	for index in range(matches.size()-1,-1,-1):
		var hit = matches[index]
		var amount = hit.get_string(1)
		value = value.substr(0,hit.get_start())+("+" if amount.begins_with("+") else "")+money(int(amount))+value.substr(hit.get_end())
	return value

# The legacy field s.gold stores integer silver. Denominations never round purchases.
static func money(value: int) -> String:
	var amount = absi(value)
	var parts = []
	if amount>=PLATINUM: parts.append("%dP" % int(amount/PLATINUM))
	if amount>=GOLD and int(amount/GOLD)%1000>0: parts.append("%dG" % (int(amount/GOLD)%1000))
	if amount%GOLD>0 or parts.is_empty(): parts.append("%dS" % (amount%GOLD))
	return ("−" if value<0 else "")+" ".join(parts)

static func threshold(level_value: int, skill: String = "bladecraft") -> int:
	var n = clampi(level_value,1,130)-1
	var late = maxi(0,level_value-20)
	var beyond = maxi(0,mini(130,level_value)-100)
	return 25*n*n+(4*late*late*late if skill in COMBAT else 0)+(1200 if skill in COMBAT else 200)*beyond*beyond*beyond

static func level(xp, skill: String = "bladecraft") -> int:
	var low = 1
	var high = 130
	while low<high:
		var mid = int((low+high+1)/2)
		if int(xp)>=threshold(mid,skill): low = mid
		else: high = mid-1
	return low

static func relic_fee(rank_value: int) -> int:
	return 0 if rank_value<10 else 5000*(rank_value-9)*(rank_value-9)

static func temper_fee(quality: int) -> int: return 250000*quality*quality

static func hunt_xp(m, enemy: Dictionary) -> int:
	var multiplier = {"safe":.8,"mastery":1.2,"elite":1.25}.get(RealmEndgame.route(m),1.0)
	return int(int(enemy.xp)*multiplier)

# One-time migration preserves level and fractional progress, never revalues wallet units.
static func migrate(s: Dictionary):
	s.erase("stamina")
	if s.get("fight") is Dictionary: s.fight.erase("stamina_started")
	if int(s.get("economy_revision",0))>=1: return
	for skill in COMBAT:
		var old_xp = int(s.xp[skill])
		var old_level = mini(100,1+int(sqrt(old_xp/25.0)))
		var old_base = 25*(old_level-1)*(old_level-1)
		if old_level>=100: s.xp[skill] = threshold(100)+maxi(0,old_xp-old_base)
		else:
			var fraction = float(old_xp-old_base)/(25*old_level*old_level-old_base)
			s.xp[skill] = threshold(old_level)+floori(fraction*(threshold(old_level+1)-threshold(old_level)))
	s.economy_revision = 1

static func experience_note(m, enemy: Dictionary) -> String:
	var current = m.level("bladecraft")
	if current>=130: return "Bladecraft mastered. Hunt for cards, materials and better equipment."
	var xp = hunt_xp(m,enemy)
	var per_win = xp-int(xp/3)*2
	var remaining = threshold(current+1)-int(m.s.xp.bladecraft)
	var wins = ceili(float(remaining)/maxi(1,per_win))
	return "%d Bladecraft XP / win · ~%d %s to Lv.%d" % [per_win,wins,"win" if wins==1 else "wins",current+1]
