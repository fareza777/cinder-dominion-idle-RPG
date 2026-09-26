extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func open(report: Dictionary):
	var v = app.modal("Welcome back")
	var clock = preload("res://ui/gameplay.gd").new(app)
	v.add_child(U.para("Your time away",26,U.TEXT))
	v.add_child(U.para(clock.time_label(float(report.get("away",report.elapsed))/1000.0),30,U.GOLD))
	v.add_child(U.para("Progress calculated for "+clock.time_label(float(report.elapsed)/1000.0)+". Tasks only produce rewards while they can run.",14))
	if report.get("capped",false): v.add_child(U.para("Offline progress is limited to 24 hours per return. Time beyond that limit did not advance your tasks.",14,U.GOLD))
	var status = U.card(v,14)
	var blocked = not m.s.queue.is_empty() and m.s.active.is_empty() and m.s.fight.is_empty()
	if blocked:
		status.add_child(U.para("Your queue needs attention",21,U.GOLD))
		status.add_child(U.para(m.requirement(m.s.queue[0].id),15))
		status.add_child(U.para("Review the queue to prepare missing materials or change the blocked task.",13))
	elif not m.s.queue.is_empty():
		status.add_child(U.para("Your task is still running",21,U.GREEN))
		status.add_child(U.para(m.activity_name(m.s.queue[0].id)+" · %d tasks remaining" % m.s.queue.size(),14))
	else:
		status.add_child(U.para("No tasks remaining",21,U.TEXT))
		status.add_child(U.para("Choose your next task to keep progressing. Completed or stopped hunts can be reviewed in Hunt reports." if int(report.get("queued_before",0))>0 else "An empty queue earns no gathering or combat rewards. Leave a task running before your next break.",14))
	var rewards = U.card(v,14)
	rewards.add_child(U.para("Results",20,U.TEXT))
	rewards.add_child(U.para("%+d gold · %d XP · %d victories" % [int(report.gold),int(report.xp),int(report.kills)],16,U.GREEN))
	for id in report.gains:
		rewards.add_child(U.para("+%d %s" % [int(report.gains[id]),m.name_of(id)],14))
	for id in report.get("fragments",{}):
		rewards.add_child(U.para("+%d %s fragments" % [int(report.fragments[id]),RealmChronicle.RELICS[id].name],14,U.GOLD))
	for id in report.get("levels",{}):
		var levels = report.levels[id]
		var level_card = U.card(v,12)
		level_card.add_child(U.para("%s · level %d → %d" % [m.local_name(m.data.skills[id]),int(levels.before),int(levels.after)],19,U.GOLD))
		var unlocked = RealmStory.unlocks(m,id,int(levels.before),int(levels.after))
		if not unlocked.is_empty(): level_card.add_child(U.para("Unlocked: "+", ".join(unlocked),14))
	if int(report.get("talent_points",0))>0:
		v.add_child(U.para("%d new talent points earned" % int(report.talent_points),16,U.GOLD))
		v.add_child(U.button("Review talents",app.talents_dialog))
	if RealmRuneforge.ready(m)>0: v.add_child(U.button("Collect available field record rewards",app.journal_dialog))
	if not report.spent.is_empty():
		var used = U.card(v,12)
		used.add_child(U.para("Materials and supplies used",17,U.TEXT))
		for id in report.spent: used.add_child(U.para("%s ×%d" % [m.name_of(id),int(report.spent[id])],13))
	if not RealmHunts.state(m).history.is_empty(): v.add_child(U.button("Review hunt results",app.hunt_reports_dialog))
	v.add_child(U.para("Results are already saved. Nothing needs to be claimed here.",12))
	var focus = RealmChronicle.focus(m)
	v.add_child(U.para("Next: "+focus.title,18,U.TEXT))
	app.modal_action("Review queue" if not m.s.queue.is_empty() else "Continue to my next step",func():
		m.s.report = {}
		app.persist()
		if not m.s.experience.welcome_done:
			app.experience.welcome()
		elif not m.s.queue.is_empty(): app.queue_dialog()
		else: preload("res://ui/chronicle.gd").new(app).act())
