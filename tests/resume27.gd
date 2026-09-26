extends SceneTree
func _init(): call_deferred("run")
func run():
	var m = RealmModel.new()
	m.s.wall = 1000000
	m.command({"type":"queue","id":"mine_copper","target":10000})
	var store = RealmSave.new()
	var original = m.s.duplicate(true)
	var sync = RealmModel.new()
	sync.s = original.duplicate(true)
	var expected = store.resume(sync,4600000)
	var frames = [0]
	var cancel = [false]
	var aborted = await store.resume_async(m,4600000,self,func(_progress): cancel[0] = true,func(): return cancel[0])
	assert(aborted.is_empty() and m.s==original)
	var result = await store.resume_async(m,4600000,self,func(_progress):
		frames[0] += 1
		assert(m.s==original))
	assert(frames[0]>1 and result==expected and m.s==sync.s)
	print("ASYNC RESUME: ",frames[0]," responsive chunks; cancellation preserves original state; synchronous report/state match after restart")
	quit()
