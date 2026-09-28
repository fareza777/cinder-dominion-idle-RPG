extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func show_plan(id: String, minutes: int = 15):
	var e = m.data.enemies[id]
	var f = RealmCombat.forecast(m,id)
	var count = maxi(1,int(minutes*60/float(f.seconds)))
	var meals = RealmHuntPlan.meals(m,f,count)
	var rewards = RealmHuntMastery.rewards(m,e,count)
	var v = app.modal("Before you set out")
	v.add_child(U.para(m.local_name(e),26,U.TEXT))
	v.add_child(U.para("Choose a duration. Queue the estimated fight count.",15))
	var row = U.row(6)
	v.add_child(row)
	for duration in [5,15,30]:
		var button = U.button("%d min" % duration,func(): show_plan(id,duration),duration==minutes)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(button)
	var plan = U.card(v,16)
	plan.add_child(U.para("%d fights · about %d minutes" % [count,ceili(count*f.seconds/60.0)],23,U.GOLD))
	plan.add_child(U.para("%s\nAbout %d meals · carrying %d\nStrongest enemy hit: %d damage before healing" % [f.rating,meals,m.count(m.s.settings.food),int(f.burst)],15,U.TEXT))
	var checks = U.card(v,12)
	checks.add_child(U.para("Before this hunt",18,U.TEXT))
	checks.add_child(U.para(("✓ Damage can overcome healing" if not f.stalled else "! More damage needed to overcome healing"),14,U.GREEN if not f.stalled else U.RED))
	checks.add_child(U.para(("✓ Can survive the estimated strongest hit" if f.burst<m.s.hp else "! Heal or improve defenses before the strongest hit"),14,U.GREEN if f.burst<m.s.hp else U.RED))
	checks.add_child(U.para("%s Food · %d / ~%d" % ["✓" if m.count(m.s.settings.food)>=meals else "!",m.count(m.s.settings.food),meals],14,U.GREEN if m.count(m.s.settings.food)>=meals else U.GOLD))
	checks.add_child(U.para("Forecast, not a guarantee. Random hits and healing timing can change the result.",12))
	plan.add_child(U.para("If every fight is won",12,U.GOLD))
	plan.add_child(U.para("%d gold · %d melee XP\n%d %s fragments\n%s ×%d" % [rewards.gold,count*RealmEconomy.hunt_xp(m,e),rewards.fragments,RealmChronicle.RELICS[RealmChronicle.fragments_for(e)].name,m.name_of(e.drop),count*int(e.qty)],15,U.GREEN))
	v.add_child(U.para("Rewards include mastery milestones. Time and food use your current build. Random loot and first-clear bonuses excluded.",13))
	if f.stalled: v.add_child(U.para("This enemy may recover faster than you can deal damage. Strengthen your weapon or change your build before a long hunt.",15,U.RED))
	elif f.risk or meals>m.count(m.s.settings.food): v.add_child(U.para("Your supplies or defenses may not hold for the whole journey. A single fight will give you a better starting point; check its Hunt report before committing to more.",15,U.GOLD))
	v.add_child(U.button("Try one fight first",func(): app.activity_dialog("hunt_"+id,1)))
	v.add_child(U.button("Prepare more "+m.name_of(m.s.settings.food),func(): app.planner_dialog("craft_"+str(m.s.settings.food),maxi(10,mini(100,meals-m.count(m.s.settings.food))))))
	v.add_child(U.button("Review my loadouts",app.loadouts_dialog))
	v.add_child(U.button("Compare builds for this hunt",func(): preload("res://ui/build_compare.gd").new(app).open(id)))
	var reason = m.available(id)
	if not m.s.queue.is_empty(): reason = "Finish or clear your current queue before starting this plan."
	if reason!="": app.dialog_footer.add_child(U.para(reason,12,U.GOLD))
	var begin = app.modal_action("Set out · %d fights" % count,func(): app.enqueue_activity("hunt_"+id,count))
	begin.disabled = reason!="" or f.stalled
