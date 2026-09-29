extends "res://tests/capture.gd"

func has_text(node: Node, phrase: String) -> bool:
 if node is Label and phrase in node.text:return true
 for child in node.get_children():
  if has_text(child,phrase):return true
 return false

func capture():
 root.size=Vector2i(412,892)
 var app=PreviewApp.new();root.add_child(app)
 app.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);app.set_process(false);app.mode="play"
 app.model.s=preload("res://tests/overhaul51.gd").prepared().s
 var m=app.model
 m.s.experience.coach_active=false
 for id in ["ash_rat","hollow_hound","march_guard_0","march_guard_4"]:
  if not m.data.enemies.has(id):continue
  m.command({"type":"clear"});m.command({"type":"queue","id":"hunt_"+id,"target":10})
  app.set_page("explore");app.toast_label.hide()
  await snap("actor-"+id+"-0.51")
  m.combat_event("CRIT 124","enemy","hit","warden")
  await create_timer(.12).timeout
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://docs/qa/screenshots/actor-hit-"+id+"-0.51.png")
 m.combat_event("MISS","hero")
 await create_timer(.12).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/qa/screenshots/actor-miss-0.51.png")
 for hero in RealmCharacters.ALL:
  m.s.hero["class"]=hero
  app.set_page("explore")
  await process_frame
  m.combat_event("+24 HP" if hero=="apothecary" else "124","hero" if hero=="apothecary" else "enemy","hit",hero)
  await create_timer(.16).timeout
  await RenderingServer.frame_post_draw
  if hero in ["frostbound","penitent","duskblade"]:root.get_texture().get_image().save_png("res://docs/qa/screenshots/skill-"+hero+"-0.51.png")
 m.command({"type":"clear"});app.set_page("skills")
 preload("res://ui/artisan.gd").new(app).open()
 await snap("artisan-0.51")
 preload("res://ui/artisan.gd").new(app).upgrade(m.s.equipped.pick)
 await snap("tool-upgrade-0.51")
 app.dismiss()
 var travels=preload("res://ui/voyages.gd").new(app)
 travels.prepare("journey_0")
 await snap("journey-prepare-0.51")
 app.dismiss();assert(m.command({"type":"voyage_start","id":"journey_0"}))
 app.set_page("explore");travels.open()
 m.advance(900000);app.refresh()
 await process_frame
 await process_frame
 assert(has_text(app.dialog,"✓ Find the entrance"))
 await snap("journey-underway-0.51")
 root.size=Vector2i(360,800);app.U.scale=1.3;app.refresh_shell()
 travels.open();await snap("journey-narrow-0.51")
 m.advance(2700000);app.refresh()
 await snap("journey-rewards-0.51")
 assert(not RealmVoyages.busy(m) and m.s.voyages.ready.complete)
 app.dismiss();assert(m.command({"type":"voyage_claim"}))
 preload("res://ui/artisan.gd").new(app).open()
 await snap("artisan-narrow-0.51")
 print("CAPTURE51 completed: battle actors/hits, artisan/tools, journey departure/stages/reward and 360px large-text layouts.")
 quit()

