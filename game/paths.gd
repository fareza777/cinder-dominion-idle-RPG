class_name RealmPaths
extends RefCounted

const ALL = {
	"warden":[["Bulwark","Third enemy attacks deal 20% less damage; all your damage is reduced by 10%."],["Reprisal","Every fourth attack gains damage equal to 15% of your armor."]],
	"ranger":[["Deadeye","Ordinary attacks deal 15% more damage."],["Venom","Every fourth attack adds 0.3% of enemy maximum HP, capped at 18 damage."]],
	"arcanist":[["Fracture","Every attack ignores 20% of enemy armor."],["Ember","Every fourth attack adds 12 damage after armor."]],
	"reaver":[["Slayer","Deal 20% more damage to bosses, but take 12% more damage."],["Frenzy","Deal 12% more damage to all enemies, but take 12% more damage."]],
	"apothecary":[["Provisioner","Meals restore 8 extra HP; deal 5% less damage."],["Blight","Enemy healing is reduced by 35%."]]}
const SOCKETS = {
	"ember":["Ember","Every fourth attack adds 8 damage; take 5% more damage."],
	"fracture":["Fracture","Every fourth attack ignores 15% armor; ordinary damage is reduced by 5%."],
	"echo":["Echo","Every fourth attack deals 12% more damage; meals restore 5 fewer HP."],
	"shelter":["Shelter","Take 8% less damage; deal 5% less damage."]}

static func active(m) -> String:
	var character = RealmCharacters.id(m)
	var choice = int(m.s.get("path_choice",-1))
	return ALL[character][choice][0] if character in ALL and choice in [0,1] else ""

static func sockets(m) -> Array: return m.s.get("sockets",[])
static func slots(m) -> int:
	return 0 if not m.s.beacon else (3 if int(m.s.kills.get("secret_4",0))>0 else (2 if m.level("bladecraft")>=75 else 1))

static func command(m, cmd) -> String:
	if not m.s.fight.is_empty(): return "Finish your hunt before changing your build."
	if cmd.type=="path_choose":
		if RealmCharacters.id(m) not in ALL or m.level("bladecraft")<25: return "Choose a character and reach Bladecraft Lv.25."
		if int(cmd.get("choice",-1)) not in [-1,0,1]: return "Choose a specialization."
		m.s.path_choice = int(cmd.choice)
	else:
		var id = str(cmd.id)
		if id not in SOCKETS: return "Unknown socket relic."
		var equipped = sockets(m).duplicate()
		if id in equipped: equipped.erase(id)
		else:
			if equipped.size()>=slots(m): return "Remove a socket relic first."
			if m.count("socket_"+id)<1: return "Forge this socket relic first."
			equipped.append(id)
		m.s.sockets = equipped
	return ""

static func outgoing(m, enemy, swing: int, damage: int) -> int:
	var special = swing%4==0
	match active(m):
		"Bulwark": damage = int(damage*.9)
		"Reprisal":
			if special: damage += int(m.stats().armor*.15)
		"Deadeye":
			if not special: damage = int(damage*1.15)
		"Venom":
			if special: damage += mini(18,int(enemy.hp*.003))
		"Ember":
			if special: damage += 12
		"Slayer":
			if enemy.boss: damage = int(damage*1.2)
		"Frenzy": damage = int(damage*1.12)
		"Provisioner": damage = int(damage*.95)
	var relics = sockets(m)
	if "ember" in relics and special: damage += 8
	if "echo" in relics and special: damage = int(damage*1.12)
	if ("fracture" in relics and not special) or "shelter" in relics: damage = int(damage*.95)
	if has_item(m,"relic_0") and special: damage += 10
	if has_item(m,"relic_2") and enemy.boss: damage = int(damage*1.12)
	if has_item(m,"relic_6") and special: damage = int(damage*1.15)
	return maxi(1,damage)

static func incoming(m, strike: int, damage: int) -> int:
	if active(m)=="Bulwark" and strike%3==0: damage = ceili(damage*.8)
	if active(m) in ["Slayer","Frenzy"]: damage = ceili(damage*1.12)
	if "ember" in sockets(m): damage = ceili(damage*1.05)
	if "shelter" in sockets(m): damage = ceili(damage*.92)
	if has_item(m,"relic_1") and strike%3==0: damage = ceili(damage*.85)
	return maxi(1,damage)

static func has_item(m, id: String) -> bool:
	for uid in m.s.equipped.values():
		if m.gear(str(uid)).get("id","")==id: return true
	return false

static func food_bonus(m) -> int:
	return (8 if active(m)=="Provisioner" else 0)-(5 if "echo" in sockets(m) else 0)+(8 if has_item(m,"relic_3") else 0)

static func valid(s) -> bool:
	if s.has("path_choice"):
		if typeof(s.path_choice) not in [TYPE_INT,TYPE_FLOAT] or not RealmSave.counter(float(s.path_choice)+1) or s.path_choice>1: return false
		if int(s.path_choice)!=-1 and (not s.has("hero") or float(s.xp.bladecraft)<14400): return false
	if s.has("sockets"):
		if not s.sockets is Array or s.sockets.size()>3: return false
		var seen = []
		for id in s.sockets:
			if id not in SOCKETS or id in seen or s.bag.get("socket_"+id,0)<1: return false
			seen.append(id)
		var limit = 0 if not s.beacon else (3 if s.kills.get("secret_4",0)>0 else (2 if float(s.xp.bladecraft)>=136900 else 1))
		if seen.size()>limit: return false
	return true
