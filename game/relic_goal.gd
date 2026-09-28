class_name RealmRelicGoal
extends RefCounted

static func plan(rank: int, owned: int, fragments: int) -> Dictionary:
	if rank>=40: return {"state":"maximum","missing":0,"wins":0,"batch":0}
	var missing = maxi(0,RealmChronicle.relic_cost(rank)-owned)
	var wins = ceili(float(missing)/maxi(1,fragments))
	return {"state":"ready" if missing==0 else "farm","missing":missing,"wins":wins,"batch":mini(100,wins)}
