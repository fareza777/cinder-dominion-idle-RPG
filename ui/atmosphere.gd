extends Control

var clock = 0.0
var motion = true
var amount = 22

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta):
	if motion:
		clock += delta
		queue_redraw()

func _draw():
	if not motion: return
	for i in range(amount):
		var x = fmod(i*79.13+sin(clock*.3+i)*12,size.x)
		var y = size.y-fmod(clock*(9+i%7)+i*27.31,size.y)
		var alpha = .1+.25*maxf(0,sin(clock*.4+i))
		draw_circle(Vector2(x,y),1.0+i%2*.6,Color(.93,.64,.3,alpha))
