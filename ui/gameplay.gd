extends RefCounted

const U = preload("res://ui/style.gd")
const P = preload("res://game/progression.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func work_orders(selected: String = "watch", batches: int = 1):
	var orders = P.orders(m)
	var v = app.modal("Work for the refuge")
	v.add_child(U.para("Leave the hearth well supplied.",26,U.TEXT))
	v.add_child(U.para("Set a longer gathering and crafting order before you leave. Materials already in your pack are used first. These orders do not start combat.",14))
	var selector = OptionButton.new()
	selector.custom_minimum_size.y = 48
	for id in orders: selector.add_item(orders[id].name)
	selector.selected = orders.keys().find(selected)
	selector.item_selected.connect(func(index): work_orders(orders.keys()[index],batches))
	v.add_child(selector)
	var d = orders[selected]
	v.add_child(U.para(d.detail,15,U.TEXT))
	var sizes = U.row(6)
	v.add_child(sizes)
	for n in [1,2,4]:
		var b = U.button("%d batch%s" % [n,"es" if n>1 else ""],func(): work_orders(selected,n),n==batches)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sizes.add_child(b)
	var plan = P.order_plan(m,selected,batches)
	if plan.error!="":
		v.add_child(U.para(plan.error,14,U.RED))
		if plan.has("unlock_skill"): v.add_child(U.button("Train "+m.local_name(m.data.skills[plan.unlock_skill]),func(): training(plan.unlock_skill,int(plan.unlock_level)),true))
		if not m.s.queue.is_empty(): v.add_child(U.button("Review current work",app.queue_dialog))
		return
	v.add_child(U.label("WHAT YOU WILL BRING HOME",10,U.GOLD))
	for recipe in d.recipes: v.add_child(U.para("%d × %s" % [int(recipe[1])*batches,m.activity_name(recipe[0])],17,U.TEXT))
	var experience = {}
	for step in plan.steps:
		var a = m.data.activities[step.id]
		experience[a.skill] = int(experience.get(a.skill,0))+int(a.xp)*int(step.target)
	for skill in experience:
		var projected = mini(100,1+int(sqrt(float(m.s.xp[skill]+experience[skill])/25.0)))
		v.add_child(U.para("%s · +%d XP · Lv.%d → %d" % [m.local_name(m.data.skills[skill]),int(experience[skill]),m.level(skill),projected],13,U.GREEN))
	v.add_child(U.para("About %s · %d queue steps" % [time_label(plan.seconds),plan.steps.size()],14,U.GOLD))
	v.add_child(U.para("Mastery may shorten this estimate as you work. Orders progress for up to 24 hours while away; finished food must be selected for auto-heal if it is not already your active food.",12))
	for step in plan.steps: v.add_child(U.para("%s ×%d" % [m.activity_name(step.id),int(step.target)],13))
	app.modal_action("Begin this order",func():
		if app.send({"type":"work_order","id":selected,"batches":batches}):
			app.dismiss()
			app.toast("Your order is underway. Cinderwatch will keep working while you are away."))

func planner(id: String, amount: int = 1):
	var v = app.modal("Crafting plan")
	app.dialog.set_meta("coach_plan",id)
	v.add_child(U.icon(m.data.activities[id].output,72))
	v.add_child(U.para("Make %d × %s" % [amount,m.activity_name(id)],24,U.TEXT))
	v.add_child(U.para("Missing materials included · Equip crafted gear from Bag.",14))
	if m.data.items[m.data.activities[id].output].category=="equipment":
		v.add_child(U.button("Track this upgrade",func():
			if app.send({"type":"upgrade_goal","id":m.data.activities[id].output}): preload("res://ui/upgrade_goal.gd").new(app).open()))
	var amounts = U.row(6)
	v.add_child(amounts)
	for n in [1,5,10,50,100]:
		var b = U.button(str(n),func(): planner(id,n),n==amount)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		amounts.add_child(b)
	var plan = P.plan(m,id,amount)
	if plan.error!="":
		v.add_child(U.para(plan.error,15,U.RED))
		if plan.has("unlock_skill"): v.add_child(U.button("Train "+m.local_name(m.data.skills[plan.unlock_skill])+" to unlock materials",func(): training(plan.unlock_skill,int(plan.unlock_level)),true))
		if not m.s.queue.is_empty(): v.add_child(U.button("Manage current queue",app.queue_dialog))
		v.add_child(U.button("Find materials manually",func(): app.activity_dialog(id)))
		return
	v.add_child(U.para("%d steps · approximately %s · no gold cost" % [plan.steps.size(),time_label(plan.seconds)],13,U.GREEN))
	for i in range(plan.steps.size()):
		var step = plan.steps[i]
		var c = U.card(v,12)
		c.add_child(U.para("%02d   %s ×%d" % [i+1,m.activity_name(step.id),int(step.target)],16,U.TEXT))
		var a = m.data.activities[step.id]
		var ingredients = []
		for key in a.inputs: ingredients.append("%d %s" % [int(a.inputs[key])*int(step.target),m.name_of(key)])
		c.add_child(U.para("Gather from the world" if ingredients.is_empty() else "Consumes: "+", ".join(ingredients),12))
	app.modal_action("Gather & craft",func():
		if app.send({"type":"plan","id":id,"amount":amount}):
			app.dismiss()
			app.toast("Your crafting order is underway. Follow its progress in Queue.")).set_meta("coach_target","plan")
	v.add_child(U.para("You can cancel at any time. Only the active cycle reserves ingredients; its unused ingredients are refunded on cancellation.",12))

func time_label(seconds: float) -> String:
	if seconds>=3600: return "%dh %02dm" % [int(seconds)/3600,int(seconds/60)%60]
	return "%dm %ds" % [int(seconds)/60,int(seconds)%60] if seconds>=60 else "%ds" % int(seconds)

func training(skill: String, target: int):
	var best = ""
	var best_rate = 0.0
	for id in m.data.activities:
		var a = m.data.activities[id]
		if a.skill!=skill or a.kind=="combat" or m.level(skill)<int(a.level): continue
		var seconds = m.duration(a)/1000.0
		if not a.inputs.is_empty():
			var plan = P.plan(m,id,100)
			if plan.error!="": continue
			seconds = plan.seconds/100.0
		var rate = float(a.xp)/maxf(.01,seconds)
		if rate>best_rate:
			best_rate = rate
			best = id
	if best=="":
		app.toast("No available training recipe. Review this skill for its requirements.")
		return
	var selected = m.data.activities[best]
	var missing_xp = maxi(1,25*(target-1)*(target-1)-int(m.s.xp[skill]))
	var cycles = clampi(ceili(float(missing_xp)/int(selected.xp)),1,100)
	if selected.inputs.is_empty(): app.activity_dialog(best,cycles)
	else: planner(best,cycles)

func tactics():
	var v = app.modal("Fighting style")
	v.add_child(U.para("Choose your approach before a hunt. Attacks and skills trigger automatically, including while offline. Every fourth attack attempts your style skill; a miss still uses that attempt.",14))
	for id in P.STANCES:
		var d = P.STANCES[id]
		var selected = m.progression().stance==id
		var c = U.card(v,14,U.GOLD if selected else U.LINE)
		c.add_child(U.label(d.name+(" · ACTIVE" if selected else ""),23,U.GOLD,true))
		c.add_child(U.para(d.detail,14))
		var button = U.button("Selected" if selected else "Use "+d.name,func():
			if app.send({"type":"stance","id":id}): tactics(),not selected)
		button.disabled = selected or not m.s.fight.is_empty()
		c.add_child(button)
	if not m.s.fight.is_empty(): v.add_child(U.para("Retreat from combat to change styles. Your equipment stays safe.",14,U.RED))
	v.add_child(U.button("Advanced training · Bladecraft Lv.25",advanced_training))

func advanced_training():
	var v = app.modal("Advanced training")
	v.add_child(U.para("Advanced training · Bladecraft Lv.25",20,U.GOLD))
	v.add_child(U.para("Choose one alongside your fighting style. Change it freely between hunts.",14))
	for id in RealmDoctrines.ALL:
		var d = RealmDoctrines.ALL[id]
		var c = U.card(v,12)
		c.add_child(U.para(d.name,18,U.TEXT))
		c.add_child(U.para(d.detail,14))
		var selected = str(m.s.get("doctrine","none"))==id
		var button = U.button("Selected" if selected else "Choose "+d.name,func():
			if app.send({"type":"doctrine","id":id}): advanced_training())
		button.disabled = selected or not m.s.fight.is_empty() or (id!="none" and m.level("bladecraft")<25)
		c.add_child(button)

func contracts():
	var v = app.modal("Refuge contracts")
	v.add_child(U.para("Optional milestones. Progress is counted automatically across your entire journey. Each reward can be claimed once. Spend scraps and gold on permanent refuge upgrades.",14))
	for c in P.CONTRACTS:
		var claimed = c.id in m.progression().claimed
		var ready = P.value(m,c)>=c.target
		var card = U.card(v,14,U.GREEN if ready and not claimed else U.LINE)
		card.add_child(U.para(c.title+(" · CLAIMED" if claimed else ""),20,U.TEXT))
		card.add_child(U.para(c.detail,14))
		app.dynamic(card,func(): return "%d / %d" % [P.value(m,c),int(c.target)],13,U.GOLD)
		var meter = U.progress(P.value(m,c),c.target,U.GREEN,5)
		card.add_child(meter)
		var meter_ref = weakref(meter)
		app.dialog_callbacks.append(func():
			var live = meter_ref.get_ref()
			if is_instance_valid(live): live.value = P.value(m,c))
		card.add_child(U.para("+%d gold · +%d food · +%d scraps" % [int(c.gold),int(c.food),int(c.scrap)],12,U.GOLD))
		if not claimed:
			var claim = U.button("Claim reward",func():
				if app.send({"type":"claim","id":c.id}): contracts(),true)
			claim.disabled = not ready
			card.add_child(claim)
			var ref = weakref(claim)
			app.dialog_callbacks.append(func():
				var button = ref.get_ref()
				if is_instance_valid(button): button.disabled = P.value(m,c)<c.target)
			if not ready: card.add_child(U.button("Go to activity",func(): app.activity_dialog(c.activity)))

func refuge():
	var v = app.modal("Rebuild Cinderwatch")
	app.dynamic(v,func(): return "%d gold · %d metal scraps" % [int(m.s.gold),m.count("scrap")],18,U.GOLD)
	v.add_child(U.para("Permanent upgrades for this campaign. Earn every rank through play. Forge speed applies to new cycles; the Hearth works whenever you are outside combat.",14))
	for id in P.UPGRADES:
		var d = P.UPGRADES[id]
		var rank = int(m.progression().upgrades[id])
		var card = U.card(v,14)
		card.add_child(U.label("%s · %d / 3" % [d.name,rank],22,U.TEXT,true))
		card.add_child(U.para(d.detail,14))
		card.add_child(U.progress(rank,3,U.GOLD,5))
		if rank==3:
			card.add_child(U.label("FULLY RESTORED",12,U.GREEN))
			continue
		var gold = int(d.gold)*(rank+1)
		var scraps = int(d.scrap)*(rank+1)
		card.add_child(U.para("Next rank: %d gold + %d scraps" % [gold,scraps],13,U.GOLD))
		var b = U.button("Build rank %d" % (rank+1),func():
			if app.send({"type":"upgrade","id":id}): refuge(),true)
		card.add_child(b)
		var ref = weakref(b)
		app.dialog_callbacks.append(func():
			var button = ref.get_ref()
			if is_instance_valid(button): button.disabled = m.s.gold<gold or m.count("scrap")<scraps)
		b.disabled = m.s.gold<gold or m.count("scrap")<scraps
	v.add_child(U.button("Earn rewards through contracts",contracts))
