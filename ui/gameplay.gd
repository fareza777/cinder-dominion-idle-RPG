extends RefCounted

const U = preload("res://ui/style.gd")
const P = preload("res://game/progression.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func planner(id: String, amount: int = 1):
	var v = app.modal("Supply planner")
	v.add_child(U.icon(m.data.activities[id].output,72))
	v.add_child(U.para("Make %d × %s" % [amount,m.activity_name(id)],24,U.TEXT))
	v.add_child(U.para("Gather missing materials, then craft in the correct order. Uses stock you already own. Equipment is added to your bag; equip it when finished.",14))
	var amounts = U.row(6)
	v.add_child(amounts)
	for n in [1,5,10,50,100]:
		var b = U.button(str(n),func(): planner(id,n),n==amount)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		amounts.add_child(b)
	var plan = P.plan(m,id,amount)
	if plan.error!="":
		v.add_child(U.para(plan.error,15,U.RED))
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
	v.add_child(U.button("Start complete plan",func():
		if app.send({"type":"plan","id":id,"amount":amount}):
			app.dismiss()
			app.toast("Supply chain started. Open Queue to follow each step."),true))
	v.add_child(U.para("You can cancel at any time. Only the active cycle reserves ingredients; its unused ingredients are refunded on cancellation.",12))

func time_label(seconds: float) -> String:
	return "%dm %ds" % [int(seconds)/60,int(seconds)%60] if seconds>=60 else "%ds" % int(seconds)

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
