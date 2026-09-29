extends SceneTree
const Actor=preload("res://ui/enemy_actor.gd")
class Gallery extends Control:
 var entries=[]
 var font=ThemeDB.fallback_font
 func _draw():
  draw_rect(Rect2(Vector2.ZERO,size),Color("172126"))
  for i in range(entries.size()):
   var x=(i%4)*256;var y=int(i/4)*170
   var e=entries[i]
   draw_string(font,Vector2(x+10,y+20),e.id+" / "+str(e.pose),HORIZONTAL_ALIGNMENT_LEFT,240,12,Color.WHITE)
   draw_line(Vector2(x+10,y+160),Vector2(x+246,y+160),Color("6e7566"))
   Actor.draw(self,e.id,e.pose,Rect2(x+10,y+26,236,134))
func _init():call_deferred("capture")
func capture():
 root.size=Vector2i(1024,1020)
 root.content_scale_size=Vector2i(1024,1020)
 var m=RealmModel.new();RealmUI.setup(m.data)
 var board=Gallery.new();root.add_child(board);board.size=Vector2(1024,1020)
 var count=0
 for sheet in range(10):
  board.entries=[]
  for id in m.data.enemies:
   if int(Actor.definition(id).sheet)!=sheet:continue
   for pose in range(2):
    var b=Actor.measured(id)[pose]
    assert(b.rect[2]>0 and b.rect[3]>0 and not b.pieces.is_empty())
    board.entries.append({"id":id,"pose":pose});count+=1
  assert(board.entries.size()==24)
  board.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://docs/qa/screenshots/actors-bounds-0.51.1-%d.png" % sheet)
 print("ACTOR BOUNDS: ",count," complete poses rendered from measured source regions.")
 quit()
