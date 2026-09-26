class_name RealmDiscovery
extends RefCounted
static func visible(m, id: String) -> bool:
	return int(m.s.kills.get(id,0))>0 or m.available(id)==""
static func enemies(m) -> Array:
	return m.data.enemies.keys().filter(func(id): return visible(m,id))
