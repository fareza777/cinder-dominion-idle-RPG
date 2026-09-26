class_name RealmEquipmentPreview
extends RefCounted

static func compare(m, uid: String) -> Dictionary:
	var item = m.gear(uid)
	if item.is_empty(): return {}
	var slot = str(m.data.items[item.id].slot)
	var baseline = RealmModel.new()
	baseline.s = m.s.duplicate(true)
	var proposed = RealmModel.new()
	proposed.s = m.s.duplicate(true)
	proposed.s.equipped[slot] = uid
	var result = {"before":baseline.stats(),"after":proposed.stats(),"equipped":m.s.equipped.get(slot,"")==uid,"current":m.gear(str(m.s.equipped.get(slot,""))).duplicate(true)}
	result.sets_before = RealmGearSets.summary(baseline)
	result.sets_after = RealmGearSets.summary(proposed)
	var activity = {"axe":"cut_ash","pick":"mine_copper","rod":"fish_minnow"}.get(slot,"")
	if activity!="" and m.data.activities.has(activity):
		result.activity = activity
		result.seconds_before = baseline.duration(m.data.activities[activity])/1000.0
		result.seconds_after = proposed.duration(m.data.activities[activity])/1000.0
	return result
