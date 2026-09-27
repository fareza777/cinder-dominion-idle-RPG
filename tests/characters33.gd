extends "res://tests/characters32.gd"

func _init():
	assert(RealmCharacters.ALL.size()==5)
	for character in ["reaver","apothecary"]:
		var m = RealmModel.new()
		assert(m.command({"type":"hero_create","id":character,"name":"Ash Walker"}))
		for level in [1,5,25,50,75]:
			m.s.xp.bladecraft = 25*(level-1)*(level-1)
			var rank = RealmCharacters.rank(m)
			var neutral = RealmModel.new()
			neutral.s = m.s.duplicate(true)
			neutral.s.erase("hero")
			var food = m.s.settings.food
			if character=="apothecary":
				assert(RealmCombat.food_heal(m,food)-RealmCombat.food_heal(neutral,food)==(6+3*(rank-1) if rank>0 else 0))
				assert(m.stats().attack<=neutral.stats().attack)
			else:
				var enemy = m.data.enemies.bellkeeper.duplicate(true)
				var boss_damage = RealmCombat.player_damage(m,enemy,4)
				enemy.boss = false
				var normal_damage = RealmCombat.player_damage(m,enemy,4)
				assert(boss_damage==maxi(1,int(normal_damage*(1.25+.1*(rank-1)))) if rank>0 else boss_damage==normal_damage)
			assert(not RealmCharacters.skill_description(character,rank).is_empty())
	print("CHARACTERS 33 PASS: both new skills at all rank thresholds")
	super()
