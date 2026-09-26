extends RefCounted

const U = preload("res://ui/style.gd")
const H = preload("res://game/hunt_mastery.gd")
var app
var m

func _init(owner):
	app = owner
	m = owner.model

func open(group: String = "open"):
	var v = app.modal("Hunt mastery")
	var total = 0
	for id in m.data.enemies: total += H.rank(m,id)
	v.add_child(U.para("%d / %d ranks earned" % [total,m.data.enemies.size()*4],20,U.GOLD))
	v.add_child(U.para("Bonuses apply only to that enemy. Past wins count.",13))
	var tabs = U.row(6)
	v.add_child(tabs)
	for choice in [["open","Available"],["all","All enemies"]]:
		tabs.add_child(U.button(choice[1],func(): open(choice[0]),choice[0]==group))
	var ids = m.data.enemies.keys()
	ids.sort_custom(func(a,b):
		var ra = H.rank(m,a)
		var rb = H.rank(m,b)
		var left_a = H.TARGETS[ra]-int(m.s.kills.get(a,0)) if ra<4 else 1000000
		var left_b = H.TARGETS[rb]-int(m.s.kills.get(b,0)) if rb<4 else 1000000
		return left_a<left_b)
	for id in ids:
		var enemy = m.data.enemies[id]
		if group=="open" and m.available(id)!="": continue
		var r = H.rank(m,id)
		var wins = int(m.s.kills.get(id,0))
		var card = U.card(v,14)
		var row = U.row(10)
		card.add_child(row)
		row.add_child(U.enemy_portrait(enemy,Vector2(56,72)))
		var words = U.column(4)
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(words)
		words.add_child(U.para(m.local_name(enemy),19,U.TEXT))
		words.add_child(U.para("%s · %d wins" % [H.NAMES[r],wins],13,U.GOLD))
		if r<4:
			card.add_child(U.progress(wins,H.TARGETS[r],U.GOLD,6))
			card.add_child(U.para("%d %s to %s" % [H.TARGETS[r]-wins,"win" if H.TARGETS[r]-wins==1 else "wins",H.NAMES[r+1]],13))
		card.add_child(U.button("View bonuses",func(): detail(id)))

func detail(id: String):
	var enemy = m.data.enemies[id]
	var r = H.rank(m,id)
	var wins = int(m.s.kills.get(id,0))
	var v = app.modal(m.local_name(enemy)+" mastery")
	var row = U.row(16)
	v.add_child(row)
	row.add_child(U.enemy_portrait(enemy,Vector2(76,104)))
	var words = U.column(6)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(words)
	words.add_child(U.para(H.NAMES[r],24,U.GOLD))
	words.add_child(U.para("%d wins · rank %d / 4" % [wins,r],15))
	v.add_child(U.para("Against this enemy: +%d ATK" % r,17,U.TEXT))
	v.add_child(U.para("Per win: %d gold · %d fragments" % [H.gold(m,enemy),H.fragments(m,enemy)],15,U.GREEN))
	for i in range(4):
		var rank_number = i+1
		var card = U.card(v,12,U.GOLD.darkened(.5) if r>=rank_number else U.LINE)
		card.add_child(U.para("%s · %d wins%s" % [H.NAMES[rank_number],H.TARGETS[i]," · ✓" if r>=rank_number else ""],17,U.TEXT))
		card.add_child(U.para("+%d ATK · +%d gold · +%d fragments / win" % [rank_number,rank_number,int(rank_number/2)],13,U.GOLD))
	v.add_child(U.para("Bonuses are cumulative totals. New rates start on the next fight.",12))
	v.add_child(U.button("All hunt mastery",open))
	var reason = m.available(id)
	if reason!="":
		v.add_child(U.para(reason,14,U.GOLD))
	else:
		var count = mini(100,H.TARGETS[r]-wins) if r<4 else 25
		var label = "Hunt · %d %s" % [count,"fight" if count==1 else "fights"]
		if r<4 and H.TARGETS[r]-wins>100: v.add_child(U.para("Next batch: 100 fights",13))
		app.modal_action(label,func(): app.activity_dialog("hunt_"+id,count))
