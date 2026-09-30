extends SceneTree
func _init():
 var results=[]
 var encounters=[]
 for n in range(9):encounters.append([0,n])
 for r in range(7):encounters.append([r,9])
 for pair in encounters:
  var r=int(pair[0]);var m=preload("res://tests/balance50.gd").build("warden",5)
  for skill in m.s.xp:m.s.xp[skill]=RealmEconomy.threshold(100+r*5,skill)
  for uid in m.s.equipped.values():
   var g=m.gear(uid)
   if m.data.items[g.id].slot not in ["axe","pick","rod"]:g.q=7+r*2
  var id="realm_%d_%d" % pair
  var result=preload("res://tests/balance34.gd").fight(m,id)
  result.enemy=id;results.append(result);print("FIGHT54 ",id," ",result)
 FileAccess.open("res://build/balance54.json",FileAccess.WRITE).store_string(JSON.stringify(results,"\t"))
 quit()
