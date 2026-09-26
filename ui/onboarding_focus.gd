extends Control

const U = preload("res://ui/style.gd")
const TIPS = {
	"ore":"Mine 4 ore for your sword. Tap Goals to find the task.",
	"ingots":"Turn your ore into 2 ingots. Tap Goals to open Smithing.",
	"wood":"Gather 1 log for the sword's grip. Tap Goals.",
	"sword":"Your materials are ready. Tap Goals to forge your sword.",
	"equip":"Your sword is in the Bag. Tap Goals to open it.",
	"rats":"You're ready to fight. Tap Goals to prepare your first hunt."
}
var app
var card: PanelContainer
var heading: Label
var instruction: Label
var leave: Button
var focus_rect = Rect2()
var phase = 0.0
var state = ""
var text_scale = -1.0
var shields: Array[Control] = []

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 30
	for i in range(4):
		var shield = Control.new()
		shield.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(shield)
		shields.append(shield)
	card = PanelContainer.new()
	card.add_theme_stylebox_override("panel",U.box(U.INK,U.GOLD,12,16))
	add_child(card)
	var words = U.column(8)
	card.add_child(words)
	heading = U.para("",18,U.GOLD)
	words.add_child(heading)
	instruction = U.para("",15,U.TEXT)
	words.add_child(instruction)
	leave = U.button("Skip guidance",finish)
	words.add_child(leave)
	hide()

func finish():
	app.model.s.experience.coach_active = false
	app.persist()
	hide()

func target_in(node: Node,key: String) -> Control:
	if node is Control and node.is_visible_in_tree() and node.get_meta("coach_target","")==key:
		return node
	for child in node.get_children():
		if child==self: continue
		var found = target_in(child,key)
		if found!=null: return found
	return null

func _process(delta):
	if app==null: return
	if app.mode!="play" or app.paused or not app.model.s.experience.get("coach_active",false):
		hide()
		return
	var o = app.model.objective()
	var key = "goals"
	var text = TIPS.get(o.key,"")
	var scope: Node = app
	var done = int(o.index)>6
	if is_instance_valid(app.dialog):
		scope = app.dialog
		if app.dialog.get_meta("coach_equip",false) and o.key!="equip":
			app.call_deferred("dismiss")
			hide()
			return
		if done:
			hide()
			return
		if app.dialog.get_meta("journey_guide",false):
			key = "goal_action"
			text = "Tap the highlighted button to open this task."
		elif app.dialog.get_meta("coach_activity","")==o.activity and o.activity!="":
			key = "begin"
			text = "Tap Begin. The task repeats automatically until this target is reached."
			if o.key=="rats": text = "Tap Begin. Attacks are automatic; your starting food heals you when needed."
			if not app.model.s.queue.is_empty():
				key = "manage_queue"
				text = "A task is already queued. Review it before starting another order."
			elif app.model.requirement(o.activity)!="":
				key = "materials"
				text = "You need more materials. Tap here to plan gathering and crafting together."
		elif app.dialog.get_meta("coach_plan","")==o.activity and o.activity!="":
			key = "plan"
			text = "Tap Gather & craft. Materials are gathered first, then your item is made automatically."
		elif app.dialog.get_meta("coach_equip",false):
			key = "equip"
			text = "Tap Equip item to use your new sword in battle."
		else:
			hide()
			return
	elif not app.model.s.queue.is_empty() and not done:
		key = "running"
		if app.model.s.queue[0].id==o.activity:
			text = "Working automatically · %d / %d. Wait for the target, then follow the next highlight." % [mini(int(o.current),int(o.goal)),int(o.goal)]
		elif app.model.s.queue.any(func(step): return step.id==o.activity):
			text = "Earlier tasks run first. This goal is already queued and will start automatically."
		else: text = "Another task is running. Tap Queue to manage it; your next goal is saved above."
		if app.model.s.active.is_empty() and app.model.s.fight.is_empty() and app.model.requirement(app.model.s.queue[0].id)!="": text = "Task waiting: "+app.model.requirement(app.model.s.queue[0].id)+". Tap Queue to manage it."
	var target = target_in(scope,key)
	if target==null and not done:
		hide()
		return
	if target is Button and target.disabled:
		hide()
		return
	show()
	if text_scale!=U.scale:
		text_scale = U.scale
		heading.add_theme_font_size_override("font_size",int(18*U.scale))
		instruction.add_theme_font_size_override("font_size",int(15*U.scale))
		leave.add_theme_font_size_override("font_size",int(14*U.scale))
	heading.text = "First hunt complete" if done else "STEP %d / 6 · %s" % [int(o.index),o.title]
	instruction.text = "Keep growing: gather materials, improve your gear, then challenge the next enemy. Goals shows your next target." if done else text
	leave.text = "Continue exploring" if done else "Skip guidance"
	var next_state = o.key+":"+key
	if state!="" and next_state!=state and o.key!=state.get_slice(":",0): app.play_cue("guide")
	state = next_state
	focus_rect = Rect2() if done else target.get_global_rect().grow(5)
	card.size.x = maxf(240,size.x-32)
	card.size.y = card.get_combined_minimum_size().y
	var y = size.y*.36 if done else (focus_rect.end.y+20 if focus_rect.get_center().y<size.y*.45 else focus_rect.position.y-card.size.y-20)
	card.position = Vector2(16,clampf(y,20,maxf(20,size.y-card.size.y-20)))
	var r = focus_rect.intersection(Rect2(Vector2.ZERO,size))
	var regions = [Rect2(0,0,size.x,r.position.y),Rect2(0,r.end.y,size.x,maxf(0,size.y-r.end.y)),Rect2(0,r.position.y,r.position.x,r.size.y),Rect2(r.end.x,r.position.y,maxf(0,size.x-r.end.x),r.size.y)]
	if done: regions = [Rect2(Vector2.ZERO,size),Rect2(),Rect2(),Rect2()]
	for i in range(4):
		shields[i].position = regions[i].position
		shields[i].size = regions[i].size
	phase += delta
	queue_redraw()

func _draw():
	var shade = Color(.015,.022,.03,.70)
	if focus_rect.size==Vector2.ZERO:
		draw_rect(Rect2(Vector2.ZERO,size),shade)
		return
	var r = focus_rect.intersection(Rect2(Vector2.ZERO,size))
	draw_rect(Rect2(0,0,size.x,r.position.y),shade)
	draw_rect(Rect2(0,r.end.y,size.x,maxf(0,size.y-r.end.y)),shade)
	draw_rect(Rect2(0,r.position.y,r.position.x,r.size.y),shade)
	draw_rect(Rect2(r.end.x,r.position.y,maxf(0,size.x-r.end.x),r.size.y),shade)
	var alpha = .85+.15*sin(phase*3) if app.model.s.settings.motion else 1.0
	draw_rect(r,Color(U.GOLD,alpha),false,3)
	var start = Vector2(clampf(r.get_center().x,card.position.x+20,card.position.x+card.size.x-20),card.position.y if card.position.y>r.end.y else card.position.y+card.size.y)
	var end = Vector2(start.x,r.end.y+4 if card.position.y>r.end.y else r.position.y-4)
	draw_line(start,end,U.GOLD,2,true)
	var direction = 1 if end.y>start.y else -1
	draw_line(end,end+Vector2(-5,-6*direction),U.GOLD,2,true)
	draw_line(end,end+Vector2(5,-6*direction),U.GOLD,2,true)
