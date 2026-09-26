extends AudioStreamPlayer

var app
var tracks = {}
var voices: Array[AudioStreamPlayer] = []
var gains = [0.0,0.0]
var active = 0
var mood = ""
var event_serial = 0
var cue_at = -1000
var preview_mood = ""
var preview_owner: WeakRef

func preview(id: String, owner: Control):
	if not tracks.has(id): return
	preview_mood = id
	preview_owner = weakref(owner)

func _ready():
	stop()
	for id in ["hearth","wilds","sanctum","crown"]:
		var path = "res://assets/audio/"+id+".ogg"
		if ResourceLoader.exists(path):
			var audio = load(path).duplicate()
			if audio is AudioStreamOggVorbis:
				audio.loop = true
			tracks[id] = audio
	voices.append(self)
	var other = AudioStreamPlayer.new()
	add_child(other)
	voices.append(other)
	if app!=null: event_serial = int(app.model.battle_event.serial)

func _process(delta: float):
	if app==null: return
	for voice in voices: voice.stream_paused = app.paused
	if app.paused: return
	var target = "hearth"
	if app.mode=="play" and not app.model.s.fight.is_empty():
		var region = app.model.data.enemies[app.model.s.fight.enemy].get("region","wilds")
		target = "sanctum" if region=="marsh" else region
		if not tracks.has(target): target = "wilds"
	if preview_mood!="":
		var owner = preview_owner.get_ref() if preview_owner!=null else null
		if is_instance_valid(owner) and owner.is_inside_tree(): target = preview_mood
		else: preview_mood = ""
	# Complete each crossfade before accepting another mood change.
	if target!=mood and gains[1-active]<=.001 and tracks.has(target):
		active = 1-active
		mood = target
		voices[active].stream = tracks[target]
		voices[active].volume_db = -80
		voices[active].play()
	for i in range(2):
		gains[i] = move_toward(gains[i],1.0 if i==active else 0.0,delta/2.0)
		voices[i].volume_db = linear_to_db(maxf(.00001,float(app.model.s.settings.music)*sqrt(gains[i])))
		if gains[i]<=0 and i!=active: voices[i].stop()
	var event = app.model.battle_event
	if int(event.serial)!=event_serial:
		event_serial = int(event.serial)
		if app.mode=="play" and int(app.model.s.time)-int(event.get("time",-10000))<250 and int(app.model.s.time)-cue_at>200:
			if event.get("kind","")=="hit" and str(event.text) not in ["MISS","PHASE II"] and not str(event.text).begins_with("+"):
				cue_at = int(app.model.s.time)
				app.play_cue("strike" if event.side=="enemy" else "hurt")
