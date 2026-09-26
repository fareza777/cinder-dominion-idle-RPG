class_name RealmSave
extends RefCounted

const DIRECTORY = "user://saves"
const LIMIT = 5*1024*1024
var message = ""

static func counter(v) -> bool:
	return (typeof(v)==TYPE_FLOAT or typeof(v)==TYPE_INT) and is_finite(float(v)) and float(v)==floor(float(v)) and v>=0 and v<=1e12

func valid(s, data: Dictionary) -> bool:
	if not s is Dictionary: return false
	var fields = ["version","revision","time","wall","rng","gold","bag","gear","overflow","equipped","next_uid","xp","mastery","queue","active","fight","hp","regen_at","kills","gains","spent","tutorial","beacon","presets","log","processed","settings","report"]
	for key in fields:
		if not s.has(key): return false
	for key in ["version","revision","gold","next_uid","hp"]:
		if not counter(s[key]): return false
	for key in ["time","wall","regen_at"]:
		if typeof(s[key]) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(s[key])) or s[key]<0 or s[key]>9e15 or floor(float(s[key]))!=float(s[key]): return false
	if s.version!=1 or s.hp>100 or not s.rng is String or not s.rng.is_valid_int(): return false
	for key in ["bag","equipped","xp","mastery","active","fight","kills","gains","spent","presets","settings","report"]:
		if not s[key] is Dictionary: return false
	for key in ["gear","overflow","queue","log","processed"]:
		if not s[key] is Array: return false
	if s.queue.size()>20 or s.gear.size()>1000 or s.log.size()>20 or s.processed.size()>128: return false
	for key in ["bag","gains","spent"]:
		for id in s[key]:
			if not data.items.has(id) or not counter(s[key][id]): return false
	for id in data.skills:
		if not s.xp.has(id) or not counter(s.xp[id]): return false
	for id in s.mastery:
		if not data.activities.has(id) or not counter(s.mastery[id]): return false
	for id in s.kills:
		if not data.enemies.has(id) or not counter(s.kills[id]): return false
	var uids = {}
	for g in s.gear+s.overflow:
		if not g is Dictionary: return false
		for key in ["uid","id","q","count","locked","favorite"]:
			if not g.has(key): return false
		if not data.items.has(g.id) or data.items[g.id].category!="equipment": return false
		if not counter(g.q) or g.q>7 or not counter(g.count) or g.count<1: return false
		if not g.uid is String or uids.has(g.uid) or not g.locked is bool or not g.favorite is bool: return false
		uids[g.uid] = g
	for slot in s.equipped:
		if not uids.has(s.equipped[slot]) or data.items[uids[s.equipped[slot]].id].slot!=slot: return false
	for slots in s.presets.values():
		if not slots is Dictionary: return false
		for slot in slots:
			if not uids.has(slots[slot]) or data.items[uids[slots[slot]].id].slot!=slot: return false
	if s.has("loadouts"):
		if not s.loadouts is Dictionary or s.loadouts.size()>3: return false
		for id in s.loadouts:
			if id not in RealmLoadouts.NAMES or not RealmLoadouts.valid(s.loadouts[id],data,uids): return false
	if s.has("hunts") and not RealmHunts.valid(s.hunts,data): return false
	for step in s.queue:
		if not step is Dictionary: return false
		for key in ["id","target","kind","done","output","skip"]:
			if not step.has(key): return false
		if not data.activities.has(step.id) or step.kind not in ["cycles","output","level"]: return false
		if not counter(step.target) or step.target<1 or step.target>1000000 or not counter(step.done) or not counter(step.output) or not step.skip is bool: return false
	if not s.active.is_empty():
		for key in ["id","started","due","reserved"]:
			if not s.active.has(key): return false
		if s.queue.is_empty() or s.active.id!=s.queue[0].id or not s.fight.is_empty(): return false
		if not counter(s.active.due) or s.active.due<s.time or not counter(s.active.started): return false
		if not s.active.reserved is Dictionary or s.active.reserved!=data.activities[s.active.id].inputs: return false
	if not s.fight.is_empty():
		for key in ["enemy","hp","player_at","enemy_at","hits","buff_until","buff","potion_at","spawn_at"]:
			if not s.fight.has(key): return false
		if s.queue.is_empty() or s.queue[0].id!="hunt_"+str(s.fight.enemy) or not data.enemies.has(s.fight.enemy): return false
		for key in ["hp","player_at","enemy_at","hits","buff_until","potion_at","spawn_at"]:
			if not counter(s.fight[key]): return false
		if s.fight.player_at<s.time or s.fight.enemy_at<s.time or s.fight.buff not in ["attack","armor"]: return false
	if s.has("upgrade_goal"):
		if not s.upgrade_goal is String: return false
		if s.upgrade_goal!="" and (not data.items.has(s.upgrade_goal) or data.items[s.upgrade_goal].category!="equipment" or not data.activities.has("craft_"+s.upgrade_goal)): return false
	if s.has("doctrine"):
		if not s.doctrine is String or not RealmDoctrines.ALL.has(s.doctrine): return false
		if s.doctrine!="none" and float(s.xp.bladecraft)<14400: return false
	if s.has("experience"):
		if not s.experience is Dictionary or s.experience.get("version",0)!=2 or not s.experience.get("welcome_done",false) is bool: return false
		if s.experience.has("coach_active") and not s.experience.coach_active is bool: return false
	if s.has("progression"):
		var p = s.progression
		if not p is Dictionary or not RealmProgression.STANCES.has(p.get("stance","")): return false
		if not p.get("claimed") is Array or not p.get("upgrades") is Dictionary: return false
		var ids = []
		for contract in RealmProgression.CONTRACTS: ids.append(contract.id)
		var seen = []
		for id in p.claimed:
			if id not in ids or id in seen: return false
			seen.append(id)
		for id in RealmProgression.UPGRADES:
			if not counter(p.upgrades.get(id,-1)) or p.upgrades[id]>3: return false
	if s.fight.has("phase") and (not counter(s.fight.phase) or s.fight.phase<1 or s.fight.phase>2): return false
	if s.fight.has("swings") and not counter(s.fight.swings): return false
	if s.has("chronicle") and not RealmChronicle.valid(s.chronicle,s.xp): return false
	if s.has("runeforge") and not RealmRuneforge.valid(s.runeforge): return false
	var cfg = s.settings
	for key in ["locale","font","motion","battery","music","sfx","food","threshold","potion","potion_policy"]:
		if not cfg.has(key): return false
	if cfg.locale not in ["id","en"] or not cfg.motion is bool or not cfg.battery is bool: return false
	for key in ["font","music","sfx","threshold"]:
		if typeof(cfg[key]) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(cfg[key])): return false
	if cfg.font<.8 or cfg.font>1.3 or cfg.threshold<.1 or cfg.threshold>.9 or cfg.music<0 or cfg.music>1 or cfg.sfx<0 or cfg.sfx>1: return false
	if not data.items.has(cfg.food) or data.items[cfg.food].category!="food": return false
	if cfg.potion!="" and (not data.items.has(cfg.potion) or data.items[cfg.potion].category!="potion"): return false
	for line in s.log:
		if not line is String or line.length()>512: return false
	return true

func encode(s: Dictionary) -> String:
	var payload = JSON.stringify(s)
	return JSON.stringify({"payload":payload,"checksum":payload.sha256_text()})

func decode(text: String, data: Dictionary) -> Dictionary:
	if text.length()>LIMIT: return {}
	var doc = JSON.parse_string(text)
	if not doc is Dictionary or not doc.get("payload") is String: return {}
	if doc.get("checksum","")!=doc.payload.sha256_text(): return {}
	var state = JSON.parse_string(doc.payload)
	return state if valid(state,data) else {}

func generations(directory: String) -> Array:
	var out = []
	if not DirAccess.dir_exists_absolute(directory): return out
	for name in DirAccess.get_files_at(directory):
		if name.begins_with("save_") and name.ends_with(".json"): out.append(name)
	out.sort()
	out.reverse()
	return out

func read_state(data: Dictionary, directory: String = DIRECTORY) -> Dictionary:
	message = ""
	var files = generations(directory)
	for i in range(files.size()):
		var f = FileAccess.open(directory.path_join(files[i]),FileAccess.READ)
		if f==null or f.get_length()>LIMIT: continue
		var state = decode(f.get_as_text(),data)
		if not state.is_empty():
			if i>0: message = "Progress recovered from a backup."
			return state
	if not files.is_empty(): message = "Save could not be read. Original files are preserved. Import a backup to recover."
	return {}

func write_state(s: Dictionary, data: Dictionary, directory: String = DIRECTORY) -> bool:
	if not valid(s,data):
		message = "Progress was not saved: invalid state."
		return false
	DirAccess.make_dir_recursive_absolute(directory)
	var copy = s.duplicate(true)
	var largest = int(s.revision)
	for file in generations(directory): largest = maxi(largest,int(file.trim_prefix("save_").trim_suffix(".json")))
	copy.revision = largest+1
	var filename = "save_%016d.json" % int(copy.revision)
	var dest = directory.path_join(filename)
	var temp = dest+".tmp"
	var f = FileAccess.open(temp,FileAccess.WRITE)
	if f==null:
		message = "Save failed. Check the available storage on your device."
		return false
	f.store_string(encode(copy))
	f.flush()
	f.close()
	if decode(FileAccess.get_file_as_string(temp),data).is_empty(): return false
	if DirAccess.rename_absolute(temp,dest)!=OK: return false
	s.revision = copy.revision
	var files = generations(directory)
	for i in range(3,files.size()): DirAccess.remove_absolute(directory.path_join(files[i]))
	message = ""
	return true

func resume(model: RealmModel, now: int) -> Dictionary:
	var away = maxi(0,now-int(model.s.wall)) if model.s.wall>0 else 0
	var elapsed = mini(away,RealmModel.MAX_OFFLINE)
	var before = model.s.duplicate(true)
	model.advance(elapsed)
	return resume_report(model,before,now,away,elapsed)

func resume_async(model: RealmModel, now: int, tree: SceneTree, progress: Callable, cancelled: Callable = Callable()) -> Dictionary:
	var away = maxi(0,now-int(model.s.wall)) if model.s.wall>0 else 0
	var elapsed = mini(away,RealmModel.MAX_OFFLINE)
	var before = model.s.duplicate(true)
	var working = RealmModel.new()
	working.s = before.duplicate(true)
	var remaining = elapsed
	while remaining>0:
		if cancelled.is_valid() and cancelled.call(): return {}
		remaining -= working.advance(remaining,4000)
		progress.call(1.0-float(remaining)/maxi(1,elapsed))
		await tree.process_frame
	if cancelled.is_valid() and cancelled.call(): return {}
	model.s = working.s
	model.combat_events.clear()
	model.last_reward = working.last_reward
	return resume_report(model,before,now,away,elapsed)

func resume_report(model: RealmModel, before: Dictionary, now: int, away: int, elapsed: int) -> Dictionary:
	model.s.wall = now
	var report = {"away":away,"capped":away>RealmModel.MAX_OFFLINE,"levels":{},"queued_before":before.queue.size(),"elapsed":elapsed,"gold":int(model.s.gold)-int(before.gold),"gains":{},"spent":{},"xp":0,"kills":0}
	for id in model.s.gains:
		var amount = int(model.s.gains[id])-int(before.gains.get(id,0))
		if amount>0: report.gains[id] = amount
	for id in model.s.spent:
		var amount = int(model.s.spent[id])-int(before.spent.get(id,0))
		if amount>0: report.spent[id] = amount
	for skill in model.s.xp:
		report.xp += int(model.s.xp[skill])-int(before.xp[skill])
		var old_level = mini(100,1+int(sqrt(float(before.xp[skill])/25.0)))
		if model.level(skill)>old_level: report.levels[skill] = {"before":old_level,"after":model.level(skill)}
	for enemy in model.s.kills: report.kills += int(model.s.kills[enemy])-int(before.kills.get(enemy,0))
	report.fragments = {}
	report.talent_points = RealmChronicle.points_earned(model)-mini(10,int((before.xp.bladecraft+before.xp.might+before.xp.warding)/250))
	var previous_fragments = before.get("chronicle",{}).get("fragments",{})
	for id in RealmChronicle.RELICS:
		var amount = int(RealmChronicle.state(model).fragments[id])-int(previous_fragments.get(id,0))
		if amount>0: report.fragments[id] = amount
	if elapsed>30000: model.s.report = report
	return report
