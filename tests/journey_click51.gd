extends "res://tests/capture24.gd"

func find_button(node: Node, phrase: String):
 if node is Button and phrase in node.text:return node
 for child in node.get_children():
  var found=find_button(child,phrase)
  if found!=null:return found
 return null

func capture():
 root.size=Vector2i(412,892)
 var app=PreviewApp.new();root.add_child(app)
 app.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);app.set_process(false);app.mode="play"
 app.model.s.experience.coach_active=false
 app.set_page("village")
 await process_frame
 var button=find_button(app,"Dungeon journeys")
 assert(button!=null)
 var connections=button.get_signal_connection_list("pressed")
 print("JOURNEY CALLBACK VALID: ",not connections.is_empty() and connections[0].callable.is_valid())
 var parent=button.get_parent()
 while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
 if parent!=null:parent.ensure_control_visible(button)
 await process_frame
 await click_at(button.get_global_rect().get_center())
 await create_timer(.3).timeout
 print("JOURNEY CLICK OPENED: ",is_instance_valid(app.dialog))
 if not is_instance_valid(app.dialog):quit(1);return
 await snap("journey-click-0.51.1")
 app.dismiss()
 app.model.s=preload("res://tests/overhaul51.gd").prepared().s
 app.model.s.experience.coach_active=false
 app.set_page("village")
 await process_frame
 button=find_button(app,"Dungeon journeys")
 parent=button.get_parent()
 while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
 if parent!=null:parent.ensure_control_visible(button)
 await process_frame
 await click_at(button.get_global_rect().get_center())
 await process_frame
 button=find_button(app.dialog,"Prepare journey")
 assert(button!=null)
 parent=button.get_parent()
 while parent!=null and not parent is ScrollContainer:parent=parent.get_parent()
 parent.ensure_control_visible(button)
 await process_frame
 await click_at(button.get_global_rect().get_center())
 await process_frame
 button=find_button(app.dialog,"Depart")
 assert(button!=null and not button.disabled)
 await click_at(button.get_global_rect().get_center())
 await process_frame
 assert(RealmVoyages.busy(app.model))
 app.dismiss();app.queue_dialog()
 await process_frame
 assert(find_button(app.dialog,"Recall journey")!=null)
 await snap("journey-departed-0.51.1")
 print("JOURNEY POINTER FLOW: locked entry, unlocked entry, prepare, depart and queue review passed.")
 quit()
