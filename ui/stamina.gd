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
			if is_instance_valid(button):
				var action = "Rest & help"
				if RealmStamina.state(m).paused and RealmStamina.next_enemy(m)!="": action = "Resume" if RealmStamina.resume_reason(m)=="" else "Resting"
				button.text = "Stamina %d / %d · %s" % [RealmStamina.state(m).value,RealmStamina.cap(m),action]
		app.update_callbacks.append(update)
		update.call()
		return
	var box = U.card(parent,12)
	app.dynamic(box,func(): return RealmStamina.summary(m),15,U.GOLD)
	app.dynamic(box,func(): return RealmStamina.readiness(m),14)
	resume_button(box)
	box.add_child(U.button("Rest & hunting guide",open))

func resume_button(parent):
	var b = U.button("Resume hunting",func():
		if app.send({"type":"stamina_resume"}): app.dismiss(),true)
	b.name = "ResumeHunting"
	parent.add_child(b)
	var update = func():
		if not is_instance_valid(b): return
		b.visible = RealmStamina.state(m).paused and RealmStamina.next_enemy(m)!="" and m.s.fight.is_empty()
		b.disabled = RealmStamina.resume_reason(m)!=""
		b.text = "Resting · not ready yet" if b.disabled else "Resume hunting"
	app.dialog_callbacks.append(update)
	update.call()

func open():
	var v = app.modal("Stamina & rest")
	app.dynamic(v,func(): return RealmStamina.summary(m),20,U.GOLD)
	var box = U.card(v,12)
	box.add_child(U.para("Your next hunt",18,U.GOLD))
	app.dynamic(box,func(): return RealmStamina.readiness(m),16)
	resume_button(box)
	app.dynamic(v,func():
		if not m.s.fight.is_empty(): return "Recovery paused during combat"
		var remaining = RealmStamina.wait_ms(m,RealmStamina.cap(m))
		return "Fully rested" if remaining==0 else "Full recovery in "+RealmStamina.duration_text(remaining),14)
	v.add_child(U.para("Recover 1 stamina every 3 minutes outside combat, including offline. You only need enough for your next hunt, not a full bar.",15))
	v.add_child(U.button("How stamina works",guide))
	v.add_child(U.button("Browse hunts",func(): app.dismiss(); app.set_page("explore")))
	v.add_child(U.button("Clear queue & prepare supplies",func():
		app.send({"type":"clear"})
		app.dismiss()
		app.set_page("skills")))
	v.add_child(U.button("Cards & combat guide",func(): preload("res://ui/cards.gd").new(app).help()))

func guide():
	var v = app.modal("How stamina works")
	for line in ["Capacity grows by 2 each Bladecraft level. Recover 1 stamina every 3 minutes outside combat, including while gathering, crafting or offline.","A hunt reserves enough for at most 10 minutes. You pay the entry cost plus time fought; unused stamina returns after victory, defeat or retreat. Stronger enemies cost more.","Low stamina pauses your hunting queue. Recovery does not resume it automatically unless already-earned rewarded assistance is still active. Tutorial hunts are free."]:
		v.add_child(U.para(line,16))
	v.add_child(U.button("Back to rest",open))
