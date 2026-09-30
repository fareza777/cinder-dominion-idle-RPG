extends RefCounted

# Local pacing only. This is not a server-authoritative monetization ledger.
const FILE="user://ad_delivery_v1.json"
var config: Dictionary
var data={"day":-1,"last_clock":0,"interstitials":0,"rewards":{"meals":0,"automation":0},"last_full":0,"last_reward":0,"seen":[],"metrics":{}}
var session_interstitials=0
var foreground_seconds=0.0
var storage_path=FILE
func _init(settings: Dictionary):config=settings
func load_local():
 if not FileAccess.file_exists(storage_path):return
 var f=FileAccess.open(storage_path,FileAccess.READ)
 if f==null or f.get_length()>65536:return
 var incoming=JSON.parse_string(f.get_as_text())
 if not incoming is Dictionary:return
 for key in ["day","interstitials"]:
  if not RealmSave.counter(float(incoming.get(key,-2))+(1 if key=="day" else 0)):return
 for key in ["last_clock","last_full","last_reward"]:
  var value=incoming.get(key,-1)
  if typeof(value) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(value)) or value<0 or value>9e15 or floor(float(value))!=value:return
 if not incoming.get("rewards") is Dictionary or not incoming.get("seen") is Array or not incoming.get("metrics") is Dictionary:return
 for key in ["meals","automation"]:
  if not RealmSave.counter(incoming.rewards.get(key,-1)):return
 if incoming.seen.size()>128 or not incoming.seen.all(func(x):return x is String and x.length()<160):return
 for key in incoming.metrics:
  if not key is String or key.length()>64 or not RealmSave.counter(incoming.metrics[key]):return
 data=incoming
func save_local():
 var f=FileAccess.open(storage_path,FileAccess.WRITE)
 if f!=null:f.store_string(JSON.stringify(data))
func clock(now: int) -> int:
 now=maxi(now,int(data.last_clock));data.last_clock=now
 var day=int(now/86400000)
 if day>int(data.day):
  data.day=day;data.interstitials=0;data.rewards={"meals":0,"automation":0}
 return now
func metric(key: String):data.metrics[key]=int(data.metrics.get(key,0))+1
func remaining(placement: String,now: int) -> int:
 clock(now)
 return maxi(0,int(config.reward_daily_caps.get(placement,0))-int(data.rewards.get(placement,0)))
func reward_reason(placement: String,now: int) -> String:
 now=clock(now)
 if placement not in config.reward_daily_caps:return "Choose an available reward."
 if remaining(placement,now)<=0:return "Today's rewards have been collected. More are available tomorrow."
 var wait=int(config.reward_cooldown_seconds)*1000-(now-int(data.last_reward))
 if data.last_reward>0 and wait>0:return "Next reward available in %ds." % ceili(wait/1000.0)
 return ""
func interstitial_allowed(now: int) -> bool:
 now=clock(now)
 return foreground_seconds>=config.first_interstitial_seconds and session_interstitials<config.interstitial_session_cap and data.interstitials<config.interstitial_daily_cap and (data.last_full==0 or now-int(data.last_full)>=int(config.interstitial_cooldown_seconds)*1000)
func remember(token: String) -> bool:
 if token in data.seen:return false
 data.seen.append(token)
 if data.seen.size()>128:data.seen.pop_front()
 return true
func shown(rewarded: bool,now: int):
 data.last_full=clock(now)
 if not rewarded:data.interstitials+=1;session_interstitials+=1
 metric("rewarded_shown" if rewarded else "interstitial_shown")
func earned(placement: String,now: int):
 data.last_reward=clock(now);data.rewards[placement]+=1;metric("reward_"+placement)
