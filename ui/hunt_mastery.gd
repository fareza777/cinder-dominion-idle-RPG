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
	app.dynamic(v,func():
		var total = 0
		for id in m.data.enemies: total += H.rank(m,id)
		return "%d / %d ranks earned" % [total,m.data.enemies.size()*4],20,U.GOLD)
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
		var card = U.card(v,14)
		var row = U.row(10)
		card.add_child(row)
		row.add_child(U.enemy_portrait(enemy,Vector2(56,72)))
		var words = U.column(4)
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(words)
		words.add_child(U.para(m.local_name(enemy),19,U.TEXT))
		app.dynamic(words,func(): return "%s · %d wins" % [H.NAMES[H.rank(m,id)],int(m.s.kills.get(id,0))],13,U.GOLD)
		live_progress(card,id)
		card.add_child(U.button("View bonuses",func(): detail(id)))

func detail(id: String):
	var enemy = m.data.enemies[id]
	var v = app.modal(m.local_name(enemy)+" mastery")
	var row = U.row(16)
	v.add_child(row)
	row.add_child(U.enemy_portrait(enemy,Vector2(76,104)))
	var words = U.column(6)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(words)
	app.dynamic(words,func(): return H.NAMES[H.rank(m,id)],24,U.GOLD)
	app.dynamic(words,func(): return "%d wins · rank %d / 4" % [int(m.s.kills.get(id,0)),H.rank(m,id)],15)
	live_progress(v,id)
	app.dynamic(v,func(): return "Against this enemy: +%d ATK" % H.rank(m,id),17,U.TEXT)
	app.dynamic(v,func(): return "Per win: %d gold · %s" % [H.gold(m,enemy),fragments(H.fragments(m,enemy))],15,U.GREEN)
	for i in range(4):
		var rank_number = i+1
		var card = U.card(v,12,U.LINE)
		app.dynamic(card,func(): return "%s · %d wins%s" % [H.NAMES[rank_number],H.TARGETS[rank_number-1]," · ✓" if H.rank(m,id)>=rank_number else ""],17,U.TEXT)
		card.add_child(U.para("+%d ATK · +%d gold · +%s / win" % [rank_number,rank_number,fragments(int(rank_number/2))],13,U.GOLD))
	v.add_child(U.para("Bonuses are cumulative totals. New rates start on the next fight.",12))
	v.add_child(U.button("All hunt mastery",open))
	app.dynamic(v,func(): return m.available(id),14,U.GOLD)
	var action = app.modal_action("Hunt",func(): app.activity_dialog("hunt_"+id,batch_size(id)))
	watch(func():
		if not is_instance_valid(action): return
		var count = batch_size(id)
		action.text = "Hunt · %d %s" % [count,"fight" if count==1 else "fights"]
		action.disabled = m.available(id)!="")

func batch_size(id: String) -> int:
	var r = H.rank(m,id)
	return mini(100,H.TARGETS[r]-int(m.s.kills.get(id,0))) if r<4 else 25

func fragments(count: int) -> String:
	return "%d %s" % [count,"fragment" if count==1 else "fragments"]

func watch(callback: Callable):
	app.dialog_callbacks.append(callback)
	callback.call()

func live_progress(parent: Node,id: String):
	var bar = U.progress(0,1,U.GOLD,6)
	parent.add_child(bar)
	app.dynamic(parent,func():
		var r = H.rank(m,id)
		if r==4: return "All ranks earned"
		var left = H.TARGETS[r]-int(m.s.kills.get(id,0))
		return "%d %s to %s" % [left,"win" if left==1 else "wins",H.NAMES[r+1]],13)
	watch(func():
		if not is_instance_valid(bar): return
		var r = H.rank(m,id)
		bar.max_value = H.TARGETS[r] if r<4 else H.TARGETS[3]
		bar.value = mini(int(m.s.kills.get(id,0)),int(bar.max_value)))
