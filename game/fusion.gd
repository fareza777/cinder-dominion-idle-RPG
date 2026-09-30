class_name RealmFusion
extends RefCounted

static func eligible(m,g: Dictionary) -> bool:
	return not g.is_empty() and not str(g.id).begins_with("relic_") and m.data.items[g.id].slot in ["weapon","shield","head","body","hands","feet","necklace","belt","ring"]

static func cost(g: Dictionary) -> Dictionary:
	var q=int(g.q)+1
	return {"gold":int(100*pow(2.1,q-1)),"duplicates":2+int(q/4),"donor_quality":mini(5,maxi(0,q-1)),"seal":"seal_"+str((5 if q<19 else 6) if q>=17 else clampi(int((q-1)/4),0,4)),"seals":1+q*q,"level":q*5 if q<=10 else 50+(q-10)*8,"gate":"" if q<6 else ("march_5_8" if q<8 else "realm_%d_9" % mini(6,int((q-8)/2)))}

static func donors(m,g: Dictionary) -> Array:
	var out=[];var c=cost(g)
	for other in m.s.gear:
		if other.uid!=g.uid and other.id==g.id and int(other.q)>=c.donor_quality and int(other.q)<=int(g.q) and not m.protected(other.uid):out.append(other)
	out.sort_custom(func(a,b):return a.q<b.q)
	return out

static func reason(m,uid: String) -> String:
	var g=m.gear(uid)
	if not eligible(m,g):return "Choose combat equipment. Unique relics use their own tempering forge."
	if g.q>=20:return "Worldforged is the final rarity."
	if not m.s.fight.is_empty() or RealmVoyages.busy(m):return "Return from your hunt or journey before forging."
	if not m.s.active.is_empty():return "Finish your current work before forging."
	if not m.s.tutorial:return "Complete First Supplies to open the forge."
	var c=cost(g)
	if c.gate!="" and m.s.kills.get(c.gate,0)<1:return "Defeat "+m.local_name(m.data.enemies[c.gate])+" to forge this rarity."
	if m.level("runecarving")<c.level:return "Reach Runecarving Lv.%d." % c.level
	if g.q>=4 and (m.level("smithing")<90 or RealmArtisan.tier(m,"hammer")<4):return "Legendary and higher fusion requires Smithing Lv.90 and the Blackstar Hammer."
	if m.s.gold<c.gold or m.count(c.seal)<c.seals:return "Gather the coins and Forge Seals shown above."
	var amount=maxi(0,int(g.count)-1)
	if g.q<c.donor_quality:amount=0
	for d in donors(m,g):amount+=int(d.count)
	if amount<c.duplicates:return "Gather %d spare copies at %s quality or higher. Protected items are kept." % [c.duplicates,m.data.rarities[c.donor_quality]]
	return ""

static func command(m,uid: String) -> String:
	var why=reason(m,uid)
	if why!="":return why
	var g=m.gear(uid);var c=cost(g)
	# Keep target identity and every attached effect; consume only reviewed spare copies.
	var remaining=int(c.duplicates)
	var own=mini(remaining,maxi(0,int(g.count)-1)) if g.q>=c.donor_quality else 0
	remaining-=own;g.count-=own
	for d in donors(m,g):
		var used=mini(remaining,int(d.count));d.count-=used;remaining-=used
		if d.count==0:m.s.gear.erase(d)
		if remaining==0:break
	if g.count>1:
		var spare=g.duplicate(true);spare.uid="eq_%d" % int(m.s.next_uid);m.s.next_uid+=1;spare.count-=1;g.count=1
		if m.s.gear.size()<1000:m.s.gear.append(spare)
		else:m.s.overflow.append(spare)
	m.s.gold-=c.gold;m.spend(c.seal,c.seals);g.q=int(g.q)+1
	m.last_forged=uid
	m.note(m.name_of(g.id)+" reforged to "+m.data.rarities[g.q]+".")
	return ""
