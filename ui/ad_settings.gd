extends RefCounted
const U = preload("res://ui/style.gd")
var app
func _init(owner): app = owner
func open():
	app.ensure_ads()
	var v = app.modal("AdMob · test configuration")
	v.add_child(U.para("Google test ads",24,U.GOLD))
	v.add_child(U.para("Official Google demo units only. Automatic placements begin after beginner guidance. This build cannot serve production ads.",15))
	app.dynamic(v,func(): return app.ads.status,15,U.TEXT)
	v.add_child(U.button("Test banner",func(): app.ads.request("banner")))
	v.add_child(U.button("Hide banner",app.ads.stop_banner))
	v.add_child(U.button("Preview test interstitial",func(): app.ads.request("interstitial")))
	v.add_child(U.para("Automatic interstitials: after a completed Journey or a finished hunt report. First display after 10 active minutes; 15 minutes apart; at most 3 per session and 6 per day. Preview skips only the first-session wait.",13))
	v.add_child(U.button("Optional rewards",func():preload("res://ui/ad_rewards.gd").new(app).open()))
	v.add_child(U.para("Rewarded is optional. Meals are granted only after the SDK confirms the reward. Closing early or failing to load gives no reward.",13))
	var metrics=U.disclosure(v,"Local delivery diagnostics")
	app.dynamic(metrics,func():
		var lines=[]
		for key in app.ads.policy.data.metrics:lines.append(key.replace("_"," ")+": "+str(app.ads.policy.data.metrics[key]))
		return "No ad delivery yet." if lines.is_empty() else "\n".join(lines),13)
	app.modal_action("Back to Settings",app.settings_dialog)
