class_name RealmBuildCompare
extends RefCounted

static func preview(m, slot: String, enemy: String) -> Dictionary:
	var copy = RealmModel.new()
	copy.s = m.s.duplicate(true)
	# Comparison is between unbuffed builds outside an active fight.
	copy.s.fight = {}
	if slot!="":
		var error = RealmLoadouts.command(copy,{"type":"loadout_load","id":slot})
		if error!="": return {"error":error}
	return {"error":"","stats":copy.stats(),"sets":RealmGearSets.summary(copy),"forecast":RealmCombat.forecast(copy,enemy),"food":copy.s.settings.food,"stock":copy.count(copy.s.settings.food),"training":RealmDoctrines.active(copy).name}
