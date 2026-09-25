# Ashen Covenant — Adventure preview 0.5

Idle RPG dark fantasy untuk Android. Gratis, tanpa iklan. Build ini untuk dimainkan dan dievaluasi, belum versi rilis publik.

## Mulai bermain

1. Pasang `build/android/ashen-covenant-0.5.apk` di Android 64-bit. APK memakai identitas aplikasi yang sama dengan 0.1–0.4 sehingga bisa dipasang sebagai pembaruan.
2. Seluruh antarmuka dan narasi game memakai **English**. Splash mengantar ke menu utama. Pilih **New game**, ikuti atau lewati intro, lalu baca empat tahap onboarding. **Continue journey** melanjutkan progres yang sudah ada.
3. Tekan **Guide →** di bagian atas layar. Panduan menunjukkan tujuan, alasan, lokasi aktivitas dan jumlah yang dibutuhkan. Tekan tindakannya, lalu **Begin · 4 cycles** (jumlahnya mengikuti tujuan) untuk memulai jumlah siklus yang tepat.
4. Tugas awal: 4 copper ore → 2 copper ingots → 1 ash log → Copper Sword → Equip item → 3 Ash Rats. Panduan lalu mengantar lewat musuh berikutnya hingga Bellkeeper, tanpa melompat langsung ke boss.
5. Pantau activity bar. **Queue** menampilkan tugas berjalan/menunggu, progres target, dan alasan terhambat. **Sources/Find** membantu mencari bahan yang kurang. Satu aktivitas berjalan pada satu waktu.
6. Buka **Food & survival guide** untuk belajar memancing, memasak, memilih makanan dan menyiapkan auto-heal. Perlengkapan hasil crafting harus dipasang dari **Bag**.
7. Progres tersimpan otomatis dan berlanjut maksimal 24 jam saat kembali. Menu **☰** tersedia dari dalam permainan. New Game meminta konfirmasi dan menyimpan cadangan terpisah; **Settings → Restore a previous journey** memulihkannya.

## Baru di 0.5

**Farming sesuai build.** Relic → Find a hunting ground membandingkan wilayah yang sudah terbuka: fragment per kemenangan, estimasi waktu, kebutuhan makanan dan hasil per menit. Pilihan yang lebih aman didahulukan. Tombolnya menyiapkan jumlah kemenangan menuju rank berikutnya. Hadiah ekspedisi meningkat menurut wilayah dan tier, sehingga melawan guardian memberi alasan yang lebih kuat daripada terus berburu musuh awal.

**Tiga guardian, tiga ancaman.** Thornbound Sentinel menembus separuh armor setiap serangan ketiga. Drowned Oracle memulihkan HP. Crowned Bellkeeper menghasilkan ledakan damage lebih besar. Ketiganya memakai portrait baru; persiapan menjelaskan kemampuan dan arena menampilkan hitung mundurnya. Angka healing dan damage bersamaan tetap terbaca.

**Tindakan selalu terjangkau.** Tombol Begin, Gather & craft dan Begin this order tetap di bawah dialog ketika detail digulir. Work orders menampilkan proyeksi kenaikan level dan waktu dalam jam/menit. Angka pemulihan makanan sudah memasukkan bonus Emberheart. Semua teks baru memakai English.

Review mendalam, temuan yang dibenahi, dan pekerjaan menuju kualitas produksi ada di `docs/review-0.5.md`. Ini peningkatan preview yang dapat dimainkan, belum klaim game AAA selesai.
## Baru di 0.4

**Mulai dengan satu tujuan.** Refuge menampilkan **YOUR NEXT MOVE** di atas ilustrasi: apa yang perlu dikerjakan, alasannya, dan tombol tindakannya. Mulai dari 4 copper ore. Roadmap menjelaskan jalur senjata pertama → perlengkapan dan makanan → Bellkeeper → ekspedisi. Rekomendasi kemudian mengikuti kondisi antrean, talent, relic, gear, makanan dan Smithing.

**Work orders untuk sesi panjang.** Setelah First Supplies, Refuge → Leave work for the refuge membuka empat jenis pesanan. Pilih 1/2/4 batch, tinjau hasil, XP dan estimasi waktu, lalu mulai. Satu batch Feed the Forge menghasilkan 500 copper ingots dari bahan yang dikumpulkan otomatis; empat batch bisa berjalan beberapa jam. Pesanan tidak memulai combat.

**Grind dengan tujuan.** Setiap musuh memberikan fragment relic tertentu secara pasti. Tiga relic memiliki masing-masing 10 rank; pilih satu untuk bonus attack, armor atau pemulihan makanan. Biaya upgrade meningkat, sementara tier ekspedisi lebih tinggi menghasilkan lebih banyak fragment. Tiga jalur talent menyediakan 15 rank dengan batas alokasi 10 poin, satu poin per 250 melee XP, dan reset gratis di luar combat. Tier baru memberi tujuan, build alternatif memberi alasan untuk mencoba lagi.

**Dunia setelah boss.** Peta dunia bergambar orisinal membuka Ashen Wilds, Drowned Sanctum dan Obsidian Crown setelah Bellkeeper. Setiap wilayah punya lima tier. Kalahkan tier sebelumnya sekali untuk lanjut; ulangi tier yang sudah terbuka untuk farming. Ada hadiah first-clear, fragment pasti, peluang 5% loot iron, dan Rare Iron Sword saat pertama menyelesaikan tier 5. Versi 0.5 memberi setiap wilayah portrait guardian orisinal dan mekanik serangan berbeda.

**Kembali dengan rencana.** Bounty board terbuka setelah First Supplies, berisi gathering, crafting dan hunting. Hadiah: gold, makanan, fragment bertema harian. Board yang belum selesai tetap tersimpan; board yang seluruh hadiahnya sudah diklaim berganti pada hari UTC berikutnya. Tidak ada streak yang hilang. Laporan offline kini mencakup fragment, talent points baru, dan tujuan berikutnya.

**Jalur monetisasi.** Kerangka provider untuk purchase, restore dan rewarded ads ada di `services/commerce.gd` / `data/commerce.json`. Semua provider masih nonaktif. Belum ada SDK Billing/AdMob, produk hidup, pembayaran, atau iklan. Ini fondasi pemisahan integrasi, bukan integrasi toko yang sudah selesai. Detail: `docs/monetization-boundary.md`.

## Fondasi gameplay (0.3)

- **Supply planner:** dari preview resep, pilih **Plan materials & craft automatically**. Tinjau seluruh bahan, urutan kerja, dan estimasi waktu sebelum **Gather & craft**. Mendukung 1–100 hasil; antrean harus kosong. Drop acak dan pembelian tetap manual, dengan petunjuk jelas jika dibutuhkan.
- **Fighting style:** Vanguard (seimbang, pukulan keempat 2×), Warden (+4 armor, −15% attack, skill pulih 8 HP), Reaver (+25% attack, −3 armor, skill 2.5×). Pilih di Hero/Explore sebelum bertarung. Skill dicoba setiap serangan keempat dan bisa meleset.
- **Refuge contracts:** delapan milestone opsional berhadiah gold, makanan, dan scraps. Klaim satu kali per campaign.
- **Rebuild Cinderwatch:** Ember Forge mempercepat produksi, Gateward menambah armor, Resting Hearth mempercepat pemulihan. Masing-masing tiga rank, dibeli dengan hasil bermain.
- **Persiapan lebih mudah:** Equip best, rencana sepuluh makanan pilihan, estimasi risiko/lama pertarungan, progres membuka musuh berikutnya. Statistik Owned equipment sekarang menghitung isi tas dengan benar.
- **Combat lebih hidup:** latar arena ilustrasi, flash dan angka damage, bar HP, waktu serangan, hitungan skill, telegraph Third Toll, ringkasan hadiah kemenangan/kekalahan.

Save lama tetap dapat dilanjutkan. Semua fitur baru gratis dan bekerja dengan progres offline. Perhitungan risiko adalah estimasi, bukan jaminan kemenangan; skill, miss dan critical membuat hasil bervariasi.

## Pembuka dan navigasi (0.2)

Splash bermerek, intro ilustrasi tiga adegan dengan fade dan gerakan kamera, menu utama, onboarding, panduan perjalanan 12 langkah, petunjuk permanen lintas layar, penjelasan recipe/loot/food, serta opsi antrean lanjutan yang bisa dibuka sesuai kebutuhan.

Settings mencakup About, Share, Rate, panduan bermain, replay intro/tips, ukuran teks, animasi, audio dan cadangan. Share membuka pemilih aplikasi Android; di komputer tersedia Copy message. Pesan dibagikan hanya setelah pemain memilih sendiri. Rate menjelaskan bahwa listing publik belum tersedia. Tidak ada tautan toko palsu. Koneksi rating bisa diaktifkan setelah URL toko resmi tersedia.

## Isi build

- Cinderwatch, enam musuh biasa, satu boss cerita, dan 15 tier ekspedisi di tiga wilayah tambahan.
- Woodcutting, Mining, Fishing, Cooking, Smithing, Alchemy; tiga jalur perkembangan melee.
- 40 jenis item, 20 resep, rarity equipment, perbandingan statistik, lock/favorite, salvage, preset perlengkapan.
- Antrean 20 langkah dengan target siklus, hasil baru, atau level; pilihan melewati aktivitas yang belum bisa berjalan.
- Auto-combat, food/potion, loot, progres quest, pedagang, ringkasan offline dan cadangan save.
- Ilustrasi orisinal, bara bergerak, portrait pertarungan, musik suasana dan bunyi aksi; ukuran huruf, pengurangan gerak, mode hemat daya.

Pembelian kosmetik, ekspansi dan AdMob rewarded ads opsional adalah arah monetisasi terbaru, belum diaktifkan. Semua isi build ini gratis.

## Batas versi

Ini preview Chapter I dan tiga rangkaian ekspedisi, belum kampanye penuh. Kampanye lengkap, ranged/magic, pet, sistem bangunan di luar tiga upgrade refuge, affix/rune, cloud save dan Google Play Billing belum tersedia. Seluruh antarmuka, katalog, lore, dan pesan sistem versi ini menggunakan English; pengaturan bahasa lama tidak lagi mengubah bahasa tampilan. Catatan historis dari save 0.1 dapat tetap memakai bahasa lamanya. Intro berupa ilustrasi bergerak dan teks, tanpa video 3D atau voice-over. Balance jangka panjang, retensi nyata, dan variasi perangkat fisik masih memerlukan playtest. Board harian menggunakan waktu perangkat; belum ada server waktu atau validasi ekonomi daring.

## Pengembangan

Buka `project.godot` dengan Godot **4.7.1** dan export template yang sama. Android menggunakan Compatibility renderer, ARM64 dan x86_64, Java 17 dan Android SDK. Preset ekspor adalah **Android**. APK saat ini ditandatangani debug; tidak siap diunggah sebagai rilis toko.

Pemeriksaan ringan: `godot --headless --path . --script tests/essential_checks.gd`. Regenerasi katalog melalui `python tools/build_content.py`. Sumber audio ada di `tools/make_audio.py`; font statis disiapkan dengan `tools/prepare_fonts.py` (fontTools).

Lihat `docs/review-0.5.md`, `docs/qa/polish-0.5-report.md` dan `docs/qa/foundation-report.md` untuk bukti dan keterbatasan pemeriksaan, serta `assets/manifest.json` untuk asal aset.
