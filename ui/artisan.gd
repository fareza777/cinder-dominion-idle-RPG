extends RefCounted
const U=preload("res://ui/style.gd")
var app
var m
func _init(owner):app=owner;m=owner.model
func open(kind: String = "hammer"):
 var v=app.modal("The artisan's bench")
 var picker=OptionButton.new();picker.custom_minimum_size.y=46;picker.fit_to_longest_item=false
 var kinds=["hammer","knife","mortar"]
 for label in ["Smithing hammers","Cooking knives","Alchemy mortars"]:picker.add_item(label)
 picker.select(kinds.find(kind));picker.item_selected.connect(func(index):open(kinds[index]));v.add_child(picker)
 v.add_child(U.para("Better hammers improve the chance of exceptional work. Legendary rolls require a Blackstar Hammer and Smithing Lv.90. Named recipes keep their promised quality." if kind=="hammer" else "A better bench tool produces extra supplies over repeated batches. Select it before starting work; tools are reusable.",15))
 if kind=="hammer":v.add_child(U.para("Uncommon and Rare pieces can carry one trait, Epic up to two, and Legendary up to three. Traits are revealed on the finished item.",14,U.GOLD))
 for tier in range(1,5):
  var id="artisan_%s_%d" % [kind,tier];var c=U.card(v,12);var row=U.row(10);c.add_child(row)
  row.add_child(U.icon(id,64));var labels=U.column(4);labels.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(labels)
  labels.add_child(U.para(m.name_of(id),20,U.GOLD));labels.add_child(U.para("Owned: %d" % m.count(id),13))
  if kind!="hammer":c.add_child(U.para("Extra supplies accumulate at %d per 100 completed batches." % (tier*3),13))
  var b=U.button("Selected" if RealmArtisan.selected(m,kind)==id and m.count(id)>0 else "Use this tool",func():
   if app.send({"type":"artisan_select","id":id}):open(kind))
  b.disabled=m.count(id)<1 or not m.s.active.is_empty() or not m.s.fight.is_empty();c.add_child(b)
  c.add_child(U.button("Materials & craft",func():app.activity_dialog("craft_"+id,1)))
 v.add_child(U.button("Improve gathering tools",tools))
func tools(page: int = 0):
 var v=app.modal("Gathering tools")
 v.add_child(U.para("Rarity, tool rank and traits improve your tools. Each tool has six upgrade ranks. Equipped and improved tools are kept safe from salvage.",15))
 var choices=m.s.gear.filter(func(g):return m.data.items[g.id].slot in RealmArtisan.TOOLS)
 choices.sort_custom(func(a,b):return m.gear_score(a)>m.gear_score(b))
 for g in choices.slice(page*8,(page+1)*8):
  var row=U.row(8);v.add_child(row);row.add_child(U.icon(g.id,46))
  var b=U.button(m.data.rarities[int(g.q)]+" "+m.name_of(g.id)+" · Rank %d" % g.get("tool_rank",0),func():upgrade(g.uid));b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(b)
 if page>0:v.add_child(U.button("Previous",func():tools(page-1)))
 if (page+1)*8<choices.size():v.add_child(U.button("More tools",func():tools(page+1)))
func upgrade(uid: String):
 var g=m.gear(uid)
 if g.is_empty():tools();return
 var v=app.modal(m.name_of(g.id));v.add_child(U.icon(g.id,110))
 var rank=int(g.get("tool_rank",0));v.add_child(U.para("Tool rank %d / 6" % rank,22,U.GOLD))
 v.add_child(U.para("Each rank adds 1.5% gathering speed and builds toward 2 extra supplies per 100 cycles. Rarity and traits add their own bonuses.",15))
 if rank>=6:return
 var c=RealmArtisan.tool_cost(m,g)
 v.add_child(U.para("%s · %d %s · %d scraps\nSmithing Lv.%d" % [RealmEconomy.money(c.gold),c.ingots,m.name_of(c.metal),c.scrap,c.level],16,U.GOLD))
 v.add_child(U.button("Find "+m.name_of(c.metal),func():app.sources_dialog(c.metal)))
 v.add_child(U.para(RealmArtisan.tool_reason(m,g),14))
 var b=app.modal_action("Improve to rank %d" % (rank+1),func():
  if app.send({"type":"tool_upgrade","id":uid}):upgrade(uid))
 b.disabled=RealmArtisan.tool_reason(m,g)!=""
