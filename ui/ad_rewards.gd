extends RefCounted
const U=preload("res://ui/style.gd")
var app
func _init(owner):app=owner;app.ensure_ads()
func reward_button(parent,placement: String):
 var button=U.button("Prepare test ad",func():app.ads.request("rewarded",placement),true)
 parent.add_child(button)
 var ref=weakref(button)
 app.dynamic(parent,func():return app.ads.reward_reason(placement),13,U.GOLD)
 app.dialog_callbacks.append(func():
  if ref.get_ref()==null:return
  var why=app.ads.reward_reason(placement)
  var label="4 hours of queue assistance" if placement=="automation" else "%d %s" % [app.ads.config.reward_meals,app.model.name_of(app.model.s.settings.food)]
  ref.get_ref().text=("Watch ad · " if app.ads.cache_ready("rewarded") else "Prepare ad · ")+label
  ref.get_ref().disabled=why!="" or app.ads.full_screen)
func open():
 var v=app.modal("Optional supplies & assistance")
 v.add_child(U.para("Google test ads",13,U.GOLD))
 v.add_child(U.para("Choose a reward, then watch an ad. Closing early or an unavailable ad grants nothing. Manual play remains available.",14))
 for placement in ["meals","automation"]:
  var c=U.card(v,12)
  c.add_child(U.para("Trail provisions" if placement=="meals" else "Queue assistance",21,U.GOLD))
  c.add_child(U.para("Receive 15 of your selected cooked food." if placement=="meals" else "Unlock four hours of assistance. Uses your own materials and normal crafting time. Enable it after claiming.",14))
  app.dynamic(c,func():return "%d / %d available today" % [app.ads.policy.remaining(placement,app.ads.now()),app.ads.config.reward_daily_caps[placement]],13)
  reward_button(c,placement)
 app.dynamic(v,func():return app.ads.status,14)
 v.add_child(U.button("Set up queue assistance",func():preload("res://ui/endgame.gd").new(app).assistance()))
 app.modal_action("Keep playing",func():app.dismiss(),false)
