extends RefCounted

const U = preload("res://ui/style.gd")
const ROWS = {"warden":0,"ranger":1,"arcanist":2,"reaver":3,"apothecary":4}

static func frames(character: String) -> Array[Texture2D]:
	var result: Array[Texture2D] = []
	for frame in range(4):
		if character in ROWS:
			result.append(U.atlas_tile("res://assets/art/hero-combat-0.37.png",int(ROWS[character])*4+frame,4,5))
		else: result.append(U.atlas_tile("res://assets/art/combat-poses-0.27.png",frame,4,4))
	return result

static func frame(model) -> int:
	if not model.s.settings.motion or model.s.fight.is_empty(): return 0
	var attack_age = 99999
	var hit_age = 99999
	for event in model.combat_events:
		if event.get("kind","hit")!="hit" or event.text=="PHASE II" or str(event.text).begins_with("+"): continue
		var age = int(model.s.time)-int(event.get("time",0))
		if event.side=="enemy": attack_age = mini(attack_age,age)
		elif event.text!="MISS": hit_age = mini(hit_age,age)
	if hit_age<160: return 3
	if attack_age<220: return 2
	if attack_age<430: return 3
	if int(model.s.fight.player_at)-int(model.s.time)<300: return 1
	return 0

static var sheet: Texture2D

static func draw(canvas: CanvasItem, character: String, index: int, area: Rect2, tint: Color = Color.WHITE):
	if character not in ROWS:
		canvas.draw_texture_rect(frames("")[index],area,false,tint)
		return
	if sheet==null: sheet = load("res://assets/art/hero-combat-0.37.png")
	var cell = sheet.get_size()/Vector2(4,5)
	var row = int(ROWS[character])
	var top = -16.0 if index==1 and row>=2 else 0.0
	var bottom = cell.y-18 if index==1 and row==2 else cell.y
	var edge = cell.x
	var outline = PackedVector2Array([Vector2(0,top),Vector2(edge,top),Vector2(edge,bottom),Vector2(0,bottom)])
	# Painted blades extend beyond the nominal grid. These UV silhouettes retain
	# their tips while excluding the neighboring recovery figure's lower cloak.
	if index==2:
		outline = PackedVector2Array([Vector2(0,0),Vector2(edge,0),Vector2(edge,48),Vector2(edge+62,48),Vector2(edge+62,146),Vector2(edge,146),Vector2(edge,cell.y),Vector2(0,cell.y)])
	elif index==3:
		outline = PackedVector2Array([Vector2(0,0),Vector2(edge,0),Vector2(edge,cell.y),Vector2(0,cell.y),Vector2(0,146),Vector2(62,146),Vector2(62,48),Vector2(0,48)])
	var vertices = PackedVector2Array()
	var uvs = PackedVector2Array()
	for point in outline:
		vertices.append(area.position+point/cell*area.size)
		uvs.append((Vector2(index,row)*cell+point)/sheet.get_size())
	canvas.draw_polygon(vertices,PackedColorArray([tint]),uvs,sheet)
