extends "res://tests/capture52.gd"
func label_with(node: Node,phrase: String):
 if node is Label and phrase in node.text:return node
 for child in node.get_children():
  var found=label_with(child,phrase)
  if found!=null:return found
 return null
func photo(name: String):
 await create_timer(.3).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://build/audit54/"+name+".png")
func capture():
 DirAccess.make_dir_recursive_absolute("res://build/audit54")
 root.size=Vector2i(412,892)
 var app=PreviewApp.new();root.add_child(app);app.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 app.mode="play";app.model.s=preload("res://tests/progression54.gd").prepared().s
 app.model.s.experience.coach_active=false;app.seen_levels.clear()
 app.set_page("village");await press(app,"Dungeon journeys");await press(app,"Prepare journey")
 await photo("journey-prepare");await press(app,"Depart")
 assert(RealmVoyages.busy(app.model))
 await create_timer(.4).timeout
 var timer=label_with(app.dialog,"remaining")
 assert(timer!=null)
 var before=timer.text;var start=int(app.model.s.time)
 await create_timer(2.2).timeout
 timer=label_with(app.dialog,"remaining")
 assert(timer!=null and timer.text!=before)
 print("LIVE JOURNEY elapsed=",int(app.model.s.time)-start," before=",before," after=",timer.text)
 await photo("journey-running")
 app.set_process(false)
 app.model.advance(int(app.model.s.voyages.active.next)-int(app.model.s.time));app.refresh()
 await create_timer(.3).timeout
 assert(label_with(app.dialog,"Supplies secured")!=null)
 print("LIVE STAGE: modal refreshed at chamber boundary")
 app.model.advance(int(app.model.s.voyages.active.due)-int(app.model.s.time));app.refresh()
 await create_timer(.3).timeout
 assert(find_button(app.dialog,"Collect all rewards")!=null)
 await photo("journey-rewards");await press(app,"Collect all rewards")
 assert(app.model.s.voyages.ready.is_empty());print("LIVE COMPLETION: collect button appeared and claimed cargo")
 app.dismiss();app.set_page("explore");preload("res://ui/hunt_build.gd").new(app).open("realm_0_3")
 await photo("hunt-build");await press(app,"Review cards & compatible slots")
 assert(label_with(app.dialog,"discovered")!=null)
 app.dismiss();var uid=str(app.model.s.equipped.weapon);app.model.s.gear_attunements={uid:"burn"};app.model.gear(uid).q=15
 preload("res://ui/fusion.gd").new(app).open(uid);await press(app,"Weapon awakenings")
 await photo("weapon-awakenings");await press(app,"Choose weapon attunement")
 assert(find_button(app.dialog,"Apply attunement")!=null)
 app.dismiss();app.model.command({"type":"end_contract","id":"frontline"})
 preload("res://ui/endgame.gd").new(app).contracts();await photo("commissions")
 app.dismiss();preload("res://ui/cards.gd").new(app).detail("card_realm_4_9");await photo("sovereign-card")
 app.dismiss();app.model.s.kills.erase("realm_6_9");app.experience.guide();await photo("late-objective")
 app.dismiss();root.size=Vector2i(360,800);app.model.s.settings.font=1.3;preload("res://ui/style.gd").scale=1.3;app.build_shell();app.set_page("explore")
 preload("res://ui/hunt_build.gd").new(app).open("realm_0_3");await photo("large-hunt-build")
 app.dismiss();preload("res://ui/voyages.gd").new(app).prepare("journey_0");await photo("large-journey-prepare")
 await press(app,"Depart");await photo("large-journey-running")
 print("UI54 pointer navigation, second countdown, completion and phone captures passed")
 quit()
