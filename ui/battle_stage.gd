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
var region_art: Dictionary = {}
var current_enemy = ""
var enemy_face: Texture2D
var enemy_background: Texture2D
var floating: Array = []
var impacts = {"hero":0.0,"enemy":0.0}
var recovery = {"hero":0.0,"enemy":0.0}
var attacks = {"hero":0.0,"enemy":0.0}
var dodges = {"hero":0.0,"enemy":0.0}
var awakening = 0.0
var arrival = 0.0
var draw_clock = 0.0
var cast_time = 0.0
var cast_name = ""
var poses: Array[Texture2D] = []
const FX = preload("res://ui/battle_fx.gd")
var class_effects: Array = []
var effects_enabled = true

func _ready():
	poses = preload("res://ui/hero_combat.gd").frames(RealmCharacters.id(model))
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
	if ResourceLoader.exists("res://assets/art/world-map.png"):
		var map = load("res://assets/art/world-map.png")
		var crops = {"wilds":Rect2(0,0,750,500),"marsh":Rect2(700,300,750,500),"crown":Rect2(900,0,636,420)}
		for region in crops:
			var art = AtlasTexture.new()
			art.atlas = map
			art.region = crops[region]
			art.filter_clip = true
			region_art[region] = art
	if ResourceLoader.exists("res://assets/art/battlefields.png"):
		var arenas = load("res://assets/art/battlefields.png")
		for index in range(3):
			var art = AtlasTexture.new()
			art.atlas = arenas
			art.region = Rect2(0,index*arenas.get_height()/3.0,arenas.get_width(),arenas.get_height()/3.0)
			art.filter_clip = true
			region_art[["wilds","marsh","crown"][index]] = art
		background = region_art.wilds
	serial = int(model.battle_event.serial)

func _process(delta: float):
	if model==null: return
	if not is_visible_in_tree(): return
	for effect in class_effects: effect.life -= delta
	class_effects = class_effects.filter(func(effect): return effect.life>0)
	elapsed += delta
	cast_time = maxf(0,cast_time-delta)
	awakening = maxf(0,awakening-delta)
	arrival = maxf(0,arrival-delta)
	for side in impacts:
		impacts[side] = maxf(0,impacts[side]-delta)
		recovery[side] = maxf(0,recovery[side]-delta)
		attacks[side] = maxf(0,attacks[side]-delta)
		dodges[side] = maxf(0,dodges[side]-delta)
	flash = maxf(0,flash-delta)
	for item in floating: item.life -= delta
	floating = floating.filter(func(item): return item.life>0)
	var id = str(model.s.fight.get("enemy",""))
	if id!="" and id!=current_enemy:
		current_enemy = id
		arrival = .65
		enemy_face = U.enemy_texture(model.data.enemies[id])
		enemy_background = U.atlas_tile("res://assets/art/ascension-places-0.25.png",int(model.data.enemies[id].place_tile),2,2) if model.data.enemies[id].has("place_tile") else null
	if serial!=int(model.battle_event.serial):
		for event in model.combat_events:
			if int(event.serial)>serial and int(model.s.time)-int(event.get("time",0))<1000:
				var effect = FX.from_event(model,event)
				if not effect.is_empty():
					class_effects.append(effect)
					if class_effects.size()>6: class_effects.pop_front()
				if event.get("kind","")=="cast":
					cast_time = .9
					cast_name = str(event.text)
					continue
				if event.text=="PHASE II": awakening = 1.2
				elif str(event.text).begins_with("+"): recovery[event.side] = .8
				else:
					attacks["hero" if event.side=="enemy" else "enemy"] = .45
					if event.text=="MISS": dodges[event.side] = .45
					else: impacts[event.side] = .4
				floating.append({"text":event.text,"side":event.side,"life":1.0})
				if floating.size()>4: floating.pop_front()
		serial = int(model.battle_event.serial)
		flash = .85
		event_text = model.battle_event.text
		event_side = model.battle_event.side
	draw_clock += delta
	if draw_clock>= (1.0/30.0 if model.s.settings.battery else 1.0/60.0):
		draw_clock = 0
		queue_redraw()

func bar(rect: Rect2, fraction: float, color: Color):
	draw_rect(rect,Color("30383b"))
	draw_rect(Rect2(rect.position,Vector2(rect.size.x*clampf(fraction,0,1),rect.size.y)),color)

func caption(at: Vector2, value: String, color: Color, font_size: int = 13, width: float = -1):
	var points = mini(20,roundi(font_size*U.scale))
	if width>0:
		var short = value
		while short.length()>1 and U.body_font.get_string_size(short,HORIZONTAL_ALIGNMENT_LEFT,-1,points).x>width: short = short.left(short.length()-1)
		if short!=value: value = short.left(maxi(1,short.length()-1))+"…"
	draw_string(U.body_font,at,value,HORIZONTAL_ALIGNMENT_CENTER,width,points,color)

func draw_face(texture: Texture2D, rect: Rect2, tint: Color):
	var source = texture.get_size()
	var factor = maxf(rect.size.x/source.x,rect.size.y/source.y)
	var visible_size = rect.size/factor
	var offset = Vector2((source.x-visible_size.x)/2,(source.y-visible_size.y)*.2)
	draw_texture_rect_region(texture,rect,Rect2(offset,visible_size),tint)

func _draw():
	if model==null or faces.is_empty(): return
	var fighting = not model.s.fight.is_empty()
	var f = model.s.fight
	var enemy = RealmEndgame.enemy(model,model.data.enemies[f.enemy]) if fighting else {}
	var backdrop = enemy_background if enemy_background!=null else region_art.get(enemy.get("region",""),background)
	var backdrop_width = size.y*backdrop.get_width()/backdrop.get_height()
	var drift = sin(elapsed*.17)*4 if model.s.settings.motion else 0.0
	draw_texture_rect(backdrop,Rect2((size.x-backdrop_width)/2+drift-5,-3,backdrop_width+10,size.y+6),false,Color(.88,.88,.88))
	draw_rect(Rect2(Vector2.ZERO,size),Color(.025,.04,.055,.25))
	draw_rect(Rect2(0,0,size.x,38),Color(.015,.025,.035,.72))
	draw_rect(Rect2(0,202,size.x,78),Color(.015,.025,.035,.83))
	var w = minf(126,(size.x-64)/2)
	var left = Rect2(16,45,w,152)
	var right = Rect2(size.x-16-w,45,w,152)
	for side in range(2):
		var r = left if side==0 else right
		var target = "hero" if side==0 else "enemy"
		var hit = impacts[target]>.2
		var direction = 1 if side==0 else -1
		var swing = sin(clampf(attacks[target]/.45,0,1)*PI)
		var evade = sin(clampf(dodges[target]/.45,0,1)*PI)
		var windup = 0.0
		if fighting:
			var until = float(int(f.player_at if side==0 else f.enemy_at)-int(model.s.time))/1000.0
			windup = clampf(1.0-until/.5,0,1)
		if side==0 and model.s.settings.motion:
			r.position.y += sin(elapsed*1.4+side*2)*1.2-evade*3
			r.position.x += direction*(swing*15-windup*4-evade*11)
			if hit: r.position.x -= direction*sin(clampf(impacts[target]/.4,0,1)*PI)*6
			var center = r.get_center()
			draw_set_transform(center,direction*(swing*.035-evade*.045),Vector2(1,1+sin(elapsed*1.4+side*2)*.006))
			r.position -= center
		if side==0 or fighting:
			var pose_row = 0 if side==0 else -1
			if pose_row>=0:
				var frame = 3 if hit else ((2 if attacks[target]>.18 else 3) if attacks[target]>0 else (1 if windup>.4 else 0))
				if not model.s.settings.motion: frame = 0
				var pose_center = (left if side==0 else right).get_center()
				if model.s.settings.motion: pose_center.x += direction*(swing*15-windup*4-evade*11)
				draw_set_transform(pose_center,0,Vector2(1 if side==0 else -1,1))
				var area = Rect2(-85,-76,170,152)
				preload("res://ui/hero_combat.gd").draw(self,RealmCharacters.id(model),frame,area,Color(1,.72,.68) if hit else Color.WHITE)
				draw_set_transform(Vector2.ZERO)
			else:
				draw_rect(r.grow(2),U.GOLD.darkened(.45))
				var face = enemy_face if enemy_face!=null else faces[int(enemy.portrait)]
				draw_face(face,r,Color.WHITE)
		else:
			draw_rect(r,U.INK)
			caption(r.position+Vector2(0,80),"Awaiting hunt",U.MUTED,12,w)
		if model.s.settings.motion: draw_set_transform(Vector2.ZERO)
		r = left if side==0 else right
		if recovery[target]>0:
			var life = recovery[target]/.8
			if model.s.settings.motion and effects_enabled:
				for i in range(4):
					var point = r.get_center()+Vector2(-18+i*12,30-(1-life)*52+i%2*7)
					draw_circle(point,1.4,Color(U.GREEN,life*.6))
		var health = float(model.s.hp)/100 if side==0 else (float(f.hp)/enemy.hp if fighting else 0.0)
		bar(Rect2(r.position.x,207,w,6),health,U.GREEN if side==0 else U.RED)
		var hp = "%d / 100 HP" % int(model.s.hp) if side==0 else ("%d / %d HP" % [maxi(0,int(f.hp)),int(enemy.hp)] if fighting else "Choose a target below")
		caption(Vector2(r.position.x,231),hp,U.TEXT,11,w)
		if fighting:
			var remaining = int(f.player_at if side==0 else f.enemy_at)-int(model.s.time)
			var interval = 2000 if side==0 else int(enemy.interval)
			bar(Rect2(r.position.x,241,w,3),1.0-float(remaining)/interval,U.GOLD)
	caption(Vector2(16,29),RealmCharacters.hero_name(model).to_upper(),U.GOLD,11,w)
	caption(Vector2(right.position.x,29),model.local_name(enemy).split(" · ")[0].to_upper() if fighting else "THE OUTSKIRTS",U.GOLD,10,w)
	caption(Vector2(size.x/2-20,127),"II" if fighting and RealmTrials.active_phase(model,enemy) else "VS",U.RED if fighting and RealmTrials.active_phase(model,enemy) else U.GOLD,22,40)
	if awakening>0:
		var strength = awakening/1.2
		if model.s.settings.motion:
			for i in range(7):
				var point = right.get_center()+Vector2(-34+i*11,45-(1-strength)*100+i%2*8)
				draw_line(point,point+Vector2(2,-11),Color(U.RED,strength*.4),1.5,true)
		caption(Vector2(0,190),"THE GUARDIAN AWAKENS",U.GOLD,12,size.x)
	if model.s.settings.motion and effects_enabled:
		for i in range(8 if model.s.settings.battery else 14):
			var x = fmod(i*47.3+sin(elapsed*.4+i)*9,size.x)
			var y = 198-fmod(elapsed*(7+i%4)+i*19.7,155)
			draw_circle(Vector2(x,y),.7+i%2*.4,Color(U.GOLD,.18+.14*sin(elapsed+i)))
	if fighting and cast_time>0:
		var strength = cast_time/.9
		if model.s.settings.motion:
			var origin = left.get_center()
			match enemy.get("region",""):
				"wilds":
					for i in range(5):
						var x = left.position.x+12+i*23
						draw_polyline(PackedVector2Array([Vector2(x,196),Vector2(x-8,176-strength*25),Vector2(x+4,150-strength*30)]),Color(U.GREEN,strength*.7),2.0,true)
				"marsh":
					for i in range(4):
						var point = right.get_center()+Vector2(-30+i*20,30-(1-strength)*70)
						draw_polyline(PackedVector2Array([point,point+Vector2(-6,-15),point+Vector2(3,-27)]),Color(.5,.8,.8,strength*.35),1.5,true)
				_:
					for i in range(6):
						var point = origin+Vector2(-28+i*11,-24+(1-strength)*65)
						draw_line(point,point+Vector2(4,10),Color(U.GOLD,strength*.5),1.5,true)
		caption(Vector2(0,190),cast_name.to_upper(),U.GOLD,12,size.x)
	if fighting and enemy.boss and int(f.hits)%3==2:
		var warning_alpha = .6+.2*sin(elapsed*4) if model.s.settings.motion else .7
		draw_rect(right.grow(6),Color(U.RED,warning_alpha),false,2.0)
		var charge = 1.0-clampf(float(int(f.enemy_at)-int(model.s.time))/float(enemy.interval),0,1)
		bar(Rect2(right.position.x,39,w,3),charge,U.RED)
	if fighting:
		var charges = int(f.get("swings",0))%4
		caption(Vector2(0,268),"%s  %d / 4    ·    NEXT ATTACK %.1fs" % [{"balanced":"CLEAVE","guard":"WARD","reaver":"REND"}[model.progression().stance],charges,maxf(0,(int(f.player_at)-int(model.s.time))/1000.0)],U.GOLD,10,size.x)
	else: caption(Vector2(0,268),"PREPARE  ·  HUNT  ·  BRING HOPE HOME",U.GOLD,10,size.x)
	if effects_enabled:
		for effect in class_effects: FX.draw(self,effect,left,right,bool(model.s.settings.motion))
		if cast_time<=0 and awakening<=0:
			for i in range(class_effects.size()-1,-1,-1):
				var skill = str(class_effects[i].skill)
				if skill!="":
					caption(Vector2(0,190),FX.LABELS.get(skill,""),U.GOLD,12,size.x)
					break
	var lanes = {"hero":0,"enemy":0}
	for i in range(floating.size()):
		var item = floating[i]
		var x = left.position.x if item.side=="hero" else right.position.x
		var lane = int(lanes[item.side])
		lanes[item.side] += 1
		var y = 140-(1.0-float(item.life))*24-lane*30 if model.s.settings.motion else 125.0-lane*30
		draw_rect(Rect2(x,y-20,w,27),Color(0,0,0,.8))
		var color = U.GREEN if str(item.text).begins_with("+") else (U.RED if item.side=="hero" else U.GOLD)
		caption(Vector2(x,y),item.text,color,14,w)
