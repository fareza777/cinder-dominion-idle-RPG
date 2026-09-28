extends RefCounted
const U=preload("res://ui/style.gd")
var app
var m
func _init(owner):app=owner;m=owner.model
func open(region: int = 0):
 var d=RealmMarches.data().regions[region]
 var v=app.modal("The Far Marches")
 var chooser=OptionButton.new();chooser.fit_to_longest_item=false;chooser.custom_minimum_size.y=48
 for r in RealmMarches.data().regions:chooser.add_item(r.name)
 chooser.select(region);chooser.item_selected.connect(func(index):open(index));v.add_child(chooser)
 U.scenic(v,U.atlas_tile("res://assets/art/march-places-0.50.png",region,3,2),"",d.name,145)
 var gate=RealmMarches.available(m,"march_%d_0" % region)
 if gate!="":v.add_child(U.para(gate,17,U.GOLD));return
 v.add_child(U.para(d.detail+". Secure the route, forge its equipment, then challenge its ruler.",15))
 v.add_child(U.button("Regional equipment & farming",func():equipment(region),true))
 var progress=0
 for n in range(9):
  var id="march_%d_%d" % [region,n]
  if m.s.kills.get(id,0)>0:progress+=1
  if not RealmDiscovery.visible(m,id):continue
  var row=U.row(10);v.add_child(row);row.add_child(U.enemy_portrait(m.data.enemies[id],Vector2(58,72)))
  var b=U.button(m.local_name(m.data.enemies[id])+(" · Cleared" if m.s.kills.get(id,0)>0 else ""),func():app.activity_dialog("hunt_"+id,1));b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(b)
 v.add_child(U.para("%d / 9 encounters cleared" % progress,15,U.GOLD))
 var claimed=region in m.s.get("march_claimed",[])
 var claim=U.button("Supply road secured" if claimed else "Claim expedition rewards",func():
  if app.send({"type":"march_claim","region":region}):open(region))
 claim.disabled=claimed or progress<9;v.add_child(claim)
 for id in m.data.enemies:
  var e=m.data.enemies[id]
  if e.get("march_guardian",false) and e.march==region and RealmDiscovery.visible(m,id):
   v.add_child(U.button("Optional guardian · "+e.en,func():app.activity_dialog("hunt_"+id,1)))
 if region==0 and RealmDiscovery.visible(m,"march_wanderer"):v.add_child(U.button("Hunt the Lanternless Wayfarer",func():app.activity_dialog("hunt_march_wanderer",1)))
func equipment(region: int):
 var d=RealmMarches.data().regions[region];var v=app.modal(d.name+" · Equipment")
 v.add_child(U.para("Choose your next upgrade. Every material for this equipment has a guaranteed source; masterworks are separate rare discoveries.",15))
 for id in m.data.items:
  var item=m.data.items[id]
  if item.get("family","")!=d.id:continue
  var row=U.row(8);v.add_child(row);row.add_child(U.icon(id,54))
  var b=U.button(item.en+" · "+str(RealmEquipmentSlots.NAMES.get(item.slot,"Ring")),func():
   if app.send({"type":"upgrade_goal","id":id}):preload("res://ui/upgrade_goal.gd").new(app).open())
  b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(b)
func attune(uid: String):
 var v=app.modal("Weapon attunement")
 v.add_child(U.para("Choose one effect for this weapon. Replacing it costs 250 Gold, 10 Hollow Shards and 100 scraps. Requires Smithing Lv.65.",15))
 var current=m.s.get("gear_attunements",{}).get(uid,"")
 for id in RealmMarches.ATTUNEMENTS:
  var d=RealmMarches.ATTUNEMENTS[id];var c=U.card(v,12)
  c.add_child(U.para(d.name,20,U.GOLD));c.add_child(U.para(d.detail,15))
  var b=U.button("Applied" if id==current else "Apply attunement",func():
   if app.send({"type":"gear_attune","uid":uid,"id":id}):attune(uid))
  b.disabled=id==current or not m.s.fight.is_empty();c.add_child(b)
