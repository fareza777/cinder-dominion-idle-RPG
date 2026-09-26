extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func show_preview(parent, uid: String, target: String, changed: Callable):
	var enemies = []
	for id in m.data.enemies:
		if m.available(id)=="": enemies.append(id)
	if enemies.is_empty(): return
	if target not in enemies:
		var objective = m.objective()
		var activity = m.data.activities.get(objective.activity,{})
		target = str(activity.get("enemy",enemies[0]))
		if target not in enemies: target = enemies[0]
	var comparison = RealmWorkshop.preview(m,uid,target)
	if comparison.is_empty(): return
	var card = U.card(parent,14)
	card.add_child(U.para("Effect on your build",22,U.TEXT))
	card.add_child(U.para("Current build → refined piece equipped. No materials are spent by this preview.",13))
	if not comparison.equipped: card.add_child(U.para("This item is in your bag. The preview assumes you equip it after refinement. Refining an unequipped item does not equip it automatically.",13,U.GOLD))
	card.add_child(U.para("Attack   %.1f → %.1f\nArmor   %.1f → %.1f" % [comparison.before.attack,comparison.after.attack,comparison.before.armor,comparison.after.armor],17,U.TEXT))
	card.add_child(U.para("Compare against",12,U.GOLD))
	var picker = OptionButton.new()
	picker.custom_minimum_size = Vector2(0,48)
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker.fit_to_longest_item = false
	for id in enemies: picker.add_item(m.local_name(m.data.enemies[id]))
	picker.select(enemies.find(target))
	card.add_child(picker)
	picker.item_selected.connect(func(index): changed.call(enemies[index]))
	var before = comparison.hunt_before
	var after = comparison.hunt_after
	card.add_child(U.para("%s → %s" % [before.rating,after.rating],15,U.GOLD))
	if before.stalled or after.stalled:
		card.add_child(U.para("Before: "+("enemy recovery exceeds your damage" if before.stalled else "damage can overcome enemy recovery")+".\nAfter: "+("enemy recovery still exceeds your damage" if after.stalled else "damage can overcome enemy recovery")+".",14))
	else:
		card.add_child(U.para("Estimated fight   %ds → %ds\nMeals per fight   %d → %d" % [int(before.seconds),int(after.seconds),int(before.meals),int(after.meals)],15,U.TEXT))
	card.add_child(U.para("Strongest enemy hit   %d → %d damage" % [int(before.burst),int(after.burst)],14))
	card.add_child(U.para("Estimates use your current health, style, talents, relic, rune and food. Misses and critical hits vary. Small stat gains may not change rounded combat values yet.",12))
	if not m.s.fight.is_empty(): card.add_child(U.para("Finish or leave the current battle before refining. Temporary combat buffs can affect this preview.",12,U.GOLD))
