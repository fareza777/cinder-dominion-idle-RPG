class_name RealmBuildDepth
extends RefCounted

# Conditional combat rules share the real combat path and its bounded forecast.
const ROLES={
 "prowler":"Opening rush · First three strikes deal 20% more damage. Armor and Weaken soften the opening.",
 "bulwark":"Iron hide · Normal hits deal 25% less damage until Armor Break is applied. Special attacks bypass this guard.",
 "bleeder":"Rending claws · Third strikes apply Bleed. Bring Bleed resistance and enough food for sustained damage.",
 "mender":"Restoration · Third strikes restore 1% HP. Poison halves this healing; Wound reduces it further.",
 "hexer":"Withering curse · Third strikes apply Wound, reducing your healing. Wound resistance shortens the curse.",
 "sentinel":"Charged shell · Takes 20% less direct damage until Shock or Armor Break disrupts it.",
 "executioner":"Finishing blow · Deals 20% more damage while you are below half health, unless Weakened. Raise your food threshold.",
 "cantor":"Rallying hymn · Every third strike heals 0.4% HP and applies Slow. Wound and Slow resistance help sustain a long hunt.",
 "zealot":"Reckless assault · Third strikes deal 15% more damage, but your special attacks deal 15% more damage too.",
 "sovereign":"Sovereign's decree · In phase two, third strikes also apply Armor Break. Armor Break resistance and a shorter fight help."}

static func role(e: Dictionary) -> String:return str(e.get("combat_role",""))
static func enemy_damage(m,e: Dictionary,strike: int,damage: int) -> int:
 var r=role(e)
 if r=="prowler" and strike<=3:damage=ceili(damage*1.2)
 if r=="executioner" and m.s.hp<50 and not RealmAfflictions.has(m,"enemy","weaken"):damage=ceili(damage*1.2)
 if r=="zealot" and strike%3==0:damage=ceili(damage*1.15)
 return damage

static func player_damage(m,e: Dictionary,special: bool,damage: int) -> int:
 var r=role(e);var broken=RealmAfflictions.has(m,"enemy","armor_break")
 if r=="bulwark" and not special and not broken:damage=int(damage*.75)
 if r=="sentinel" and not broken and not RealmAfflictions.has(m,"enemy","shock"):damage=int(damage*.8)
 if r=="zealot" and special:damage=int(damage*1.15)
 var rules=card_rules(m)
 if "winter" in rules:damage=int(damage*(1.22 if RealmAfflictions.has(m,"enemy","chill") else .94))
 if "ember" in rules:damage=int(damage*(1.28 if special and RealmAfflictions.has(m,"enemy","burn") else (.94 if not special else 1.0)))
 if "venom" in rules:damage=int(damage*(1.2 if RealmAfflictions.has(m,"enemy","poison") else .92))
 if "blood" in rules:damage=int(damage*(1.22 if m.s.hp<50 else .95))
 if "echo" in rules:damage=int(damage*(1.3 if special else .9))
 if "bastion" in rules:damage=int(damage*.92)
 if "mercy" in rules:damage=int(damage*(1.3 if not m.s.fight.is_empty() and m.s.fight.hp<e.hp*.3 else .94))
 return maxi(1,damage)

static func card_rules(m) -> Array:
 var rules=[]
 for id in RealmCards.active(m):
  var r=RealmCards.definitions()[id].get("build_rule","")
  if r!="" and r not in rules:rules.append(r)
 return rules

static func incoming(m,third: bool,damage: int) -> int:
 var rules=card_rules(m)
 if "bastion" in rules and third:damage=ceili(damage*.75)
 if "blood" in rules:damage=ceili(damage*1.06)
 return maxi(1,damage)

static func weapon(m) -> Dictionary:return m.gear(str(m.s.equipped.get("weapon","")))
static func milestone_text(m,g: Dictionary) -> String:
 if g.is_empty() or m.data.items[g.id].slot!="weapon":return ""
 var a=m.s.get("gear_attunements",{}).get(g.uid,"")
 var active="Choose an attunement to awaken these effects." if a=="" else "Attunement: "+RealmMarches.ATTUNEMENTS[a].name+"."
 return active+"\nTier 6: fourth hits also apply Wound (elemental), Weaken (Resolute), or Armor Break (Merciless).\nTier 11: fourth hits grant a small Barrier.\nTier 16: every eighth hit removes Wound, Weaken and Slow from you."

static func on_hit(m,e: Dictionary,special: bool):
 if not special:return
 var g=weapon(m)
 var a=m.s.get("gear_attunements",{}).get(g.get("uid",""),"")
 if a!="" and not g.is_empty():
  if g.q>=5:RealmAfflictions.apply(m,"enemy",("weaken" if a=="counter" else ("armor_break" if a=="execution" else "wound")),1)
  if g.q>=10:RealmAfflictions.apply(m,"hero","barrier",2)
  if g.q>=15 and int(m.s.fight.swings)%8==0:
   var effects=m.s.fight.get("effects",{}).get("hero",{})
   for effect in ["wound","weaken","slow"]:effects.erase(effect)

static func enemy_proc(m,e: Dictionary,third: bool):
 if third and role(e)=="sovereign" and int(m.s.fight.get("phase",1))>=2:RealmAfflictions.apply(m,"hero","armor_break",1)
