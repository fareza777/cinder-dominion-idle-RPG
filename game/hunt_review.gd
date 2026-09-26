class_name RealmHuntReview
extends RefCounted

static func metrics(report: Dictionary) -> Dictionary:
	var wins = int(report.wins)
	var seconds = maxf(0,float(report.ended)-float(report.started))/1000.0
	return {"comparable":report.result=="Completed" and wins>0,"seconds":seconds,
		"per_win":seconds/wins if wins>0 else 0.0,"meals_per_win":float(report.meals)/wins if wins>0 else 0.0}

static func previous(reports: Array, selected: int) -> Dictionary:
	var current = reports[selected]
	if not metrics(current).comparable: return {}
	for i in range(selected+1,reports.size()):
		if reports[i].enemy==current.enemy and metrics(reports[i]).comparable: return reports[i]
	return {}
