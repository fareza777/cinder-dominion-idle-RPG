extends "res://tests/capture31.gd"
const U = preload("res://ui/style.gd")
func words(node):
 var out=str(node.text) if node is Label or node is Button else ""
 for child in node.get_children():out+=" "+words(child)
 return out
func capture():
 root.size=Vector2i(412,892)
 var scene=PreviewApp.new();root.add_child(scene);scene.set_process(false)
 scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 scene.model.s.experience.coach_active=false
 scene.mode="play"
 for enemy in ["ash_rat","hollow_hound"]:
  scene.model.gain("card_"+enemy,1)
  var icon=U.icon("card_"+enemy,100)
  var battle=U.enemy_texture(scene.model.data.enemies[enemy])
  assert(icon.texture.atlas==battle.atlas and icon.texture.region==battle.region)
  icon.free()
  preload("res://ui/cards.gd").new(scene).detail("card_"+enemy)
  await snap("card-"+enemy+"-0.49")
 preload("res://ui/masterworks.gd").new(scene).open()
 for id in RealmLegacyFinds.GEAR:assert(not words(scene.dialog).contains(scene.model.name_of(id)))
 await snap("hidden-masterworks-0.49")
 var id=RealmLegacyFinds.GEAR[0]
 scene.model.gain(RealmBlueprints.item(id),1)
 preload("res://ui/masterworks.gd").new(scene).open()
 assert(words(scene.dialog).contains(scene.model.name_of(id)))
 assert(not words(scene.dialog).contains(scene.model.name_of(RealmLegacyFinds.GEAR[1])))
 await snap("discovered-masterwork-0.49")
 scene.dismiss()
 scene.skill="smithing"
 scene.show_locked_recipes=true
 scene.set_page("skills")
 assert(not words(scene).contains(scene.model.name_of(RealmLegacyFinds.GEAR[1])))
 for key in scene.model.data.items:
  if scene.model.data.items[key].category!="equipment" and not str(key).begins_with("blueprint_"):scene.model.gain(key,1)
 scene.set_page("inventory")
 var next=button_text(scene,"Next supplies")
 assert(next!=null and not next.disabled)
 next.pressed.emit()
 assert(scene.supply_page==1)
 await snap("supplies-page2-0.49")
 root.size=Vector2i(360,800)
 U.scale=1.3
 scene.refresh_shell();scene.set_page("inventory")
 await process_frame
 scene.scroller.ensure_control_visible(button_text(scene,"Next supplies"))
 await snap("supplies-large-0.49")
 print("PASS: card/battle art identity; hidden and discovered masterwork UI at 412x892")
 quit()

