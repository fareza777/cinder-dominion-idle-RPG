extends Control

const U = preload("res://ui/style.gd")
var model
var elapsed = 0.0
var flash = 0.0
var serial = -1
var event_text = ""
var event_side = "enemy"
var background: Texture2D
var faces: Array[Texture2D] = []

func _ready():
	custom_minimum_size.y = 280
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	var backdrop = AtlasTexture.new()
	backdrop.atlas = load("res://assets/art/cinematic.png")
	backdrop.region = Rect2(0,0,1536,341)
	background = backdrop
	for index in range(8):
		var face = AtlasTexture.new()
		face.atlas = U.portraits
		face.region = Rect2((index%4)*U.portraits.get_width()/4.0,int(index/4)*U.portraits.get_height()/2.0,U.portraits.get_width()/4.0,U.portraits.get_height()/2.0)
		face.filter_clip = true
		faces.append(face)
	serial = int(model.battle_event.serial)

func _process(delta: float):
	if model==null: return
	elapsed += delta
	flash = maxf(0,flash-delta)
	if serial!=int(model.battle_event.serial):
		serial = int(model.battle_event.serial)
		flash = .85
		event_text = model.battle_event.text
		event_side = model.battle_event.side
	queue_redraw()

func bar(rect: Rect2, fraction: float, color: Color):
	draw_rect(rect,Color("30383b"))
	draw_rect(Rect2(rect.position,Vector2(rect.size.x*clampf(fraction,0,1),rect.size.y)),color)

func caption(at: Vector2, value: String, color: Color, font_size: int = 13, width: float = -1):
	draw_string(U.body_font,at,value,HORIZONTAL_ALIGNMENT_CENTER,width,font_size,color)

func _draw():
	if model==null or faces.is_empty(): return
	var fighting = not model.s.fight.is_empty()
	var f = model.s.fight
	var enemy = model.data.enemies[f.enemy] if fighting else {}
	var backdrop_width = size.y*background.get_width()/background.get_height()
	draw_texture_rect(background,Rect2((size.x-backdrop_width)/2,0,backdrop_width,size.y),false,Color(.65,.65,.65))
	draw_rect(Rect2(Vector2.ZERO,size),Color(.025,.04,.055,.48))
	var w = minf(126,(size.x-64)/2)
	var left = Rect2(16,45,w,152)
	var right = Rect2(size.x-16-w,45,w,152)
	for side in range(2):
		var r = left if side==0 else right
		var target = "hero" if side==0 else "enemy"
		var hit = flash>.55 and target==event_side
		if hit and model.s.settings.motion: r.position.x += sin(elapsed*75)*3
		draw_rect(r.grow(2),U.RED if hit else U.GOLD.darkened(.55))
		if side==0 or fighting:
			draw_texture_rect(faces[0 if side==0 else int(enemy.portrait)],r,false,Color(1,.72,.68) if hit else Color.WHITE)
		else:
			draw_rect(r,U.INK)
			caption(r.position+Vector2(0,80),"Awaiting hunt",U.MUTED,12,w)
		var health = float(model.s.hp)/100 if side==0 else (float(f.hp)/enemy.hp if fighting else 0.0)
		bar(Rect2(r.position.x,207,w,6),health,U.GREEN if side==0 else U.RED)
		var hp = "%d / 100 HP" % int(model.s.hp) if side==0 else ("%d / %d HP" % [maxi(0,int(f.hp)),int(enemy.hp)] if fighting else "Choose a target below")
		caption(Vector2(r.position.x,231),hp,U.TEXT,11,w)
		if fighting:
			var remaining = int(f.player_at if side==0 else f.enemy_at)-int(model.s.time)
			var interval = 2000 if side==0 else int(enemy.interval)
			bar(Rect2(r.position.x,241,w,3),1.0-float(remaining)/interval,U.GOLD)
	caption(Vector2(16,29),"EMBERKEEPER",U.GOLD,11,w)
	caption(Vector2(right.position.x,29),model.local_name(enemy).to_upper() if fighting else "THE OUTSKIRTS",U.GOLD,10,w)
	caption(Vector2(size.x/2-20,127),"VS",U.GOLD,22,40)
	if fighting:
		var charges = int(f.get("swings",0))%4
		caption(Vector2(0,268),"STYLE SKILL  %d / 4    ·    NEXT ATTACK %.1fs" % [charges,maxf(0,(int(f.player_at)-int(model.s.time))/1000.0)],U.GOLD,10,size.x)
	else: caption(Vector2(0,268),"PREPARE  ·  HUNT  ·  BRING HOPE HOME",U.GOLD,10,size.x)
	if flash>0 and event_text!="":
		var x = left.position.x if event_side=="hero" else right.position.x
		var y = 100-(.85-flash)*24 if model.s.settings.motion else 92.0
		draw_rect(Rect2(x,y-20,w,27),Color(0,0,0,.8))
		caption(Vector2(x,y),event_text,U.RED if event_side=="hero" else U.GOLD,16,w)
