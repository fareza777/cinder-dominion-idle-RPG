class_name RealmWorld
extends RefCounted

const PROFESSIONS = ["herbalism","hunting","thieving","crafting","arcane_arts","divinity","runecarving"]
static var regions: Array = []
static func data() -> Array:
	if regions.is_empty(): regions=JSON.parse_string(FileAccess.get_file_as_string("res://data/realms.json"))
	return regions

static func migrate(s: Dictionary):
	if s.has("world_revision"): return
	for skill in PROFESSIONS:
		if not s.xp.has(skill): s.xp[skill]=0
	s.world_revision=1

static func available(m,id: String) -> String:
	var e=m.data.enemies[id]
	if m.level("bladecraft")<100+int(e.realm)*5:return "Reach Bladecraft Lv.%d to enter this realm." % (100+int(e.realm)*5)
	return "" if m.s.kills.get(e.unlock,0)>0 else "Defeat "+m.local_name(m.data.enemies[e.unlock])+" to open this route."

static func location(e: Dictionary) -> String:
	if e.has("realm"):return "realm_"+str(int(e.realm))
	if e.has("march"):return "march_"+str(int(e.march))
	if e.has("frontier"):return "frontier_"+str(int(e.frontier))
	if e.get("secret",false):return "guardians"
	if e.get("depth",false):return "depths"
	if e.get("trial",false):return "trials"
	return e.get("region","outskirts")

static func locations() -> Array:
	var out=[{"id":"outskirts","name":"Cinderwatch Outskirts"}]
	for id in RealmChronicle.REGIONS:out.append({"id":id,"name":RealmChronicle.REGIONS[id].name})
	for i in range(RealmFrontiers.REGIONS.size()):out.append({"id":"frontier_"+str(i),"name":RealmFrontiers.REGIONS[i]})
	for i in range(6):out.append({"id":"march_"+str(i),"name":RealmMarches.data().regions[i].name})
	for r in data():out.append(r)
	out.append_array([{"id":"guardians","name":"Hidden Sanctuaries"},{"id":"trials","name":"Guardian Trials"},{"id":"depths","name":"Hollow Depths"}])
	return out

static func encounters(m,place: String) -> Array:
	return m.data.enemies.keys().filter(func(id):return location(m.data.enemies[id])==place)

static func victory(m,e: Dictionary):
	if not e.has("realm") or not e.boss or m.s.kills.get(e.id,0)>0:return
	var r=int(e.realm)
	m.gain("seal_"+str(mini(4,int(r/2))),5+r)
	m.note(data()[r].name+" secured. New equipment recipes are ready at the forge.")
