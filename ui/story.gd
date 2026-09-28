extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func open(index: int = -1):
	if index<0:
		index = 0
		for i in range(RealmStory.CHAPTERS.size()):
			if RealmStory.unlocked(m,i): index = i
	var chapter = RealmStory.CHAPTERS[index]
	var unlocked = RealmStory.unlocked(m,index)
	var v = app.modal("Story journal")
	v.add_child(U.para("%d / %d chapters unlocked" % [RealmStory.count(m),RealmStory.CHAPTERS.size()],12,U.GOLD))
	if unlocked:
		if ResourceLoader.exists("res://assets/art/story-chapters-0.13.png"):
			var art = TextureRect.new()
			var atlas = AtlasTexture.new()
			atlas.atlas = load("res://assets/art/story-chapters-0.13.png")
			var width = atlas.atlas.get_width()/3.0
			atlas.region = Rect2(int(chapter.art)*width,0,width,atlas.atlas.get_height())
			atlas.filter_clip = true
			art.texture = preload("res://ui/premium.gd").art(9+mini(2,int(chapter.frontier_tile)/6)) if chapter.has("frontier_tile") else atlas
			art.custom_minimum_size.y = 150
			art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			v.add_child(art)
		v.add_child(U.para(chapter.title,28,U.TEXT))
		v.add_child(U.para(chapter.body,16,U.TEXT))
		var next = U.card(v,14)
		next.add_child(U.para("What to do next",17,U.GOLD))
		next.add_child(U.para(chapter.next,14))
	else:
		v.add_child(U.para("This chapter is still locked.",25,U.TEXT))
		v.add_child(U.para(chapter.gate+" to read it. Your progress is tracked automatically.",16))
	var chapters = OptionButton.new()
	chapters.custom_minimum_size.y = 48
	chapters.fit_to_longest_item = false
	v.add_child(chapters)
	v.move_child(chapters,1)
	for i in range(RealmStory.CHAPTERS.size()):
		var label = RealmStory.CHAPTERS[i].title if RealmStory.unlocked(m,i) else "Locked chapter"
		chapters.add_item("%02d · %s" % [i+1,label])
	chapters.select(index)
	chapters.item_selected.connect(open)
	app.modal_action("View my current objective",app.guide_dialog)
