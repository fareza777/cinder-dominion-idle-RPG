class_name RealmStamina
extends RefCounted

const REGEN = 180000
const DEADLINE = 600000

static func cap(m) -> int: return 120+2*(m.level("bladecraft")-1)
static func state(m) -> Dictionary:
	if not m.s.has("stamina"): m.s.stamina = {"value":cap(m),"rest":0,"paused":false}
	return m.s.stamina

static func cost(enemy: Dictionary) -> Dictionary:
	var guardian = enemy.get("secret",false) or enemy.get("depth",false)
	var entry = 12 if guardian else (8 if enemy.boss else 1)
	var interval = 12000 if guardian else (15000 if enemy.boss else 30000)
	return {"entry":entry,"interval":interval,"reserve":entry+int(DEADLINE/interval)}

static func advance(m, elapsed: int):
	var st = state(m)
	if not m.s.fight.is_empty() or elapsed<=0: return
	if st.value>=cap(m): st.rest = 0; return
	var total = int(st.rest)+elapsed
	st.value = mini(cap(m),int(st.value)+int(total/REGEN))
	st.rest = 0 if st.value>=cap(m) else total%REGEN

static func start(m, enemy: Dictionary) -> bool:
	var st = state(m)
	if not m.s.tutorial: return true
	var assistant = m.s.get("assistant_queue",{})
	if st.paused and assistant.get("enabled",false) and int(assistant.get("until",0))>m.s.time and st.value>=cost(enemy).reserve: st.paused = false
	if st.paused: m.error = "Hunting paused. Rest, then tap Resume hunting."; return false
	if st.value<cost(enemy).reserve:
		st.paused = true
		m.error = "Not enough stamina. Rest or prepare supplies, then resume hunting."
		return false
	st.value -= cost(enemy).reserve
	return true

static func finish(m):
	if m.s.fight.is_empty() or not m.s.fight.has("stamina_started"): return
	var c = cost(m.data.enemies[m.s.fight.enemy])
	var elapsed = maxi(0,int(m.s.time)-int(m.s.fight.stamina_started))
	var used = mini(int(c.reserve),int(c.entry)+ceili(float(elapsed)/int(c.interval)))
	state(m).value = mini(cap(m),int(state(m).value)+int(c.reserve)-used)
	m.s.fight.erase("stamina_started")

static func summary(m) -> String:
	var st = state(m)
	return "Stamina %d / %d%s" % [st.value,cap(m)," · Hunting paused" if st.paused else (" · Reserved during battle" if not m.s.fight.is_empty() and m.s.tutorial else " · +1 every 3m resting")]

static func valid(s: Dictionary) -> bool:
	if not s.has("stamina"): return true
	var st = s.stamina
	return st is Dictionary and RealmSave.counter(st.get("value",-1)) and st.value<=120+2*(RealmLegacyGrowth.level(s.xp)-1) and RealmSave.counter(st.get("rest",-1)) and st.rest<REGEN and st.get("paused") is bool
