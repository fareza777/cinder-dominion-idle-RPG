extends RefCounted
const U = preload("res://ui/style.gd")
var app
var m
func _init(owner): app = owner; m = owner.model

func panel(parent, compact: bool = false):
	if compact:
		var button = U.button("Stamina & rest",open)
		parent.add_child(button)
		var update = func():
			if is_instance_valid(button): button.text = "Stamina %d / %d · %s" % [RealmStamina.state(m).value,RealmStamina.cap(m),"Resume" if RealmStamina.state(m).paused else "Rest & help"]
		app.update_callbacks.append(update)
		update.call()
		return
	var box = U.card(parent,12)
	app.dynamic(box,func(): return RealmStamina.summary(m),15,U.GOLD)
	var b = U.button("Resume hunting",func():
		app.send({"type":"stamina_resume"})
		app.refresh())
	box.add_child(b)
	app.update_callbacks.append(func():
		if is_instance_valid(b): b.visible = RealmStamina.state(m).paused)
	b.visible = RealmStamina.state(m).paused
	box.add_child(U.button("Rest & hunting guide",open))

func open():
	var v = app.modal("Stamina & rest")
	app.dynamic(v,func(): return RealmStamina.summary(m),20,U.GOLD)
	app.dynamic(v,func():
		var st = RealmStamina.state(m)
		var minutes = ceili(maxi(0,(RealmStamina.cap(m)-int(st.value))*RealmStamina.REGEN-int(st.rest))/60000.0)
		return "%dh %dm to full while resting" % [int(minutes/60),minutes%60],14)
	v.add_child(U.para("Capacity grows by 2 each Bladecraft level. Recover 1 stamina every 3 minutes outside combat, including while gathering, crafting or offline.",15))
	v.add_child(U.para("A hunt reserves enough for at most 10 minutes. You pay the entry cost plus time fought; unused stamina returns after victory, defeat or retreat. Stronger enemies cost more.",15))
	v.add_child(U.para("Low stamina pauses your hunting queue. Recovery does not resume it automatically unless already-earned rewarded assistance is still active. Tutorial hunts are free.",15))
	v.add_child(U.button("Resume hunting",func(): app.send({"type":"stamina_resume"}); open()))
	v.add_child(U.button("Clear queue & prepare supplies",func():
		app.send({"type":"clear"})
		app.dismiss()
		app.set_page("skills")))
	v.add_child(U.button("Cards & combat guide",func(): preload("res://ui/cards.gd").new(app).help()))
