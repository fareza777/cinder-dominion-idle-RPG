extends "res://tests/capture30.gd"
func snap(name: String):
	await create_timer(.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://build/"+name.replace("0.30","0.47")+".png")
