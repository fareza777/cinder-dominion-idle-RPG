extends "res://tests/capture.gd"
func find_stage(node: Node):
 if node.get_script()==preload("res://ui/battle_stage.gd"):return node
 for child in node.get_children():
  var found=find_stage(child)
  if found!=null:return found
 return null
func capture():
 root.size=Vector2i(412,892)
 var app=PreviewApp.new();root.add_child(app)
 app.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);app.set_process(false);app.mode="play"
 app.model.s=preload("res://tests/overhaul51.gd").prepared().s
 var m=app.model;m.s.experience.coach_active=false
 for width in [412,360]:
  root.size=Vector2i(width,892 if width==412 else 800)
  app.U.scale=1.0 if width==412 else 1.3
  app.refresh_shell()
  for id in ["grave_thrall","secret_4","march_guard_0"]:
   m.command({"type":"clear"})
   assert(m.command({"type":"queue","id":"hunt_"+id,"target":10}))
   app.set_page("explore");app.toast_label.hide()
   await process_frame
   var stage=find_stage(app)
   assert(stage!=null)
   stage.set_process(false)
   stage.attacks.enemy=0;stage.impacts.hero=0;stage.queue_redraw()
   await snap("battle-ground-%s-%d-0.51.1" % [id,width])
   stage.attacks.enemy=.28;stage.impacts.hero=.3;stage.queue_redraw()
   await snap("battle-attack-%s-%d-0.51.1" % [id,width])
 print("BATTLE PHONE: complete heads and shared ground in ready/attack samples at 412px and 360px/130% text.")
 quit()
