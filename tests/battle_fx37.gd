extends SceneTree

const FX = preload("res://ui/battle_fx.gd")

func _init():
	for character in RealmCharacters.ALL:
		for skilled in [false,true]:
			var m = RealmModel.new()
			m.fresh(37)
			m.command({"type":"hero_create","id":character,"name":"Effect Test"})
			m.s.xp.bladecraft = 400 if skilled else 0
			# Durable training fixture keeps real combat running through the triggers.
			m.data.enemies.ash_rat.hp = 10000
			m.data.enemies.ash_rat.attack = 12
			m.data.enemies.ash_rat.interval = 1000
			m.data.enemies.ash_rat.boss = character=="reaver"
			m.gain(m.s.settings.food,100)
			m.s.settings.threshold = .9
			assert(m.command({"type":"queue","id":"hunt_ash_rat","target":1}))
			var seen = false
			var serial = int(m.battle_event.serial)
			for i in range(80):
				m.advance(250)
				for event in m.combat_events:
					if event.serial<=serial: continue
					if event.get("skill","")==character:
						seen = true
						assert(not FX.from_event(m,event).is_empty())
						if character=="warden": assert(event.side=="hero" and not event.text.begins_with("+"))
						if character=="apothecary": assert(event.text.begins_with("+"))
				serial = int(m.battle_event.serial)
			if character=="reaver" and skilled:
				m.command({"type":"clear"})
				m.data.enemies.ash_rat.boss = false
				m.command({"type":"queue","id":"hunt_ash_rat","target":1})
				m.advance(10000)
				for event in m.combat_events: assert(event.get("skill","")!="reaver","Sundering Blow is boss-only")
			assert(seen==skilled,"Class effect must follow unlocked real skill: "+character)
			assert(FX.from_event(m,{"text":"MISS","side":"enemy"}).is_empty())
			assert(FX.from_event(m,{"text":"PHASE II","side":"enemy"}).is_empty())
			assert(FX.from_event(m,{"text":"+5 HP","side":"hero"}).is_empty())
			var before = JSON.stringify(m.s)
			var random_state = m.rng.state
			for event in m.combat_events: FX.from_event(m,event)
			assert(before==JSON.stringify(m.s) and random_state==m.rng.state)
	print("BATTLE FX 37 PASS: real class triggers at rank 1, no class triggers at rank 0, misses/heals excluded, state and RNG unchanged by FX")
	quit()
