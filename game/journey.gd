class_name RealmJourney
extends RefCounted

static func steps(m) -> Array:
	var weapon = m.gear(str(m.s.equipped.get("weapon","")))
	var equipped = not weapon.is_empty() and weapon.id in ["copper_sword","iron_sword"]
	return [
		entry("ore","Gather 4 copper ore","Ore is the raw material for your first real weapon. Your stone pick is already equipped.","mine_copper",int(m.s.gains.get("copper_ore",0)),4,"Mine copper ore","Mining → Copper ore"),
		entry("ingots","Smelt 2 copper ingots","Each ingot uses 2 copper ore. Smelting turns the 4 ore you gathered into 2 ingots.","craft_copper_ingot",int(m.s.gains.get("copper_ingot",0)),2,"Smelt copper ingots","Smithing → Copper ingot"),
		entry("wood","Gather 1 ash log","A sword needs a wooden grip. Your wood axe is already equipped.","cut_ash",int(m.s.gains.get("ash_log",0)),1,"Cut an ash log","Woodcutting → Ash log"),
		entry("sword","Forge your copper sword","Use 2 copper ingots and 1 ash log. Crafting puts the weapon in your Bag; it does not equip it.","craft_copper_sword",int(m.s.gains.get("copper_sword",0)),1,"Forge a copper sword","Smithing → Copper Sword"),
		entry("equip","Equip your new sword","Open the sword in your Bag and choose Equip item. Green numbers show an improvement over your current gear.","",1 if equipped or m.s.tutorial else 0,1,"Open your copper sword","Bag → Copper Sword → Equip item","equip"),
		entry("rats","Defeat 3 Ash Rats","Attacks happen automatically. Your 5 starting grilled minnows restore 20 HP each when health falls to 50%. Each victory gives coins, XP and loot.","hunt_ash_rat",int(m.s.kills.get("ash_rat",0)),3,"Hunt 3 Ash Rats","Explore → Ash Rat"),
		entry("thralls","Defeat 5 Grave Thralls","First Supplies unlocks the graveyard and grants 30 Silver plus 10 grilled minnows. Craft copper armor and cook meat from rats if you need more protection or food.","hunt_grave_thrall",int(m.s.kills.get("grave_thrall",0)),5,"Hunt Grave Thralls","Explore → Grave Thrall"),
		entry("bandits","Defeat 5 Cinder Bandits","The path opens when 5 Grave Thralls fall. Bandits drop copper ore for more equipment. Keep your auto-heal food stocked.","hunt_cinder_bandit",int(m.s.kills.get("cinder_bandit",0)),5,"Hunt Cinder Bandits","Explore → Cinder Bandit"),
		entry("guards","Defeat 5 Chapel Guards","Guards have more armor. Improve your sword and fill empty armor slots in the Bag before a long hunt.","hunt_chapel_guard",int(m.s.kills.get("chapel_guard",0)),5,"Hunt Chapel Guards","Explore → Chapel Guard"),
		entry("wraiths","Defeat 5 Ember Wraiths","Wraiths strike quickly. Bring cooked food and consider a healing draught. You can Retreat at any time to stop combat.","hunt_ember_wraith",int(m.s.kills.get("ember_wraith",0)),5,"Hunt Ember Wraiths","Explore → Ember Wraith"),
		entry("smith","Reach Smithing level 10","Smelting and forging both give Smithing XP. Gather copper ore, smelt ingots and craft armor. Level 10 unlocks iron recipes and the final approach.","craft_copper_ingot",m.level("smithing"),10,"Train Smithing","Skills → Smithing","level"),
		entry("boss","Silence the Bellkeeper","The third strike deals 1.8× damage. Equip your strongest armor and weapon, select food and stock healing draughts. Victory rekindles Cinderwatch's beacon.","hunt_bellkeeper",1 if m.s.beacon else 0,1,"Prepare for the Bellkeeper","Explore → The Bellkeeper","boss")
	]

static func entry(key, title, detail, activity, current, goal, action, route, kind="activity") -> Dictionary:
	return {"key":key,"title":title,"detail":detail,"activity":activity,"current":current,"goal":goal,"action":action,"route":route,"kind":kind}

static func smithing_batch(m) -> int:
	var remaining = maxi(0,25*9*9-int(m.s.xp.smithing))
	return ceili(float(remaining)/float(m.data.activities.craft_copper_ingot.xp))

static func current(m) -> Dictionary:
	var all = steps(m)
	for i in range(all.size()):
		var step = all[i]
		if step.current<step.goal:
			step.index = i+1
			step.total = all.size()
			return step
	var expedition = RealmChronicle.next_expedition(m)
	if expedition!="":
		var enemy = m.data.enemies[expedition]
		var region_index = RealmChronicle.REGIONS.keys().find(enemy.region)
		return {"key":expedition,"title":"Clear "+m.local_name(enemy),"detail":"Win once to unlock the next tier. If the fight is too costly, farm a cleared tier and upgrade your gear, relic or rune. Each victory gives %d %s fragments." % [int(enemy.fragments),RealmChronicle.RELICS[enemy.relic].name],"activity":"hunt_"+expedition,"current":0,"goal":1,"action":"Prepare expedition","route":RealmChronicle.REGIONS[enemy.region].name+" → Tier "+str(int(enemy.tier)),"kind":"expedition","index":12+region_index*5+int(enemy.tier),"total":27}
	for trial_id in RealmTrials.IDS:
		if int(m.s.kills.get(trial_id,0))==0:
			var trial_enemy = m.data.enemies[trial_id]
			return {"key":trial_id,"title":"Conquer "+m.local_name(trial_enemy),"detail":"This optional boss gains stronger attacks at half health. Check its mechanics, equip your build and bring cooked food. Win once for Epic equipment and 120 bonus fragments.","activity":"hunt_"+trial_id,"current":0,"goal":1,"action":"Prepare guardian trial","route":"World map → Guardian trials","kind":"expedition","index":28+RealmTrials.IDS.find(trial_id),"total":30}
	var apex_index = 30
	for id in m.data.enemies:
		var enemy = m.data.enemies[id]
		if not enemy.get("apex",false): continue
		apex_index += 1
		if int(m.s.kills.get(id,0))==0:
			return {"key":id,"title":"Defeat "+m.local_name(enemy),"detail":"Use Ascension paths to craft stronger equipment, then prepare food and review this hunt. "+RealmCombat.mechanic(enemy),"activity":"hunt_"+id,"current":0,"goal":1,"action":"Prepare Apex hunt","route":"Explore → Ascension → Apex hunts","kind":"expedition","index":apex_index,"total":39}
	var late_index = 39
	for id in RealmEndgame.IDS:
		late_index += 1
		if int(m.s.kills.get(id,0))==0:
			return {"key":id,"title":"Defeat "+m.local_name(m.data.enemies[id]),"detail":"An optional guardian stands beyond the Apex routes. Prepare a specialized build; its core opens unique crafting options.","activity":"hunt_"+id,"current":0,"goal":1,"action":"Prepare guardian hunt","route":"Beyond the beacon → Optional guardians","kind":"expedition","index":late_index,"total":64}
	for region in range(3):
		for n in range(6):
			late_index += 1
			var id = "frontier_%d_%d" % [region,n]
			if int(m.s.kills.get(id,0))==0:
				return {"key":id,"title":"Defeat "+m.local_name(m.data.enemies[id]),"detail":"Improve your equipment, counter this enemy's debuff and stock cooked food. Clear each pair of encounters to claim a frontier objective reward.","activity":"hunt_"+id,"current":0,"goal":1,"action":"Prepare frontier hunt","route":RealmFrontiers.REGIONS[region],"kind":"expedition","index":late_index,"total":64}
	return {"key":"complete","title":"All charted hunts cleared","detail":"Claim remaining frontier rewards, complete your masterworks and card builds, or push deeper into the Hollow Depths.","activity":"","current":1,"goal":1,"action":"Open world map","route":"All routes cleared","kind":"complete","index":64,"total":64}
