extends RefCounted
const U = preload("res://ui/style.gd")
var app
func _init(owner): app = owner
func open():
	app.ensure_ads()
	var v = app.modal("AdMob · test configuration")
	v.add_child(U.para("Google test ads",24,U.GOLD))
	v.add_child(U.para("This preview uses official demo units. Ads load only when you request a test below. Production advertising is not enabled.",15))
	app.dynamic(v,func(): return app.ads.status,15,U.TEXT)
	v.add_child(U.button("Test banner",func(): app.ads.request("banner")))
	v.add_child(U.button("Hide banner",app.ads.stop_banner))
	v.add_child(U.button("Test interstitial",func(): app.ads.request("interstitial")))
	v.add_child(U.para("Fullscreen ads are blocked during combat and guidance. Interstitial cooldown: 15 minutes.",13))
	v.add_child(U.button("Watch test ad · +5 selected meals",func(): app.ads.request("rewarded")))
	v.add_child(U.para("Rewarded is optional. Meals are granted only after the SDK confirms the reward. Closing early or failing to load gives no reward.",13))
	app.modal_action("Back to Settings",app.settings_dialog)
