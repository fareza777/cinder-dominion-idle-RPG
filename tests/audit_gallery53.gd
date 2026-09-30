extends SceneTree
func _init():call_deferred("capture")
func capture():
	root.size=Vector2i(1236,1784);root.content_scale_size=root.size
	var board=GridContainer.new();board.columns=3;board.add_theme_constant_override("h_separation",0);board.add_theme_constant_override("v_separation",0);root.add_child(board)
	var files=Array(DirAccess.get_files_at("res://build/audit53")).filter(func(f):return f.ends_with("-after.png"));files.sort()
	for start in range(0,files.size(),6):
		for child in board.get_children():child.free()
		for file in files.slice(start,start+6):
			var t=TextureRect.new();t.custom_minimum_size=Vector2(412,892);t.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;t.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;t.texture=ImageTexture.create_from_image(Image.load_from_file("res://build/audit53/"+file));board.add_child(t)
		await process_frame;await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://build/audit53/gallery-%d.png" % int(start/6))
		print(int(start/6)," ",files.slice(start,start+6))
	quit()
