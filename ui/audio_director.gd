extends AudioStreamPlayer

var app
var mood = ""
var gain = 0.0
var tracks = {}

func _ready():
	for id in ["hearth","wilds","sanctum","crown"]:
		var path = "res://assets/audio/"+id+".wav"
		if ResourceLoader.exists(path): tracks[id] = load(path)

func _process(delta: float):
	if app==null: return
	var target = "hearth"
	if app.mode=="play" and not app.model.s.fight.is_empty():
		var region = app.model.data.enemies[app.model.s.fight.enemy].get("region","wilds")
		target = "sanctum" if region=="marsh" else region
	if app.paused:
		stream_paused = true
		return
	stream_paused = false
	if target!=mood:
		gain = maxf(0,gain-delta*1.5)
		if gain<=0 and tracks.has(target):
			mood = target
			stream = tracks[target]
			play()
	else: gain = minf(1,gain+delta*.8)
	volume_db = linear_to_db(maxf(.00001,float(app.model.s.settings.music)*gain))
