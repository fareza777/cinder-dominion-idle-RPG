extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
func _init(owner):
	app = owner
	m = app.model
func home(parent):
	var goal = m.s.get("training_goal",{})
	if goal.is_empty(): return
	var c = U.card(parent,12)
	app.dynamic(c,func(): return "%s · Lv.%d / %d" % [m.local_name(m.data.skills[goal.skill]),m.level(goal.skill),goal.target],18,U.GOLD)
	c.add_child(U.button("Review training goal",func(): open(goal.skill,goal.target,goal.minutes)))

func open(skill: String, target: int, minutes: int = 60):
	var v = app.modal("Training plan")
	v.add_child(U.para("%s · Lv.%d → %d" % [m.local_name(m.data.skills[skill]),m.level(skill),target],23,U.TEXT))
	var levels = [target]
	for level in [25,50,75,100]:
		if level>m.level(skill) and level not in levels: levels.append(level)
	levels.sort()
	var picker = OptionButton.new()
	picker.custom_minimum_size.y = 48
	for level in levels: picker.add_item("Target · Level %d" % level)
	picker.selected = levels.find(target)
	picker.item_selected.connect(func(index): open(skill,levels[index],minutes))
	v.add_child(picker)
	var row = U.row(6)
	v.add_child(row)
	for n in RealmTraining.MINUTES:
		var b = U.button({15:"15 min",60:"1 hour",240:"4 hours"}[n],func(): open(skill,target,n),minutes==n)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(b)
	var plan = RealmTraining.plan(m,skill,target,minutes)
	if plan.error!="":
		v.add_child(U.para(plan.error,16,U.GOLD))
		if not m.s.queue.is_empty(): app.modal_action("View current work",app.queue_dialog)
		else: app.modal_action("Review skills",func():
			app.dismiss()
			app.skill = skill
			app.set_page("skills"))
	else:
		var card = U.card(v,14)
		card.add_child(U.para(m.activity_name(plan.activity),21,U.GOLD))
		card.add_child(U.para("%d cycles · %s\n+%d %s XP · projected Lv.%d" % [plan.cycles,preload("res://ui/gameplay.gd").new(app).time_label(plan.seconds),plan.xp,m.local_name(m.data.skills[skill]),plan.level_after],16,U.TEXT))
		v.add_child(U.para("Includes missing materials. One recipe runs toward your target within this time limit, up to 1,000 cycles. Review your goal afterward to use newly unlocked recipes.",14))
		if plan.level_after<target: v.add_child(U.para("This batch does not finish Lv.%d. Your goal stays saved for the next visit." % target,14,U.GOLD))
		for step in plan.steps: v.add_child(U.para("%s ×%d" % [m.activity_name(step.id),step.target],14))
		v.add_child(U.para("Times use current bonuses. Mastery can shorten the work; no coins is spent.",12))
		app.modal_action("Start training batch",func():
			if app.send({"type":"training","id":skill,"target":target,"minutes":minutes}):
				app.dismiss()
				app.toast("Training queued. Review your saved goal after this batch."))
	if not m.s.get("training_goal",{}).is_empty():
		v.add_child(U.button("Stop tracking · keep queued work",func():
			app.send({"type":"training_clear"})
			app.dismiss()))
