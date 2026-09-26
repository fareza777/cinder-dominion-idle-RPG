class_name RealmTraining
extends RefCounted
const SKILLS = ["mining","woodcutting","fishing","smithing","cooking","alchemy"]
const MINUTES = [15,60,240]

static func chain(m, id: String, cycles: int, skill: String) -> Dictionary:
	var plan = {"steps":[],"stock":m.s.bag.duplicate(true),"error":"","seconds":0.0,"xp":0}
	RealmProgression.append_recipe(m,id,cycles,plan,[])
	if plan.steps.size()>20: plan.error = "This training plan needs too many queue steps."
	for step in plan.steps:
		var activity = m.data.activities[step.id]
		if activity.skill==skill: plan.xp += int(activity.xp)*int(step.target)
	return plan

static func plan(source, skill: String, target: int, minutes: int) -> Dictionary:
	var m = RealmModel.new()
	m.data = source.data
	m.s = source.s.duplicate(true)
	if skill not in SKILLS or target<2 or target>100 or minutes not in MINUTES: return {"error":"Choose a skill, a level up to 100 and a training duration."}
	if m.level(skill)>=target: return {"error":"Target reached. Choose your next upgrade or a higher level.","complete":true}
	if not m.s.queue.is_empty(): return {"error":"Finish your current work before starting another training plan."}
	var milestone = target
	var missing = 25*(milestone-1)*(milestone-1)-int(m.s.xp[skill])
	var best = {"error":"No training recipe can be supplied yet. Gather materials or train the required gathering skills first."}
	var best_rate = -1.0
	for id in m.data.activities:
		var a = m.data.activities[id]
		if a.skill!=skill or a.kind=="combat" or a.level>m.level(skill): continue
		var low = 1
		var high = mini(1000,maxi(1,ceili(float(missing)/float(a.xp))))
		var candidate = {}
		while low<=high:
			var mid = (low+high)/2
			var attempt = chain(m,id,mid,skill)
			if attempt.error=="" and attempt.seconds<=minutes*60:
				attempt.cycles = mid
				if attempt.xp>=missing:
					candidate = attempt
					high = mid-1
				else:
					if candidate.is_empty() or candidate.xp<missing: candidate = attempt
					low = mid+1
			else: high = mid-1
		if candidate.is_empty(): continue
		var rate = candidate.xp/maxf(.001,candidate.seconds)
		if rate>best_rate:
			best_rate = rate
			best = candidate
			best.activity = id
			best.milestone = milestone
			best.level_after = mini(100,1+int(sqrt(float(m.s.xp[skill]+candidate.xp)/25.0)))
	return best
