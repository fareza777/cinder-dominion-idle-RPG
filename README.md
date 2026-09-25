# Ashen Covenant — Chapter I preview 0.3

Idle RPG dark fantasy untuk Android. Gratis, tanpa iklan. Build ini untuk dimainkan dan dievaluasi, belum versi rilis publik.

## Mulai bermain

1. Pasang `build/android/ashen-covenant-0.3.apk` di Android 64-bit. APK memakai identitas aplikasi yang sama dengan 0.1 / 0.2 sehingga bisa dipasang sebagai pembaruan.
2. Bahasa default adalah **English**. Splash mengantar ke menu utama. Pilih **New game**, ikuti atau lewati intro, lalu baca empat tahap onboarding. **Continue journey** melanjutkan progres yang sudah ada.
3. Tekan **Guide →** di bagian atas layar. Panduan menunjukkan tujuan, alasan, lokasi aktivitas dan jumlah yang dibutuhkan. Tekan tindakannya, lalu **Start this objective** untuk memulai jumlah siklus yang tepat.
4. Tugas awal: 4 copper ore → 2 copper ingots → 1 ash log → Copper Sword → Equip item → 3 Ash Rats. Panduan lalu mengantar lewat musuh berikutnya hingga Bellkeeper, tanpa melompat langsung ke boss.
5. Pantau activity bar. **Queue** menampilkan tugas berjalan/menunggu, progres target, dan alasan terhambat. **Sources/Find** membantu mencari bahan yang kurang. Satu aktivitas berjalan pada satu waktu.
6. Buka **Food & survival guide** untuk belajar memancing, memasak, memilih makanan dan menyiapkan auto-heal. Perlengkapan hasil crafting harus dipasang dari **Bag**.
7. Progres tersimpan otomatis dan berlanjut maksimal 24 jam saat kembali. Menu **☰** tersedia dari dalam permainan. New Game meminta konfirmasi dan menyimpan cadangan terpisah; **Settings → Restore a previous journey** memulihkannya.

## Baru di 0.3

- **Supply planner:** dari preview resep, pilih **Plan materials & craft automatically**. Tinjau seluruh bahan, urutan kerja, dan estimasi waktu sebelum **Start complete plan**. Mendukung 1–100 hasil; antrean harus kosong. Drop acak dan pembelian tetap manual, dengan petunjuk jelas jika dibutuhkan.
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

- Cinderwatch, enam musuh biasa dan satu boss.
- Woodcutting, Mining, Fishing, Cooking, Smithing, Alchemy; tiga jalur perkembangan melee.
- 40 jenis item, 20 resep, rarity equipment, perbandingan statistik, lock/favorite, salvage, preset perlengkapan.
- Antrean 20 langkah dengan target siklus, hasil baru, atau level; pilihan melewati aktivitas yang belum bisa berjalan.
- Auto-combat, food/potion, loot, progres quest, pedagang, ringkasan offline dan cadangan save.
- Ilustrasi orisinal, bara bergerak, portrait pertarungan, musik suasana dan bunyi aksi; ukuran huruf, pengurangan gerak, mode hemat daya.

Pembelian kosmetik dan ekspansi adalah model bisnis yang direncanakan, belum diaktifkan. Semua isi build ini gratis.

## Batas versi

Ini preview satu wilayah. Kampanye lengkap, ranged/magic, pet, sistem bangunan di luar tiga upgrade refuge, affix/rune, cloud save dan Google Play Billing belum tersedia. Inggris menjadi bahasa utama termasuk pesan sistem dan lore; pilihan Indonesia masih ada, tetapi alur baru belum seluruhnya dilokalkan. Catatan historis dari save 0.1 dapat tetap memakai bahasa lamanya. Intro berupa ilustrasi bergerak dan teks, tanpa video 3D atau voice-over. Balance dan variasi perangkat fisik masih memerlukan playtest.

## Pengembangan

Buka `project.godot` dengan Godot **4.7.1** dan export template yang sama. Android menggunakan Compatibility renderer, ARM64 dan x86_64, Java 17 dan Android SDK. Preset ekspor adalah **Android**. APK saat ini ditandatangani debug; tidak siap diunggah sebagai rilis toko.

Pemeriksaan ringan: `godot --headless --path . --script tests/essential_checks.gd`. Regenerasi katalog melalui `python tools/build_content.py`. Sumber audio ada di `tools/make_audio.py`; font statis disiapkan dengan `tools/prepare_fonts.py` (fontTools).

Lihat `docs/qa/gameplay-0.3-report.md` dan `docs/qa/foundation-report.md` untuk bukti dan keterbatasan pemeriksaan, serta `assets/manifest.json` untuk asal aset.
