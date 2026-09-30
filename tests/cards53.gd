extends "res://tests/audit53.gd"
func no_rarity_labels(node: Node) -> bool:
	if node is Label and node.text in ["Rare","Epic","Legendary","Mythic"]:return false
	for child in node.get_children():
		if not no_rarity_labels(child):return false
	return true
func capture():
	suffix="final"
	root.size=Vector2i(412,892)
	var app=PreviewApp.new();root.add_child(app);app.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	app.set_process(false);app.mode="play";app.model.s=preload("res://tests/overhaul51.gd").prepared().s
	app.model.s.experience.coach_active=false;app.set_page("character")
	var cards=preload("res://ui/cards.gd").new(app)
	cards.collection();assert(no_rarity_labels(app.dialog));await photo("cards-framed")
	cards.detail("card_ash_rat");assert(no_rarity_labels(app.dialog));await photo("rat-card-framed")
	cards.collection_filter="realm_6";cards.collection();await photo("realm-cards")
	cards.detail("card_realm_6_0");await photo("realm-card-detail")
	root.size=Vector2i(360,800);app.model.s.settings.font=1.3;preload("res://ui/style.gd").scale=1.3
	cards.collection();await photo("large-realm-cards")
	print("CARDS53: five final visual captures; no visible rarity labels.")
	quit()
