extends SceneTree
const Audit = preload("res://tests/balance34.gd")

static func build(character: String, masterwork: bool):
	var m = Audit.build(character,"max")
	for skill in m.s.xp: m.s.xp[skill]=RealmEconomy.threshold(100,skill)
	var c=RealmChronicle.state(m)
	c.talents={"power":5,"guard":5,"fortune":0,"technique":10,"hunter":10,"endurance":10,"recovery":10,"resolve":10,"bounty":0}
	c.relics={"fang":40,"ward":40,"heart":40}
	for id in ["dawnsteel_necklace","dawnsteel_belt","dawnsteel_ring","dawnsteel_ring"]:
		var uid=m.add_gear(id,5);m.command({"type":"equip","id":uid})
	if masterwork:
		for id in RealmLegacyFinds.GEAR:
			var uid=m.add_gear(id,5)
			var slot="ring_left" if id=="heirloom_ember_ring" else ("ring_right" if id=="heirloom_glass_ring" else m.data.items[id].slot)
			m.command({"type":"equip","id":uid,"slot":slot})
		var _legacy_cards=["card_chapel_guard","card_grave_thrall","card_bellkeeper","card_wilds_4","card_wilds_5","card_trial_marsh","card_trial_crown","card_apex_crown_2","card_apex_crown_1","card_apex_marsh_2"]
		var index=0
		for slot in m.s.equipped:
			if slot in ["axe","pick","rod"]:continue
			var family=m.data.items[m.gear(m.s.equipped[slot]).id].slot
			var choices=RealmCards.definitions().keys().filter(func(id):return RealmCards.allowed(id,family) and id not in RealmCards.active(m))
			if not choices.is_empty():
				m.gain(choices[0],1)
				assert(m.command({"type":"card_insert","uid":m.s.equipped[slot],"id":choices[0]}))
			index+=1
	return m

func _init():
	var results=[]
	for character in RealmCharacters.ALL:
		for masterwork in [false,true]:
			for enemy in ["frontier_0_0","frontier_1_5","frontier_2_5"]:
				var m=build(character,masterwork)
				var result=Audit.fight(m,enemy)
				result.merge({"class":character,"masterwork":masterwork,"enemy":enemy})
				results.append(result)
	var file=FileAccess.open("res://build/balance43.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(results,"\t"))
	print("BALANCE43 ",results.size()," encounters; ",results.filter(func(r):return r.get("win",false)).size()," wins")
	quit()
