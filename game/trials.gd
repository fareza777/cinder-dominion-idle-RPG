class_name RealmTrials
extends RefCounted

const IDS = ["trial_wilds","trial_marsh","trial_crown"]
const STORIES = {
	"wilds":"The road has opened, yet the watchman will not leave his post. Beneath his broken armor, a second heart takes root.",
	"marsh":"You have crossed the drowned cloisters. Now the oracle asks for one final audience, beneath the water where her hymn began.",
	"crown":"The outer bells are silent. At the throne, the keeper raises the last hammer. For the first time, the keeper looks down from his throne."}

static func second_phase(enemy: Dictionary, hp: int) -> bool:
	return (bool(enemy.get("trial",false)) or enemy.get("secret",false) or enemy.get("depth",false)) and hp*2<=int(enemy.hp)

static func active_phase(m, enemy: Dictionary) -> bool:
	return not m.s.fight.is_empty() and m.s.fight.enemy==enemy.id and int(m.s.fight.get("phase",1))==2

static func phase_text(enemy: Dictionary) -> String:
	match enemy.get("region",""):
		"wilds": return "Below half health, Bramble crush ignores 75% of your armor instead of 50%. A shorter second phase means fewer crushing hits."
		"marsh": return "Below half health, Drowned hymn restores 8% of maximum health instead of 5%. Stillwater weakens both versions of the hymn."
	return "Below half health, Final toll rises from 2.2× to 2.8× attack damage before armor. Bring strong food and raise your healing threshold."

static func advice(region: String) -> String:
	match region:
		"wilds": return "Try Vanguard with Ashfang for a shorter fight, or Warden when supplies are tight. Thornscript helps your fourth strike against its armor."
		"marsh": return "Stillwater is a direct counter to recovery. Combine it with enough weapon damage; armor alone cannot end the hymn."
	return "A defensive loadout and stronger cooked food can soften the final toll. Dirge increases the damage you take as well as the damage you deal."

static func cleared(m) -> int:
	var count = 0
	for id in IDS:
		if int(m.s.kills.get(id,0))>0: count += 1
	return count
