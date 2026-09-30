extends Node
const Policy=preload("res://services/ad_policy.gd")
const DEMO_APP="ca-app-pub-3940256099942544~3347511713"
const DEMO={"banner":"ca-app-pub-3940256099942544/9214589741","interstitial":"ca-app-pub-3940256099942544/1033173712","rewarded":"ca-app-pub-3940256099942544/5224354917"}
var app
var config=JSON.parse_string(FileAccess.get_file_as_string("res://data/ads.json"))
var policy
var status="Google test ads. Native display requires Android."
var sdk_ready=false
var initializing=false
var init_at=0
var init_retry=0
var init_token=0
var full_screen=false
var quiet_resume_until=0
var active_ad
var banner
var banner_loaded=false
var banner_wanted=true
var banner_shown=false
var banner_height=0
var banner_width=0
var generation=0
var pending_rewards=[]
var maintenance=0.0
var slots={}
var full_overlay: Control

func _ready():
 policy=Policy.new(config);policy.load_local()
 for format in ["banner","interstitial","rewarded"]:slots[format]={"ad":null,"loading":false,"at":0,"loaded":0,"token":0,"retry":0,"failures":0}

func native_available() -> bool:
 return OS.get_name()=="Android" and Engine.has_singleton("PoingGodotAdMob")

func demo_configuration() -> bool:
 if not config.get("test_mode",false) or config.get("app_id","")!=DEMO_APP:return false
 for key in DEMO:
  if config.get(key,"")!=DEMO[key]:return false
 return ProjectSettings.get_setting("admob/general/android/app_id",DEMO_APP)==DEMO_APP

func now() -> int:return int(Time.get_unix_time_from_system()*1000)
func foreground() -> bool:
 return app.mode=="play" and not app.paused and not app.recovering
func safe_context() -> bool:
 return foreground() and not full_screen and app.model.s.tutorial and app.model.s.experience.get("welcome_done",false) and not app.model.s.experience.get("coach_active",false) and app.model.s.fight.is_empty()
func banner_allowed() -> bool:
 var keyboard=DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD) and DisplayServer.virtual_keyboard_get_height()>0
 return safe_context() and not is_instance_valid(app.dialog) and app.page in config.banner_pages and not keyboard and policy.foreground_seconds>=config.banner_start_seconds

func _process(delta):
 if policy==null:return
 if foreground() and not full_screen and app.model.s.tutorial and not app.model.s.experience.get("coach_active",false):policy.foreground_seconds+=delta
 drain_rewards()
 sync_banner()
 maintenance+=delta
 if maintenance<1:return
 maintenance=0
 if not native_available() or not demo_configuration():return
 var ticks=Time.get_ticks_msec()
 if initializing and ticks-init_at>int(config.request_timeout_seconds)*1000:
  initializing=false;init_token+=1;init_retry=ticks+60000;status="Ads could not connect. Your game can continue."
 if not safe_context():return
 if not sdk_ready:
  initialize_sdk();return
 for format in slots:
  var slot=slots[format]
  if slot.loading and ticks-slot.at>int(config.request_timeout_seconds)*1000:failed(format,int(slot.token))
  if slot.ad!=null and ticks-slot.loaded>int(config.cache_seconds)*1000:
   slot.ad.destroy();slot.ad=null
  if format=="banner":
   if banner_wanted and banner_allowed() and banner==null and not slot.loading:preload_format(format)
  elif not slot.loading and slot.ad==null:preload_format(format)

func initialize_sdk():
 if sdk_ready or initializing or Time.get_ticks_msec()<init_retry or not native_available() or not demo_configuration():return
 initializing=true;init_at=Time.get_ticks_msec();init_token+=1
 var token=init_token
 var request_config=RequestConfiguration.new()
 request_config.max_ad_content_rating=RequestConfiguration.MAX_AD_CONTENT_RATING_T
 MobileAds.set_request_configuration(request_config)
 var listener=OnInitializationCompleteListener.new()
 listener.on_initialization_complete=func(_result):
  if token!=init_token:return
  initializing=false;sdk_ready=true;status="Preparing optional test ads."
 MobileAds.initialize(listener)

func preload_format(format: String):
 if format not in slots or not sdk_ready or not demo_configuration():return
 var slot=slots[format]
 if slot.loading or slot.ad!=null or Time.get_ticks_msec()<slot.retry:return
 slot.loading=true;slot.at=Time.get_ticks_msec();slot.token+=1
 var token=int(slot.token);policy.metric(format+"_requests")
 if format=="banner":
  var size=AdSize.get_current_orientation_anchored_adaptive_banner_ad_size(AdSize.FULL_WIDTH)
  if size.width<=0 or size.height<=0:size=AdSize.BANNER
  banner=AdView.new(config.banner,size,AdPosition.BOTTOM);banner.hide()
  banner_width=DisplayServer.window_get_size().x
  banner.ad_listener.on_ad_loaded=func():
   if token!=slots.banner.token:return
   slots.banner.loading=false;slots.banner.failures=0;banner_loaded=true
   banner_height=banner.get_height_in_pixels();policy.metric("banner_loaded");status="Test banner ready."
  banner.ad_listener.on_ad_failed_to_load=func(_error):failed("banner",token)
  banner.ad_listener.on_ad_impression=func():policy.metric("banner_impressions");policy.save_local()
  banner.load_ad(AdRequest.new())
 else:
  var listener=RewardedAdLoadCallback.new() if format=="rewarded" else InterstitialAdLoadCallback.new()
  listener.on_ad_failed_to_load=func(_error):failed(format,token)
  listener.on_ad_loaded=func(ad):
   if token!=slots[format].token:ad.destroy();return
   slots[format].loading=false;slots[format].ad=ad;slots[format].loaded=Time.get_ticks_msec();slots[format].failures=0
   policy.metric(format+"_loaded");status="Test "+format+" ready."
  if format=="rewarded":RewardedAdLoader.new().load(config.rewarded,AdRequest.new(),listener)
  else:InterstitialAdLoader.new().load(config.interstitial,AdRequest.new(),listener)

func failed(format: String,token: int):
 if token!=slots[format].token:return
 var slot=slots[format];slot.token+=1;slot.loading=false;slot.failures+=1
 slot.retry=Time.get_ticks_msec()+mini(300000,30000*int(pow(2,mini(4,slot.failures-1))))
 if format=="banner":destroy_banner()
 policy.metric(format+"_failures");policy.save_local()
 status="No ad available. Nothing was spent; you can keep playing."

func sync_banner():
 var allowed=banner!=null and banner_loaded and banner_wanted and banner_allowed()
 if banner!=null and banner_shown!=allowed:
  banner_shown=allowed
  if allowed:banner.show()
  else:banner.hide()
 if is_instance_valid(app.banner_space):
  app.banner_space.visible=allowed
  if allowed:
   var ratio=app.size.y/maxf(1,DisplayServer.window_get_size().y)
   app.banner_space.custom_minimum_size.y=maxf(58,banner_height*ratio+14)
 if banner!=null and abs(DisplayServer.window_get_size().x-banner_width)>8:
  slots.banner.token+=1;slots.banner.loading=false;destroy_banner()

func destroy_banner():
 if banner!=null:banner.destroy()
 banner=null;banner_loaded=false;banner_shown=false
 if is_instance_valid(app.banner_space):app.banner_space.hide()
func stop_banner():
 banner_wanted=false;sync_banner();status="Test banner hidden for this session."

func reward_reason(placement: String) -> String:
 if not safe_context():return "Finish your battle or guidance before watching an ad."
 if app.model.s.queue.any(func(step):return app.model.data.activities[step.id].kind=="combat") or app.model.s.get("assistant_queue",{}).get("enabled",false):return "Finish your hunt order or stop assistance before watching an ad."
 var why=policy.reward_reason(placement,now())
 if why!="":return why
 if placement=="automation" and int(app.model.s.get("assistant_queue",{}).get("until",0))-int(app.model.s.time)>1800000:return "Assistance is already unlocked. Renew when less than 30 minutes remain."
 return ""

func cache_ready(format: String) -> bool:
 var slot=slots.get(format,{})
 return slot.get("ad")!=null and Time.get_ticks_msec()-int(slot.loaded)<int(config.cache_seconds)*1000

func request(format: String,placement: String = "meals"):
 if not demo_configuration():status="This build permits official Google test IDs only.";return
 if not native_available():status="Ad display requires the Android APK. No reward was granted.";return
 if not safe_context():status="Finish your battle or beginner guidance first.";return
 if format=="banner":
  banner_wanted=true;initialize_sdk()
  if sdk_ready and banner==null:preload_format("banner")
  status="The test banner appears on management pages after you close this panel.";return
 if format not in ["rewarded","interstitial"]:return
 if format=="rewarded":
  var why=reward_reason(placement)
  if why!="":status=why;return
 elif not interstitial_allowed(true):status="Interstitial cooldown or display limit reached.";return
 if not sdk_ready:initialize_sdk()
 if not cache_ready(format):
  if sdk_ready:preload_format(format)
  status="Preparing a test ad. Tap Watch ad again when it is ready.";return
 var ad=slots[format].ad;slots[format].ad=null
 show_fullscreen(ad,format=="rewarded",placement)

func campaign() -> String:
 if not app.model.s.has("ad_identity"):app.model.s.ad_identity=Crypto.new().generate_random_bytes(16).hex_encode()
 return app.model.s.ad_identity

func interstitial_allowed(manual: bool = false) -> bool:
 if not safe_context() or not app.model.s.queue.is_empty() or not app.model.s.active.is_empty() or RealmVoyages.busy(app.model):return false
 if manual:
  var elapsed=policy.foreground_seconds;policy.foreground_seconds=maxf(elapsed,config.first_interstitial_seconds)
  var allowed=policy.interstitial_allowed(now());policy.foreground_seconds=elapsed;return allowed
 return policy.interstitial_allowed(now())

func natural_break(kind: String,key: String,duration_ms: int):
 if kind not in ["hunt","journey"] or duration_ms<300000:return
 var token=campaign()+":"+kind+":"+key
 if not policy.remember(token):return
 policy.save_local()
 # Never wait for an ad here. A late load must not interrupt the next activity.
 if not demo_configuration() or not native_available() or not interstitial_allowed() or is_instance_valid(app.dialog) or not cache_ready("interstitial"):return
 var ad=slots.interstitial.ad;slots.interstitial.ad=null
 show_fullscreen(ad,false,"")

func show_fullscreen(ad,rewarded: bool,placement: String):
 if not safe_context() or (rewarded and reward_reason(placement)!=""):
  ad.destroy();return
 var ctx={"id":Crypto.new().generate_random_bytes(16).hex_encode(),"campaign":campaign(),"placement":placement,"food":str(app.model.s.settings.food),"earned":false,"closed":false,"shown":false,"rewarded":rewarded}
 generation+=1
 if native_available():
  var volume=maxf(float(app.model.s.settings.music),float(app.model.s.settings.sfx))
  MobileAds.set_app_volume(volume);MobileAds.set_app_muted(volume<=0)
 active_ad=ad;full_screen=true;app.persist();sync_banner()
 full_overlay=Control.new();full_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);full_overlay.z_index=100;app.add_child(full_overlay)
 if is_instance_valid(app.effect):
  app.effect.stop()
  for voice in app.effect.get_children():voice.stop()
 var callbacks=FullScreenContentCallback.new()
 var ad_ref=weakref(ad)
 callbacks.on_ad_showed_full_screen_content=func():
  if ctx.closed or ctx.shown:return
  ctx.shown=true;policy.shown(rewarded,now());policy.save_local()
 callbacks.on_ad_impression=func():policy.metric("rewarded_impressions" if rewarded else "interstitial_impressions");policy.save_local()
 callbacks.on_ad_dismissed_full_screen_content=func():
  if ad_ref.get_ref()!=null:close_fullscreen(ad_ref.get_ref(),ctx,false)
 callbacks.on_ad_failed_to_show_full_screen_content=func(_error):
  if ad_ref.get_ref()!=null:close_fullscreen(ad_ref.get_ref(),ctx,true)
 ad.full_screen_content_callback=callbacks
 if rewarded:
  var listener=OnUserEarnedRewardListener.new()
  listener.on_user_earned_reward=func(_reward):
   if ctx.earned or ctx.closed:return
   ctx.earned=true;pending_rewards.append(ctx)
   drain_rewards()
  ad.show(listener)
 else:ad.show()

func close_fullscreen(ad,ctx: Dictionary,failed_show: bool):
 if ctx.closed:return
 ctx.closed=true;ad.destroy()
 quiet_resume_until=Time.get_ticks_msec()+10000
 if active_ad==ad:active_ad=null;full_screen=false
 if is_instance_valid(full_overlay):full_overlay.queue_free()
 full_overlay=null
 if failed_show:status="Ad could not be shown. Nothing was spent.";policy.metric("show_failures")
 elif ctx.earned:status="Reward earned."
 else:status="Ad closed. No reward was earned." if ctx.rewarded else "Ad closed."
 policy.save_local()
 drain_rewards()

func drain_rewards():
 if pending_rewards.is_empty() or not foreground():return
 for ctx in pending_rewards.duplicate():
  pending_rewards.erase(ctx)
  if app.model.s.get("ad_identity","")!=ctx.campaign:continue
  var receipts=app.model.s.get("ad_reward_receipts",[])
  if ctx.id in receipts:continue
  receipts.append(ctx.id)
  if receipts.size()>32:receipts.pop_front()
  app.model.s.ad_reward_receipts=receipts
  if ctx.placement=="automation":RealmAutomation.earned(app.model)
  else:app.model.gain(ctx.food,int(config.reward_meals))
  policy.earned(ctx.placement,now());policy.save_local();app.persist()
  status="Four hours of queue assistance unlocked." if ctx.placement=="automation" else "+%d %s received." % [config.reward_meals,app.model.name_of(ctx.food)]
  app.toast(status)

func _exit_tree():
 if policy!=null:policy.save_local()
 destroy_banner()
 for slot in slots.values():
  if slot.ad!=null:slot.ad.destroy()
 if active_ad!=null:active_ad.destroy()
 if is_instance_valid(full_overlay):full_overlay.queue_free()
