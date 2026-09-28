extends "res://tests/capture31.gd"

func capture():
	root.size=Vector2i(360,800)
	var scene=PreviewApp.new();root.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);scene.set_process(false)
	scene.U.scale=1.3
	scene.build_shell()
	scene.model.s.tutorial=true;scene.model.s.experience.coach_active=false
	scene.set_page("village")
	for amount in [0,20,1234567,123456789012]:
		scene.model.s.gold=amount;scene.refresh();scene.toast_label.hide()
		await snap("coins-%d-narrow-0.45" % amount)
		assert(scene.wallet.coins[0].icon!=null)
		assert(scene.wallet.coins[2].visible==(amount>=1000000))
	scene.model.s.gold=1234567;scene.refresh()
	scene.wallet.coins[2].pressed.emit()
	assert(is_instance_valid(scene.dialog))
	await snap("wallet-icons-narrow-0.45")
	assert(preload("res://ui/currency.gd").amounts(1234567)==[567,234,1])
	assert(preload("res://ui/currency.gd").grouped(123456)=="123,456")
	print("PASS currency zero/early/mixed/large amounts, coin visibility, wallet action and five phone captures")
	quit()
