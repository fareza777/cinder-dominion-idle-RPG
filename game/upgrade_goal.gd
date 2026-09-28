class_name RealmUpgradeGoal
extends RefCounted

static func current(m) -> String:
	var id = str(m.s.get("upgrade_goal",""))
	return id if RealmBlueprints.learned(m,id) else ""

static func status(m) -> Dictionary:
	var id = current(m)
	if id=="": return {}
	var item = m.data.items[id]
	var best = {}
	for g in m.s.gear:
		if g.id==id and (best.is_empty() or m.gear_score(g)>m.gear_score(best)): best = g
	var position = str(item.slot)
	if position=="ring":
		position = "ring_left"
		for hand in ["ring_left","ring_right"]:
			if m.gear(str(m.s.equipped.get(hand,""))).get("id","")==id: position = hand
	var equipped = m.gear(str(m.s.equipped.get(position,"")))
	if not equipped.is_empty() and (equipped.id==id or m.gear_score(equipped)>=m.gear_score({"id":id,"q":1})):
		return {"kind":"ready","text":"Target equipped · review your next hunt" if equipped.id==id else "Stronger equipment already equipped · review your next hunt","action":"Review hunts"}
	if not best.is_empty(): return {"kind":"equip","text":"Crafted · review your new equipment","action":"Review & equip","uid":best.uid}
	if not m.s.queue.is_empty(): return {"kind":"queue","text":"Work in progress · check your queue","action":"View current work"}
	var recipe = m.data.activities["craft_"+id]
	if m.level(recipe.skill)<recipe.level:
		return {"kind":"train","text":"Requires Smithing Lv.%d · currently %d" % [recipe.level,m.level(recipe.skill)],"action":"Train Smithing","skill":recipe.skill,"level":recipe.level}
	var plan = RealmProgression.plan(m,recipe.id,1)
	if plan.has("unlock_skill"):
		return {"kind":"train","text":plan.error,"action":"Train "+m.local_name(m.data.skills[plan.unlock_skill]),"skill":plan.unlock_skill,"level":plan.unlock_level}
	if plan.has("missing_item") and not m.sources(plan.missing_item).is_empty():return {"kind":"farm","text":"Gather %d %s for this upgrade" % [plan.missing_amount,m.name_of(plan.missing_item)],"action":"Find missing materials","material":plan.missing_item}
	return {"kind":"craft","text":"Gather missing materials, then forge one piece","action":"Plan materials & craft"}
