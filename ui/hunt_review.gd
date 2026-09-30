extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func open(selected: int = 0):
	var v = app.modal("Hunt reports")
	var state = RealmHunts.state(m)
	var reports = state.history.duplicate(true)
	if not state.active.is_empty():
		var active = state.active.duplicate(true)
		active.ended = int(m.s.time)
		reports.push_front(active)
	if reports.is_empty():
		v.add_child(U.para("Your first hunt starts here.",25,U.TEXT))
		v.add_child(U.para("Choose an enemy in Explore and try one fight. This screen will show the rewards, time and supplies used.",16))
		app.modal_action("Choose a hunt",func():
			app.dismiss()
			app.set_page("explore"))
		return
	selected = clampi(selected,0,reports.size()-1)
	var report = reports[selected]
	var enemy = m.data.enemies[report.enemy]
	var metrics = RealmHuntReview.metrics(report)
	v.add_child(U.para("Latest hunt" if selected==0 else "Earlier hunt",11,U.GOLD))
	var hero = U.card(v,14)
	hero.add_child(U.para(m.local_name(enemy),25,U.TEXT))
	var row = U.row(14)
	hero.add_child(row)
	row.add_child(U.enemy_portrait(enemy,Vector2(80,108)))
	var summary = U.column(6)
	summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(summary)
	summary.add_child(U.para(report.result+" · %d %s" % [int(report.wins),"victory" if int(report.wins)==1 else "victories"],16,U.RED if report.result=="Defeated" else U.GOLD))
	summary.add_child(U.para("%s\n%d meals · %d potions" % [preload("res://ui/gameplay.gd").new(app).time_label(metrics.seconds),int(report.meals),int(report.potions)],14))
	if metrics.comparable:
		hero.add_child(U.para("%.1fs and %.1f meals per victory" % [metrics.per_win,metrics.meals_per_win],15,U.TEXT))
		var previous = RealmHuntReview.previous(reports,selected)
		if not previous.is_empty():
			var before = RealmHuntReview.metrics(previous)
			hero.add_child(U.para("Previous completed hunt against this enemy:\n%.1fs and %.1f meals per victory" % [before.per_win,before.meals_per_win],13))
			hero.add_child(U.para("Different food, starting health, builds and chance can change these averages. Compare several hunts before choosing a farm.",12))
		else: hero.add_child(U.para("Complete another hunt against this enemy to compare time and food use.",12))
	elif report.result=="Underway":
		hero.add_child(U.para("This hunt is still running. Totals include rewards and supplies recorded so far.",13))
		hero.add_child(U.button("Refresh report",func(): open(selected)))
	else: hero.add_child(U.para("This order ended early. Its totals include time and supplies spent on unfinished fights, so they are not used for completed-hunt comparisons.",13))
	var rewards = U.card(v,14)
	rewards.add_child(U.para("Rewards received",19,U.TEXT))
	rewards.add_child(U.para("%d gold · %d melee XP\n%d %s fragments" % [int(report.gold),int(report.xp),int(report.fragments),RealmChronicle.RELICS[RealmChronicle.fragments_for(enemy)].name],15,U.GREEN))
	for id in report.loot:
		if m.data.items[id].category!="equipment" or report.get("equipment",{}).is_empty(): rewards.add_child(U.para("%s ×%d" % [m.name_of(id),int(report.loot[id])],13))
	for key in report.get("equipment",{}):
		var parts = str(key).split("|")
		var quality = int(parts[1])
		rewards.add_child(U.para("%s %s ×%d" % [m.data.rarities[quality],m.name_of(parts[0]),int(report.equipment[key])],15,U.QUALITY[quality]))
	rewards.add_child(U.para("Already added to your inventory. No claim is needed.",12))
	var next = U.card(v,14)
	next.add_child(U.para("Prepare your next hunt",19,U.TEXT))
	if report.result=="Defeated": next.add_child(U.para("Your equipment is safe. Refill food, let your health recover, and improve your defenses before trying again.",14,U.GOLD))
	if report.has("consumed") and not report.consumed.is_empty():
		for id in report.consumed:
			var amount = int(report.consumed[id])
			next.add_child(U.para("%s: %d used · %d left" % [m.name_of(id),amount,m.count(id)],13))
			if m.data.activities.has("craft_"+id): next.add_child(U.button("Plan %d more %s" % [amount,m.name_of(id)],func(): app.planner_dialog("craft_"+id,amount)))
	elif not report.has("consumed"):
		next.add_child(U.para("This older report records supply totals without item names. Check your selected food before restocking.",13))
		next.add_child(U.button("Choose food and supplies",app.experience.survival))
	else: next.add_child(U.para("No food or potions were used in this hunt.",13))
	next.add_child(U.button("Review equipment upgrades",app.workshop_dialog))
	next.add_child(U.button("View my next objective",app.guide_dialog))
	v.add_child(U.para("Recent orders",19,U.TEXT))
	for i in range(reports.size()):
		var entry = reports[i]
		var button = U.button("%02d · %s\n%s · %d wins" % [i+1,m.local_name(m.data.enemies[entry.enemy]),entry.result,int(entry.wins)],func(): open(i),i==selected)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(button)
	app.modal_action("Plan this hunt again",func(): app.hunt_plan_dialog(str(report.enemy)))
	v.add_child(U.button("Return to Stronghold",func():
		app.dismiss();app.set_page("village")
		if selected==0 and report.result=="Completed" and int(report.wins)>=3:
			app.ensure_ads();app.ads.natural_break("hunt","%s:%d:%d" % [report.enemy,report.started,report.ended],int(report.ended-report.started))))
