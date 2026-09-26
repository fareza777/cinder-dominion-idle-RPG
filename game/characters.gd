class_name RealmCharacters
extends RefCounted

const ALL = {
	"warden":{"name":"Warden","role":"Armored defender","trade":"+3 armor · 10% less attack","attack":.9,"armor":1.0,"guard":3,"tile":0,"skill":"Iron Guard","detail":"Every third incoming attack deals 25% less damage."},
	"ranger":{"name":"Ranger","role":"Relentless hunter","trade":"15% more attack · 20% less armor","attack":1.15,"armor":.8,"guard":0,"tile":1,"skill":"Marked Strike","detail":"Every fourth attack deals 20% more damage."},
	"arcanist":{"name":"Arcanist","role":"Armor-breaking spellblade","trade":"5% more attack · 30% less armor","attack":1.05,"armor":.7,"guard":0,"tile":2,"skill":"Ember Lance","detail":"Every fourth attack ignores 40% of enemy armor."}
}
const ATTRIBUTES = {"might":"Might","resolve":"Resolve","focus":"Focus"}

static func id(m) -> String: return m.s.get("hero",{}).get("class","")
static func hero_name(m) -> String: return m.s.get("hero",{}).get("name","The Emberkeeper")
static func rank(m) -> int:
	if id(m)=="" or m.level("bladecraft")<5: return 0
	return 1+int(m.level("bladecraft")>=25)+int(m.level("bladecraft")>=50)+int(m.level("bladecraft")>=75)
static func allocated(m, key: String) -> int: return int(m.s.get("hero",{}).get("attributes",{}).get(key,0))
static func points(m) -> int: return 3+int((m.level("bladecraft")-1)/5)-allocated(m,"might")-allocated(m,"resolve")-allocated(m,"focus")
static func valid_name(value) -> bool:
	if not value is String or value!=value.strip_edges(): return false
	var rule = RegEx.new()
	rule.compile("^[\\p{L}\\p{N} '\\-]{2,24}$")
	return rule.search(value)!=null and value.replace(" ","").replace("'","").replace("-","")!=""
static func valid(hero, xp: Dictionary) -> bool:
	if not hero is Dictionary or hero.get("class","") not in ALL or not valid_name(hero.get("name",null)): return false
	if not hero.get("attributes") is Dictionary: return false
	var total = 0
	for key in ATTRIBUTES:
		var v = hero.attributes.get(key,-1)
		if not RealmSave.counter(v) or v>22: return false
		total += int(v)
	var level = mini(100,1+int(sqrt(float(xp.bladecraft)/25.0)))
	return total<=3+int((level-1)/5)
static func command(m, cmd: Dictionary) -> String:
	if cmd.type=="hero_create":
		if m.s.has("hero"): return "Your character is already chosen for this journey."
		if cmd.get("id","") not in ALL or not valid_name(cmd.get("name",null)): return "Enter a name with 2–24 letters, numbers, spaces, apostrophes or hyphens."
		if not m.s.fight.is_empty(): return "Finish your hunt before choosing a character."
		m.s.hero = {"class":cmd.id,"name":cmd.name,"attributes":{"might":0,"resolve":0,"focus":0}}
		return ""
	if id(m)=="": return "Choose your character first."
	if not m.s.fight.is_empty(): return "Finish your hunt before changing attributes."
	if cmd.type=="attribute_reset":
		m.s.hero.attributes = {"might":0,"resolve":0,"focus":0}
		return ""
	if cmd.get("id","") not in ATTRIBUTES or points(m)<=0: return "No attribute points available."
	m.s.hero.attributes[cmd.id] += 1
	return ""

static func apply_stats(m, stats: Dictionary):
	if id(m)=="": return
	var c = ALL[id(m)]
	stats.attack = maxi(1,int((stats.attack+allocated(m,"might"))*c.attack))
	stats.armor = maxi(0,int((stats.armor+allocated(m,"resolve"))*c.armor)+int(c.guard))

static func portrait(m) -> Texture2D:
	if id(m)=="": return load("res://assets/art/hero-armory-0.31.png")
	return preload("res://ui/style.gd").atlas_tile("res://assets/art/heroes-0.32.png",ALL[id(m)].tile,3,1)
