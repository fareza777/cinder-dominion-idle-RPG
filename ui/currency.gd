extends HBoxContainer

const U = preload("res://ui/style.gd")
const NAMES = ["Silver","Gold","Platinum"]
var coins: Array[Button] = []
var last_amount = -1

static func texture(index: int) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = preload("res://assets/art/currency-0.43.png")
	# Remove the atlas cell's transparent padding so small coins stay legible.
	atlas.region = Rect2(index*724+55,45,614,614)
	return atlas

static func amounts(value: int) -> Array:
	return [value%1000,int(value/1000)%1000,int(value/1000000)]

static func grouped(value: int) -> String:
	var digits = str(value)
	var result = ""
	for i in range(digits.length()):
		if i>0 and (digits.length()-i)%3==0: result+=","
		result+=digits[i]
	return result

func setup(open_wallet: Callable):
	add_theme_constant_override("separation",4)
	for index in range(3):
		var b = U.button("0",open_wallet)
		b.icon = texture(index)
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width",26)
		b.add_theme_constant_override("h_separation",3)
		b.add_theme_font_size_override("font_size",int(14*U.scale))
		b.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
		b.add_theme_stylebox_override("hover",U.box(U.PANEL,U.LINE,2,2))
		b.add_theme_stylebox_override("pressed",U.box(U.INK,U.GOLD,2,2))
		b.custom_minimum_size = Vector2(60,32)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_OFF
		b.name = NAMES[index]+"Coins"
		coins.append(b)
	for index in [2,1,0]: add_child(coins[index])

func update_amount(value: int):
	if value==last_amount: return
	last_amount = value
	var values = amounts(value)
	for index in range(3):
		var amount = int(values[index])
		coins[index].visible = amount>0 or (index==0 and value==0)
		coins[index].text = grouped(amount) if amount<10000 else str(int(amount/1000))+"K"
		coins[index].tooltip_text = grouped(amount)+" "+NAMES[index]+" · Open wallet"
