extends Control

const U = preload("res://ui/style.gd")
const SKILLS = ["mining","woodcutting","fishing","smithing","cooking","alchemy"]
var model
var frames: Array[Texture2D] = []
var hero_poses: Array[Texture2D] = []
var enemy_art: Texture2D
var activity_id = ""
var skill_index = 0
var frame = 0
var clock = 0.0
var running = false
var combat = false
var character_id = "unset"

func _ready():
	name = "WorkStage"
	custom_minimum_size = Vector2(64,54)
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	load_character()
	_process(0)

func load_character():
	character_id = RealmCharacters.id(model)
	frames.clear()
	hero_poses.clear()
	var path = "res://assets/art/work-poses-0.31.png" if character_id=="" else "res://assets/art/work-%s-0.32.png" % character_id
	if character_id in ["reaver","apothecary"]: path = "res://assets/art/work-%s-0.33.png" % character_id
	var sheet = load(path)
	# Observed painted row edges, excluding thin separators in the source atlas.
	var edges = [0,236,474,713,969,1210,1536]
	for i in range(24):
		var tile = AtlasTexture.new()
		tile.atlas = sheet
		tile.filter_clip = true
		var row = int(i/4)
		tile.region = Rect2((i%4)*256+2,edges[row]+2,252,edges[row+1]-edges[row]-4)
		frames.append(tile)
	hero_poses = preload("res://ui/hero_combat.gd").frames(character_id)

func _process(delta):
	if model==null: return
	if character_id!=RealmCharacters.id(model): load_character()
	visible = not model.s.queue.is_empty()
	if not visible: return
	var step = model.s.queue[0]
	var activity = model.data.activities[step.id]
	combat = activity.kind=="combat"
	if activity_id!=step.id and combat: enemy_art = U.enemy_texture(model.data.enemies[activity.enemy])
	activity_id = step.id
	skill_index = maxi(0,SKILLS.find(activity.skill))
	running = not model.s.fight.is_empty() if combat else not model.s.active.is_empty()
	frame = 0
	if running and model.s.settings.motion:
		if combat:
			frame = preload("res://ui/hero_combat.gd").frame(model)
		else:
			# Simulation time freezes visual work when the app is paused.
			var span = mini(2400,int(model.s.active.due-model.s.active.started))
			frame = mini(3,int(fposmod(float(model.s.time-model.s.active.started),span)/span*4))
	clock += delta
	if clock>=(1.0/15 if model.s.settings.battery else 1.0/30):
		clock = 0
		queue_redraw()

func _draw():
	if frames.is_empty() or activity_id=="": return
	var area = Rect2(Vector2.ZERO,size)
	if combat:
		draw_rect(area,Color("152029"))
		if enemy_art!=null: draw_texture_rect(enemy_art,Rect2(size.x*.52,2,size.x*.46,size.y-4),false,Color(.8,.8,.8))
		preload("res://ui/hero_combat.gd").draw(self,character_id,frame,Rect2(-6,3,size.x*.72,size.y-6))
		if frame==2: draw_line(Vector2(size.x*.4,15),Vector2(size.x*.70,38),U.GOLD,2,true)
	else:
		var texture = frames[skill_index*4+frame]
		var source = texture.get_size()
		var scale_factor = maxf(size.x/source.x,size.y/source.y)
		var shown = size/scale_factor
		draw_texture_rect_region(texture,area,Rect2((source-shown)*.5,shown),Color.WHITE if running else Color(.55,.55,.55))
	if not running:
		for x in [size.x-14,size.x-8]: draw_rect(Rect2(x,size.y-14,3,8),U.GOLD)
	draw_rect(area,U.GOLD.darkened(.4),false,1)
