extends "res://tests/capture31.gd"
func capture():
	var scene=PreviewApp.new();root.add_child(scene);scene.set_process(false)
	scene.model.s=preload("res://tests/balance43.gd").build("warden",true).s.duplicate(true)
	scene.model.s.experience.coach_active=false
	for round in range(3):
		for page in ["village","inventory","character","skills","explore"]:
			var start=Time.get_ticks_usec()
			scene.set_page(page)
			var built=Time.get_ticks_usec()
			await process_frame;await RenderingServer.frame_post_draw
			print("TAB ",round," ",page," build_ms=",(built-start)/1000.0," ready_ms=",(Time.get_ticks_usec()-start)/1000.0)
	quit()
