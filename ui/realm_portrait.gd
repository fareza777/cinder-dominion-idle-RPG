extends TextureRect

var enemy_id=""
func _ready():
	resized.connect(queue_redraw)
	queue_redraw()
func _draw():
	if enemy_id=="":return
	var actor=load("res://ui/enemy_actor.gd")
	actor.draw(self,enemy_id,0,Rect2(Vector2.ZERO,size))
