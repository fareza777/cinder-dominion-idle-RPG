class_name RealmHuntPlan
extends RefCounted

# Consecutive fights share one health pool; there is no rest between kills.
static func meals(m, forecast: Dictionary, fights: int) -> int:
	var health_buffer = maxf(0,float(m.s.hp)-float(m.s.settings.threshold)*100)
	return ceili(maxf(0,float(forecast.incoming)*maxi(1,fights)-health_buffer)/maxf(1,float(forecast.effective_heal)))
