extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func open(relic: String):
	var d = RealmChronicle.RELICS[relic]
	var state = RealmChronicle.state(m)
	var rank = int(state.relics[relic])
	var owned = int(state.fragments[relic])
	var goal = RealmRelicGoal.plan(rank,owned,1)
	var v = app.modal(d.name+" farming")
	v.add_child(U.para("Rank %d / 10 · %d fragments owned" % [rank,owned],18,U.GOLD))
	if goal.state=="ready":
		v.add_child(U.para("You have enough to upgrade.",25,U.TEXT))
		v.add_child(U.para("Cost: %d fragments · shared with rune upgrades." % RealmChronicle.relic_cost(rank),15))
		if not m.s.fight.is_empty(): v.add_child(U.para("Finish or leave combat before upgrading.",14,U.GOLD))
		var upgrade = app.modal_action("Upgrade · %d fragments" % RealmChronicle.relic_cost(rank),func():
			if app.send({"type":"relic_upgrade","id":relic}): open(relic))
		upgrade.disabled = not m.s.fight.is_empty() or not m.s.tutorial
	elif goal.state=="maximum":
		v.add_child(U.para("This relic is at maximum rank.",25,U.TEXT))
		v.add_child(U.para("Rank 10 / 10 · Fragments also upgrade runes.",15))
		v.add_child(U.button("Review rune upgrades",app.runeforge_dialog))
	else:
		v.add_child(U.para("%d fragments to the next rank" % int(goal.missing),25,U.TEXT))
	v.add_child(U.para("Unlocked hunts",19,U.GOLD))
	var choices = RealmCombat.farms(m,relic)
	if choices.is_empty(): v.add_child(U.para("Follow your Journey objectives to unlock enemies that drop these fragments.",15))
	for choice in choices:
		var enemy = m.data.enemies[choice.id]
		var estimate = choice.forecast
		var plan = RealmRelicGoal.plan(rank,owned,int(choice.fragments))
		if plan.state=="farm":
			plan.wins = RealmHuntMastery.wins_for_fragments(m,enemy,int(plan.missing))
			plan.batch = mini(100,int(plan.wins))
		var batch = int(plan.batch) if plan.state=="farm" else 10
		var card = U.card(v,14)
		var row = U.row(10)
		card.add_child(row)
		row.add_child(U.enemy_portrait(enemy,Vector2(56,70)))
		var heading = U.column(4)
		heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(heading)
		heading.add_child(U.para(m.local_name(enemy),21,U.TEXT))
		heading.add_child(U.para("%d %s per win · %s" % [int(choice.fragments),"fragment" if int(choice.fragments)==1 else "fragments",estimate.rating],14,U.GOLD))
		if enemy.has("region"): card.add_child(U.para(RealmCombat.mechanic(enemy),12))
		if plan.state=="farm":
			card.add_child(U.para("%d %s needed in total" % [int(plan.wins),"win" if int(plan.wins)==1 else "wins"],16,U.TEXT))
			if plan.wins>batch: card.add_child(U.para("Next batch: %d fights. Return for another batch if fragments are still missing." % batch,13))
		else: card.add_child(U.para("Optional farm",13))
		if not estimate.stalled:
			card.add_child(U.para("This batch: about %s · %d meals\nYield with mastery, if won: %d fragments" % [preload("res://ui/gameplay.gd").new(app).time_label(float(estimate.seconds)*batch),RealmHuntPlan.meals(m,estimate,batch),RealmHuntMastery.rewards(m,enemy,batch).fragments],14))
		else: card.add_child(U.para("Too much enemy healing · Improve damage first.",14,U.RED))
		if enemy.get("trial",false): card.add_child(U.para("Excludes first-clear bonus fragments.",12))
		card.add_child(U.button("Prepare %d %s" % [batch,"fight" if batch==1 else "fights"],func(): app.activity_dialog("hunt_"+str(choice.id),batch)))
		card.add_child(U.button("Try one fight",func(): app.activity_dialog("hunt_"+str(choice.id),1)))
	if goal.state!="ready": app.modal_action("Review relic upgrades",app.relics_dialog)
	else: v.add_child(U.button("Review all relics",app.relics_dialog))
