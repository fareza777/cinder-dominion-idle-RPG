# Ashen Covenant 0.26 — audit dan rekomendasi

Tanggal: 26 September 2026. Baseline commit: 85ec2fd. Audit solo, tanpa perubahan gameplay atau save.

## Cakupan dan batas bukti

Audit sumber mencakup konfigurasi Godot/Android, model, queue, combat/forecast, save/resume, Journey, Ascension, progression, Chronicle, Runeforge, workshop, inventory, onboarding dan audio director. Ledger dan laporan QA dibaca. Visual ditinjau dari capture runtime battle 0.25, onboarding 0.24, Ascension 0.26; gambar Refuge 0.18 hanya dipakai sebagai konteks historis, bukan bukti skin terbaru. Tidak ada fresh Android playthrough, profiler perangkat, pengukuran baterai, atau sesi dengar audio pada audit ini. 83 checks adalah hasil iterasi sebelumnya, bukan tes baru audit ini.

Estimasi tamat 40–80 jam yang disampaikan sebelumnya belum mempunyai simulasi rute atau playtest pendukung. Perlakukan sebagai dugaan awal, bukan angka produk atau hasil audit. Kurva pacing perlu diukur sebelum menetapkan durasi tamat.

## Penilaian utama

Fondasi playable sudah luas: 96 item, 117 aktivitas, 34 encounter, 64 resep, 39 tujuan Journey, 25 kontrak, sembilan skill hingga level 100. Material planner, forecast, loadout, offline report, protected salvage, save generations dan panduan bertarget adalah aset penting. Jumlah konten belum setara dengan kedalaman pilihan. Kesenjangan terbesar ada pada variasi build, kesinambungan progres, presentasi battle dan bukti performa Android.

## Temuan prioritas

| Prioritas | Bukti | Dampak | Rekomendasi |
|---|---|---|---|
| P0 | game/chronicle.gd: points_earned membatasi 10 poin pada 2.500 gabungan combat XP; talent hanya ATK, armor, gold | Pohon progres cepat selesai; keputusan berikutnya didominasi angka gear | Tambah pilihan yang mengubah cara bermain pada milestone, pertahankan poin lama dan respec |
| P0 | tools/ascension_content.py: empat tier mengulang kategori resep, menaikkan statistik dan XP | Banyak konten vertikal, sedikit alasan mencoba build berbeda | Tambah identitas equipment/recipe, bukan sekadar tier baru |
| P0 | game/runeforge.gd: victories menjumlah regional tier 1–5 dan trial, tidak Apex | Pemain endgame tidak mendapat kemajuan regional dari hunt lanjutan | Tetapkan apakah semua encounter regional dihitung; jika ya gunakan data region dan migrasi/rekalkulasi aman. Ini gap desain, belum dipastikan bug terhadap spesifikasi |
| P0 | game/progression.gd: empat work order hanya minnow/copper/iron | Fitur persiapan idle tidak mengikuti Ascension | Work order sesuai tier/food pilihan, target durasi, preview seluruh rantai dan bottleneck |
| P0 | game/save_store.gd resume memanggil model.advance sinkron; advance mengulang event sampai target | Risiko jeda saat kembali dari 24 jam, belum terukur di Android | Ukur worst case, lalu pecah catch-up dalam anggaran waktu/frame sambil mempertahankan urutan RNG dan reward |
| P1 | ui/battle_stage.gd memakai crop portrait dengan translasi, rotasi kecil, arc dan flash | Pertempuran terasa seperti kartu yang bergerak | Bangun satu hero rig dan tiga keluarga musuh dengan pose dan timing berbeda |
| P1 | ui/ascension.gd memakai threshold ATK sword sebagai penentu next action | Review Apex bisa muncul meskipun armor/food/skill masih kurang | Satu target encounter dengan checklist readiness berbasis forecast; pertahankan kebebasan browse |
| P1 | ui/pages.gd inventory membuat card untuk semua gear; model mengizinkan 1.000 gear entries | Scroll panjang dan potensi banyak node; belum ada benchmark penuh | Filter slot/quality/upgrade, sort dan pagination/virtualization jika profil membuktikan perlu |
| P1 | game/chronicle.gd daily berisi tiga tugas tetap dan reward tetap | Variasi dan relevansi hadiah endgame terbatas | Pilihan bounty sesuai tier, carry-over dipertahankan, hadiah deterministik relevan |
| P1 | ui/audio_director.gd memuat empat WAV dan hanya menerima AudioStreamWAV | Loop musik pendek; konversi format tidak cukup dengan mengganti file | Dukung Ogg stream/loop; pisahkan bus, uji transisi dan variasi musikal |
| P1 | save version tetap 1 dan validasi menolak ID tidak dikenal | Menghapus/rename konten kelak dapat membuat save lama gagal validasi | Migration chain sebelum validasi final, alias ID dan fixture save lintas versi |
| P2 | services/commerce.gd dan data/commerce.json hanya seam disabled | IAP/AdMob belum siap lewat toggle | Rancang entitlement, restore dan transaksi idempotent sebelum SDK; jangan aktifkan pada tahap audit |

## Visual dan art

Tema metal gelap/perunggu sudah konsisten, tetapi frame bertumpuk membuat hampir semua elemen memiliki bobot visual yang sama. Battle capture memperlihatkan portrait kecil di dalam banyak bingkai sementara tombol utilitas memakan ruang besar. Pada Ascension sempit, banner dan prerequisites menghabiskan layar sebelum equipment terlihat.

Perbaikan: satu frame utama per panel; baris sekunder lebih ringan; satu primary action; header ringkas. Pada Ascension, tampilkan target equipment, manfaat dan bahan yang kurang di atas, sedangkan artwork menjadi banner ringkas. Pada battle, prioritaskan arena, HP, serangan berikutnya dan hasil hunt; satukan utilitas dalam panel ringkas. Tetap gunakan teks English langsung seperti `Craft Steel Sword`, `Needs 12 ore`, `Food for ~20 fights` dan `Queue complete`.

Batch art berikut sebaiknya terukur: satu hero berlapis dengan idle/attack/hit/guard/death/victory; tiga archetype enemy; tiga arena berlapis; ikon armor/tools/food lanjutan yang kini memakai alias lama; ikon relic/rune yang khas. Buat art bible untuk perspektif, cahaya, siluet, palet, ukuran dan safe area. Gambar hasil generate harus disiapkan layer dan rig; tidak otomatis menjadi animasi berkualitas. Pertahankan portrait sebagai inspect art.

Gunakan anticipation, contact dan recovery yang jelas, material-specific impact, telegraph serangan khusus, kabut/lilin ringan, dan perubahan visual Refuge setelah upgrade. Efek tidak mengubah waktu simulasi atau hasil hit. Reduced motion harus tetap menunjukkan status lewat ikon/teks. Jangan menambah ornament di belakang teks.

## Gameplay dan progression

Alur yang disarankan: pilih satu target upgrade → lihat bahan dan waktu → jalankan supply chain → pasang hasil → lihat perubahan forecast → coba musuh berikut → kembali farming dengan alasan jelas. Pemain boleh memilih aktivitas bebas; recommended action tidak boleh memaksa jalur tunggal atau menyamakan ATK cukup dengan aman bertarung.

Tambahkan kedalaman lewat tiga identitas build lebih dahulu: Warden untuk guard/sustain, Reaver untuk risiko/damage, Vanguard untuk break/tempo. Dua atau tiga pilihan kemampuan per identitas lebih berguna daripada puluhan passive +1. Status bleed, stagger atau ward harus punya counter yang jelas, maksimal sedikit ikon pada layar, dan bisa dipakai sistem auto-combat tanpa tap wajib. Semua perubahan wajib ikut forecast dan offline resolver yang sama.

Gear dapat mendapat satu efek khas atau bonus dua bagian yang mengubah interaksi. Sisakan equipment non-set yang kompetitif. Pertahankan crafting/refinement deterministik; bila menambah loot langka, sediakan fragments atau target craft agar farming punya akhir yang terlihat. Berikan preview upgrade sebelum memakai resource. Jangan memperpanjang grind hanya dengan menaikkan XP.

Retention: objective sesi 5–10 menit, queue untuk jeda panjang, bounty yang relevan dan pilihan weekly hunt dengan modifier sederhana. Ini target desain, belum durasi build sekarang. Hindari streak yang menghapus progres dan kewajiban login pada jam tertentu. Endgame berikutnya dapat berupa dungeon pendek bercabang setelah loop inti terukur. Prestige/reset ditunda sampai jelas bagian mana yang menyenangkan untuk diulang.

Audit ekonomi harus mencatat milestone first sword, first boss, gear tiap tier, first Apex dan final Apex; waktu total supply chain, food spent, death, XP/hour serta fragment/hour. Ukur jalur pemula dan efisien. Talent cepat mentok, skill combat yang benefit-nya jarang berubah, dan reward awal yang dibawa ke late game perlu diperbaiki dengan data ini.

## Engine dan arsitektur

Tetap gunakan Godot dan 2D. Tidak ditemukan bukti bahwa mengganti engine akan menyelesaikan kekurangan sekarang. Built-in 2D skeleton/cutout dapat dipakai untuk prototype rig; validasi workflow pada versi terpasang karena tutorial resmi memperingatkan sebagian materi belum diperbarui untuk 4.7.

Pisahkan tanggung jawab besar main.gd secara bertahap: navigation/modal, lifecycle/save, presenter layar dan audio. Jangan rewrite seluruh sistem. Gunakan schema/typed resource atau validasi katalog untuk persyaratan, hasil recipe, unlock graph dan asset reference. Terus pertahankan ID stabil.

Model berjalan tiap frame; UI refresh tiap 0,15 detik; save tiap 15 detik. Ini bukan otomatis masalah, tetapi perlu profile. Prioritaskan resume 24 jam, inventory besar, save write dan battle. Optimasi kandidat: cache derived stats dengan invalidation eksplisit, update label saat nilai berubah, hentikan redraw yang tidak perlu, batch produksi hanya saat tidak melewati perubahan penting. Jangan mengagregasi combat dengan formula rata-rata yang mengubah RNG/reward.

14 WAV sumber berjumlah 35.222.696 byte; itu ukuran sumber, bukan bukti ukuran RAM atau kontribusi APK yang sama. Coba Ogg untuk musik, WAV untuk cue pendek, lalu bandingkan CPU, ukuran dan kualitas. Mixer Music/Ambience/SFX/UI mempermudah ducking dan pengaturan. Tambah variasi motif dan impact; kualitas suara belum dapat dinilai lewat kode saja.

Target penerimaan yang diusulkan: mode hemat 30 fps stabil pada perangkat sasaran; sentuhan terasa langsung; proses resume menampilkan progress bila butuh waktu; tidak ada reward ganda ketika pause/resume; tidak ada clipping pada 360x800 dengan font 130%. Angka performa harus dicatat pada perangkat nyata, bukan dianggap sudah tercapai.

## Fitur dan kesiapan rilis

Paling berguna berikutnya: pinned upgrade, tier-aware work orders, inventory sort/slot filters, loadout comparison, bestiary dengan drop/unlock/counter, session hunt summary, queue finish estimate dan notifikasi opt-in jika kelak dibutuhkan. Cloud save dapat menyusul setelah save migration dan konflik antarperangkat dirancang.

Monetisasi kosmetik memerlukan slot tampilan yang nyata: cloak/weapon appearance, camp decoration, portrait/frame. Expansi harus menambah wilayah dan mekanik, tanpa merusak akses ke progres yang sudah dibeli. Rewarded ads, bila dipilih, tidak dijadikan solusi wajib atas pacing yang sengaja diperlambat. Integrasi yang ada belum memproses pembelian atau iklan sungguhan. Audit ini bukan verifikasi kebijakan toko atau kesiapan legal.

## Urutan pengerjaan yang disarankan

1. **Kejelasan dan konsistensi:** target upgrade, readiness checklist, work order lanjutan, keputusan hitungan Apex/Runeforge. Selesai bila satu upgrade bisa direncanakan sampai dipakai tanpa mencari panel secara manual.
2. **Battle visual:** satu hero, tiga enemy, satu arena sebagai vertical slice. Selesai bila serangan/guard/hit/death berbeda terbaca dan tidak mengubah hasil simulasi.
3. **Kedalaman build:** tiga identitas style dengan pilihan nyata; satu kelompok gear beridentitas. Selesai bila beberapa build punya tradeoff terukur pada beberapa encounter.
4. **Pacing dan kembali bermain:** simulasi milestone, bounty relevan, reward loop dan offline recap. Selesai bila durasi dan bottleneck punya angka yang bisa diperiksa.
5. **Produksi Android:** profile, migrasi save, lifecycle, distribusi release dan integrasi commerce terpisah setelah core stabil.

Tidak perlu menambah ratusan item, multiplayer, gacha atau mengganti engine pada iterasi terdekat. Selesaikan satu bagian kecil dengan mutu tinggi sebagai standar untuk konten berikutnya.

## Rujukan teknis

- Godot optimization: https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html — ukur bottleneck dan perangkat sasaran sebelum optimasi.
- Godot 2D skeletons: https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeletons.html — dukungan rig 2D; peringatan pembaruan versi pada halaman perlu diperhatikan.
- Godot audio importing: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_audio_samples.html — tradeoff format audio, kompresi dan CPU.
