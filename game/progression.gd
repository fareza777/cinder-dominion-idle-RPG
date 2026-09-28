class_name RealmProgression
extends RefCounted

const STANCES = {
	"balanced":{"name":"Vanguard","detail":"Balanced offense. Every 4th attack deals double damage.","attack":1.0,"armor":0},
	"guard":{"name":"Warden","detail":"+4 armor, −15% attack. Every 4th attack restores 8 HP.","attack":0.85,"armor":4},
	"reaver":{"name":"Reaver","detail":"+25% attack, −3 armor. Every 4th attack deals 2.5× damage.","attack":1.25,"armor":-3}}
const UPGRADES = {
	"forge":{"name":"Ember Forge","detail":"Production takes 5% less time per rank.","gold":40,"scrap":2},
	"ward":{"name":"Gateward","detail":"Gain +1 armor per rank in every fighting style.","gold":50,"scrap":3},
	"hearth":{"name":"Resting Hearth","detail":"Recover +1 HP per second per rank outside combat.","gold":30,"scrap":1}}
const ORDERS = {
	"larder":{"name":"Stock the Larder","detail":"Return to a full pack of cooked fish, ready for a longer hunt.","recipes":[["craft_cooked_minnow",150]]},
	"forge":{"name":"Feed the Forge","detail":"Turn a steady supply of ore into ingots and Smithing experience.","recipes":[["craft_copper_ingot",500]]},
	"watch":{"name":"Before the Long Watch","detail":"Prepare food and copper ingots together. Spend your next visit improving gear and exploring.","recipes":[["craft_cooked_minnow",100],["craft_copper_ingot",250]]},
	"iron":{"name":"An Iron Foundation","detail":"Build a stock of iron ingots for stronger equipment. Requires Mining and Smithing level 10.","recipes":[["craft_iron_ingot",100]]}}

static func order_plan(m, id: String, batches: int) -> Dictionary:
	var result = {"steps":[],"stock":m.s.bag.duplicate(true),"error":"","seconds":0.0}
	var available_orders = orders(m)
	if not available_orders.has(id) or batches not in [1,2,4]:
		result.error = "Choose a work order and one, two or four batches."
		return result
	if not m.s.queue.is_empty():
		result.error = "Finish or clear your current queue before starting a work order."
		return result
	for recipe in available_orders[id].recipes: append_recipe(m,recipe[0],int(recipe[1])*batches,result,[])
	if result.steps.size()>20: result.error = "This order needs more than 20 queue slots. Choose fewer batches."
	return result

static func orders(m) -> Dictionary:
	var out = ORDERS.duplicate(true)
	out["selected_food"] = {"name":"Pack my selected food","detail":"Prepare the food you currently use for auto-heal.","recipes":[["craft_"+str(m.s.settings.food),100]]}
	for metal in ["steel","moonsteel","dusksteel","dawnsteel"]:
		var id = "craft_"+metal+"_ingot"
		out[metal] = {"name":m.name_of(metal+"_ingot")+" reserves","detail":"Gather ore and coal, then smelt 100 ingots for your next upgrades.","recipes":[[id,100]]}
	return out
const BASE_CONTRACTS = [
	{"id":"ore","title":"Fuel the Forge","detail":"Collect 20 copper ore.","source":"gains","key":"copper_ore","target":20,"gold":20,"food":3,"scrap":2,"activity":"mine_copper"},
	{"id":"ingots","title":"Apprentice Smith","detail":"Smelt 15 copper ingots.","source":"gains","key":"copper_ingot","target":15,"gold":30,"food":0,"scrap":3,"activity":"craft_copper_ingot"},
	{"id":"food","title":"A Warm Meal","detail":"Cook 15 grilled minnows.","source":"mastery","key":"craft_cooked_minnow","target":15,"gold":20,"food":5,"scrap":1,"activity":"craft_cooked_minnow"},
	{"id":"rats","title":"Clear the Cellars","detail":"Defeat 10 ash rats.","source":"kills","key":"ash_rat","target":10,"gold":25,"food":5,"scrap":2,"activity":"hunt_ash_rat"},
	{"id":"thralls","title":"Rest for the Restless","detail":"Defeat 10 grave thralls.","source":"kills","key":"grave_thrall","target":10,"gold":40,"food":5,"scrap":4,"activity":"hunt_grave_thrall"},
	{"id":"bandits","title":"Reclaim the Road","detail":"Defeat 15 cinder bandits.","source":"kills","key":"cinder_bandit","target":15,"gold":60,"food":8,"scrap":5,"activity":"hunt_cinder_bandit"},
	{"id":"wraiths","title":"Embers in the Mist","detail":"Defeat 15 ember wraiths.","source":"kills","key":"ember_wraith","target":15,"gold":80,"food":10,"scrap":6,"activity":"hunt_ember_wraith"},
	{"id":"bell","title":"The Last Toll","detail":"Defeat the Bellkeeper.","source":"kills","key":"bellkeeper","target":1,"gold":120,"food":15,"scrap":10,"activity":"hunt_bellkeeper"}]

const CONTRACTS = BASE_CONTRACTS + preload("res://game/ascension_contracts.gd").ALL

static func state(m) -> Dictionary:
	if not m.s.has("progression"):
		m.s.progression = {"stance":"balanced","claimed":[],"upgrades":{"forge":0,"ward":0,"hearth":0}}
	return m.s.progression

static func value(m, contract: Dictionary) -> int:
	return mini(int(contract.target),int(m.s[contract.source].get(contract.key,0)))

static func ready_count(m) -> int:
	var total = 0
	for c in CONTRACTS:
		if c.id not in state(m).claimed and value(m,c)>=c.target: total += 1
	return total

# Plan against a copy of stock. Dependencies reserve their inputs once, in order.
static func plan(m, activity: String, amount: int) -> Dictionary:
	var result = {"steps":[],"stock":m.s.bag.duplicate(true),"error":"","seconds":0.0}
	if not m.s.queue.is_empty():
		result.error = "Finish or clear the current queue before planning a complete supply chain."
	elif amount<1 or amount>100:
		result.error = "Choose between 1 and 100 items per plan."
	else: append_recipe(m,activity,amount,result,[])
	if result.steps.size()>20: result.error = "This plan exceeds 20 queue steps. Choose a smaller batch."
	return result

static func append_recipe(m, aid: String, amount: int, result: Dictionary, trail: Array):
	if result.error!="": return
	if aid in trail or not m.data.activities.has(aid):
		result.error = "This supply chain cannot be automated. Use Sources to gather the missing materials."
		return
	var a = m.data.activities[aid]
	if RealmBlueprints.reason(m,a)!="":
		result.error = RealmBlueprints.reason(m,a)
		return
	if a.kind=="combat" or m.level(a.skill)<int(a.level):
		result.error = "Unlock %s Lv.%d first." % [m.local_name(m.data.skills[a.skill]),int(a.level)]
		result.unlock_skill = a.skill
		result.unlock_level = int(a.level)
		return
	for id in a.inputs:
		var need = int(a.inputs[id])*amount
		var missing = maxi(0,need-int(result.stock.get(id,0)))
		if missing>0:
			var source = ""
			var locked_source = {}
			for candidate in m.sources(id):
				var recipe = m.data.activities[candidate]
				if recipe.kind!="combat" and recipe.output==id and m.level(recipe.skill)<int(recipe.level): locked_source = recipe
				if recipe.kind!="combat" and recipe.output==id and m.level(recipe.skill)>=int(recipe.level):
					source = candidate
					break
			if source=="":
				result.error = "Collect %d %s first (Sources or Merchant). Combat drops and merchant purchases need a separate step." % [missing,m.name_of(id)]
				if not locked_source.is_empty():
					result.error = "%s requires %s Lv.%d. Train this skill before planning this recipe." % [m.name_of(id),m.local_name(m.data.skills[locked_source.skill]),int(locked_source.level)]
					result.unlock_skill = locked_source.skill
					result.unlock_level = int(locked_source.level)
				return
			append_recipe(m,source,missing,result,trail+[aid])
			if result.error!="": return
		result.stock[id] = int(result.stock.get(id,0))-need
	result.stock[a.output] = int(result.stock.get(a.output,0))+amount
	result.steps.append({"id":aid,"target":amount,"kind":"cycles","done":0,"output":0,"skip":false})
	result.seconds += m.duration(a)*amount/1000.0
