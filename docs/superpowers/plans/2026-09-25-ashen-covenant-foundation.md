# Ashen Covenant Playable Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menghasilkan fondasi idle RPG Android yang bisa dimainkan dari pengumpulan bahan sampai boss, dengan dark fantasy beranimasi, enam skill pendukung, melee, 40 item, 20 resep, antrean, save, dan progres offline yang dapat diverifikasi.

**Architecture:** Godot menjalankan simulasi yang terpisah dari tampilan. Command tervalidasi mengubah satu state melalui transaksi, kemudian disimpan sebelum perubahan hasil ditampilkan. Online dan offline menjalankan mesin kejadian yang sama; durasi dipecah menjadi batch tanpa mengubah hasil RNG atau urutan kejadian.

**Tech Stack:** Godot 4 stable, GDScript, JSON untuk konten, Godot Resource/Scene untuk presentasi, Android SDK, runner pengujian GDScript headless tanpa dependensi tambahan. Versi engine/export template dipatok bersama saat Task 1.

**Spec:** `docs/superpowers/specs/2026-09-25-dark-fantasy-idle-rpg-design.md`, baseline disetujui 25 September 2026.

## Global Constraints

- Android untuk dirilis ke publik.
- Idle RPG dengan kompleksitas dan hubungan antarsistem sekelas referensi Realm Idle.
- Dark fantasy, antarmuka lebih rapi, dunia dan karakter lebih hidup.
- Gratis dimainkan, tanpa iklan, pembelian kosmetik dan ekspansi konten.
- Satu aktivitas utama berjalan pada satu waktu, baik combat maupun skill.
- Antrean gratis hingga 20 langkah mendukung target jumlah siklus, jumlah hasil baru, atau level skill.
- Progres offline maksimal 24 jam per jeda, sama untuk semua pemain.
- Tidak ada checkout aktif dalam tahap fondasi.
- Bahasa Indonesia dan Inggris disiapkan melalui kunci lokalisasi sejak awal.
- Target tahap ini adalah satu wilayah, enam musuh biasa, satu boss, enam skill pendukung, melee, 40 item, 20 resep. Target game dasar tetap 15 skill, delapan wilayah, 400 item, 180 resep, dan 24 pet.
- Pet, build ranged/magic, semua bangunan, seluruh kampanye, cloud, dan billing memperoleh rencana terpisah sesuai milestone spesifikasi. Jangan menampilkan kontrol seolah fitur tersebut sudah bekerja.

## Review Focus

1. Impor angka negatif, tipe salah, NaN, atau jumlah kelewat besar: ditolak tanpa merusak save aktif; Task 2 dan 7 mengujinya.
2. Ketuk ganda pada craft/equip/salvage saat antrean aktif: transaksi berlaku sekali dan tidak menyentuh equipment yang dilindungi; Task 3 dan 8 mengujinya.
3. HP habis pada timestamp yang sama dengan auto-heal atau serangan: urutan deterministik dan tidak menerima loot setelah defeat; Task 5 mengujinya.
4. Aplikasi dihentikan sesudah catch-up tersimpan tetapi sebelum ringkasan ditutup: resume tidak memberikan hasil kedua kali; Task 7 mengujinya.
5. Locale berubah, font 130%, layar pendek, dan safe area: seluruh tombol utama tetap dapat dijangkau tanpa teks terpotong; Task 9 dan 10 mengujinya.

## Lingkungan awal dan pemisahan rencana

Repositori saat perencanaan hanya berisi spesifikasi. Java 21, Node, dan Python ditemukan; folder Android SDK ada. Godot/adb belum ditemukan lewat PATH, sehingga keberadaan SDK bukan bukti build Android sudah dapat dijalankan. Jangan menginstal atau mengganti Java yang sudah ada tanpa kebutuhan kompatibilitas yang terverifikasi.

Rencana ini hanya milestone fondasi. Milestone kedalaman build, konten lengkap, serta layanan rilis menjadi rencana berikutnya yang masing-masing ditinjau terhadap hasil nyata fondasi. Ketergantungan berjalan berurutan: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10.

## Struktur file dan batas tanggung jawab

| Path | Tanggung jawab |
| --- | --- |
| `project.godot`, `export_presets.cfg`, `.gitignore` | Konfigurasi proyek, ekspor debug, pengecualian cache/rahasia |
| `tools/run-tests.ps1`, `tools/check-content.ps1` | Entry point validasi yang menerima path engine eksplisit |
| `tests/run.gd`, `tests/checks.gd` | Runner exit code dan assertion yang tetap aktif pada headless |
| `game/content/catalog.gd`, `data/*.json` | Konten tervalidasi dan indeks sumber bahan |
| `game/state/game_state.gd`, `game/state/state_validator.gd` | State baru, batas nilai, versi schema |
| `game/inventory/inventory.gd`, `equipment.gd` | Jumlah item, equipment, preset, lock, salvage |
| `game/progression/progression.gd` | XP dan perhitungan level |
| `game/activities/activity_queue.gd`, `production.gd` | Target langkah, konsumsi siklus, mastery |
| `game/combat/combat.gd`, `combat_stats.gd` | Serangan, food, potion, kemenangan, kekalahan |
| `game/simulation/simulation.gd`, `event_order.gd` | Command, kejadian deterministik, penyelesaian waktu |
| `game/quests/quest_book.gd` | Tutorial dan unlock boss |
| `game/save/save_repository.gd`, `save_codec.gd`, `offline_clock.gd` | Snapshot, backup, migrasi, catch-up |
| `game/session/game_session.gd` | Koordinator UI/command/simpan, status disk error |
| `ui/main.tscn`, `ui/main.gd`, `ui/theme.tres` | Shell portrait, navigasi, area aman |
| `ui/screens/{village,explore,skills,inventory,character}.tscn` | Lima layar nyata beserta script sepasangnya |
| `ui/components/{activity_bar,item_card,queue_editor,offline_report}.tscn` | Komponen bersama beserta script sepasangnya |
| `ui/art/{village_stage,battle_stage}.tscn` | Latar dan animasi yang tidak mengubah simulasi |
| `assets/art/`, `assets/audio/`, `assets/fonts/`, `assets/manifest.json` | Aset asli/berlisensi dan asalnya |
| `localization/id.csv`, `localization/en.csv` | Seluruh label, pesan gagal, nama item, dan tutorial |
| `tests/test_*.gd`, `tests/fixtures/` | Pengujian domain dan save dengan fixture terkontrol |
| `docs/qa/foundation-report.md`, `docs/development.md` | Bukti pengujian, batas hasil, cara menjalankan |

Semua path relatif terhadap root `E:/Idle GPT Astra`. Nama file saudara pada tabel berada di direktori yang sama. File domain tidak mengakses scene tree, network, UI, atau waktu sistem secara langsung.

## Kontrak data bersama

Gunakan Dictionary dengan kunci wajib tervalidasi; enum berupa StringName pada runtime dan string pada JSON. Hasil operasi selalu `{"ok": bool, "code": String, "state": Dictionary, "events": Array}`. Kegagalan mengembalikan state input tanpa mutasi. Operasi yang berhasil mengembalikan deep copy baru.

```gdscript
# Bentuk state; nilainya dibuat GameState.fresh(seed), bukan singleton bersama.
{
  "schema_version": 1, "content_version": "foundation-1", "revision": 0,
  "sim_ms": 0, "saved_unix_ms": 0, "rng_state": "1", "gold": 0,
  "materials": {}, "equipment": [], "overflow": [], "equipped": {},
  "presets": [], "skills_xp": {}, "mastery_cycles": {},
  "queue": [], "active": {}, "combat": {}, "hp": 100,
  "quests": {}, "kills": {}, "unlocks": ["cinderwatch"],
  "processed_command_ids": [], "last_offline_report": {},
  "settings": {"locale": "id", "font_scale": 1.0,
    "reduced_motion": false, "battery_saver": true,
    "music": 0.5, "sfx": 0.7, "food_id": "", "heal_threshold": 0.5}
}
```

Equipment entry: `{uid,item_id,rarity,affixes,rune_id,count,locked,favorite}`. `uid` dihasilkan dari counter state, bukan jam atau RNG combat. Tambahkan `next_uid` ke factory dan validator. Bentuk afiks: array `{id,value}` yang diurutkan ketika membandingkan stack. Fondasi memakai array afiks kosong dan rune_id kosong; efek afiks/rune dibuat bersama milestone kedalaman build. Slot: weapon, shield, head, body, hands, feet, axe, pick, rod. Preset menyimpan nama dan UID per slot; aktivitas hanya membaca tool yang relevan. Factory memasang kelima starter equipment ke slotnya.

Langkah antrean: `{id,activity_id,target_kind,target_value,skip_blocked,cycles_done,outputs_done}`. `target_kind` adalah cycles, output, atau level. Production yang berjalan menyimpan input yang sudah direservasi, waktu selesai, dan ID langkah. Menghapus langkah aktif mengembalikan input reservasi tepat sekali dan membuang progres siklus parsial.

Angka gold/item/XP dibatasi bilangan bulat 0–10^12, queue maksimal 20, teks nama maksimal 64 karakter, impor maksimal 5 MiB. RNG int64 disimpan sebagai string desimal untuk menghindari pembulatan JSON. Integer numerik yang diimpor harus finite dan benar-benar integral sebelum konversi.

Factory melakukan `RandomNumberGenerator.new()`, mengatur seed, lalu menyimpan `str(rng.state)`. Semua modul pemakai RNG memulihkan state ini dan menuliskannya kembali sesudah roll. Jangan memberi seed ulang pada setiap siklus. Revision hanya dinaikkan oleh commit save yang berhasil, bukan per frame/batch simulasi. `next_uid` bersifat monoton dan UID berformat `eq_` diikuti bilangan bulat. Uji identitas online/offline membandingkan seluruh state simulasi sebelum commit disk, bukan metadata kapan file ditulis.

Simulation events berbentuk `{id,type,sim_ms,args}` dengan counter monoton `next_event_id` yang ditambahkan ke factory/validator. Contoh event: `item_gained` args `{item_id,amount}`, `enemy_killed` args `{enemy_id}`, `equipped` args `{uid,item_id}`, dan `defeated` args `{enemy_id,reason}`. QuestBook menyimpan `last_event_id` serta `lifetime_counts` untuk menolak replay. Tests yang mengirim event langsung harus mengikuti envelope ini.

Command payload: queue_add memakai bentuk langkah penuh; queue_cancel `{step_id}`; queue_reorder `{step_ids}` hanya untuk langkah menunggu; equip/lock/favorite `{uid}` dengan `enabled` pada lock/favorite; salvage `{uids}`; buy/sell `{item_id,count}` hanya bahan/merchant item yang memenuhi aturan; save_preset `{name,slots}`; load_preset `{name}`; set_food `{item_id,threshold}`; set_potion `{item_id,policy}` dengan policy off/start/low_hp; retreat `{}`; settings `{key,value}` untuk whitelist pengaturan. Equipment yang dilindungi tidak dapat dijual. Semua command memiliki ID unik yang dibuat koordinator session, dan nama/ID konten harus divalidasi terhadap katalog.

Tabel rarity lengkap dalam metadata: Worn0.8, Common1.0, Fine1.1, Rare1.25, Epic1.5, Legendary1.8, Mythic2.2, Relic2.7. Nilai bonus fractional dibulatkan ke bawah setelah seluruh modifier dihitung. Distribusi drop fondasi hanya menghasilkan subset yang dinyatakan di bawah.

### Fixture konten fondasi

Daftar tepat 40 item berikut menjadi input Task 2. Semua rarity tersedia dalam metadata; fondasi mendistribusikan Worn/Common/Fine/Rare, dan membuka rarity lain bersama tier kontennya pada milestone berikutnya.

- 14 bahan: `ash_log, oak_log, copper_ore, iron_ore, coal, copper_ingot, iron_ingot, raw_minnow, raw_perch, raw_meat, emberleaf, grave_moss, empty_vial, scrap`.
- 3 makanan: `cooked_minnow, cooked_perch, cooked_meat`.
- 3 potion: `healing_draught, guard_draught, fury_draught`.
- 12 crafted equipment: `copper_sword, copper_shield, copper_helm, copper_chest, copper_gloves, copper_boots, iron_sword, iron_shield, iron_helm, iron_chest, iron_gloves, iron_boots`.
- 8 starter/merchant equipment: `worn_sword, worn_shield, wood_axe, stone_pick, reed_rod, ash_axe, copper_pick, iron_rod`.

Stok awal: worn_sword, worn_shield, wood_axe, stone_pick, reed_rod; masing-masing satu. Berikan lima cooked_minnow sebagai bekal tutorial dan 20 gold. Merchant menjual empty_vial 2g, ash_axe 30g, copper_pick 40g, iron_rod 60g. Upgrade alat memberi pengurangan durasi relevan sebesar 10%; tidak dapat dijual kembali dengan harga lebih tinggi.

20 resep tepat, dengan input per satu output:

| ID output | Skill/level | Input | Detik | XP |
| --- | --- | --- | --- | --- |
| copper_ingot | smithing/1 | copper_ore:2 | 3 | 8 |
| iron_ingot | smithing/10 | iron_ore:2, coal:1 | 5 | 18 |
| cooked_minnow | cooking/1 | raw_minnow:1 | 2 | 5 |
| cooked_perch | cooking/5 | raw_perch:1 | 3 | 10 |
| cooked_meat | cooking/1 | raw_meat:1 | 3 | 8 |
| healing_draught | alchemy/1 | emberleaf:2, empty_vial:1 | 4 | 10 |
| guard_draught | alchemy/5 | grave_moss:2, empty_vial:1 | 5 | 15 |
| fury_draught | alchemy/8 | emberleaf:2, grave_moss:1, empty_vial:1 | 6 | 20 |
| copper_sword | smithing/1 | copper_ingot:2, ash_log:1 | 5 | 15 |
| copper_shield | smithing/2 | copper_ingot:2, ash_log:2 | 5 | 15 |
| copper_helm | smithing/3 | copper_ingot:2 | 5 | 15 |
| copper_chest | smithing/5 | copper_ingot:4 | 8 | 25 |
| copper_gloves | smithing/2 | copper_ingot:1 | 4 | 10 |
| copper_boots | smithing/2 | copper_ingot:1 | 4 | 10 |
| iron_sword | smithing/10 | iron_ingot:2, oak_log:1 | 7 | 30 |
| iron_shield | smithing/11 | iron_ingot:2, oak_log:2 | 7 | 30 |
| iron_helm | smithing/12 | iron_ingot:2 | 7 | 30 |
| iron_chest | smithing/15 | iron_ingot:4 | 10 | 45 |
| iron_gloves | smithing/11 | iron_ingot:1 | 6 | 20 |
| iron_boots | smithing/11 | iron_ingot:1 | 6 | 20 |

Recipe activity ID = `craft_` + output ID. Gathering: `cut_ash` (level1, 3s, 5XP), `cut_oak` (level5, 4s, 10XP), `mine_copper` (level1, 3s, 5XP), `mine_coal` (level5, 4s, 10XP), `mine_iron` (level10, 5s, 15XP), `fish_minnow` (level1, 3s, 5XP), `fish_perch` (level5, 4s, 10XP). Each cycle yields one associated material. Ash/oak respectively have 20% emberleaf/grave_moss side drop. All probabilities are resolved once at cycle completion. Generate one combat activity `hunt_` + enemy ID per enemy, referencing its enemy definition. These are activities, not extra recipes. Gathering/production/combat are distinguished by a required `kind` field.

Skill threshold for level L: `25 * (L - 1) * (L - 1)`, capped at 100. This is the initial tuning curve, measured during Task 10. Mastery adds 1% speed per 100 completed cycles, capped at 10%; combining tool and mastery discounts clamps total discount to 30%.

Combat fixture: base player HP100, attack4, armor0, attack interval2000ms, hit95%, crit5%, crit multiplier1.5. Copper/iron swords add attack4/8. Shields add armor2/4; helms1/2; chest3/6; gloves1/2; boots1/2. Worn shield armor1; worn sword adds0. Food heals20/35/30 respectively. Healing draught heals50; guard gives armor+3 for60s; fury gives attack+3 for60s. Potion policy is off by default, configurable by selecting one potion and threshold or start-of-fight use. Potion reuse has a 60s cooldown, persisted in combat state.

| Enemy ID | HP | Attack | Armor | Interval ms | Gold | XP | Guaranteed material |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ash_rat | 18 | 2 | 0 | 2500 | 3 | 6 | raw_meat:1 |
| hollow_hound | 35 | 4 | 0 | 2200 | 5 | 10 | raw_meat:1 |
| grave_thrall | 50 | 5 | 1 | 2800 | 7 | 14 | grave_moss:1 |
| cinder_bandit | 65 | 6 | 2 | 2400 | 9 | 18 | copper_ore:2 |
| chapel_guard | 85 | 7 | 4 | 3000 | 12 | 24 | scrap:2 |
| ember_wraith | 70 | 8 | 1 | 2000 | 14 | 26 | emberleaf:2 |
| bellkeeper | 240 | 12 | 5 | 3000 | 80 | 100 | iron_ingot:3 |

Normal enemies have a 5% copper equipment drop, uniform among six types, with rarity Common/Fine/Rare weighted 85/13/2. Bellkeeper has a guaranteed Rare copper_sword on first kill, plus normal material reward. Boss every third attack has 1.8x attack with a visible bell telegraph during its preceding interval. Initial numbers are tuneable; do not claim balanced before measured scenarios and human playtests.

## Task 1: Executable project and test harness

**Files:** create `project.godot`, `.gitignore`, `tools/run-tests.ps1`, `tests/run.gd`, `tests/checks.gd`, `tests/test_boot.gd`, `ui/main.tscn`, `docs/development.md`.
**Interfaces:** `Checks.equal(actual, expected, message)` records failures; `Checks.truth(value, message)` records failures; `run.gd` loads `test_*.gd` and invokes `run(checks)`; exits nonzero on any failure.

- [ ] Locate a Godot 4 stable binary or acquire the official portable release and matching templates during execution; record version, source URL, checksum, and path in development documentation. Inspect existing Android SDK packages. Keep local binaries outside tracked files.
- [ ] Write and run the initial failing smoke check; runner must return failure for the intentionally false assertion, then replace it with the actual boot check.

```gdscript
# tests/test_boot.gd
extends RefCounted
func run(c):
    c.equal(ProjectSettings.get_setting("application/config/name"),
        "Ashen Covenant", "project name")
```

- [ ] Configure portrait logical viewport 432×960, canvas_items scaling, Compatibility rendering, and an initial empty main scene. Main scene will be replaced by the actual shell in Task 8. Ignore `.godot/`, `build/`, `*.keystore`, `*.jks`, `.env`, and local tool-path files.
- [ ] Implement runner using `SceneTree`, iterate sorted filenames under `res://tests/`, load each test, aggregate checks, and call `quit(1 if failures > 0 else 0)`. Assertions must not rely on Godot debug-only `assert`. PowerShell accepts `-GodotPath` and forwards engine exit status. Check parsing/import errors in captured engine output as failures as well.
- [ ] Run `& $GodotPath --headless --path . --editor --import`, then `& $GodotPath --headless --path . --script res://tests/run.gd`. Expect clean import and one passing suite. Commit only task files with message `build: establish Godot project and headless checks`.

## Task 2: Validated content and fresh state

**Files:** create `game/content/catalog.gd`, `game/state/game_state.gd`, `game/state/state_validator.gd`, `data/items.json`, `data/recipes.json`, `data/activities.json`, `data/enemies.json`, `data/rarities.json`, `tests/test_catalog.gd`, `tests/test_state.gd`.
**Interfaces:** `Catalog.load_directory(path: String) -> Dictionary`, `Catalog.validate(data: Dictionary) -> Array[String]`, `GameState.fresh(seed: int) -> Dictionary`, `StateValidator.errors(state: Dictionary, catalog: Dictionary) -> Array[String]`. Catalog load returns `{ok,code,data,errors}` rather than the state-operation envelope.

- [ ] Add failing checks for exact counts, all IDs resolvable, impossible recipes rejected, independent fresh states, unknown item ID, negative/inexact amounts, and excessive array lengths.

```gdscript
func run(c):
    var catalog = Catalog.load_directory("res://data")
    c.truth(catalog.ok, "valid content")
    c.equal(catalog.data.items.size(), 40, "40 real definitions")
    c.equal(catalog.data.recipes.size(), 20, "20 recipes")
    var s = GameState.fresh(42)
    s.materials["copper_ore"] = -1
    c.truth(not StateValidator.errors(s, catalog.data).is_empty(), "reject negative")
    s.materials["copper_ore"] = 1.5
    c.truth(not StateValidator.errors(s, catalog.data).is_empty(), "reject fractional")
```

- [ ] Run the headless suite and verify the new missing classes cause failure.
- [ ] Populate every item/recipe/enemy from the fixture section. Add `name_key`, `description_key`, `icon_id`, category, and equipment/food/potion fields. Reject duplicate IDs, nonpositive durations, unresolved inputs/outputs, invalid chance weights, and cyclic prerequisites with no initial source. Build a source index from gathering, merchant, recipe, and enemy tables.

```gdscript
# Required numeric check before assigning imported counters.
static func is_counter(value: Variant) -> bool:
    if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
        return false
    return is_finite(float(value)) and float(value) == floor(float(value)) \
        and value >= 0 and value <= 1000000000000
```

- [ ] Complete the factory and validator for every common state field, including `next_uid`, inventory limits, RNG decimal string, locale whitelist, time bounds, and references. Validate incoming Dictionary structure before reading children. Preserve unsupported-version saves as files rather than attempting a reset.
- [ ] Run all tests; deliberately remove a recipe ingredient definition and verify validation fails, then restore it. Commit `feat: define validated foundation content and player state`.

## Task 3: Inventory transactions and equipment

**Files:** create `game/inventory/inventory.gd`, `game/inventory/equipment.gd`, `tests/test_inventory.gd`.
**Interfaces:** `Inventory.transact(state, inputs, outputs, catalog) -> Dictionary`; `Equipment.equip(state, uid, catalog) -> Dictionary`; `Equipment.preview_salvage(state, uids, catalog) -> Dictionary`; `Equipment.salvage(state, uids, catalog) -> Dictionary`. All use the common result envelope; preview also includes `items` and `materials`.

- [ ] Write atomicity, protection, overflow, and identical-stack tests.

```gdscript
func run(c):
    var catalog = Catalog.load_directory("res://data").data
    var s = GameState.fresh(42)
    s.materials["copper_ore"] = 1
    var before = s.duplicate(true)
    var r = Inventory.transact(s, {"copper_ore": 2}, {"copper_ingot": 1}, catalog)
    c.truth(not r.ok, "insufficient material rejected")
    c.equal(s, before, "no partial debit")
    var sword_uid = s.equipped.weapon
    c.truth(not Equipment.salvage(s, [sword_uid], catalog).ok, "equipped protected")
```

- [ ] Run to confirm failure; implement validation before any copy is mutated. Insufficient input returns `insufficient_material`; equipment in any preset returns `protected_equipment`. Reject duplicates in a salvage UID list. All selected salvage entries succeed together or none do.

```gdscript
# Transaction skeleton after input/output ID and integer validation.
for item_id in inputs:
    if state.materials.get(item_id, 0) < inputs[item_id]:
        return {"ok": false, "code": "insufficient_material", "state": state, "events": []}
var next = state.duplicate(true)
for item_id in inputs:
    next.materials[item_id] -= inputs[item_id]
for item_id in outputs:
    next.materials[item_id] = next.materials.get(item_id, 0) + outputs[item_id]
```

- [ ] Route equipment outputs through a separate equipment-entry creation path, not the material counters. Merge identical properties, retain lock/favorite flags, and send new variants beyond 1,000 to overflow. Each equipment yields one scrap per Common-quality unit, two Fine, four Rare; Worn yields one. Overflow transfer does not regenerate properties or RNG.
- [ ] Add tests for locked/favorite/preset preservation, output-cap overflow, and selling merchant items at at most 25% purchase price. Run suite and commit `feat: add atomic inventory and protected equipment operations`.

## Task 4: Production, XP, and bounded activity queue

**Files:** create `game/progression/progression.gd`, `game/activities/activity_queue.gd`, `game/activities/production.gd`, `tests/test_production.gd`, `tests/test_queue.gd`.
**Interfaces:** `Progression.level_for_xp(xp: int) -> int`; `ActivityQueue.enqueue(state, step, catalog) -> Dictionary`; `ActivityQueue.cancel(state, step_id, catalog) -> Dictionary`; `Production.start_cycle(state, catalog) -> Dictionary`; `Production.finish_cycle(state, catalog) -> Dictionary`.

- [ ] Add tests for level thresholds, 20-step limit, reserved inputs, one-time refund, level/output/cycle targets, and stop/skip behavior.

```gdscript
func run(c):
    c.equal(Progression.level_for_xp(0), 1, "level one")
    c.equal(Progression.level_for_xp(25), 2, "threshold")
    var cat = Catalog.load_directory("res://data").data
    var s = GameState.fresh(42)
    var step = {"id":"q1", "activity_id":"mine_copper", "target_kind":"cycles",
        "target_value":2, "skip_blocked":false, "cycles_done":0, "outputs_done":0}
    var queued = ActivityQueue.enqueue(s, step, cat)
    c.truth(queued.ok, "valid step accepted")
    var started = Production.start_cycle(queued.state, cat)
    c.equal(started.state.active.due_ms, 3000, "event due in three seconds")
```

- [ ] Run red, then implement integer level thresholds by bounded search rather than floating sqrt. Track mastery cycles separately from XP. Apply duration modifiers when each cycle begins and persist the resulting due timestamp.
- [ ] Debit/reserve ingredients at start. At completion, issue one output transaction, XP, and mastery increment; clear reservation before starting the next cycle. Cancellation refunds the stored reservation, not a recomputed recipe. Missing requirements stop the queue with a translated code and item/skill arguments.
- [ ] Output targets count only the primary output earned by that step. Gather side drops do not satisfy it. A level target already reached advances without executing another cycle. Limit consecutive skipped steps to queue length to prevent busy loops.
- [ ] Test cancel twice, change tools during cycle, and an unreachable level requirement with skip on/off. Run suite and commit `feat: implement production progression and activity queues`.

## Task 5: Melee combat and event simulation

**Files:** create `game/combat/combat_stats.gd`, `game/combat/combat.gd`, `game/simulation/event_order.gd`, `game/simulation/simulation.gd`, `tests/test_combat.gd`, `tests/test_simulation.gd`.
**Interfaces:** `CombatStats.compute(state, catalog) -> Dictionary`; `Combat.start(state, enemy_id, catalog) -> Dictionary`; `Combat.resolve_event(state, event_kind, catalog) -> Dictionary`; `Simulation.command(state, command, catalog) -> Dictionary`; `Simulation.advance(state, elapsed_ms: int, catalog) -> Dictionary`.

- [ ] Add deterministic chunk-equivalence and defeat tests. Save and restore the RNG state through every result, and ensure test state comparison includes queues, consumption, combat timers, rewards, and RNG.

```gdscript
func run(c):
    var cat = Catalog.load_directory("res://data").data
    var start = GameState.fresh(42)
    var cmd = {"id":"test-start", "type":"queue_add", "payload":{
        "id":"fight", "activity_id":"hunt_ash_rat", "target_kind":"cycles",
        "target_value":10, "skip_blocked":false, "cycles_done":0, "outputs_done":0}}
    start = Simulation.command(start, cmd, cat).state
    var whole = Simulation.advance(start, 60000, cat).state
    var chunks = start
    for i in range(60):
        chunks = Simulation.advance(chunks, 1000, cat).state
    c.equal(whole, chunks, "online and offline have identical outcomes")
```

- [ ] Run red, implement combat stats with fixture values and rarity multipliers Worn0.8/Common1/Fine1.1/Rare1.25; apply to equipment bonuses only. Bladecraft adds 0.1 percentage point accuracy/level beyond1 (cap99%), Might adds1 attack per5 levels, Warding adds1 armor per5 levels. On kill split fixture XP equally among those three skills using integer floor, assigning remainder to Bladecraft.
- [ ] Implement damage `max(1, floor(attack * 100.0 / (100.0 + armor * 5)))`; roll hit then crit, use the persisted RNG, and never consume RNG for visual effects. All enemies hit95% with no crit. A 1-second spawn interval follows kills; HP persists between fights. Out of combat recover1 HP/second up to max.
- [ ] Event priority at equal timestamps: expire buffs → consume scheduled potion → player attack → enemy attack → food/defeat resolution → reward if player alive and enemy dead → production completion → next queue step. If player attack kills, suppress the dead enemy's attack. HP≤0 means defeat before food can rescue. Food triggers only for living player at/below threshold, one item per damage event; healing potion obeys its cooldown. Guard/fury cannot extend themselves before expiry. Death clears combat queue execution and returns to village without gear loss.

```gdscript
# Central loop must retain a due event across arbitrary advance chunk boundaries.
var target_ms = state.sim_ms + elapsed_ms
# Resolve the earliest due event <= target_ms using EventOrder priorities;
# then schedule the next event from its actual completion time, never frame time.
# At return set sim_ms to target_ms; do not add arbitrary frame-based bonuses.
```

- [ ] Implement all command types from the shared contract, including lock/favorite, presets, and waiting-step reorder. Processed command IDs are stored in a bounded history of128 entries; synchronous session serialization prevents concurrent replay. Duplicate commands return success without a second mutation. Commands use validated payloads; unknown types return `unknown_command`. A command is recorded only on success; a rejected command can be retried after its blocking condition changes.
- [ ] Persist the next passive-heal deadline instead of recovering HP once per advance call. Process quest events immediately in chronological order. Aggregate offline report counters by item/skill and retain at most100 recent presentation events per batch; the event counter still advances for every domain event. Drain batches through the session coordinator to avoid accumulating hours of visual events in memory.
- [ ] Test zero elapsed, negative elapsed rejected, resource exhaustion, no food defeat, simultaneous attacks, buff expiry at attack time, rare loot overflow, boss first reward once, and 24-hour chunk equivalence. Run suite and commit `feat: add deterministic melee combat and idle simulation`.

## Task 6: Playable tutorial, sources, and first boss unlock

**Files:** create `game/quests/quest_book.gd`, `data/quests.json`, `tests/test_quests.gd`; modify `Simulation` to apply quest events and `GameState` for progress counters.
**Interfaces:** `QuestBook.apply_events(state, events, catalog) -> Dictionary`; `QuestBook.visible_objective(state, catalog) -> Dictionary`; `QuestBook.is_enemy_unlocked(state, enemy_id) -> bool`.

- [ ] Write a complete tutorial integration test using real gathering/crafting/combat commands. Tutorial: gather4 copper ore → smelt2 ingots → gather1 ash log → craft/equip copper sword → defeat3 ash rats. Each objective auto-completes on verified events, not button presses.

```gdscript
func run(c):
    var cat = Catalog.load_directory("res://data").data
    var s = GameState.fresh(42)
    c.truth(QuestBook.is_enemy_unlocked(s, "ash_rat"), "starter available")
    c.truth(not QuestBook.is_enemy_unlocked(s, "bellkeeper"), "boss gated")
    var r = QuestBook.apply_events(s,
        [{"id":1, "type":"item_gained", "sim_ms":0,
          "args":{"item_id":"copper_ore", "amount":4}}], cat)
    c.equal(r.state.quests.first_blade.step, 1, "verified event advances quest")
```

- [ ] Run red; implement event counters that track lifetime progress so useful actions before a quest is visible still count. Quest rewards are given through idempotent reward flags. First tutorial completion gives30 gold and10 cooked_minnow, unlocking the next two enemy choices.
- [ ] Unlock cinder_bandit after5 grave_thrall kills; chapel_guard after5 cinder_bandit; ember_wraith after5 chapel_guard; bellkeeper after5 ember_wraith and Smithing10. The remaining hollow_hound/grave_thrall unlock after tutorial. Boss first kill lights the village beacon, shows chapter completion, and leaves repeat farming available.
- [ ] Provide source-link data and translated block reasons for every target. Add tests for repeating the same quest event ID and loading completed quests; neither repeats rewards. Commit `feat: connect tutorial objectives and Cinderwatch progression`.

## Task 7: Recoverable saves and offline accounting

**Files:** create `game/save/save_codec.gd`, `save_repository.gd`, `offline_clock.gd`, `tests/test_save.gd`, `tests/test_offline.gd`, `tests/fixtures/schema0.json`.
**Interfaces:** `SaveCodec.encode(state) -> String`; `SaveCodec.decode(text, catalog) -> Dictionary`; `SaveRepository.write_snapshot(directory, state, catalog) -> Dictionary`; `SaveRepository.read_snapshot(directory, catalog) -> Dictionary`; `OfflineClock.elapsed_ms(saved_ms: int, now_ms: int) -> int`; `OfflineClock.resume(state, now_ms: int, catalog) -> Dictionary`.

- [ ] Add isolated temporary-directory tests for damaged primary save, power interruption, unsupported schema, oversized import, RNG roundtrip, rollback clocks, and reopening a committed offline report.

```gdscript
func run(c):
    c.equal(OfflineClock.elapsed_ms(2000, 1000), 0, "clock rollback")
    c.equal(OfflineClock.elapsed_ms(0, 90000000), 86400000, "24 hour cap")
    var cat = Catalog.load_directory("res://data").data
    var s = GameState.fresh(42)
    s.saved_unix_ms = 1000
    var resumed = OfflineClock.resume(s, 61000, cat)
    var reopened = OfflineClock.resume(resumed.state, 61000, cat)
    c.equal(reopened.state.materials, resumed.state.materials, "no duplicate reward")
    c.equal(reopened.state.sim_ms, resumed.state.sim_ms, "time consumed once")
```

- [ ] Run red; implement JSON envelope `{schema_version, revision, payload, checksum}` with SHA256 over the exact encoded payload string. Checksum detects corruption, not cheating. Validate decoded state before promoting it to active. Reject imports above5 MiB before parsing. Preserve intact files on validation failure.
- [ ] Write alternating generation files through a temporary file, flush/close, reread and validate, then rename to an unused generation name. Keep the newest three valid committed generations (current plus two backups); ignore incomplete `.tmp` files. Choose latest valid revision when loading. Only prune older generations after success; never delete the last valid save.
- [ ] Define schema0 migration as the same state without settings/mastery_cycles/next_uid; fill defaults and infer next_uid from equipment UIDs. Build schema0.json by encoding a fresh seed42 state with those three keys removed and schema_version set to0; use that fixed file for migration tests. Unknown future schema returns `newer_save_version`, with file retained. Imported progress cannot include paid entitlements. A successful import receives a new local save revision higher than the current local generation, while preserving simulation and RNG state; external revision cannot override generation ordering.
- [ ] Resume on a deep copy; apply capped delta through Simulation, set saved_unix_ms to current observed wall time even on rollback, and persist once before showing the report. On disk failure keep the original durable checkpoint and show a retry error; never silently pretend progress is saved. Resume report acknowledgment updates UI state only.
- [ ] Test kill-after-temp-write and kill-after-commit before report acknowledgement. Run suite and commit `feat: persist recoverable saves and exact offline progress`.

## Task 8: Functional portrait interface

**Files:** create `game/session/game_session.gd`, UI shell/screens/components listed in file map, `localization/id.csv`, `localization/en.csv`, `tests/test_session.gd`, `tests/test_ui_smoke.gd`.
**Interfaces:** `GameSession.submit(command: Dictionary) -> Dictionary`; `GameSession.load_or_create() -> Dictionary`; signals `state_changed(state)`, `events_ready(events)`, `persistence_failed(code)`. Screens consume state and emit commands, never mutate state directly.

- [ ] Write a session test submitting identical buy commands twice and checking one gold debit, plus a smoke test that instantiates all five screens with a fresh state.

```gdscript
func run(c):
    var scene = load("res://ui/main.tscn").instantiate()
    c.equal(scene.get_node("SafeArea/Layout/Navigation").get_child_count(),
        5, "five usable destinations")
    scene.free()
```

- [ ] Run red; build actual screens: village objective/merchant/beacon; explore enemy choices/combat/food; skills activities/recipes/source links; inventory compare/equip/lock/salvage; character stats/food/potion/settings. Queue editor handles adding/reordering waiting steps and cancellation with a refund explanation. No dead buttons or pretend future features.
- [ ] Use a shared activity bar showing action, progress, remaining target, and stop reason. Offline report shows gross gains and consumed resources separately; expose continue/change-activity actions. Error codes are translated with arguments instead of raw implementation messages.
- [ ] Serialize UI submissions and protect buttons during a transaction. Use monotonic elapsed time while active, checkpoint every15 seconds and on important transactions/pause; when returning from pause use wall-time catch-up once and reset the monotonic anchor. Avoid re-awarding live session time at resume.
- [ ] Run UI smoke and domain suites. Manually execute tutorial across all screens, cancel and restart crafting, change locale, and restart the game. Commit `feat: connect portrait game screens to persistent simulation`.

## Task 9: Dark fantasy art, motion, and readability

**Files:** create `ui/theme.tres`, `ui/art/village_stage.tscn`, `ui/art/battle_stage.tscn`, assets and provenance manifest; modify screen components and add `tests/test_presentation.gd`.
**Interfaces:** `VillageStage.render_state(state: Dictionary) -> void`; `BattleStage.play_events(events: Array) -> void`; both expose `set_reduced_motion(enabled: bool) -> void`. Presentation events do not feed gameplay mutations.

- [ ] Define palette charcoal `#111214`, panel `#1C2023`, ivory `#ECE7DC`, amber `#D9A65C`, danger `#E57B79`, occult `#B49ACB`. Use ivory for body text; reserve dim colors for decoration unless contrast is measured. At logical width432 use19px body text and58px touch heights as baseline, then verify device scaling rather than claiming dp equivalence automatically.
- [ ] Produce original village, battlefield, hero layers, seven enemy portraits/sprites, and40 distinguishable item icons. Use the image generation skill for raster creation where available; keep reusable text and buttons native. Use generated imagery as source assets requiring inspection, not a screenshot of an entire UI. Record origin, generation/source notes, license status, and intended usage per file in `assets/manifest.json`.
- [ ] Compose village from sky, architecture, foreground, fog, and ember layers. Hero silhouette remains recognizable on a small phone. Combat has a clear player/enemy separation and protected HP/readout area. Item rarity uses border, icon marker, and text. Compare equipment in aligned rows with positive/negative labels.
- [ ] Animate idle breathing over3 seconds, attack anticipation120ms, impact80ms, recovery200ms; cap damage-number population at12. Reduced motion removes parallax, screen shake, drifting fog, and floating numbers; replace them with static highlights. Battery mode targets30 FPS and fewer particles. SFX/music buses use stored settings; use original or clearly licensed audio and font assets.

```gdscript
func run(c):
    var stage = load("res://ui/art/battle_stage.tscn").instantiate()
    stage.set_reduced_motion(true)
    c.truth(not stage.get_node("AmbientParticles").emitting, "reduced motion")
    c.equal(stage.get_node("DamageReadout").mouse_filter,
        Control.MOUSE_FILTER_IGNORE, "effects cannot block input")
    stage.free()
```

- [ ] Capture and inspect village, combat, skills, inventory, and offline report at360×800, 432×960, and480×900 logical sizes, Indonesian/English and100%/130% font. Correct clipped text, weak contrast, inconsistent icon scale, and crowded cards before calling visual work complete. Keep screenshots in `docs/qa/screenshots/`. Commit `art: establish animated dark fantasy presentation`.

## Task 10: Android build, balance audit, and acceptance report

**Files:** create `export_presets.cfg`, `tools/check-content.ps1`, `tests/test_acceptance.gd`, `docs/qa/foundation-report.md`; update `docs/development.md` and content tuning only where evidence supports it.
**Interfaces:** CLI exports debug APK to `build/android/ashen-covenant-debug.apk`; build path stays ignored. QA report maps every acceptance result to test output, screenshot, or observed device behavior.

- [ ] Run source validation and the full domain/save/UI suite. Add a scripted progression test that mines, crafts, equips, heals, unlocks boss, defeats boss, saves, resumes, and confirms victory reward cannot repeat.

```gdscript
func run(c):
    var cat = Catalog.load_directory("res://data").data
    c.equal(cat.enemies.size(), 7, "six enemies and one boss")
    c.equal(cat.recipes.size(), 20, "complete production fixture")
    for seed in [1, 42, 999]:
        var state = GameState.fresh(seed)
        var result = Simulation.advance(state, 86400000, cat)
        c.truth(result.ok, "24h state remains valid")
        c.truth(StateValidator.errors(result.state, cat).is_empty(), "state invariants")
```

- [ ] Add non-idle 24-hour benchmarks using long combat/gathering targets and buff expiry; compare one large advance against unequal chunks. Measure time and peak memory, do not use the empty-queue test above as a performance claim. Profile before optimizing; keep chunk equivalence after changes.
- [ ] Measure tutorial completion time and first-boss route with starter, copper, and iron loadouts. Reject recipe dead ends and guaranteed profit buy/sell cycles. Adjust content constants with a note explaining observed problem and effect; rerun affected deterministic tests. Human 4-of-5 onboarding evaluation remains pending until real participants have played.
- [ ] Verify installed SDK/JDK compatibility against the official Godot documentation, pin engine/templates, and configure a debug export. Use `& $GodotPath --headless --path . --export-debug "Android" build/android/ashen-covenant-debug.apk`. The package ID for internal testing is `com.ashencovenant.prototype`; final publisher identity is chosen before release, not inferred from the working title.
- [ ] Run APK on an available Android emulator/device. Verify cold start, pause/resume, background kill, airplane-mode play, save recovery, notch/safe area, back navigation, audio settings, and font scale. If no device/emulator can run, deliver the build if available but report Android behavior as unverified; desktop screenshots never count as Android proof.
- [ ] Write acceptance report: feature inventory, exact engine/build version, test commands/results, screenshots, performance hardware, asset provenance gaps, known issues, and next milestone boundary. No billing/cloud/store-release claims. Commit `test: verify playable foundation and document Android readiness`.

## Rangkuman self-review rencana

Spec sections1–2 are expressed in the full tutorial loop; sections3–8 are implemented to milestone1 scope through Tasks2–6; section9 through Tasks8–9; section10 is preserved as no ads/no live purchases in this milestone; section11 through Tasks1–8; sections12–13 through Task10 and this milestone boundary. Section14 limits comparative claims and requires real playtest evidence.

The 40-item and20-recipe fixtures are enumerated and have sources. Melee uses three combat XP tracks alongside six support skills; this does not imply all15 final skills are implemented. The single active slot is shared between combat and production. Save timestamps and simulation timestamps are separate; reporting cannot award loot. The five Review Focus entries have owning tasks and explicit checks.

Manual visual assessment, Android testing, and human onboarding evaluation remain separate from automated domain tests. Each is reported honestly if it cannot be performed. No estimate of completion date is promised before the first working build and tooling checks.

## Execution handoff

Plan prepared; implementation has not started. User must review this written plan and select the execution method required by the active planning skill.

Recommended: **Subagent-driven** implementation with a fresh implementer/reviewer per task, because save, RNG, queues, and combat share contracts where a subtle mismatch can destroy player progress. Alternative: **Native**, one implementer in this session with an independent review at the end, reducing coordination overhead. Do not spawn implementers before the selected method and written plan are accepted.
