extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func open():
	var v = app.modal("Task queue")
	if m.s.queue.is_empty():
		v.add_child(U.para("Choose what to work on next.",25,U.TEXT))
		v.add_child(U.para("Queue gathering, crafting or a hunt. One task runs at a time, including up to 24 hours while you are away.",15))
		v.add_child(U.button("Plan food and materials",app.work_orders_dialog))
		app.modal_action("View my next objective",app.guide_dialog)
		return
	v.add_child(U.para("%d / 20 tasks queued" % m.s.queue.size(),22,U.TEXT))
	v.add_child(U.para("Only the first task can run. Tasks below it wait their turn. Use Refresh progress to update this view.",14))
	var blocked = m.s.active.is_empty() and m.s.fight.is_empty()
	if blocked:
		var warning = U.card(v,14,U.RED.darkened(.4))
		warning.add_child(U.para("This queue is waiting",20,U.GOLD))
		warning.add_child(U.para(m.requirement(m.s.queue[0].id),15,U.TEXT))
		var activity = m.data.activities[m.s.queue[0].id]
		if activity.kind!="combat" and not activity.inputs.is_empty(): warning.add_child(U.button("Prepare missing materials",prepare,true))
		if activity.kind!="combat" and m.level(activity.skill)<int(activity.level): warning.add_child(U.para("Train %s to level %d first. Cancel this task or complete another training plan before queuing it again." % [m.local_name(m.data.skills[activity.skill]),int(activity.level)],13))
		elif activity.kind=="combat": warning.add_child(U.button("Review unlocks and preparation",app.progress_dialog))
	for i in range(m.s.queue.size()):
		var step = m.s.queue[i]
		var activity = m.data.activities[step.id]
		var card = U.card(v,12,U.GOLD.darkened(.5) if i==0 else U.LINE)
		card.add_child(U.para("%02d · %s" % [i+1,m.activity_name(step.id)],19,U.TEXT))
		card.add_child(U.para(("Waiting for requirements" if blocked else "Running") if i==0 else "Queued",12,U.GOLD if i==0 else U.MUTED))
		var value = m.level(activity.skill) if step.kind=="level" else int(step.output if step.kind=="output" else step.done)
		var unit = "skill level" if step.kind=="level" else ("items produced" if step.kind=="output" else ("fights completed" if activity.kind=="combat" else "cycles completed"))
		card.add_child(U.para("%d / %d %s" % [value,int(step.target),unit],13))
		card.add_child(U.progress(value,int(step.target),U.GOLD,5))
		var row = U.row(8)
		card.add_child(row)
		if i>1: row.add_child(U.button("Move up",func():
			if i<m.s.queue.size() and m.s.queue[i]==step: app.send({"type":"up","index":i})
			open()))
		row.add_child(U.button("Cancel task",func():
			if i<m.s.queue.size() and m.s.queue[i]==step: app.send({"type":"cancel","index":i})
			open()))
	v.add_child(U.para("Cancelling an active crafting cycle returns its reserved ingredients. Cancelling combat stops that hunt. Rewards already earned are kept.",12))
	v.add_child(U.button("Refresh progress",open))
	app.modal_action("Stop all tasks",func():
		if app.send({"type":"clear"}): open(),false)

func prepare():
	var v = app.modal("Prepare missing materials")
	var original = m.s.queue[0] if not m.s.queue.is_empty() else {}
	var plan = RealmQueueRepair.plan(m)
	if plan.error!="":
		v.add_child(U.para(plan.error,17,U.GOLD))
		v.add_child(U.para("Your queue has not changed. Review the blocked task or make room for the preparation steps.",14))
		if plan.has("unlock_skill"): v.add_child(U.para("Required: %s level %d." % [m.local_name(m.data.skills[plan.unlock_skill]),int(plan.unlock_level)],14))
		app.modal_action("Back to queue",open)
		return
	v.add_child(U.para("Gather first. Resume crafting next.",24,U.TEXT))
	v.add_child(U.para("These steps will be inserted before your blocked task. Its completed progress and all waiting tasks stay in place.",15))
	v.add_child(U.para("Prepares materials for up to %d remaining cycles. Longer orders may need another batch later." % int(plan.cycles),13,U.GOLD))
	for step in plan.steps:
		var card = U.card(v,12)
		card.add_child(U.para("%s ×%d" % [m.activity_name(step.id),int(step.target)],18,U.TEXT))
	v.add_child(U.para("About %s of preparation. Materials already owned are used first." % preload("res://ui/gameplay.gd").new(app).time_label(plan.seconds),14))
	v.add_child(U.button("Back to queue",open))
	app.modal_action("Gather materials & resume",func():
		if not m.s.queue.is_empty() and m.s.queue[0]==original: app.send({"type":"repair_queue"})
		open())
