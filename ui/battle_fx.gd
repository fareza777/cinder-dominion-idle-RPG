extends RefCounted

const COLORS = {"frostbound":Color("9bc9d5"),"penitent":Color("c69774"),"duskblade":Color("b6a6cf"),"warden":Color("e1bc78"),"ranger":Color("a7cec0"),"arcanist":Color("e5ba91"),"reaver":Color("c79886"),"apothecary":Color("aac6ab")}
const LABELS = {"frostbound":"RIME SPEAR","penitent":"IRON PENANCE","duskblade":"LAST LIGHT","warden":"IRON GUARD","ranger":"MARKED STRIKE","arcanist":"EMBER LANCE","reaver":"SUNDERING BLOW","apothecary":"FIELD REMEDY","balanced":"CLEAVE","guard":"WARD","reaver_style":"REND"}

static func from_event(model, event: Dictionary) -> Dictionary:
	if event.text=="MISS":return {"class":RealmCharacters.id(model),"side":event.side,"skill":"evade","heal":false,"life":.4,"duration":.4,"critical":false}
	if event.get("kind","hit")!="hit" or event.text=="PHASE II": return {}
	var skill = str(event.get("skill",""))
	# 'reaver' stance and class are disambiguated at the event source.
	var heal = str(event.text).begins_with("+")
	if heal and skill!="apothecary": return {}
	return {"class":RealmCharacters.id(model),"side":event.side,"skill":skill,"heal":heal,"life":.72 if skill!="" else .38,"duration":.72 if skill!="" else .38,"critical":str(event.text).begins_with("CRIT")}

static func beam(canvas: CanvasItem, a: Vector2, b: Vector2, color: Color, strength: float, width: float = 2):
	canvas.draw_line(a,b,Color(color,strength*.12),width*5,true)
	canvas.draw_line(a,b,Color(color,strength*.35),width*2.2,true)
	canvas.draw_line(a,b,Color(color.lerp(Color.WHITE,.65),strength),width,true)

static func trail(canvas: CanvasItem, points: PackedVector2Array, color: Color, alpha: float, width: float):
	canvas.draw_polyline(points,Color(color,alpha*.07),width*4,true)
	canvas.draw_polyline(points,Color(color,alpha*.2),width*1.7,true)
	canvas.draw_polyline(points,Color(color.lerp(Color.WHITE,.35),alpha*.7),width,true)

static func draw(canvas: CanvasItem, effect: Dictionary, left: Rect2, right: Rect2, moving: bool):
	if not moving: return # Keep damage and skill text; no looping visual substitute.
	var progress = clampf(1-float(effect.life)/float(effect.duration),0,1)
	var alpha = sin((.18+progress*.82)*PI)
	var center = left.get_center() if effect.side=="hero" else right.get_center()
	var color = COLORS.get(effect["class"],Color("dfb977")) if effect.side=="enemy" or effect.skill in ["warden","apothecary"] else Color("b78379")
	var skill = str(effect.skill)
	if skill=="evade":
		for i in range(3):
			var origin=center+Vector2(-20+i*13,20-i*8)
			trail(canvas,PackedVector2Array([origin,origin+Vector2(12,-7),origin+Vector2(25,-9)]),Color("c6d2d7"),alpha*.35,1)
		return
	if skill=="frostbound":
		var origin=left.get_center()+Vector2(25,10)
		var tip=origin.lerp(center,minf(1,progress*3))
		beam(canvas,origin,tip,color,alpha,2.2)
		for i in range(5):
			var ray=Vector2.from_angle(-2.4+i*.65)
			beam(canvas,center+ray*(8+progress*18),center+ray*(17+progress*25),color,alpha,1)
	elif skill=="penitent":
		for i in range(3):
			canvas.draw_arc(center,8+progress*35+i*4,-PI*.8,PI*.25,20,Color(color,alpha*(.5-i*.12)),1.6,true)
	elif skill=="duskblade":
		for i in range(2):
			var points=PackedVector2Array()
			for j in range(13):
				var t=float(j)/12;points.append(center+Vector2(-32+t*64,(-24+t*48)*(1 if i==0 else -1)+sin(t*PI)*8))
			trail(canvas,points,color,alpha*(1-i*.2),2)
	elif skill=="warden":
		# Short deflection glint along the guard side, followed by falling metal sparks.
		var edge = center+Vector2(34,0)
		trail(canvas,PackedVector2Array([edge+Vector2(-3,-27),edge+Vector2(4,0),edge+Vector2(-5,25)]),color,alpha,1.5)
		center = edge
	elif skill=="ranger":
		# A precise cut with two fading afterimages, no target reticle.
		for i in range(3):
			var offset = Vector2(-i*4,i*4)
			trail(canvas,PackedVector2Array([center+Vector2(-32,23)+offset,center+Vector2(0,-2)+offset,center+Vector2(31,-29)+offset]),color,alpha*(1-i*.26),1.4)
	elif skill=="arcanist":
		# Tapered ember wake from blade to target, deliberately asymmetric.
		var origin = left.get_center()+Vector2(25,12)
		var end = right.get_center()+Vector2(5,-5)
		var points = PackedVector2Array()
		for i in range(13):
			var t = float(i)/12
			points.append(origin.lerp(end,t)+Vector2(0,sin(t*PI)*(-15+progress*10)))
		trail(canvas,points,color,alpha,2.1)
		for i in range(6):
			var t = fposmod(i*.153+progress*.4,1)
			canvas.draw_circle(origin.lerp(end,t)+Vector2(0,-sin(t*PI)*12+i%2*5),1.2,Color(color,alpha*.65))
	elif skill=="apothecary":
		# Soft rising wisps and motes suggest restored vitality without a UI symbol.
		for i in range(3):
			var points = PackedVector2Array()
			for j in range(10):
				var t = float(j)/9
				points.append(center+Vector2(-18+i*18+sin(t*PI*1.5+i)*7,37-t*60-progress*12))
			trail(canvas,points,color,alpha*.45,1)
		for i in range(6):
			canvas.draw_circle(center+Vector2(sin(i*2.4)*25,35-progress*63+i%3*7),1.2,Color(color,alpha*.65))
	else:
		var heavy = skill!="" or bool(effect.critical)
		var points = PackedVector2Array()
		for i in range(15):
			var t = float(i)/14
			points.append(center+Vector2(lerpf(-34,35,t),lerpf(28,-30,t)+sin(t*PI)*11))
		trail(canvas,points,color,alpha,3 if heavy else 1.3)
	# Restrained directional fragments at contact, confined to the artwork area.
	if skill!="apothecary":
		for i in range(6 if skill!="" else 3):
			var ray = Vector2.from_angle(-1.9+i*.58)
			var distance = 5+progress*26
			beam(canvas,center+ray*distance+Vector2(0,progress*progress*8),center+ray*(distance+3),color,alpha*.5,.8)
