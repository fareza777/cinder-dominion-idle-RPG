extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
func _init(owner):
	app = owner
	m = app.model

func home(parent):
	var id = RealmUpgradeGoal.current(m)
	if id=="": return
	var card = U.card(parent,12)
	card.add_child(U.para("TRACKED UPGRADE",11,U.GOLD))
	card.add_child(U.para(m.name_of(id),20,U.TEXT))
	app.dynamic(card,func(): return RealmUpgradeGoal.status(m).get("text",""),14)
	card.add_child(U.button("View upgrade target",open,true))

func open():
	var id = RealmUpgradeGoal.current(m)
	if id=="": return
	var v = app.modal("Your next upgrade")
	v.add_child(U.icon(id,76))
	v.add_child(U.para(m.name_of(id),24,U.TEXT))
	app.dynamic(v,func(): return RealmUpgradeGoal.status(m).get("text",""),16)
	var recipe = m.data.activities["craft_"+id]
	var ingredients = U.column(10)
	v.add_child(ingredients)
	for material in recipe.inputs:
		app.dynamic(ingredients,func(): return "%s · %d / %d" % [m.name_of(material),m.count(material),recipe.inputs[material]],15)
	ingredients.add_child(U.para("The crafting plan includes missing ingredients. Equipment must be equipped after crafting.",13))
	var update_ingredients = func():
		if is_instance_valid(ingredients): ingredients.visible = RealmUpgradeGoal.status(m).get("kind","") not in ["ready","equip"]
	app.dialog_callbacks.append(update_ingredients)
	update_ingredients.call()
	v.add_child(U.button("Stop tracking",func():
		app.send({"type":"upgrade_goal","id":""})
		app.dismiss()))
	var action = app.modal_action("Continue",follow)
	var update = func():
		if is_instance_valid(action): action.text = RealmUpgradeGoal.status(m).get("action","Continue")
	app.dialog_callbacks.append(update)
	update.call()

func follow():
	var step = RealmUpgradeGoal.status(m)
	match step.get("kind",""):
		"ready":
			app.dismiss()
			app.set_page("explore")
		"equip": app.item_dialog(step.uid)
		"queue": app.queue_dialog()
		"train": preload("res://ui/gameplay.gd").new(app).training(step.skill,step.level)
		"craft": app.planner_dialog("craft_"+RealmUpgradeGoal.current(m),1)
