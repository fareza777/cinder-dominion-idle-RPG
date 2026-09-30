extends RefCounted
const U=preload("res://ui/style.gd")
var app
var m
func _init(owner):app=owner;m=app.model

func open(id: String):
 var enemy=m.data.enemies[id];var v=app.modal("Prepare your build")
 v.add_child(U.para(m.local_name(enemy),24,U.GOLD))
 v.add_child(U.para("1. Counter the threat",18))
 v.add_child(U.para(RealmCombat.mechanic(enemy),14))
 var uid=str(m.s.equipped.get("weapon",""))
 if uid!="":v.add_child(U.button("Choose weapon effects",func():preload("res://ui/marches.gd").new(app).attune(uid)))
 v.add_child(U.button("Review cards & compatible slots",func():preload("res://ui/cards.gd").new(app).collection()))
 v.add_child(U.para("2. Choose an upgrade",18))
 var choices=[]
 for a in m.data.activities.values():
  if a.kind!="craft" or m.level(a.skill)<a.level or RealmBlueprints.reason(m,a)!="":continue
  if a.has("artisan_source") and m.s.kills.get(a.artisan_source,0)<1:continue
  var item=m.data.items[a.output]
  if item.get("slot","") not in ["weapon","body","shield"]:continue
  var equipped=m.gear(str(m.s.equipped.get(item.slot,"")))
  var gain=m.gear_score({"id":a.output,"q":1})-(m.gear_score(equipped) if not equipped.is_empty() else 0)
  if gain>0:choices.append({"id":a.output,"gain":gain})
 choices.sort_custom(func(a,b):return a.gain>b.gain)
 for choice in choices.slice(0,2):
  v.add_child(U.button("Track "+m.name_of(choice.id),func():
   if app.send({"type":"upgrade_goal","id":choice.id}):preload("res://ui/upgrade_goal.gd").new(app).open()))
 if choices.is_empty():v.add_child(U.para("No stronger basic recipe is ready. Improve your current piece, attunement or card combination.",14))
 v.add_child(U.button("Fuse equipment & view awakenings",func():preload("res://ui/fusion.gd").new(app).hub()))
 v.add_child(U.para("3. Prepare supplies, then try one fight",18))
 v.add_child(U.button("Cook 15 × "+m.name_of(m.s.settings.food),func():app.planner_dialog("craft_"+str(m.s.settings.food),15)))
 v.add_child(U.button("Adjust food threshold & tactics",func():app.tactics_dialog()))
 app.modal_action("Review one fight",func():app.activity_dialog("hunt_"+id,1))
