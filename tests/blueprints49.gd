extends SceneTree
func _init():
 var m=preload("res://tests/balance43.gd").build("warden",false)
 for id in m.data.enemies: m.s.kills[id]=1
 var gear=RealmLegacyFinds.GEAR[0]
 var recipe=m.data.activities["craft_"+gear]
 for id in recipe.inputs: m.gain(id,recipe.inputs[id])
 assert(not RealmBlueprints.learned(m,gear))
 assert(m.requirement(recipe.id).contains("blueprint"))
 assert(RealmProgression.plan(m,recipe.id,1).error.contains("blueprint"))
 assert(not m.command({"type":"upgrade_goal","id":gear}))
 var random=RandomNumberGenerator.new()
 random.seed=849
 var state=random.state
 for i in range(1000000):
  state=random.state
  if random.randf()<RealmBlueprints.DROP_CHANCE: break
 m.s.blueprint_rng=str(state)
 assert(RealmBlueprints.drop(m,"ash_rat")=="")
 assert(RealmBlueprints.drop(m,recipe.blueprint)==RealmBlueprints.item(gear))
 assert(RealmBlueprints.learned(m,gear))
 assert(RealmBlueprints.drop(m,recipe.blueprint)=="")
 assert(m.requirement(recipe.id)=="")
 var save=RealmSave.new()
 assert(save.valid(m.s,m.data))
 var decoded=save.decode(save.encode(m.s),m.data)
 assert(not decoded.is_empty())
 var old=preload("res://tests/balance43.gd").build("warden",true)
 for id in RealmLegacyFinds.GEAR: assert(RealmBlueprints.learned(old,id))
 var found=false
 for i in range(2000):
  var stock=RealmMerchant.sync(m,(i+1)*RealmMerchant.INTERVAL)
  assert(RealmMerchant.valid(stock))
  for index in range(stock.offers.size()):
   var offer=stock.offers[index]
   if not str(offer.id).begins_with("blueprint_"): continue
   assert(RealmMerchant.sync(m,stock.seen-1).revision==stock.revision)
   m.s.gold=0
   var cmd={"revision":stock.revision,"index":index,"now":stock.seen}
   assert(RealmMerchant.buy(m,cmd)!="")
   m.s.gold=offer.price
   assert(RealmMerchant.buy(m,cmd)=="")
   assert(m.s.gold==0)
   assert(RealmBlueprints.learned(m,str(offer.id).trim_prefix("blueprint_")))
   assert(RealmMerchant.buy(m,cmd)!="")
   assert(save.valid(m.s,m.data))
   found=true
   break
  if found:break
 assert(found)
 print("PASS: hidden crafting, deterministic rare discovery, duplicate prevention, legacy ownership, save round trip, merchant rarity/purchase/stock stability")
 quit()
