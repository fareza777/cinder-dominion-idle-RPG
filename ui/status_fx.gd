extends RefCounted

static func draw(canvas: CanvasItem, m, side: String, area: Rect2, elapsed: float):
	for effect in ["burn","poison","bleed","chill","freeze","barrier","regeneration","shock"]:
		if not RealmAfflictions.has(m,side,effect): continue
		var color = {"burn":Color("dc8844"),"poison":Color("9baa69"),"bleed":Color("b05e60"),"chill":Color("a5c8d6"),"freeze":Color("bad7e0"),"barrier":Color("d1bb87"),"regeneration":Color("9bbc9f"),"shock":Color("c5b9df")}[effect]
		for i in range(5):
			var progress = fposmod(elapsed*.4+i*.197,1.0)
			var x = area.position.x+area.size.x*(.1+fposmod(i*.213,.8))
			var y = area.end.y-progress*area.size.y*.65
			color.a = sin(progress*PI)*.65
			var point = Vector2(x,y)
			if effect in ["freeze","chill","shock"]:
				canvas.draw_line(point,point+Vector2(3,-7),color,1.2,true)
			else: canvas.draw_circle(point,1.2 if effect!="barrier" else 1.8,color)
