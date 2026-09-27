extends "res://tests/capture30.gd"

func snap(name: String):
	await super.snap(name.replace("0.30","0.36"))
