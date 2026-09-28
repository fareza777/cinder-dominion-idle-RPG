class_name RealmStory
extends RefCounted

const CHAPTERS = [
	{"title":"A place by the fire","gate":"Available from the start","art":0,"body":"The gate opens just wide enough to let you through. Inside, a blacksmith is sorting bent nails beside a cold anvil.\n\n\"There is food if you work,\" she says. \"Start with a blade. We need the road cleared.\"","next":"Follow the first six Journey steps to forge a sword and defeat three Ash Rats."},
	{"title":"The forge is working","gate":"Complete First Supplies","art":0,"body":"The blacksmith checks the edge of your sword, then hands it back. Outside, someone has started repairing the gate.\n\n\"That will hold,\" she says. \"Bring back what you can. We can make use of it.\"","next":"Talents and relics are available. Prepare armor and food, then follow the route toward the Bellkeeper."},
	{"title":"Beyond the beacon","gate":"Defeat the Bellkeeper","art":1,"body":"The bell stops. For a moment, all you hear is the wind through the tower. Then a light appears on the road below. Another answers it.\n\nBy morning, travelers are arriving at Cinderwatch. They bring news of three roads that are open again.","next":"The World map now offers three regions. Clear each tier once to unlock the next; repeat hunts to collect relic fragments."},
	{"title":"The watch is over","gate":"Clear Ashen Wilds tier 5","art":1,"body":"The sentinel steps aside. Behind him, roots have split the stones of an old supply road. Wheel tracks are still visible beneath the moss.\n\nYou mark the way back to Cinderwatch. The next travelers will not have to fight for every mile.","next":"The Thornbound Vigil is available in Guardian Trials. Its first clear gives Epic Iron Gauntlets and bonus fragments."},
	{"title":"A voice beneath the water","gate":"Clear Drowned Sanctum tier 5","art":1,"body":"The oracle falls silent. In the empty cloister, her last words sound less like a warning than a request.\n\nYou leave a light on the steps above the water. By the time you reach the bridge, you can no longer hear the hymn.","next":"The Unbroken Hymn is available in Guardian Trials. Use enough damage to overcome healing; Stillwater can help."},
	{"title":"The last bell","gate":"Clear Obsidian Crown tier 5","art":2,"body":"The keeper's hammer strikes the floor. Dust falls from the arch above his throne. Beyond it, daylight reaches the lower steps for the first time in years.\n\nYou set down your weapon and listen. No other bell answers.","next":"Crown at Sundown is available in Guardian Trials. Prepare for stronger special attacks in its second phase."},
	{"title":"The roads remain open","gate":"Complete all three Guardian Trials","art":2,"body":"A wagon reaches Cinderwatch before sunset. It carries grain, tools, and a family who thought the refuge was only a rumor.\n\nAt the forge, the blacksmith makes room for another apprentice. Tomorrow there will be more work. Tonight, everyone eats.","next":"The first journey is complete. Pursue Apex hunts and the seven optional guardians; the Sovereign guards the road to new regions."}
,
	{"title":"A road beyond the stars","gate":"Defeat the Unlit Sovereign","art":2,"frontier_tile":5,"body":"Beyond the fallen throne, an old stair climbs toward the observatory. Its lamps are still burning. Someone has kept the road open.","next":"Open Beyond the Sovereign in Explore. Clear the Pale Observatory's six encounters and claim its three objective rewards."},
	{"title":"The city beneath the stones","gate":"Defeat the Eclipse Regent","art":1,"frontier_tile":11,"body":"The observatory's lens turns toward a city buried under iron. Chains move below its gates. The path leads down.","next":"Enter the Iron Sepulcher. Counter its debuffs and collect materials for the next masterworks."},
	{"title":"Where the fire began","gate":"Defeat the Burial King","art":2,"frontier_tile":17,"body":"The last chain breaks. Heat rises through the empty throne room, revealing a passage into the Ember Rift.","next":"Prepare for the Ember Rift's six encounters. The First Ember waits at the end of the road."},
	{"title":"A light worth keeping","gate":"Defeat the First Ember","art":0,"frontier_tile":17,"body":"The fire settles into a small, steady light. You carry it back along the roads you opened. Cinderwatch will have another dawn.","next":"Claim your frontier rewards. Complete masterworks, seek rare cards or test your build deeper in the Hollow Depths."}
]

static func unlocked(m, index: int) -> bool:
	match index:
		0: return true
		1: return bool(m.s.tutorial)
		2: return bool(m.s.beacon)
		3: return int(m.s.kills.get("wilds_5",0))>0
		4: return int(m.s.kills.get("marsh_5",0))>0
		5: return int(m.s.kills.get("crown_5",0))>0
		6: return RealmTrials.cleared(m)==3
		7: return int(m.s.kills.get("secret_6",0))>0
		8: return int(m.s.kills.get("frontier_0_5",0))>0
		9: return int(m.s.kills.get("frontier_1_5",0))>0
		10: return int(m.s.kills.get("frontier_2_5",0))>0
	return false

static func count(m) -> int:
	var total = 0
	for i in range(CHAPTERS.size()):
		if unlocked(m,i): total += 1
	return total

static func unlocks(m, skill: String, from_level: int, to_level: int) -> Array:
	var names = []
	for activity in m.data.activities.values():
		if not RealmBlueprints.learned(m,activity.output): continue
		if activity.kind!="combat" and activity.skill==skill and int(activity.level)>from_level and int(activity.level)<=to_level:
			var title = m.name_of(activity.output)
			if title not in names: names.append(title)
	return names
