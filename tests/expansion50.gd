extends SceneTree
var failed=0
func check(ok,label):
 if not ok:failed+=1;push_error(label)
 else:print("PASS ",label)
func _init():
 var m=RealmModel.new();var save=RealmSave.new()
 check(m.data.enemies.size()==120 and m.data.items.size()==682 and RealmCards.definitions().size()==120,"catalog counts")
 check(RealmCharacters.ALL.size()==8 and RealmStory.CHAPTERS.size()==18 and RealmProgression.CONTRACTS.size()==60 and RealmLegacyFinds.GEAR.size()==24,"heroes story contracts masterworks")
 check(RealmChronicle.TALENTS.size()==18 and RealmRuneforge.RUNES.size()==12,"expanded build choices")
 var links=true
 for a in m.data.activities.values():
  links=links and m.data.items.has(a.output)
  for input in a.inputs:links=links and m.data.items.has(input)
 for id in m.data.enemies:
  var e=m.data.enemies[id]
  links=links and m.data.items.has(e.drop) and RealmCards.definitions().has("card_"+id)
 check(links,"all content references resolve")
 var sword=str(m.s.equipped.weapon);var shield=str(m.s.equipped.shield)
 m.gain("card_ash_rat",2)
 var snapshot=JSON.stringify(m.s)
 check(not m.command({"type":"card_insert","id":"card_ash_rat","uid":sword}) and JSON.stringify(m.s)==snapshot,"wrong-slot insertion cannot consume or mutate")
 check(m.command({"type":"card_insert","id":"card_ash_rat","uid":shield}),"rat fits shield")
 check(RealmCards.active(m)==["card_ash_rat"],"legal card is active")
 var legacy=m.s.duplicate(true);legacy.erase("card_slot_revision");legacy.card_sockets={sword:"card_ash_rat"}
 legacy.bag.card_ash_rat=0
 var decoded=save.decode(save.encode(legacy),m.data)
 check(not decoded.is_empty() and decoded.card_sockets.is_empty() and decoded.bag.card_ash_rat==1,"old wrong-slot card returned without extractor")
 check(save.decode(save.encode(decoded),m.data).bag.card_ash_rat==1,"migration is idempotent")
 var invalid=m.s.duplicate(true);invalid.card_sockets={sword:"card_ash_rat"}
 check(save.decode(save.encode(invalid),m.data).is_empty(),"new malformed incompatible socket rejected")
 var all_slots=true
 for card in RealmCards.definitions():
  var d=RealmCards.definitions()[card]
  all_slots=all_slots and d.slots.size()>0 and d.slots.size()<=3
  for slot in d.slots:all_slots=all_slots and slot in ["weapon","body","shield","head","hands","feet","necklace","belt","ring"]
 check(all_slots,"every card has explicit limited combat slots")
 var prepared=preload("res://tests/balance43.gd").build("warden",false)
 for id in prepared.data.enemies:prepared.s.kills[id]=1
 prepared.s.gold=10000000
 prepared.gain("research_secret_2",200)
 check(prepared.command({"type":"blueprint_research","id":"secret_2"}),"field research restores a hidden blueprint")
 check(RealmBlueprints.learned(prepared,"heirloom_blade") and prepared.count("research_secret_2")==0,"research spends notes and learns recipe")
 check(not prepared.command({"type":"blueprint_research","id":"secret_2"}),"research duplicate claim rejected")
 var weapon=prepared.add_gear("rime_sword",1)
 prepared.gain("depth_shard",100);prepared.gain("scrap",1000);prepared.gain("rime_ingot",100)
 check(prepared.command({"type":"gear_attune","uid":weapon,"id":"burn"}),"weapon attunement applies with cost")
 check(prepared.command({"type":"equip","id":weapon}),"attuned weapon equips")
 check("burn" in RealmMarches.effects(prepared),"attunement contributes to build")
 check(RealmWorkshop.command(prepared,weapon)=="","regional gear refines")
 var refined=prepared.last_forged
 check(prepared.s.gear_attunements.get(refined,"")=="burn" and prepared.s.equipped.weapon==refined,"refinement preserves effect and equipped reference")
 check(save.valid(prepared.s,prepared.data),"expanded state remains valid")
 check(prepared.command({"type":"march_claim","region":0}) and not prepared.command({"type":"march_claim","region":0}),"regional reward exactly once")
 for id in RealmRuneforge.RUNES:RealmRuneforge.state(prepared).ranks[id]=3
 RealmRuneforge.state(prepared).equipped="rime"
 check(prepared.command({"type":"loadout_save","id":"journey"}) and prepared.command({"type":"loadout_load","id":"journey"}),"new rune survives saved build")
 check(not save.decode(save.encode(prepared.s),prepared.data).is_empty(),"full expanded save round trip")
 var fresh=RealmModel.new()
 check(fresh.available("march_0_0")!="" and not RealmDiscovery.visible(fresh,"march_0_8"),"new regions and future enemies remain discovery gated")
 fresh.s.kills.crown_5=1
 check(fresh.available("march_0_0")=="" and fresh.available("march_0_1")!="","first encounter unlocks without revealing entire region")
 var deep=preload("res://tests/balance43.gd").build("warden",false)
 var ds=RealmEndgame.state(deep).depth
 ds.active=true;ds.floor=5
 RealmEndgame.victory(deep,deep.data.enemies.hollow_depth)
 check(ds.checkpoint==5 and ds.floor==6 and ds.best==5,"fifth Depths clear records checkpoint")
 RealmEndgame.defeat(deep)
 check(not ds.active and ds.stash==0 and ds.checkpoint==5,"defeat retains checkpoint but loses unbanked shards")
 check(deep.command({"type":"end_depth","id":"steady"}) and ds.floor==6,"Depths entry resumes after checkpoint")
 var threats=[]
 for floor_value in range(1,5):
  ds.floor=floor_value
  threats.append(RealmEndgame.enemy(deep,deep.data.enemies.hollow_depth).status)
 check(threats==["burn","chill","bleed","weaken"],"Depths threats rotate by room")
 var online=preload("res://tests/balance50.gd").build("frostbound",0)
 RealmRuneforge.state(online).ranks.rime=3;RealmRuneforge.state(online).equipped="rime"
 online.s.gear_attunements={online.s.equipped.weapon:"burn"}
 online.command({"type":"queue","id":"hunt_march_0_0","target":2})
 var offline=RealmModel.new();offline.s=online.s.duplicate(true)
 online.advance(120000)
 for i in range(120):offline.advance(1000)
 check(online.s==offline.s,"new hero, rune, armor set and attunement agree across offline chunks")
 print("EXPANSION50 ","PASS" if failed==0 else "FAIL", " failures=",failed)
 quit(failed)
