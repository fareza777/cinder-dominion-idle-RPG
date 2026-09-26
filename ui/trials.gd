extends RefCounted

const U = preload("res://ui/style.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func show_trial(selected: String = "trial_wilds"):
	var e = m.data.enemies[selected]
	var v = app.modal("Guardian Trials")
	v.add_child(U.para("THE FINAL STAND",11,U.GOLD))
	v.add_child(U.para("%d / 3 trials conquered" % RealmTrials.cleared(m),24,U.TEXT))
	v.add_child(U.para("Clear a region's fifth tier to challenge its guardian at full strength. Each trial has two phases, a guaranteed first-clear reward and repeatable fragment drops.",14))
	var tabs = U.row(5)
	v.add_child(tabs)
	for id in RealmTrials.IDS:
		var button = U.button({"trial_wilds":"Thorn","trial_marsh":"Hymn","trial_crown":"Crown"}[id],func(): show_trial(id),selected==id)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabs.add_child(button)
	var hero = U.card(v,16,U.GOLD.darkened(.5))
	hero.add_child(U.para(m.local_name(e),25,U.TEXT))
	var row = U.row(14)
	hero.add_child(row)
	row.add_child(U.enemy_portrait(e,Vector2(100,158)))
	var title = U.column(8)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	title.add_child(U.para(RealmChronicle.REGIONS[e.region].name,12,U.GOLD))
	title.add_child(U.para("%d HP · %d ATK · %d DEF" % [int(e.hp),int(e.attack),int(e.armor)],12))
	hero.add_child(U.para(RealmTrials.STORIES[e.region],14))
	var phase = U.card(v,12)
	phase.add_child(U.label("I · HOLD YOUR GROUND",11,U.GOLD))
	phase.add_child(U.para(RealmCombat.mechanic(e),14,U.TEXT))
	phase.add_child(U.label("II · THE GUARDIAN AWAKENS",11,U.RED))
	phase.add_child(U.para(RealmTrials.phase_text(e),14,U.TEXT))
	phase.add_child(U.para("Once awakened, the guardian stays in phase II until the fight ends, even if it heals above half health.",12))
	v.add_child(U.para(RealmTrials.advice(e.region),14,U.GREEN))
	var earned = int(m.s.kills.get(selected,0))>0
	var prize = U.card(v,12)
	prize.add_child(U.label("FIRST CLEAR · CLAIMED" if earned else "FIRST CLEAR · GUARANTEED",11,U.GOLD))
	var gear = U.row(12)
	prize.add_child(gear)
	gear.add_child(U.icon(e.trial_reward,48))
	gear.add_child(U.para("Epic "+m.name_of(e.trial_reward),19,U.TEXT))
	prize.add_child(U.para("120 bonus fragments · 15 metal scraps\n20 grilled minnows",14))
	prize.add_child(U.para("Already received. Future victories grant the repeat rewards below." if earned else "Granted automatically on your first victory. Find the equipment in Bag and review your rewards in Hunt reports.",12))
	var relic = RealmChronicle.RELICS[RealmChronicle.fragments_for(e)].name
	v.add_child(U.para("EVERY VICTORY\n%d %s fragments · %d gold · %d melee XP\n%s ×%d" % [int(e.fragments),relic,int(e.gold),int(e.xp),m.name_of(e.drop),int(e.qty)],14,U.GREEN))
	var estimate = RealmCombat.forecast(m,selected)
	v.add_child(U.para("YOUR CURRENT BUILD · "+estimate.rating.to_upper(),11,U.GOLD))
	v.add_child(U.para("Strongest special hit: %d damage before food. %s" % [int(estimate.burst),"The guardian may heal faster than you can hurt it." if estimate.stalled else "Estimated fight: %ds · about %d meals." % [int(estimate.seconds),int(estimate.meals)]],14,U.TEXT))
	v.add_child(U.para("Estimates assume phase II throughout and exclude first-clear bonuses. Misses, critical hits and supplies change the result. Try one fight before queuing a long hunt.",12))
	v.add_child(U.button("Choose a complete loadout",app.loadouts_dialog))
	v.add_child(U.button("Refine equipment at the workshop",app.workshop_dialog))
	v.add_child(U.button("Review recent hunt results",app.hunt_reports_dialog))
	var reason = m.available(selected)
	if reason!="":
		app.dialog_footer.add_child(U.para(reason,12,U.GOLD))
		app.modal_action("Return to the world map",app.world_dialog)
	else:
		app.modal_action("Prepare one trial",func(): app.activity_dialog("hunt_"+selected,1))
