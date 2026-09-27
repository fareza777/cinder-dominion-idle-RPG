extends "res://tests/capture35.gd"

func capture():
	root.size = Vector2i(480,960)
	var scene = PreviewApp.new()
	root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.set_process(false)
	scene.mode = "play"
	scene.model.gain("copper_sword",1,2)
	scene.model.gain("cooked_meat",5)
	for dimensions in [Vector2i(480,960),Vector2i(360,800)]:
		root.size = dimensions
		scene.U.scale = 1.3 if dimensions.x==360 else 1.0
		scene.build_shell()
		for page in ["village","explore","skills","inventory","character"]:
			scene.toast_label.hide()
			scene.set_page(page)
			await snap("premium-"+page+"-"+str(dimensions.x)+"-0.36")
			check_width(scene,scene.size.x)
			if page=="explore":
				button_text(scene,"Prepare for a hunt").pressed.emit()
				await snap("premium-preparation-"+str(dimensions.x)+"-0.36")
				check_width(scene.dialog,scene.size.x)
				button_text(scene.dialog,"Fighting style").pressed.emit()
				assert(scene.dialog!=null)
				scene.dismiss()
				button_text(scene,"More hunts").pressed.emit()
				assert(button_text(scene.dialog,"Hunt mastery")!=null)
				scene.dismiss()
			if page=="inventory":
				button_text(scene,"Inspect").pressed.emit()
				await snap("premium-item-"+str(dimensions.x)+"-0.36")
				check_width(scene.dialog,scene.size.x)
				scene.dismiss()
				scene.pages.supply_details("cooked_meat")
				button_text(scene.dialog,"Use for auto-heal").pressed.emit()
				assert(scene.model.s.settings.food=="cooked_meat")
				var before = scene.model.count("cooked_meat")
				button_text(scene.dialog,"Sell 1").pressed.emit()
				assert(scene.model.count("cooked_meat")==before-1)
				await snap("premium-supply-"+str(dimensions.x)+"-0.36")
				check_width(scene.dialog,scene.size.x)
				scene.dismiss()
			scene.toast_label.hide()
			scene.scroller.scroll_vertical = 10000
			await snap("premium-"+page+"-bottom-"+str(dimensions.x)+"-0.36")
			check_width(scene,scene.size.x)
		scene.skill = "mining"
		scene.set_page("skills")
		await snap("premium-recipes-"+str(dimensions.x)+"-0.36")
		check_width(scene,scene.size.x)
		scene.skill = ""
		scene.model.command({"type":"queue","id":"hunt_ash_rat","target":3})
		scene.set_page("explore")
		await snap("premium-battle-"+str(dimensions.x)+"-0.36")
		check_width(scene,scene.size.x)
		scene.model.command({"type":"clear"})
		scene.settings_dialog()
		await snap("premium-settings-"+str(dimensions.x)+"-0.36")
		check_width(scene.dialog,scene.size.x)
		scene.dismiss()
		scene.experience.menu()
		await snap("premium-menu-"+str(dimensions.x)+"-0.36")
		check_width(scene.experience.front,scene.size.x)
		scene.experience.clear()
		scene.mode = "play"
	print("PREMIUM 36 PASS: five pages, two phone sizes, large text, item inspection, food selection, sale and battle")
	scene.queue_free()
	await process_frame
	quit()
