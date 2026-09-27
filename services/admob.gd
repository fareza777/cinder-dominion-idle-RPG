extends Node
var app
var config = JSON.parse_string(FileAccess.get_file_as_string("res://data/ads.json"))
var status = "Test ads are available on Android."
var sdk_ready = false
var busy = false
var full_screen = false
var banner: AdView
var banner_loaded = false
var banner_wanted = false
var banner_shown = false
var last_interstitial = -900000
var requested_at = 0
var generation = 0
var active_ad
var reward_placement = "meals"
var request_journey

func _process(_delta):
	if busy and Time.get_ticks_msec()-requested_at>45000:
		generation += 1
		busy = false
		status = "Ad request timed out. You can keep playing."
	if banner==null: return
	var allowed = banner_wanted and banner_loaded and app.mode=="play" and not app.paused and not full_screen and not app.model.s.experience.get("coach_active",false)
	if allowed!=banner_shown:
		banner_shown = allowed
		if allowed: banner.show()
		else: banner.hide()
	if is_instance_valid(app.banner_space):
		app.banner_space.visible = allowed
		if allowed:
			var ratio = app.size.y/maxf(1,app.get_viewport().get_visible_rect().size.y)
			app.banner_space.custom_minimum_size.y = maxf(60,banner.get_height_in_pixels()*ratio+8)

func request(format: String, placement: String = "meals"):
	if OS.get_name()!="Android" or not Engine.has_singleton("PoingGodotAdMob"):
		status = "Native ad testing requires the Android APK. No ad was shown."
		return
	if not config.test_mode:
		status = "Production ads need release configuration and device verification."
		return
	if busy or full_screen: return
	if placement not in ["meals","automation"]: return
	if not app.model.s.fight.is_empty() or app.model.s.experience.get("coach_active",false):
		status = "Finish your hunt or beginner guidance before testing an ad."
		return
	if format=="interstitial" and Time.get_ticks_msec()-last_interstitial<int(config.interstitial_cooldown_seconds)*1000:
		status = "Interstitial cooldown: 15 minutes between displays."
		return
	busy = true
	reward_placement = placement
	request_journey = app.model.s
	requested_at = Time.get_ticks_msec()
	generation += 1
	var attempt = generation
	status = "Preparing test ad…"
	if sdk_ready:
		load_format(format,attempt)
		return
	# Official demo units only. Production consent is deliberately not bypassed.
	var listener = OnInitializationCompleteListener.new()
	listener.on_initialization_complete = func(_result):
		sdk_ready = true
		if attempt==generation: load_format(format,attempt)
	MobileAds.initialize(listener)

func failed(attempt, _error):
	if attempt!=generation: return
	busy = false
	status = "No ad available. Nothing was spent; try again later."

func load_format(format: String, attempt: int):
	if format=="banner":
		if banner!=null: banner.destroy()
		banner = AdView.new(config.banner,AdSize.BANNER,AdPosition.BOTTOM)
		banner.hide()
		banner_loaded = false
		banner_shown = false
		banner.ad_listener.on_ad_loaded = func():
			if attempt!=generation: return
			busy = false
			banner_loaded = true
			banner_wanted = true
			status = "Test banner loaded. Space is reserved below navigation."
		banner.ad_listener.on_ad_failed_to_load = func(error): failed(attempt,error)
		banner.load_ad(AdRequest.new())
	elif format=="interstitial":
		var listener = InterstitialAdLoadCallback.new()
		listener.on_ad_failed_to_load = func(error): failed(attempt,error)
		listener.on_ad_loaded = func(ad): show_fullscreen(ad,false,attempt)
		InterstitialAdLoader.new().load(config.interstitial,AdRequest.new(),listener)
	elif format=="rewarded":
		var listener = RewardedAdLoadCallback.new()
		listener.on_ad_failed_to_load = func(error): failed(attempt,error)
		listener.on_ad_loaded = func(ad): show_fullscreen(ad,true,attempt)
		RewardedAdLoader.new().load(config.rewarded,AdRequest.new(),listener)

func show_fullscreen(ad, rewarded: bool, attempt: int):
	if attempt!=generation:
		ad.destroy()
		return
	if not app.model.s.fight.is_empty() or app.model.s.experience.get("coach_active",false):
		ad.destroy()
		busy = false
		status = "Ad cancelled because gameplay changed."
		return
	busy = false
	active_ad = ad
	full_screen = true
	var completed = {"reward":false}
	var journey = request_journey
	var placement = reward_placement
	var food = str(app.model.s.settings.food)
	var callbacks = FullScreenContentCallback.new()
	callbacks.on_ad_dismissed_full_screen_content = func():
		full_screen = false
		status = "Reward received." if completed.reward else ("Ad closed. No reward was earned." if rewarded else "Ad closed.")
		ad.destroy()
		active_ad = null
	callbacks.on_ad_failed_to_show_full_screen_content = func(_error):
		full_screen = false
		status = "Ad could not be shown. No reward was granted."
		ad.destroy()
		active_ad = null
	ad.full_screen_content_callback = callbacks
	if rewarded:
		var listener = OnUserEarnedRewardListener.new()
		listener.on_user_earned_reward = func(_reward):
			if completed.reward or not is_same(app.model.s,journey): return
			completed.reward = true
			if placement=="automation": RealmAutomation.earned(app.model)
			else: app.model.gain(food,int(config.reward_meals))
			app.persist()
			app.toast("Test reward: four hours of queue assistance unlocked." if placement=="automation" else "Test reward: +%d %s." % [config.reward_meals,app.model.name_of(food)])
		ad.show(listener)
	else:
		last_interstitial = Time.get_ticks_msec()
		ad.show()

func stop_banner():
	banner_wanted = false
	status = "Banner hidden."

func _exit_tree():
	if banner!=null: banner.destroy()
	if active_ad!=null: active_ad.destroy()
