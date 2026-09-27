class_name RealmAutomation
extends RefCounted

const DURATION = 14400000
static func state(m) -> Dictionary:
	if not m.s.has("assistant_queue"):
		m.s.assistant_queue = {"until":0,"enabled":false,"hunt":"","reserve":30,"status":"Watch a rewarded ad to unlock four hours of queue assistance."}
	return m.s.assistant_queue

# Native earned-reward callback only; not exposed as a player command.
static func earned(m):
	var s = state(m)
	s.until = maxi(int(s.until),int(m.s.time)+DURATION)
	s.status = "Four hours unlocked. Choose a hunt and enable assistance."

static func command(m, cmd) -> String:
	var s = state(m)
	if cmd.type=="assist_stop":
		s.enabled = false
		s.status = "Assistance stopped. Existing queued work remains manual."
		return ""
	if int(s.until)<=int(m.s.time): return "Complete a rewarded ad before enabling queue assistance."
	var id = str(cmd.get("id",""))
	if id!="" and (not m.data.enemies.has(id) or m.available(id)!="" or id=="hollow_depth"): return "Choose an available hunt."
	if id.begins_with("secret_") and int(m.s.kills.get(id,0))<1: return "Defeat this guardian manually before using assisted repeat hunts."
	if not m.s.queue.is_empty(): return "Finish or clear your manual queue first."
	s.hunt = id
	s.enabled = true
	s.status = "Preparing supplies, then your relic target, then repeat hunts."
	return ""

static func stop(m, reason: String):
	if not m.s.has("assistant_queue"): return
	state(m).enabled = false
	state(m).status = reason

static func next(m):
	if not m.s.has("assistant_queue"): return
	var s = state(m)
	if not s.enabled: return
	if int(m.s.time)>=int(s.until): stop(m,"Rewarded assistance expired. Your current cycle can finish."); return
	if m.s.hp<100: return
	var food = str(m.s.settings.food)
	var activity = ""
	var target = RealmEndgame.target_status(m)
	if not target.is_empty() and not target.done:
		activity = target.activity
		if activity.begins_with("craft_"):
			var index = target.item.trim_prefix("relic_")
			var needed = 6+int(index)+(2 if m.count("blank_"+index)==0 else 0)
			if m.count("core_"+index)<needed: activity = "hunt_secret_"+index
	elif s.hunt!="": activity = "hunt_"+str(s.hunt)
	else: stop(m,"Target complete. Choose another target or repeat hunt."); return
	var reserve = int(s.reserve)
	if activity.begins_with("hunt_"):
		var enemy = activity.trim_prefix("hunt_")
		if m.available(enemy)!="" or (enemy.begins_with("secret_") and int(m.s.kills.get(enemy,0))<1): stop(m,"Unlock and defeat this guardian manually first."); return
		var outlook = RealmCombat.forecast(m,enemy)
		if outlook.stalled or outlook.burst>=100: stop(m,"Hunt appears unsafe. Improve your build before restarting assistance."); return
		reserve = maxi(reserve,ceili(outlook.meals*1.2)+5)
	if m.count(food)<reserve: activity = "craft_"+food
	if not m.data.activities.has(activity): stop(m,"No recipe found. Choose another food or target."); return
	var a = m.data.activities[activity]
	if a.kind=="combat":
		if m.available(a.enemy)!="" or (a.enemy.begins_with("secret_") and int(m.s.kills.get(a.enemy,0))<1): stop(m,"Unlock and defeat this guardian manually first."); return
		if RealmCombat.forecast(m,a.enemy).risk: stop(m,"Hunt appears unsafe. Review gear, food and route before restarting."); return
		m.s.queue.append(step(activity))
	else:
		var plan = RealmProgression.plan(m,activity,1)
		if plan.error!="": stop(m,plan.error); return
		if plan.steps.is_empty(): stop(m,"No work required."); return
		# Re-evaluate after each single cycle; never create hours of work past expiry.
		m.s.queue.append(step(plan.steps[0].id))
	s.status = "Assisting: "+m.activity_name(m.s.queue[0].id)

static func step(id: String) -> Dictionary:
	return {"id":id,"target":1,"kind":"cycles","done":0,"output":0,"skip":false}

static func valid(s, data) -> bool:
	if not s is Dictionary: return false
	return RealmSave.counter(s.get("until",-1)) and s.get("enabled") is bool and s.get("hunt") is String and (s.hunt=="" or (data.enemies.has(s.hunt) and s.hunt!="hollow_depth")) and s.get("reserve",0)==30 and s.get("status") is String and s.status.length()<512
