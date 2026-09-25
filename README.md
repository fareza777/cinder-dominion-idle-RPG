# Ashen Covenant — playable foundation 0.1

Idle RPG dark fantasy untuk Android. Gratis, tanpa iklan. Build ini untuk dimainkan dan dievaluasi, belum versi rilis publik.

## Mulai bermain

1. Pasang `build/android/ashen-covenant-0.1.apk` di Android 64-bit. Izinkan instalasi dari aplikasi pengirim berkas bila Android memintanya.
2. Di Desa, tekan **Lanjutkan perjalanan** untuk mengikuti jurnal: tambang tembaga, lebur ingot, kumpulkan kayu, buat dan kenakan pedang tembaga, lalu berburu tikus abu.
3. Masukkan aktivitas ke antrean. Satu aktivitas berjalan pada satu waktu; bahan crafting dipakai saat siklus dimulai.
4. Siapkan makanan sebelum berburu. Musuh berikutnya terbuka lewat progres; Bellkeeper menjadi tujuan wilayah pertama.
5. Progres tersimpan otomatis. Saat kembali, simulasi melanjutkan aktivitas maksimal 24 jam. Pengaturan menyediakan ekspor/impor cadangan.

## Isi build

- Cinderwatch, enam musuh biasa dan satu boss.
- Woodcutting, Mining, Fishing, Cooking, Smithing, Alchemy; tiga jalur perkembangan melee.
- 40 jenis item, 20 resep, rarity equipment, perbandingan statistik, lock/favorite, salvage, preset perlengkapan.
- Antrean 20 langkah dengan target siklus, hasil baru, atau level; pilihan melewati aktivitas yang belum bisa berjalan.
- Auto-combat, food/potion, loot, progres quest, pedagang, ringkasan offline dan cadangan save.
- Ilustrasi orisinal, bara bergerak, portrait pertarungan, musik suasana dan bunyi aksi; ukuran huruf, pengurangan gerak, mode hemat daya.

Pembelian kosmetik dan ekspansi adalah model bisnis yang direncanakan, belum diaktifkan. Semua isi build ini gratis.

## Batas versi

Ini fondasi satu wilayah. Kampanye lengkap, ranged/magic, pet, bangunan lengkap, affix/rune, cloud save dan Google Play Billing belum tersedia. Bahasa Indonesia diutamakan; pilihan Inggris belum menerjemahkan seluruh pesan sistem. Animasi berupa atmosfer dan portrait, belum animasi karakter penuh. Balance, variasi perangkat fisik, safe area dan font terbesar masih memerlukan playtest.

## Pengembangan

Buka `project.godot` dengan Godot **4.7.1** dan export template yang sama. Android menggunakan Compatibility renderer, ARM64 dan x86_64, Java 17 dan Android SDK. Preset ekspor adalah **Android**. APK saat ini ditandatangani debug; tidak siap diunggah sebagai rilis toko.

Pemeriksaan ringan: `godot --headless --path . --script tests/essential_checks.gd`. Regenerasi katalog melalui `python tools/build_content.py`. Sumber audio ada di `tools/make_audio.py`; font statis disiapkan dengan `tools/prepare_fonts.py` (fontTools).

Lihat `docs/qa/foundation-report.md` untuk bukti dan keterbatasan pemeriksaan, serta `assets/manifest.json` untuk asal aset.
