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

	var initial = queue_signature()
	var dialog_ref = weakref(app.dialog)
	var pending = {"refresh":false}
	app.dialog_callbacks.append(func():
		if dialog_ref.get_ref()==app.dialog and not pending.refresh and queue_signature()!=initial:
			pending.refresh = true
			call_deferred("refresh_if_current",dialog_ref))
	var blocked = m.s.active.is_empty() and m.s.fight.is_empty()
	if blocked:
		var warning = U.card(v,14,U.RED.darkened(.4))
		warning.add_child(U.para("This queue is waiting",20,U.GOLD))
		app.dynamic(warning,func(): return (m.requirement(m.s.queue[0].id) if not m.s.queue.is_empty() else "Choose your next task."),15,U.TEXT)
		var activity = m.data.activities[m.s.queue[0].id]
		if activity.kind!="combat" and not activity.inputs.is_empty(): warning.add_child(U.button("Prepare missing materials",prepare,true))
		if activity.kind!="combat" and m.level(activity.skill)<int(activity.level): warning.add_child(U.para("Train %s to level %d first. Cancel this task or complete another training plan before queuing it again." % [m.local_name(m.data.skills[activity.skill]),int(activity.level)],13))
		elif activity.kind=="combat": warning.add_child(U.button("Review unlocks and preparation",app.progress_dialog))
	for i in range(m.s.queue.size()):
		var step = m.s.queue[i]
		var activity = m.data.activities[step.id]
		var card = U.card(v,12,U.GOLD.darkened(.5) if i==0 else U.LINE)
		var heading = U.row(10)
		card.add_child(heading)
		if activity.kind=="combat": heading.add_child(U.enemy_portrait(m.data.enemies[activity.enemy],Vector2(48,60)))
		else: heading.add_child(U.icon(activity.output,48))
		var name_label = U.para("%02d · %s" % [i+1,m.activity_name(step.id)],18,U.TEXT)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		heading.add_child(name_label)
		card.add_child(U.para(("Waiting for requirements" if blocked else "Running") if i==0 else "Queued",12,U.GOLD if i==0 else U.MUTED))
		var value = m.level(activity.skill) if step.kind=="level" else int(step.output if step.kind=="output" else step.done)
		var unit = "skill level" if step.kind=="level" else ("items produced" if step.kind=="output" else ("fights completed" if activity.kind=="combat" else "cycles completed"))
		app.dynamic(card,func(): return "%d / %d %s" % [m.level(activity.skill) if step.kind=="level" else int(step.output if step.kind=="output" else step.done),int(step.target),unit],13)
		var bar = U.progress(value,int(step.target),U.GOLD,5)
		card.add_child(bar)
		app.dialog_callbacks.append(func():
			if is_instance_valid(bar): bar.value = m.level(activity.skill) if step.kind=="level" else int(step.output if step.kind=="output" else step.done))
		var row = U.row(8)
		card.add_child(row)
		if i>1: row.add_child(U.button("Move up",func():
			if i<m.s.queue.size() and m.s.queue[i]==step: app.send({"type":"up","index":i})
			open()))
		row.add_child(U.button("Cancel task",func():
			if i<m.s.queue.size() and m.s.queue[i]==step: app.send({"type":"cancel","index":i})
			open()))
	U.disclosure(v,"Cancelling tasks").add_child(U.para("Unused crafting ingredients are returned. Cancelling a hunt ends combat. Earned rewards are kept.",14))
	app.modal_action("Stop all tasks",func():
		if app.send({"type":"clear"}): open(),false)

func queue_signature() -> String:
	var order = []
	for step in m.s.queue: order.append([step.id,step.target])
	return JSON.stringify(order)+str(m.s.active.is_empty() and m.s.fight.is_empty())

func refresh_if_current(reference):
	if reference.get_ref()!=null and reference.get_ref()==app.dialog: open()

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
