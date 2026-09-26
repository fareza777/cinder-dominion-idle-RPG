class_name RealmQueueRepair
extends RefCounted

static func plan(m) -> Dictionary:
	var failure = {"steps":[],"error":"","seconds":0.0,"cycles":0}
	if m.s.queue.is_empty():
		failure.error = "There is no queued task to prepare."
		return failure
	if not m.s.active.is_empty() or not m.s.fight.is_empty():
		failure.error = "The current task is running. Let it finish before preparing a blocked task."
		return failure
	var step = m.s.queue[0]
	var activity = m.data.activities[step.id]
	if activity.kind=="combat" or activity.inputs.is_empty():
		failure.error = "This task needs an unlock or recovery, not crafting materials."
		return failure
	if m.requirement(step.id)=="":
		failure.error = "This task already has the materials for its next cycle."
		return failure
	var remaining = int(step.target)-int(step.output if step.kind=="output" else step.done)
	if step.kind=="level": remaining = ceili(float(maxi(0,25*(int(step.target)-1)*(int(step.target)-1)-int(m.s.xp[activity.skill])))/maxi(1,int(activity.xp)))
	var cycles = clampi(remaining,1,100)
	var copy = RealmModel.new()
	copy.s = m.s.duplicate(true)
	copy.s.queue = []
	var result = RealmProgression.plan(copy,step.id,cycles)
	result.cycles = cycles
	if result.error!="": return result
	# Keep the original production task and its counters; prepend dependencies only.
	result.steps.pop_back()
	result.seconds = maxf(0,float(result.seconds)-copy.duration(activity)*cycles/1000.0)
	if result.steps.is_empty(): result.error = "No gathering steps are needed. Review the task's level requirement."
	elif result.steps.size()+m.s.queue.size()>20: result.error = "This preparation needs %d extra queue slots. Cancel a waiting task to make room." % result.steps.size()
	return result

static func apply(m) -> String:
	var preparation = plan(m)
	if preparation.error!="": return preparation.error
	m.s.queue = preparation.steps+m.s.queue
	m.start_next()
	return ""
