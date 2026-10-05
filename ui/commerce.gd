extends RefCounted

const U = preload("res://ui/style.gd")
var app

func _init(owner):
	app = owner

func open():
	var v = app.modal("Cinder Dominion Store")
	v.add_child(U.para("Support the realm without buying power.", 22, U.GOLD))
	v.add_child(U.para("Every gameplay system remains available for free. Optional purchases are permanent entitlements handled by Google Play.", 14))
	var card = U.card(v, 12)
	card.add_child(U.para("Remove Ads", 23, U.TEXT))
	card.add_child(U.para("$4.99 · One-time purchase\nRemoves banner and interstitial ads. Rewarded supplies remain optional when available.", 15, U.GOLD))
	var buy = U.button("Remove Ads · $4.99", buy_remove_ads, true)
	card.add_child(buy)
	if app.model.s.get("entitlements", {}).get("remove_ads", false):
		buy.text = "Ads removed on this journey"
		buy.disabled = true
	else:
		card.add_child(U.para("Play Billing is being connected for the public release. The purchase button will open official Google Play checkout once the release adapter is enabled.", 12, U.MUTED))
	v.add_child(U.button("Restore purchases", restore_purchases))
	if not app.commerce_status.is_empty():
		v.add_child(U.para(app.commerce_status, 13, U.MUTED))
	app.modal_action("Back to Settings", app.settings_dialog)

func buy_remove_ads():
	app.commerce_status = "Google Play Billing is not connected in this preview. No charge was made."
	open()

func restore_purchases():
	app.commerce_status = "No purchases were restored in this preview."
	open()
