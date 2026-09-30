extends SceneTree
var failures=0
func check(ok: bool,label: String):
	print("PASS " if ok else "FAIL ",label)
	if not ok:failures+=1
func _init():
	var m=RealmModel.new();var save=RealmSave.new()
	check(m.data.enemies.size()==190 and m.data.skills.size()==16 and m.data.rarities.size()==21 and m.data.items.size()==946,"catalog totals")
	var refs=true
	for a in m.data.activities.values():
		refs=refs and m.data.items.has(a.output) and m.data.skills.has(a.skill)
		for input in a.inputs:refs=refs and m.data.items.has(input)
	for id in m.data.enemies:
		refs=refs and RealmCards.definitions().has("card_"+id) and not preload("res://ui/enemy_actor.gd").definition(id).is_empty()
	check(refs,"all activity, card and actor references resolve")
	check(RealmEconomy.level(RealmEconomy.threshold(130))==130 and RealmEconomy.level(RealmEconomy.threshold(101)-1)==100 and RealmEconomy.threshold(100,"mining")==245025,"level 130 cap with unchanged early thresholds")
	var legacy=m.s.duplicate(true);legacy.erase("world_revision")
	for skill in RealmWorld.PROFESSIONS:legacy.xp.erase(skill)
	var migrated=save.decode(save.encode(legacy),m.data)
	check(not migrated.is_empty() and migrated.xp.runecarving==0 and migrated.gold==legacy.gold and migrated.gear==JSON.parse_string(JSON.stringify(legacy.gear)),"old saves gain new professions without losing equipment or money")
	var corrupt=m.s.duplicate(true);corrupt.xp.erase("runecarving")
	check(save.decode(save.encode(corrupt),m.data).is_empty(),"modern missing-skill state rejected")
	check(m.available("realm_0_0")!="" and RealmWorld.encounters(m,"realm_0").size()==10 and "ash_rat" not in RealmWorld.encounters(m,"realm_0"),"location isolation and entry gate")
	m.s.kills.march_5_8=1
	m.s.xp.bladecraft=RealmEconomy.threshold(100)
	check(m.available("realm_0_0")=="" and m.available("realm_0_1")!="","encounters unlock in order")
	for skill in RealmWorld.PROFESSIONS:
		var aid=m.data.activities.keys().filter(func(id):return m.data.activities[id].skill==skill)[0]
		var a=m.data.activities[aid];var one=RealmModel.new()
		for input in a.inputs:one.gain(input,20)
		var two=RealmModel.new();two.s=one.s.duplicate(true)
		one.command({"type":"queue","id":aid,"target":3});two.command({"type":"queue","id":aid,"target":3})
		one.advance(120000)
		for i in range(120):two.advance(1000)
		check(one.count(a.output)>=3 and one.s.xp[skill]>0 and save.decode(save.encode(one.s),one.data)==save.decode(save.encode(two.s),two.data),skill+" produces real materials and offline parity")
	m=preload("res://tests/overhaul51.gd").prepared()
	m.s.gold=100000000000
	for skill in m.data.skills:m.s.xp[skill]=RealmEconomy.threshold(130,skill)
	m.command({"type":"artisan_select","id":"artisan_hammer_4"})
	var uid=m.add_gear("copper_sword",1,true);m.gear(uid).affixes=[]
	m.command({"type":"equip","id":uid})
	m.s.card_sockets={uid:"card_march_5_8"}
	m.s.gear_attunements={uid:"burn"}
	var protected_uid=m.add_gear("copper_sword",1,true);m.gear(protected_uid).locked=true
	var before=m.s.duplicate(true)
	check(not m.command({"type":"rarity_fuse","uid":uid}) and m.gear(protected_uid).count==1 and m.gear(uid).q==1,"protected donors never consumed on blocked fusion")
	for q in range(1,20):
		var c=RealmFusion.cost(m.gear(uid))
		var donor=m.add_gear("copper_sword",c.donor_quality,true);m.gear(donor).count=c.duplicates
		m.gain(c.seal,c.seals)
		if c.gate!="":m.s.kills[c.gate]=1
		check(m.command({"type":"rarity_fuse","uid":uid}) and m.gear(uid).q==q+1,"fusion to "+m.data.rarities[q+1])
	check(m.s.equipped.weapon==uid and m.s.card_sockets[uid]=="card_march_5_8" and m.s.gear_attunements[uid]=="burn" and not save.decode(save.encode(m.s),m.data).is_empty(),"final rarity saves with sockets, attunement and equipped UID intact")
	check(not m.command({"type":"rarity_fuse","uid":uid}),"final tier rejects further fusion")
	check(RealmMerchant.sell_price(m,m.gear(uid))>0,"high rarity merchant quote")
	check(RealmLegacyGrowth.earned(m.s)==100,"endgame talent budget reaches 100 points")
	var late=RealmModel.new();late.s.xp.mining=RealmEconomy.threshold(125,"mining")
	check(late.command({"type":"queue","id":"work_ore_6","target":130,"kind":"level"}) and late.s.queue[0].target==130,"level-target queues accept 130")
	late.advance(60000)
	check(late.count("ore_6")>0 and not save.decode(save.encode(late.s),late.data).is_empty(),"post-100 activity runs and saves")
	print("EXPANSION52 ","PASS" if failures==0 else "FAIL", " failures=",failures)
	quit(0 if failures==0 else 1)

