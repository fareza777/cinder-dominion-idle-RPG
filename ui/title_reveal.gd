extends Control

const U = preload("res://ui/style.gd")
const Brand = preload("res://ui/brand.gd")
var motion = true
var elapsed = 0.0
var emblem: TextureRect
var words: VBoxContainer
var backdrop: ColorRect
var sheen: ShaderMaterial
var proceed: Button
var finished: Callable

func _ready():
	backdrop = ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade = Shader.new()
	shade.code = """shader_type canvas_item;
uniform float warmth = 0.0;
void fragment() {
 vec2 p = UV - vec2(0.5,0.40);
 float pool = exp(-dot(p*vec2(2.8,2.0),p*vec2(2.8,2.0))*5.0);
 float rim = exp(-abs(p.x)*13.0) * exp(-abs(p.y-0.25)*9.0);
 vec3 base = vec3(0.025,0.037,0.045);
 COLOR = vec4(base + vec3(0.12,0.057,0.012)*pool*warmth + vec3(0.06,0.024,0.005)*rim,1.0);
}"""
	var material = ShaderMaterial.new()
	material.shader = shade
	backdrop.material = material
	add_child(backdrop)
	var embers = preload("res://ui/atmosphere.gd").new()
	embers.motion = motion
	embers.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(embers)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.offset_top = -32
	add_child(center)
	words = U.column(12)
	words.custom_minimum_size.x = minf(size.x-48,420)
	center.add_child(words)
	emblem = Brand.emblem(Vector2(0,270))
	emblem.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var shader = Shader.new()
	shader.code = """shader_type canvas_item;
uniform float reveal = 1.0;
uniform float sweep = -0.4;
void fragment() {
 vec4 art = texture(TEXTURE, UV);
 float light = exp(-pow((UV.x+UV.y*0.25-sweep)*13.0,2.0));
 COLOR = vec4(art.rgb + vec3(0.35,0.22,0.08)*light,art.a*reveal);
}"""
	sheen = ShaderMaterial.new()
	sheen.shader = shader
	emblem.material = sheen
	words.add_child(emblem)
	var name_label = U.para("CINDER\nDOMINION",40,U.TEXT)
	name_label.add_theme_font_override("font",U.title_font)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words.add_child(name_label)
	var genre = U.label("I D L E   R P G",13,U.GOLD)
	genre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words.add_child(genre)
	proceed = Button.new()
	proceed.text = "Continue"
	proceed.flat = true
	proceed.custom_minimum_size = Vector2(160,48)
	proceed.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	proceed.offset_left = -80
	proceed.offset_right = 80
	proceed.offset_top = -88
	proceed.offset_bottom = -40
	proceed.add_theme_color_override("font_color",U.GOLD)
	proceed.pressed.connect(func(): finished.call())
	add_child(proceed)
	advance_reveal(0.0)

func advance_reveal(delta: float):
	elapsed += delta
	var progress = clampf(elapsed/1.8,0,1) if motion else 1.0
	sheen.set_shader_parameter("reveal",smoothstep(0.0,.55,progress))
	sheen.set_shader_parameter("sweep",lerpf(-.4,1.6,progress))
	backdrop.material.set_shader_parameter("warmth",.65+.35*sin(progress*PI))
	words.modulate.a = smoothstep(0.0,.5,progress)
	emblem.pivot_offset = emblem.size*.5
	emblem.scale = Vector2.ONE*lerpf(.94,1.0,smoothstep(0.0,1.0,progress))

func _process(delta):
	if motion: advance_reveal(delta)

