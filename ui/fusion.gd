extends RefCounted
const U=preload("res://ui/style.gd")
var app
var m
func _init(owner):app=owner;m=app.model
func open(uid: String):
	var g=m.gear(uid)
	if not RealmFusion.eligible(m,g):return
	var v=app.modal("Rarity forge")
	U.scenic(v,preload("res://ui/world.gd").art(1),"21 RARITIES","The forge",100)
	var panel=U.card(v,14,U.GOLD)
	panel.add_child(U.icon(g.id,90))
	panel.add_child(U.para(m.name_of(g.id),23,U.TEXT))
	panel.add_child(U.para("Tier %d / 21 · %s" % [int(g.q)+1,m.data.rarities[g.q]],16,U.QUALITY[g.q]))
	if g.q==20:
		panel.add_child(U.para("Worldforged. The final rarity has been reached.",16));return
	var c=RealmFusion.cost(g)
	panel.add_child(U.para("Next: "+m.data.rarities[g.q+1],22,U.QUALITY[g.q+1]))
	panel.add_child(U.para("Equipment power ×%.2f → ×%.2f" % [RealmModel.QUALITY[g.q],RealmModel.QUALITY[g.q+1]],15))
	v.add_child(U.para("%s\n%s ×%d\n%d spare copies · %s or higher\nRunecarving Lv.%d" % [RealmEconomy.money(c.gold),m.name_of(c.seal),c.seals,c.duplicates,m.data.rarities[c.donor_quality],c.level],16))
	v.add_child(U.button("Make Forge Seals",func():app.dismiss();app.skill="runecarving";app.set_page("skills")))
	v.add_child(U.para("The selected piece keeps its cards, traits and saved builds. Equipped, locked and favorite donor items are never consumed. Fusion always succeeds.",13))
	var why=RealmFusion.reason(m,uid)
	if why!="":v.add_child(U.para(why,14,U.GOLD))
	var button=app.modal_action("Fuse into "+m.data.rarities[g.q+1],func():
		app.send({"type":"rarity_fuse","uid":uid});open(uid),true)
	button.disabled=why!=""
	var ladder=U.disclosure(v,"all 21 rarities")
	for i in range(m.data.rarities.size()):ladder.add_child(U.para("%02d  %s · ×%.2f" % [i+1,m.data.rarities[i],RealmModel.QUALITY[i]],15,U.QUALITY[i]))
