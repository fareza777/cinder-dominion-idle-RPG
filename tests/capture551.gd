extends "res://tests/capture52.gd"
func capture():
 root.size=Vector2i(360,800)
 var app=PreviewApp.new();root.add_child(app)
 app.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);app.set_process(false);app.mode="play"
 app.model.s.experience.coach_active=false
 app.set_page("village")
 app.banner_space.show();app.banner_space.custom_minimum_size.y=preload("res://services/admob.gd").banner_reservation(90,60,1,0)
 var preview=VBoxContainer.new();app.add_child(preview)
 preview.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);preview.offset_top=-150
 var banner=PanelContainer.new();banner.custom_minimum_size.y=90;preview.add_child(banner)
 banner.add_child(app.U.para("Banner placement preview",17))
 var nav=PanelContainer.new();nav.custom_minimum_size.y=60;preview.add_child(nav)
 nav.add_child(app.U.para("Android navigation area · preview",15))
 await snap("banner-safe-preview-0.55.1")
 var hero=app.find_child("character",true,false)
 assert(hero!=null and hero.get_global_rect().end.y<=preview.get_global_rect().position.y)
 await click_at(hero.get_global_rect().get_center());assert(app.page=="character")
 app.model.s.settings.font=1.3;app.U.scale=1.3;app.set_page("character")
 await snap("banner-safe-hero-preview-0.55.1")
 print("BANNER PHONE: reserved area clears navigation; Hero pointer works; large-text preview. Native Android not rendered.")
 quit()
