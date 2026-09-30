extends SceneTree
const Settings=preload("res://services/ad_policy.gd")
var passed=0
var failed_count=0
func check(ok: bool,label: String):
 print("PASS " if ok else "FAIL ",label)
 if ok:passed+=1
 else:failed_count+=1
class MemoryPolicy extends "res://services/ad_policy.gd":
 func load_local():pass
 func save_local():pass
class AdApp extends Control:
 var model=RealmModel.new()
 var mode="play"
 var paused=false
 var recovering=false
 var page="village"
 var dialog
 var banner_space=Control.new()
 var effect
 var saves=0
 func persist():saves+=1
 func toast(_message):pass
class TestService extends "res://services/admob.gd":
 var test_time=1790000000000
 var allow_native=false
 func native_available():return allow_native
 func now():return test_time
 func _ready():
  policy=MemoryPolicy.new(config)
  for format in ["banner","interstitial","rewarded"]:slots[format]={"ad":null,"loading":false,"at":0,"loaded":0,"token":0,"retry":0,"failures":0}
  set_process(false)
class FakeAd extends RefCounted:
 var full_screen_content_callback
 var listener
 var destroyed=false
 var displays=0
 func show(value=null):
  displays+=1;listener=value
  full_screen_content_callback.on_ad_showed_full_screen_content.call()
 func destroy():destroyed=true
func _init():call_deferred("run")
func run():
 var config=JSON.parse_string(FileAccess.get_file_as_string("res://data/ads.json"));var now=1790000000000
 var p=MemoryPolicy.new(config)
 check(not p.interstitial_allowed(now),"first ten active minutes remain ad-free")
 p.foreground_seconds=600
 check(p.interstitial_allowed(now),"natural break becomes eligible after grace period")
 p.shown(false,now)
 check(not p.interstitial_allowed(now+899999) and p.interstitial_allowed(now+900000),"fifteen-minute interstitial cooldown")
 p.shown(false,now+900000);p.shown(false,now+1800000)
 check(not p.interstitial_allowed(now+2700000),"three interstitials per session")
 var day=int(now/86400000)*86400000
 p=MemoryPolicy.new(config);p.foreground_seconds=600
 for i in range(6):p.session_interstitials=0;p.shown(false,day+1000000+i*900000)
 p.session_interstitials=0
 check(not p.interstitial_allowed(day+10000000),"six interstitials per day across sessions")
 p=MemoryPolicy.new(config)
 for i in range(3):p.earned("meals",now+i*100000)
 check(p.reward_reason("meals",now+400000)!="" and p.remaining("automation",now+400000)==3,"reward placement caps remain independent")
 check(p.remaining("meals",now-86400000)==0,"clock rollback cannot refill daily rewards")
 check(p.remaining("meals",now+86400000)==3,"a later day refreshes rewards")
 p.earned("automation",now+86400000)
 p.foreground_seconds=600;p.shown(true,now+86400000)
 check(not p.interstitial_allowed(now+86400001),"rewarded viewing creates a fullscreen breathing gap")
 var disk=Settings.new(config);disk.storage_path="user://ad-policy-test55.json";disk.foreground_seconds=600;disk.shown(false,now);disk.save_local()
 var loaded=Settings.new(config);loaded.storage_path=disk.storage_path;loaded.load_local();loaded.foreground_seconds=600
 check(loaded.data.interstitials==1 and not loaded.interstitial_allowed(now+1000),"millisecond timestamps and caps survive reload")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(disk.storage_path))
 var owner=AdApp.new();root.add_child(owner);owner.add_child(owner.banner_space)
 owner.model.s.tutorial=true;owner.model.s.experience.welcome_done=true;owner.model.s.experience.coach_active=false
 var ads=TestService.new();ads.app=owner;owner.add_child(ads)
 check(ads.demo_configuration(),"only official Google demo configuration accepted")
 ads.config.rewarded="live-id";check(not ads.demo_configuration(),"a mixed live/test configuration is rejected");ads.config.rewarded=ads.DEMO.rewarded
 ads.request("rewarded","meals")
 check(owner.saves==0 and owner.model.s.get("ad_reward_receipts",[]).is_empty(),"desktop no-fill cannot create rewards")
 ads.policy.foreground_seconds=601
 check(ads.banner_allowed(),"banner eligible on management page")
 owner.page="explore";check(not ads.banner_allowed(),"banner hidden on Explore");owner.page="village"
 owner.dialog=Control.new();owner.add_child(owner.dialog);check(not ads.banner_allowed(),"banner hidden beneath dialogs");owner.dialog.queue_free();owner.dialog=null
 owner.model.s.experience.coach_active=true;check(not ads.banner_allowed() and ads.reward_reason("meals")!="","onboarding blocks ad placements");owner.model.s.experience.coach_active=false
 owner.model.command({"type":"queue","id":"hunt_ash_rat","target":1});check(not ads.banner_allowed() and ads.reward_reason("meals")!="","battle blocks banner and rewarded");owner.model.command({"type":"clear"})
 var food=owner.model.s.settings.food;var original=owner.model.count(food)
 var ad=FakeAd.new();ads.show_fullscreen(ad,true,"meals")
 ad.listener.on_user_earned_reward.call(null);ad.listener.on_user_earned_reward.call(null)
 check(owner.model.count(food)==original+15 and owner.model.s.ad_reward_receipts.size()==1,"earned callback grants the disclosed food once")
 check(not RealmSave.new().decode(RealmSave.new().encode(owner.model.s),owner.model.data).is_empty(),"campaign identity and reward receipt survive save validation")
 ad.full_screen_content_callback.on_ad_dismissed_full_screen_content.call()
 check(not ads.full_screen and ad.destroyed,"dismissal clears fullscreen and releases the ad")
 ads.test_time+=100000
 ad=FakeAd.new();ads.show_fullscreen(ad,true,"meals");var before=owner.model.count(food)
 ad.full_screen_content_callback.on_ad_dismissed_full_screen_content.call();ad.listener.on_user_earned_reward.call(null)
 check(owner.model.count(food)==before,"closing without earned callback grants nothing, including late callback")
 ads.test_time+=100000
 ad=FakeAd.new();ads.show_fullscreen(ad,true,"automation");owner.recovering=true
 ad.listener.on_user_earned_reward.call(null)
 check(not owner.model.s.has("assistant_queue"),"reward waits for offline recovery to finish")
 owner.model.s=owner.model.s.duplicate(true);owner.recovering=false;ads.drain_rewards()
 check(RealmAutomation.state(owner.model).until==owner.model.s.time+14400000,"reward survives legitimate save-dictionary replacement on resume")
 ad.full_screen_content_callback.on_ad_dismissed_full_screen_content.call()
 check(ads.reward_reason("automation")!="","an active lease cannot waste another rewarded ad")
 ads.test_time+=100000
 ad=FakeAd.new();ads.show_fullscreen(ad,true,"meals");owner.model.fresh();var fresh_count=owner.model.count(food)
 ad.listener.on_user_earned_reward.call(null);ad.full_screen_content_callback.on_ad_dismissed_full_screen_content.call()
 check(owner.model.count(food)==fresh_count,"stale callback cannot reward a new campaign")
 owner.model.s.tutorial=true;owner.model.s.experience.welcome_done=true;owner.model.s.experience.coach_active=false
 ads.policy=MemoryPolicy.new(config);ads.policy.foreground_seconds=601;ads.allow_native=true
 ads.natural_break("journey","one",3600000)
 check(not ads.full_screen,"no cached interstitial means continue immediately")
 ad=FakeAd.new();ads.slots.interstitial.ad=ad;ads.slots.interstitial.loaded=Time.get_ticks_msec()
 ads.natural_break("journey","one",3600000)
 check(ad.displays==0,"a skipped break cannot later pop up an ad for the same result")
 ads.natural_break("journey","two",3600000)
 check(ad.displays==1,"a fresh eligible natural break uses a preloaded interstitial")
 ad.full_screen_content_callback.on_ad_dismissed_full_screen_content.call()
 ads.test_time+=1000000
 ad=FakeAd.new();ads.show_fullscreen(ad,true,"meals");before=owner.model.count(food)
 ad.full_screen_content_callback.on_ad_failed_to_show_full_screen_content.call(null)
 check(not ads.full_screen and ad.destroyed and owner.model.count(food)==before,"show failure releases input without rewards")
 var slot=ads.slots.rewarded;slot.loading=true;slot.token=10
 ads.failed("rewarded",10);var retry=slot.retry
 check(not slot.loading and slot.failures==1 and retry-Time.get_ticks_msec()>29000,"failed load backs off for thirty seconds")
 ads.failed("rewarded",10)
 check(slot.failures==1 and slot.retry==retry,"stale loader callback cannot duplicate retries")
 slot.ad=FakeAd.new();slot.loaded=Time.get_ticks_msec()-2700001
 check(not ads.cache_ready("rewarded"),"expired cached ads cannot be displayed")
 owner.queue_free();await process_frame
 print("ADS55 ",passed," passed, ",failed_count," failed");quit(1 if failed_count else 0)
