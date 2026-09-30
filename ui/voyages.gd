extends RefCounted
const U=preload("res://ui/style.gd")
var app
var m
func _init(owner):app=owner;m=owner.model
func time_text(ms: int) -> String:
 var minutes=ceili(maxi(0,ms)/60000.0)
 return "%dh %02dm" % [int(minutes/60),minutes%60]
func home(parent):
 var active=m.s.get("voyages",{}).get("active",{})
 var ready=m.s.get("voyages",{}).get("ready",{})
 if active.is_empty() and ready.is_empty():
  parent.add_child(U.button("Dungeon journeys · 1–8 hours",func():open()));return
 var c=U.card(parent,12);var a=active if not active.is_empty() else ready
 c.add_child(U.para(RealmVoyages.route(a.id).name,21,U.GOLD))
 app.dynamic(c,func():return "Rewards ready to collect" if not RealmVoyages.busy(m) else "%s remaining · %d / 4 stages" % [time_text(int(m.s.voyages.active.due-m.s.time)),m.s.voyages.active.stage],15)
 c.add_child(U.button("Review journey",func():open(),true))
func open(page: int = 0):
 var v=app.modal("Dungeon journeys");var s=RealmVoyages.state(m)
 if not s.ready.is_empty():
  rewards(v,s.ready);return
 if not s.active.is_empty():
  underway(v,s.active);return
 v.add_child(U.para("Pack provisions and explore offline for supplies, rare materials and equipment.",15))
 v.add_child(U.para("One journey at a time. Hunting and profession work pause while your hero is away.",13,U.GOLD))
 var known=RealmVoyages.data().routes.filter(func(r):return m.s.kills.get(r.gate,0)>0)
 if known.is_empty():v.add_child(U.para("Defeat the Bellkeeper to uncover the first route.",17));return
 for r in known.slice(page*4,(page+1)*4):
  var c=U.card(v,12);U.scenic(c,U.atlas_tile("res://assets/art/march-places-0.50.png",r.art,3,2),"",r.name,95)
  c.add_child(U.para("%dh · Bladecraft Lv.%d · %d combined attack & armor" % [r.hours,r.level,r.power],14,U.GOLD))
  c.add_child(U.button("Prepare journey",func():prepare(r.id),true))
 if page>0:v.add_child(U.button("Previous routes",func():open(page-1)))
 if (page+1)*4<known.size():v.add_child(U.button("More routes",func():open(page+1)))
func prepare(id: String,risk: String = "steady"):
 var r=RealmVoyages.route(id);var v=app.modal(r.name)
 U.scenic(v,U.atlas_tile("res://assets/art/march-places-0.50.png",r.art,3,2),"",r.name,140)
 var picker=OptionButton.new();picker.custom_minimum_size.y=46;picker.fit_to_longest_item=false
 picker.add_item("Steady journey");picker.add_item("Perilous · stronger build, richer caches");picker.select(1 if risk=="perilous" else 0)
 picker.item_selected.connect(func(index):prepare(id,"perilous" if index==1 else "steady"));v.add_child(picker)
 v.add_child(U.para("%dh journey · Four stages\nRequires %d combined attack & armor" % [r.hours,int(r.power*(1.3 if risk=="perilous" else 1.0))],18,U.GOLD))
 var amount=int(r.provisions)*(2 if risk=="perilous" else 1)
 v.add_child(U.para("Pack %d %s (%d owned)\nTravel fee: %s" % [amount,m.name_of(r.food),m.count(r.food),RealmEconomy.money(r.fee)],15))
 v.add_child(U.button("Prepare provisions",func():app.sources_dialog(r.food)))
 var row=U.row(10);v.add_child(row);row.add_child(U.icon(r.material,64));row.add_child(U.para("Guaranteed: "+m.name_of(r.material)+", scraps and coins.\nFinal vault: Hollow Shards and a chance of Rare or Epic equipment.",14))
 v.add_child(U.para("Supplies and fees are paid at departure. Recall keeps completed caches but forfeits the final vault; spent provisions are not refunded.",13))
 v.add_child(U.para(RealmVoyages.reason(m,id,risk),14,U.GOLD))
 var b=app.modal_action("Depart · %dh journey" % r.hours,func():
  if app.send({"type":"voyage_start","id":id,"risk":risk}):app.set_page("explore");open())
 b.disabled=RealmVoyages.reason(m,id,risk)!=""
func underway(v,a: Dictionary):
 var r=RealmVoyages.route(a.id);U.scenic(v,U.atlas_tile("res://assets/art/march-places-0.50.png",r.art,3,2),"JOURNEY UNDERWAY",r.name,155)
 app.dynamic(v,func():return "%s remaining" % time_text(int(a.due-m.s.time)),24,U.GOLD)
 for i in range(4):v.add_child(U.para(("✓ " if i<a.stage else "%d. " % (i+1))+r.stages[i],15,U.GREEN if i<a.stage else U.TEXT))
 v.add_child(U.para("Your hero carries the expedition's cargo. Completed caches remain yours if you recall early.",14))
 v.add_child(U.button("Recall journey…",func():
  var prompt=app.modal("Recall this journey?")
  prompt.add_child(U.para("Return with completed caches. You will lose the final vault reward, and provisions and travel fees will not be refunded.",16))
  prompt.add_child(U.button("Keep travelling",func():open()))
  prompt.add_child(U.button("Recall hero",func():
   if app.send({"type":"voyage_recall"}):open()))))
 var ref=weakref(v)
 var shown_stage=int(a.stage)
 app.dialog_callbacks.append(func():
  if ref.get_ref()!=null and (not RealmVoyages.busy(m) or int(a.stage)!=shown_stage):open.call_deferred())
func rewards(v,a: Dictionary):
 var r=RealmVoyages.route(a.id);v.add_child(U.para(r.name,24,U.GOLD))
 v.add_child(U.para("Vault secured" if a.complete else "Recalled · collected caches",18,U.GREEN))
 v.add_child(U.para(RealmEconomy.money(int(a.gold)),19,U.GOLD))
 for id in a.cargo:
  var row=U.row(8);v.add_child(row);row.add_child(U.icon(id,40));row.add_child(U.para("%d %s" % [a.cargo[id],m.name_of(id)],15))
 for g in a.gear:
  var row=U.row(8);v.add_child(row);row.add_child(U.icon(g.id,54));row.add_child(U.para(m.data.rarities[int(g.q)]+" "+m.name_of(g.id),18,U.QUALITY[int(g.q)]))
 app.modal_action("Collect all rewards",func():
  if app.send({"type":"voyage_claim"}):app.set_page("village");app.dismiss();app.toast("Journey cargo collected."))
