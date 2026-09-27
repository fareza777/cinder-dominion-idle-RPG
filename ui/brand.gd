extends RefCounted

const TITLE = "Cinder Dominion: Idle RPG"
const SHORT = "CINDER DOMINION"
const EMBLEM = "res://assets/art/cinder-dominion-emblem-0.35.png"

static func emblem(size: Vector2) -> TextureRect:
	var art = TextureRect.new()
	art.texture = load(EMBLEM)
	art.custom_minimum_size = size
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return art
