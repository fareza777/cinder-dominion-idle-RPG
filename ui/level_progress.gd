extends RefCounted

const U = preload("res://ui/style.gd")

static func show_progress(app, parent, skill: String):
	var m = app.model
	var level = m.level(skill)
	var card = U.card(parent,14,U.GOLD.darkened(.5))
	if level>=100:
		card.add_child(U.para("Maximum level reached",20,U.GOLD))
		card.add_child(U.para("Every recipe for this skill is available. Keep gathering or crafting the supplies your next upgrade needs.",14))
		return
	app.dynamic(card,func(): return "%d XP to level %d" % [maxi(0,25*m.level(skill)*m.level(skill)-int(m.s.xp[skill])),mini(100,m.level(skill)+1)],18,U.GOLD)
	var bar = U.progress(0,1,U.GOLD,7)
	card.add_child(bar)
	app.update_callbacks.append(func():
		if is_instance_valid(bar):
			var current = m.level(skill)
			bar.value = 1.0 if current>=100 else float(m.s.xp[skill]-25*(current-1)*(current-1))/maxf(1,25*current*current-25*(current-1)*(current-1)))
	var next_level = 101
	for activity in m.data.activities.values():
		if activity.kind!="combat" and activity.skill==skill and int(activity.level)>level: next_level = mini(next_level,int(activity.level))
	if next_level<=100:
		var names = RealmStory.unlocks(m,skill,level,next_level)
		card.add_child(U.para("Next unlock · level %d\n%s" % [next_level,", ".join(names)],14,U.TEXT))
		card.add_child(U.button("Plan training toward level %d" % next_level,func(): preload("res://ui/gameplay.gd").new(app).training(skill,next_level)))
		card.add_child(U.para("Training plans use an available recipe or resource. Large targets are split into batches of up to 100 cycles; repeat a batch if more XP is needed.",12))
	else: card.add_child(U.para("All recipes for this skill are unlocked. Continue training or gather materials for your equipment and supplies.",14))
