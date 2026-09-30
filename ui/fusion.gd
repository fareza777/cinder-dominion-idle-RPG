extends RefCounted
const U=preload("res://ui/style.gd")
var app
var m
func _init(owner):app=owner;m=app.model
func hub(page: int = 0):
	var v=app.modal("The forge")
	U.scenic(v,preload("res://ui/world.gd").art(1),"21 RARITIES","Shape your next upgrade",100)
	v.add_child(U.button("Refine equipment",func():preload("res://ui/armory.gd").new(app).workshop()))
	v.add_child(U.para("Fuse spare copies and Forge Seals to raise a piece's rarity. Choose the piece you want to keep.",14))
	var gear=m.s.gear.filter(func(g):return RealmFusion.eligible(m,g))
	gear.sort_custom(func(a,b):
		if (a.uid==m.s.equipped.get("weapon",""))!=(b.uid==m.s.equipped.get("weapon","")):return a.uid==m.s.equipped.get("weapon","")
		if m.s.equipped.values().has(a.uid)!=m.s.equipped.values().has(b.uid):return m.s.equipped.values().has(a.uid)
		return m.name_of(a.id)<m.name_of(b.id))
	if gear.is_empty():v.add_child(U.para("Craft or find equipment to begin forging.",16));return
	page=clampi(page,0,maxi(0,ceili(gear.size()/8.0)-1))
	for g in gear.slice(page*8,(page+1)*8):
		var uid=str(g.uid)
		v.add_child(U.button("%s · %s%s" % [m.name_of(g.id),m.data.rarities[g.q]," · Equipped" if m.s.equipped.values().has(uid) else ""],func():open(uid)))
	if page>0:v.add_child(U.button("Previous pieces",func():hub(page-1)))
	if (page+1)*8<gear.size():v.add_child(U.button("More pieces",func():hub(page+1)))

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
