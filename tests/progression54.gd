extends SceneTree
var failures=0
var checks=0
func check(ok: bool,label: String):
 checks+=1;print("PASS " if ok else "FAIL ",label)
 if not ok:failures+=1
static func prepared():
 var m=preload("res://tests/overhaul51.gd").prepared()
 for skill in m.s.xp:m.s.xp[skill]=RealmEconomy.threshold(130,skill)
 for id in m.data.enemies:m.s.kills[id]=5
 for id in ["copper_ore","copper_ingot","ash_log","copper_sword"]:m.s.gains[id]=5
 return m
func clone(m):
 var out=RealmModel.new();out.s=m.s.duplicate(true);out.rng.state=int(m.s.rng);return out
func _init():
 var save=RealmSave.new();var m=prepared()
 for r in RealmVoyages.data().routes:
  m=prepared();check(m.command({"type":"voyage_start","id":r.id,"path":"elite"}),r.id+" starts")
  var other=clone(m)
  m.advance(int(r.hours)*3600000)
  for i in range(16):other.advance(int(r.hours)*225000)
  check(m.s.voyages==other.s.voyages and m.s.voyage_rng==other.s.voyage_rng and not save.decode(save.encode(m.s),m.data).is_empty(),r.id+" offline/chunk parity and valid cargo")
 m=prepared();var route=RealmVoyages.data().routes[0]
 m.command({"type":"voyage_start","id":route.id,"path":"supplies"});m.advance(900000)
 var first=m.s.voyages.active.cargo[route.material]
 check(m.command({"type":"voyage_path","path":"vault"}),"path changes for next chamber")
 m.advance(900000)
 check(m.s.voyages.active.history[0].path=="supplies" and m.s.voyages.active.history[1].path=="vault" and m.s.voyages.active.cargo[route.material]>first,"completed cache preserved after path change")
 check(not save.decode(save.encode(m.s),m.data).is_empty(),"mid-journey save reload")
 var bad=m.s.duplicate(true);bad.voyages.active.gold+=1
 check(save.decode(save.encode(bad),m.data).is_empty(),"inflated journey cargo rejected")
 bad=m.s.duplicate(true);bad.voyages.active.history[0].won=false
 check(save.decode(save.encode(bad),m.data).is_empty(),"impossible safe-path failure rejected")
 check(m.command({"type":"voyage_recall"}) and m.command({"type":"voyage_claim"}) and not m.command({"type":"voyage_claim"}),"recall preserves caches; reward claims only once")
 m=prepared();m.command({"type":"voyage_start","id":route.id});m.s.voyages.active.erase("path");m.s.voyages.active.erase("history")
 check(not save.decode(save.encode(m.s),m.data).is_empty(),"legacy journey still loads")
 m.advance(3600000)
 check(not save.decode(save.encode(m.s),m.data).is_empty() and m.s.voyages.ready.cargo[route.material]==8,"legacy journey keeps original payout")
 m=prepared();m.s.wall=100000;m.command({"type":"voyage_start","id":route.id});save.resume(m,3700000)
 check(not RealmVoyages.busy(m) and m.s.voyages.ready.complete,"closed-game elapsed time completes journey")
 var before=m.s.voyages.duplicate(true);save.resume(m,3700000)
 check(m.s.voyages==before,"reopening same instant does not duplicate caches")
 m=prepared();m.s.kills.erase("march_0_0");m.s.kills.erase("trial_wilds")
 check(m.objective().key=="march_0_0","optional trials do not hide the main road")
 m=prepared();m.s.kills.erase("realm_6_9")
 check(m.objective().key=="realm_6_9","objectives reach the final realm")
 m.s.kills.realm_6_9=1;check(m.objective().key=="complete","completion requires new campaign too")
 m=prepared();m.command({"type":"queue","id":"hunt_realm_0_3","target":1})
 var e=m.data.enemies.realm_0_3;var guarded=RealmCombat.player_damage(m,e,1)
 RealmAfflictions.apply(m,"enemy","armor_break")
 check(RealmCombat.player_damage(m,e,1)>guarded,"Armor Break defeats bulwark guard")
 e=m.data.enemies.realm_0_2;var healing=RealmCombat.move(m,e,3,200).heal
 RealmAfflictions.apply(m,"enemy","poison");check(RealmCombat.move(m,e,3,200).heal<healing,"Poison cuts mender recovery")
 var roles=[]
 for n in range(10):roles.append(m.data.enemies["realm_0_%d" % n].combat_role)
 check(roles.size()==10 and roles.all(func(id):return roles.count(id)==1),"ten distinct encounter roles in each realm")
 var uid=str(m.s.equipped.weapon);m.s.card_sockets={uid:"card_realm_0_9"}
 check(RealmBuildDepth.player_damage(m,e,false,100)==94,"winter pact has a real downside without Chill")
 RealmAfflictions.apply(m,"enemy","chill")
 check(RealmBuildDepth.player_damage(m,e,false,100)==122,"winter pact rewards its intended status")
 m.s.fight.effects.enemy={}
 m.s.card_sockets={uid:"card_realm_1_9"};RealmAfflictions.apply(m,"enemy","burn")
 check(RealmBuildDepth.player_damage(m,e,true,100)==128 and RealmBuildDepth.player_damage(m,e,false,100)==94,"ember pact trades normal hits for burning specials")
 m.s.card_sockets={uid:"card_realm_2_9"};var before_poison=RealmBuildDepth.player_damage(m,e,false,100);RealmAfflictions.apply(m,"enemy","poison")
 check(before_poison==92 and RealmBuildDepth.player_damage(m,e,false,100)==120,"venom pact rewards poison setup")
 m.s.card_sockets={uid:"card_realm_3_9"};m.s.hp=40
 check(RealmBuildDepth.player_damage(m,e,false,100)==122 and RealmBuildDepth.incoming(m,false,100)==106,"blood pact exposes the hero to danger")
 m.s.hp=100;m.s.card_sockets={uid:"card_realm_4_9"}
 check(RealmBuildDepth.player_damage(m,e,true,100)==130 and RealmBuildDepth.player_damage(m,e,false,100)==90,"echo pact concentrates damage in special hits")
 m.s.card_sockets={uid:"card_realm_5_9"}
 check(RealmBuildDepth.player_damage(m,e,false,100)==92 and RealmBuildDepth.incoming(m,true,100)==75,"bastion pact exchanges damage for third-hit protection")
 m.s.card_sockets={uid:"card_realm_6_9"};m.s.fight.hp=int(e.hp*.2)
 check(RealmBuildDepth.player_damage(m,e,false,100)==130,"mercy pact executes wounded enemies")
 m.s.card_sockets={};m.s.gear_attunements={uid:"burn"};m.s.fight.effects.enemy={};m.s.fight.effects.hero={};m.s.fight.swings=4
 m.gear(uid).q=4;RealmBuildDepth.on_hit(m,e,true)
 check(not RealmAfflictions.has(m,"enemy","wound"),"weapon awakening stays locked below tier six")
 m.gear(uid).q=5;RealmBuildDepth.on_hit(m,e,true)
 check(RealmAfflictions.has(m,"enemy","wound") and not RealmAfflictions.has(m,"hero","barrier"),"tier six does not grant later milestones")
 m.s.card_sockets={};m.s.gear_attunements={uid:"burn"};m.gear(uid).q=15;m.s.fight.swings=8
 RealmAfflictions.apply(m,"hero","wound");RealmBuildDepth.on_hit(m,e,true)
 check(RealmAfflictions.has(m,"enemy","wound") and RealmAfflictions.has(m,"hero","barrier") and not RealmAfflictions.has(m,"hero","wound"),"three weapon milestones apply in combat")
 check(not save.decode(save.encode(m.s),m.data).is_empty(),"milestone effects survive valid combat save")
 m=prepared();m.s.wall=2000000000
 check(m.command({"type":"end_contract","id":"frontline"}),"frontline commission accepted")
 var target=RealmEndgame.state(m).board.target
 check(m.s.kills.has(target) and not save.decode(save.encode(m.s),m.data).is_empty(),"commission uses discovered target and persists")
 m.s.kills[target]+=6;var reward=RealmEndgame.contract_reward(m,"frontline");var coins=m.s.gold
 check(reward.gold>100000 and m.command({"type":"end_claim","id":"frontline"}) and m.s.gold==coins+reward.gold and not m.command({"type":"end_claim","id":"frontline"}),"late commission reward scales and claims once")
 var early=RealmModel.new()
 check(RealmChronicle.bounty_reward(m,"hunt").gold>RealmChronicle.bounty_reward(early,"hunt").gold,"ordinary bounty economy scales with proven progress")
 check("realm_6_9" in RealmEndgame.weekly_pool(),"weekly hunt includes conquered realm rulers")
 print("PROGRESSION54 ",checks-failures,"/",checks);quit(1 if failures else 0)
