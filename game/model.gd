class_name RealmModel
extends RefCounted

const MAX_OFFLINE = 86400000
const QUALITY = [0.8, 1.0, 1.1, 1.25, 1.5, 1.8, 2.2, 2.7]
var data: Dictionary
var s: Dictionary
var rng = RandomNumberGenerator.new()
var error = ""
var last_hit = ""

func _init():
	data = JSON.parse_string(FileAccess.get_file_as_string("res://data/catalog.json"))
	fresh()

func fresh(seed_value: int = 12345):
	rng.seed = seed_value
	s = {"version":1,"revision":0,"time":0,"wall":0,"rng":str(rng.state),"gold":20,
		"bag":{"cooked_minnow":5},"gear":[],"overflow":[],"equipped":{},"next_uid":1,
		"xp":{},"mastery":{},"queue":[],"active":{},"fight":{},"hp":100,
		"regen_at":1000,"kills":{},"gains":{},"spent":{},"tutorial":false,"beacon":false,
		"presets":{},"log":[],"processed":[],"settings":{"locale":"id","font":1.0,
		"motion":true,"battery":true,"music":0.35,"sfx":0.5,"food":"cooked_minnow",
		"threshold":0.5,"potion":"","potion_policy":"off"},"report":{}}
	for key in data.skills: s.xp[key] = 0
	for id in ["worn_sword","worn_shield","wood_axe","stone_pick","reed_rod"]:
		var uid = add_gear(id, 1)
		s.equipped[data.items[id].slot] = uid

func local_name(entry: Dictionary) -> String:
	return str(entry.get("en",entry.get("name",""))) if s.settings.locale == "en" else str(entry.get("name",""))

func name_of(id: String) -> String:
	return local_name(data.items.get(id,{"name":id,"en":id}))

func level(skill: String) -> int:
	return mini(100, 1 + int(sqrt(float(s.xp.get(skill,0)) / 25.0)))

func count(id: String) -> int:
	return int(s.bag.get(id,0))

func gear(uid: String) -> Dictionary:
	for g in s.gear:
		if g.uid == uid: return g
	return {}

func stats() -> Dictionary:
	var st = {"attack":4.0 + floor((level("might")-1)/5.0),"armor":floor((level("warding")-1)/5.0),"hp":100,"accuracy":minf(.99,.95+(level("bladecraft")-1)*.001)}
	for uid in s.equipped.values():
		var g = gear(str(uid))
		if g.is_empty(): continue
		var d = data.items[g.id]
		st.attack += float(d.get("attack",0))*QUALITY[int(g.q)]
		st.armor += float(d.get("armor",0))*QUALITY[int(g.q)]
	if not s.fight.is_empty() and s.fight.get("buff_until",0)>s.time:
		st[s.fight.buff] += 3
	st.attack = int(st.attack)
	st.armor = int(st.armor)
	return st

func protected(uid: String) -> bool:
	var g = gear(uid)
	if g.is_empty(): return true
	if g.locked or g.favorite or uid in s.equipped.values(): return true
	for slots in s.presets.values():
		if uid in slots.values(): return true
	return false

func add_gear(id: String, quality: int) -> String:
	for g in s.gear:
		if g.id == id and int(g.q) == quality:
			g.count += 1
			return g.uid
	var uid = "eq_%d" % int(s.next_uid)
	s.next_uid += 1
	var g = {"uid":uid,"id":id,"q":quality,"count":1,"locked":false,"favorite":false}
	if s.gear.size() >= 1000: s.overflow.append(g)
	else: s.gear.append(g)
	return uid

func gain(id: String, amount: int, quality: int = 1):
	if data.items[id].category == "equipment":
		for i in range(amount): add_gear(id,quality)
	else: s.bag[id] = count(id)+amount
	s.gains[id] = int(s.gains.get(id,0))+amount

func spend(id: String, amount: int):
	s.bag[id] = count(id)-amount
	s.spent[id] = int(s.spent.get(id,0))+amount

func note(message: String):
	s.log.push_front(message)
	if s.log.size()>20: s.log.resize(20)

func available(enemy_id: String) -> String:
	var d = data.enemies[enemy_id]
	if d.unlock == "": return ""
	if d.unlock == "tutorial":
		return "Selesaikan Bekal Pertama" if not s.tutorial else ""
	if int(s.kills.get(d.unlock,0))<5: return "Kalahkan %s 5×" % local_name(data.enemies[d.unlock])
	if d.boss and level("smithing")<10: return "Penempaan level 10"
	return ""

func requirement(aid: String) -> String:
	if not data.activities.has(aid): return "Aktivitas tidak ditemukan"
	var a = data.activities[aid]
	if a.kind=="combat":
		var locked = available(a.enemy)
		if locked!="": return locked
		if s.hp<=0: return "Pulihkan HP di desa"
	else:
		if level(a.skill)<int(a.level): return "%s Lv.%d" % [local_name(data.skills[a.skill]),int(a.level)]
		for id in a.inputs:
			if count(id)<int(a.inputs[id]): return "Kurang %s (%d/%d)" % [name_of(id),count(id),int(a.inputs[id])]
	return ""

func command(cmd: Dictionary) -> bool:
	error = ""
	var cid = str(cmd.get("cid",""))
	if cid!="" and cid in s.processed: return true
	var action = str(cmd.get("type",""))
	var id = str(cmd.get("id",""))
	match action:
		"queue":
			if not data.activities.has(id): return fail("Aktivitas tidak dikenal")
			if s.queue.size()>=20: return fail("Antrean penuh (20)")
			var target = clampi(int(cmd.get("target",50)),1,1000000)
			var kind = str(cmd.get("kind","cycles"))
			if kind not in ["cycles","output","level"]: return fail("Target tidak valid")
			s.queue.append({"id":id,"target":mini(target,100) if kind=="level" else target,"kind":kind,"done":0,"output":0,"skip":bool(cmd.get("skip",false))})
			if s.active.is_empty() and s.fight.is_empty(): start_next()
		"cancel":
			var index = int(cmd.get("index",0))
			if index<0 or index>=s.queue.size(): return fail("Antrean berubah")
			if index==0: refund_active()
			s.queue.remove_at(index)
			start_next()
		"up":
			var index = int(cmd.get("index",0))
			if index<2 or index>=s.queue.size(): return fail("Aktivitas berjalan tetap di urutan pertama")
			var step = s.queue[index]
			s.queue.remove_at(index)
			s.queue.insert(index-1,step)
		"clear":
			refund_active()
			s.queue.clear()
		"equip":
			if not s.fight.is_empty(): return fail("Hentikan pertarungan untuk mengganti build")
			var g = gear(id)
			if g.is_empty(): return fail("Item tidak ditemukan")
			s.equipped[data.items[g.id].slot] = id
		"lock","favorite":
			var g = gear(id)
			if g.is_empty(): return fail("Item tidak ditemukan")
			var field = "locked" if action=="lock" else "favorite"
			g[field] = not g[field]
		"salvage":
			var ids = cmd.get("ids",[])
			if ids.is_empty(): return fail("Tidak ada item yang bisa dilebur")
			var seen = {}
			for uid in ids:
				if seen.has(uid) or protected(uid): return fail("Item terpasang, terkunci, atau tersimpan dalam preset")
				seen[uid] = true
			var amount = 0
			for uid in ids:
				var g = gear(uid)
				amount += int(g.count)*([1,1,2,4,6,8,12,16][int(g.q)])
				s.gear.erase(g)
			gain("scrap",amount)
			note("Dilebur menjadi %d serpihan" % amount)
		"buy":
			if not data.merchant.has(id): return fail("Barang tidak dijual")
			var qty = clampi(int(cmd.get("amount",1)),1,100)
			var cost = int(data.merchant[id])*qty
			if s.gold<cost: return fail("Gold tidak cukup")
			s.gold -= cost
			gain(id,qty)
		"sell":
			if not data.items.has(id) or data.items[id].category=="equipment": return fail("Gunakan peleburan untuk perlengkapan")
			var qty = clampi(int(cmd.get("amount",1)),1,1000)
			if count(id)<qty: return fail("Jumlah item tidak cukup")
			spend(id,qty)
			s.gold += qty
		"food":
			if not data.items.has(id) or data.items[id].category!="food": return fail("Bukan makanan")
			s.settings.food = id
		"potion":
			if id!="" and (not data.items.has(id) or data.items[id].category!="potion"): return fail("Ramuan tidak valid")
			s.settings.potion = id
			s.settings.potion_policy = "auto" if id!="" else "off"
		"preset_save":
			s.presets[id.left(24)] = s.equipped.duplicate(true)
		"preset_load":
			if not s.fight.is_empty(): return fail("Hentikan pertarungan terlebih dahulu")
			if not s.presets.has(id): return fail("Preset kosong")
			s.equipped = s.presets[id].duplicate(true)
		"overflow":
			var moved = []
			for g in s.overflow:
				if s.gear.size()>=1000: break
				s.gear.append(g)
				moved.append(g)
			for g in moved: s.overflow.erase(g)
		"setting":
			if not s.settings.has(id): return fail("Pengaturan tidak dikenal")
			s.settings[id] = cmd.get("value")
		_:
			return fail("Perintah tidak dikenal")
	check_quest()
	if cid!="":
		s.processed.append(cid)
		if s.processed.size()>128: s.processed.pop_front()
	return true

func fail(message: String) -> bool:
	error = message
	return false

func refund_active():
	if not s.active.is_empty():
		for id in s.active.reserved:
			var qty = int(s.active.reserved[id])
			s.bag[id] = count(id)+qty
			s.spent[id] = int(s.spent.get(id,0))-qty
	s.active = {}
	s.fight = {}
	s.regen_at = int(s.time)+1000

func duration(a: Dictionary) -> int:
	var tool_slot = {"woodcutting":"axe","mining":"pick","fishing":"rod"}.get(a.skill,"")
	var discount = 0.0
	var g = gear(str(s.equipped.get(tool_slot,"")))
	if not g.is_empty(): discount = float(data.items[g.id].get("speed",0))
	discount += minf(.1,floor(float(s.mastery.get(a.id,0))/100.0)*.01)
	return maxi(200,int(float(a.duration)*1000*(1-minf(.3,discount))))

func step_complete(step: Dictionary) -> bool:
	if step.kind=="level": return level(data.activities[step.id].skill)>=int(step.target)
	return int(step.output if step.kind=="output" else step.done)>=int(step.target)

func start_next():
	if not s.active.is_empty() or not s.fight.is_empty(): return
	while not s.queue.is_empty():
		var step = s.queue[0]
		if step_complete(step):
			s.queue.pop_front()
			continue
		var why = requirement(step.id)
		if why!="":
			if step.skip:
				s.queue.pop_front()
				continue
			error = why
			return
		var a = data.activities[step.id]
		if a.kind=="combat":
			var enemy = data.enemies[a.enemy]
			s.fight = {"enemy":a.enemy,"hp":enemy.hp,"player_at":int(s.time)+2000,"enemy_at":int(s.time)+int(enemy.interval),"hits":0,"buff_until":0,"buff":"attack","potion_at":0,"spawn_at":0}
		else:
			for id in a.inputs: spend(id,int(a.inputs[id]))
			s.active = {"id":step.id,"started":s.time,"due":int(s.time)+duration(a),"reserved":a.inputs.duplicate(true)}
		return

func advance(ms: int):
	if ms<=0: return
	rng.state = int(s.rng)
	var target = int(s.time)+ms
	start_next()
	while int(s.time)<target:
		var due = target+1
		if not s.active.is_empty(): due = int(s.active.due)
		if not s.fight.is_empty():
			due = mini(int(s.fight.player_at),int(s.fight.enemy_at))
			if s.fight.buff_until>s.time: due = mini(due,int(s.fight.buff_until))
		else:
			if s.hp<100: due = mini(due,maxi(int(s.regen_at),int(s.time)))
		if due>target: break
		s.time = due
		if not s.fight.is_empty(): resolve_combat()
		else:
			if s.hp<100 and s.regen_at<=s.time:
				s.hp = mini(100,int(s.hp)+1)
				s.regen_at = int(s.time)+1000
			if not s.active.is_empty() and s.active.due<=s.time: finish_production()
		start_next()
	s.time = target
	s.rng = str(rng.state)

func quality_roll() -> int:
	var roll = rng.randf()
	return 3 if roll<.02 else (2 if roll<.15 else 1)

func finish_production():
	var a = data.activities[s.active.id]
	var q = quality_roll() if data.items[a.output].category=="equipment" else 1
	gain(a.output,1,q)
	if a.side!="" and rng.randf()<.2: gain(a.side,1)
	s.xp[a.skill] = int(s.xp[a.skill])+int(a.xp)
	s.mastery[a.id] = int(s.mastery.get(a.id,0))+1
	s.queue[0].done += 1
	s.queue[0].output += 1
	s.active = {}
	if q>=2: note("%s · %s" % [data.rarities[q],name_of(a.output)])
	check_quest()

func hit_damage(atk: int, armor: int) -> int:
	return maxi(1,int(floor(atk*100.0/(100+armor*5))))

func resolve_combat():
	var f = s.fight
	var d = data.enemies[f.enemy]
	if f.buff_until>0 and f.buff_until<=s.time: f.buff_until = 0
	var pot = str(s.settings.potion)
	if pot!="" and count(pot)>0 and f.potion_at<=s.time:
		var effect = data.items[pot].effect
		if effect!="heal" or s.hp<=50:
			spend(pot,1)
			f.potion_at = int(s.time)+60000
			if effect=="heal": s.hp = mini(100,int(s.hp)+50)
			else:
				f.buff = effect
				f.buff_until = int(s.time)+60000
	var st = stats()
	if f.player_at<=s.time:
		f.player_at = int(s.time)+2000
		if rng.randf()<st.accuracy:
			var damage = hit_damage(int(st.attack),int(d.armor))
			var crit = rng.randf()<.05
			if crit: damage = int(damage*1.5)
			f.hp -= damage
			last_hit = ("CRIT " if crit else "")+str(damage)
		else: last_hit = "MISS"
	if f.hp<=0:
		win(d)
		return
	if f.enemy_at<=s.time:
		f.enemy_at = int(s.time)+int(d.interval)
		f.hits += 1
		if rng.randf()<.95:
			var attack = int(d.attack*1.8) if d.boss and int(f.hits)%3==0 else int(d.attack)
			s.hp -= hit_damage(attack,int(st.armor))
		if s.hp<=0:
			s.hp = 0
			note("Kalah melawan %s. Perlengkapan tetap aman." % local_name(d))
			s.fight = {}
			s.queue.clear()
			s.regen_at = int(s.time)+1000
			return
		var food = str(s.settings.food)
		if s.hp<=100*float(s.settings.threshold) and count(food)>0:
			spend(food,1)
			s.hp = mini(100,int(s.hp)+int(data.items[food].heal))

func win(enemy: Dictionary):
	var id = enemy.id
	s.kills[id] = int(s.kills.get(id,0))+1
	s.gold += int(enemy.gold)
	gain(enemy.drop,int(enemy.qty))
	var xp = int(enemy.xp)
	s.xp.bladecraft += xp-int(xp/3)*2
	s.xp.might += int(xp/3)
	s.xp.warding += int(xp/3)
	if rng.randf()<.05:
		var part = ["sword","shield","helm","chest","gloves","boots"][rng.randi_range(0,5)]
		var q = quality_roll()
		gain("copper_"+part,1,q)
		note("Loot: %s %s" % [data.rarities[q],name_of("copper_"+part)])
	if enemy.boss and not s.beacon:
		s.beacon = true
		gain("copper_sword",1,3)
		note("Lonceng terdiam. Api Cinderwatch kembali menyala.")
	s.queue[0].done += 1
	s.queue[0].output += int(enemy.qty)
	s.fight = {}
	s.regen_at = int(s.time)+1000
	check_quest()

func objective() -> Dictionary:
	var steps = [
		["Bijih untuk sebuah harapan","Gather copper ore",int(s.gains.get("copper_ore",0)),4,"mine_copper"],
		["Nyalakan tungku pertama","Smelt copper ingots",int(s.gains.get("copper_ingot",0)),2,"craft_copper_ingot"],
		["Kayu untuk gagang pedang","Gather an ash log",int(s.gains.get("ash_log",0)),1,"cut_ash"],
		["Tempa pedang pertamamu","Forge a copper sword",int(s.gains.get("copper_sword",0)),1,"craft_copper_sword"]]
	for st in steps:
		if st[2]<st[3]: return {"title":st[1] if s.settings.locale=="en" else st[0],"current":st[2],"goal":st[3],"activity":st[4],"kind":"activity"}
	var weapon = gear(str(s.equipped.get("weapon","")))
	if not s.tutorial and (weapon.is_empty() or weapon.id not in ["copper_sword","iron_sword"]):
		return {"title":"Equip your new sword" if s.settings.locale=="en" else "Pasang pedang barumu","current":0,"goal":1,"activity":"","kind":"equip"}
	if not s.tutorial:
		return {"title":"Clear the outskirts" if s.settings.locale=="en" else "Amankan pinggiran desa","current":int(s.kills.get("ash_rat",0)),"goal":3,"activity":"hunt_ash_rat","kind":"activity"}
	if s.beacon: return {"title":"Cinderwatch lives again" if s.settings.locale=="en" else "Cinderwatch hidup kembali","current":1,"goal":1,"activity":"","kind":"complete"}
	return {"title":"Silence the Bellkeeper" if s.settings.locale=="en" else "Bungkam Sang Penjaga Lonceng","current":0,"goal":1,"activity":"hunt_bellkeeper","kind":"boss"}

func check_quest():
	if s.tutorial: return
	var weapon = gear(str(s.equipped.get("weapon","")))
	if not weapon.is_empty() and weapon.id in ["copper_sword","iron_sword"] and int(s.kills.get("ash_rat",0))>=3 and int(s.gains.get("copper_sword",0))>=1 and int(s.gains.get("copper_ingot",0))>=2 and int(s.gains.get("copper_ore",0))>=4 and int(s.gains.get("ash_log",0))>=1:
		s.tutorial = true
		s.gold += 30
		gain("cooked_minnow",10)
		note("Bekal Pertama selesai · +30 gold · +10 ikan panggang")

func activity_name(id: String) -> String:
	var a = data.activities[id]
	if a.kind=="combat": return local_name(data.enemies[a.enemy])
	return name_of(a.output)

func sources(id: String) -> Array:
	var out = []
	for key in data.activities:
		var a = data.activities[key]
		if a.output==id or a.get("side","")==id: out.append(key)
	return out
