# Spesifikasi desain: Ashen Covenant

Tanggal: 25 September 2026.
Status: rancangan untuk ditinjau pengguna; belum merupakan game yang sudah dibuat.
Ashen Covenant adalah nama kerja internal, bukan nama publik yang sudah diperiksa ketersediaannya.

## 1. Brief yang disepakati

- Android untuk dirilis ke publik.
- Idle RPG dengan kompleksitas dan hubungan antarsistem sekelas referensi Realm Idle.
- Dark fantasy, antarmuka lebih rapi, dunia dan karakter lebih hidup.
- Gratis dimainkan, tanpa iklan, pembelian kosmetik dan ekspansi konten.
- Implementasi bertahap mempertahankan ambisi game lengkap. Prototipe kecil merupakan tahap validasi, bukan pengganti lingkup akhir.

Detail mekanik, jumlah konten, nama kerja, teknologi, dan batas offline di bawah adalah keputusan desain yang diusulkan. Pengguna belum meninjau dokumen ini.

## 2. Identitas dan pengalaman inti

Pemain adalah penjaga bara terakhir yang membantu permukiman bertahan setelah bencana menutupi dunia dengan abu. Ekspedisi menyediakan bahan, pengetahuan, dan penduduk yang membantu membangun kembali permukiman. Api dan kehidupan perlahan kembali ke desa, sementara wilayah luar tetap berbahaya.

Pemain mengatur persiapan dan tujuan; karakter menjalankan kegiatan secara otomatis. Pertempuran tidak membutuhkan refleks atau mengetuk layar berulang. Aktivitas harus bermakna ketika dimainkan selama beberapa menit maupun ditinggal berjam-jam.

Siklus inti: tentukan target → kumpulkan bahan → produksi bekal/perlengkapan → pilih build → ekspedisi → belanjakan hasil → buka pilihan baru.

Prinsip kualitas: pemain mengetahui apa yang sedang terjadi, apa yang menghalangi targetnya, serta tindakan berikutnya. Kedalaman berasal dari pilihan dan hubungan sistem, bukan banyaknya istilah yang harus dihafal.

## 3. Lingkup game dasar

Target konten ini adalah kriteria pengembangan, bukan klaim konten sudah tersedia.

| Komponen | Target game dasar |
| --- | --- |
| Skill | 15, level 1–100, dengan mastery aktivitas terpisah |
| Gaya combat | Melee, ranged, magic; pergantian bebas di luar pertarungan |
| Wilayah | 8, masing-masing punya bahan, musuh, dan identitas visual |
| Musuh | 64 biasa/elite dan 8 boss dengan aturan berbeda |
| Item | Minimal 400 definisi unik, di luar penggandaan rarity atau kosmetik |
| Resep | Minimal 180 resep dengan fungsi dalam rantai produksi |
| Pet | 24 pet gameplay yang seluruhnya diperoleh lewat bermain |
| Bangunan | 6 bangunan, masing-masing 4 tahap perkembangan visual |
| Bahasa | Indonesia dan Inggris |
| Kampanye | Cerita utama gratis dengan akhir yang utuh |

Koleksi, kontrak, mastery, variasi build, dan tantangan boss menyediakan tujuan setelah kampanye. Tidak ada reset wajib yang menghapus progres.

PvP, perdagangan antarpemain, guild, dan world boss bersama berada di jalur pengembangan lanjutan. Itu memerlukan rancangan server dan ekonomi tersendiri; bukan fitur yang diam-diam dianggap selesai oleh fondasi offline.

## 4. Skill dan keterkaitan produksi

Lima skill combat: Bladecraft (akurasi melee), Might (daya melee), Warding (pertahanan semua gaya), Marksmanship (ranged), dan Sorcery (magic).

Sepuluh skill pendukung: Woodcutting, Mining, Fishing, Cooking, Smithing, Leatherworking, Artificing, Alchemy, Runecraft, dan Devotion.

- Kayu → gagang, busur, bahan bangunan.
- Bijih → ingot → senjata, armor, alat; hasil samping mendukung Artificing.
- Ikan/daging → makanan → ketahanan ekspedisi.
- Kulit dari perburuan → armor ringan dan komponen crafting.
- Bahan botani diperoleh sebagai hasil samping wilayah dan kebun desa → ramuan Alchemy.
- Kristal dan relik → rune, perhiasan, modifikasi perlengkapan.
- Sisa musuh terkutuk → pemurnian Devotion → pilihan blessing.

Setiap aktivitas memiliki ID stabil, persyaratan, input, durasi, output, XP, tabel peluang, dan aturan mastery. Daftar resep menunjukkan sumber bahan serta tombol menuju aktivitas terkait.

Menaikkan satu skill membuka beberapa jalur yang berguna. Tidak semua resep lama langsung kehilangan nilai: bahan lama tetap dipakai untuk kebutuhan tertentu, dengan sumber alternatif agar tidak menjadi hambatan wajib berkepanjangan.

## 5. Combat dan build

Satu karakter bertarung otomatis melawan satu musuh. Pemain membawa satu preset perlengkapan, hingga tiga kemampuan otomatis, satu blessing, satu pet aktif, makanan, dan ramuan dengan aturan pemakaian.

Stat utama: HP, akurasi, daya serang, armor, resistansi, interval serangan, critical chance, dan critical damage. Layar utama memprioritaskan HP, damage efektif, ketahanan, dan konsumsi bekal; rumus rinci tersedia di panel penjelasan.

Contoh keluarga build: guardian menggunakan shield dan counter; reaver menggunakan bleed; ranger menggunakan poison dan serangan cepat; pyromancer menggunakan burn; frost mage menggunakan slow dan pertahanan. Semua dapat diperoleh gratis.

Efek status menggunakan aturan stacking yang eksplisit dalam data. Boss tidak boleh dapat dikunci tanpa batas oleh stun/slow. Resistansi, batas tumpukan, dan urutan penyelesaian efek diterangkan di ensiklopedia.

Setiap boss memiliki satu mekanik yang mendorong perubahan persiapan. Misalnya musuh berarmor mendorong penetration atau damage berkala; musuh dengan serangan besar mendorong shield dan ambang auto-heal. Game memberikan penjelasan kekalahan yang bisa ditindaklanjuti.

Auto-heal dan retreat tersedia gratis. Ketika kalah, karakter kembali ke desa dan kegiatan combat berhenti; perlengkapan tidak dihapus. Bekal yang sudah dipakai tetap terpakai. Tidak ada biaya pemulihan berbayar.

## 6. Loot, crafting, dan inventory

Delapan rarity: Worn, Common, Fine, Rare, Epic, Legendary, Mythic, Relic. Jumlah rarity ini adalah pilihan desain sendiri; kedalaman tambahan datang dari tier material, affix, set, rune, dan mastery.

Material menentukan tingkat dasar. Rarity menentukan anggaran kualitas. Affix mengubah spesialisasi. Set memberi sinergi. Rune menambahkan satu pilihan yang dapat diganti. Tidak ada satu item terbaik untuk seluruh situasi.

Duplikat dapat dilebur menjadi bahan peningkatan. Progres menuju peningkatan berikutnya terlihat jelas. Item kunci kampanye memiliki jalur perolehan terjamin selain drop acak, sehingga kemajuan utama tidak bergantung pada keberuntungan ekstrem.

Inventory mendukung pencarian, filter, sort, favorit, penguncian, perbandingan, preset, dan salvage sekaligus. Item terpasang, terkunci, atau diperlukan preset dilindungi secara default. Pratinjau salvage memperlihatkan seluruh item dan hasil sebelum konfirmasi.

Material tersimpan sebagai jumlah per ID. Equipment bertumpuk jika semua propertinya identik. Batas varian equipment awal 1.000; overflow masuk kotak hasil yang tidak kedaluwarsa. Kapasitas tidak dijual dan loot tidak dibuang diam-diam.

## 7. Antrean dan progres offline

Satu aktivitas utama berjalan pada satu waktu, baik combat maupun skill. Bangunan memberi bonus pasif; tidak menjalankan antrean produksi kedua. Aturan ini menjaga biaya kesempatan dan menyederhanakan penjelasan progres.

Antrean gratis hingga 20 langkah mendukung target jumlah siklus, jumlah hasil baru, atau level skill. Contoh: tambang 100 ore → lebur 20 ingot → buat satu pedang → berburu 30 musuh. Tidak ada loop antrean tanpa batas pada versi pertama.

Jika bahan, level, atau bekal tidak mencukupi, antrean berhenti dengan alasan yang jelas. Pemain dapat memilih melewati langkah gagal; default tetap berhenti. Target dihitung dari hasil langkah itu, bukan seluruh stok lama.

Progres offline maksimal 24 jam per jeda, sama untuk semua pemain. Batas ini ditampilkan sebelum keluar dan pada ringkasan kembali. Angka 24 jam merupakan default desain yang dievaluasi saat playtest.

Simulasi offline mematuhi konsumsi, unlock, auto-heal, kekalahan, dan pergantian langkah seperti sesi online. Hadiah hanya diterapkan sekali. Ringkasan menampilkan durasi, XP, bahan masuk/keluar, loot, perubahan level, dan alasan berhenti.

Saat jam perangkat mundur, durasi negatif menjadi nol tanpa menghapus progres. Lompatan maju dibatasi 24 jam; timestamp masa depan tidak boleh menyebabkan permainan terkunci. Mode offline tidak diklaim kebal manipulasi jam. Data lokal tidak dipakai sebagai bukti kontribusi kompetitif.

## 8. Dunia dan desa

Delapan wilayah usulan: Cinderwatch Outskirts, Hollowpine, Blackvein Mine, Mire of Bells, Sunken Abbey, Ashfall Bastion, Pale Glacier, dan The Eclipsed Spire. Nama dan lore dibuat khusus untuk proyek ini.

Wilayah terbuka lewat milestone cerita, kesiapan karakter, dan misi pendahuluan. Kemenangan boss mengubah keadaan desa dan membuka resep atau spesialisasi, bukan hanya mengganti angka musuh.

Bangunan: forge, kitchen, apothecary, archive, sanctuary, dan watchtower. Upgrade membutuhkan hasil permainan dan mengubah tampilan. Dekorasi berbayar tidak menambahkan bonus bangunan.

Pet gameplay didapat dari milestone, quest, serta drop dengan progres alternatif terjamin. Skin pet hanya mengubah tampilan. Archive menyimpan koleksi dan pengetahuan sumber item. Kontrak bersifat opsional; tidak ada hukuman kehilangan streak login.

## 9. Visual, suara, dan navigasi

Dark fantasy 2D dengan ilustrasi bertekstur, karakter berlapis yang dapat dianimasikan, serta latar dengan beberapa lapisan kedalaman. Palet arang, besi, batu pucat, dan amber. Merah untuk bahaya; ungu digunakan terbatas untuk energi gaib. Teks tidak mengandalkan warna saja untuk menyampaikan status.

Desa menampilkan api, asap, kabut, perubahan bangunan, dan gerak penduduk ringan. Combat menampilkan napas karakter, antisipasi serangan, benturan, efek status, dan reaksi musuh. Efek tidak menutupi HP atau tombol.

Navigasi bawah: Desa, Jelajah, Keahlian, Tas, Karakter. Aktivitas yang berjalan memiliki bilah ringkas yang dapat dibuka dari semua tab. Toko kosmetik berada di desa/profil dan tidak mengambil alih alur bermain.

Desain portrait mengikuti area aman layar. Target teks utama setara minimal 16sp, area sentuh 48dp, dan kontras teks biasa 4,5:1. Uji dilakukan pada perangkat; angka desain bukan klaim aksesibilitas sudah lulus.

Sediakan pembesaran teks, pengurangan gerak, pengaturan partikel, mode hemat baterai, dan kontrol musik/efek terpisah. Semua animasi dapat dilewati tanpa memengaruhi hasil simulasi.

Musik ambient tenang dengan motif lokal wilayah. Bunyi crafting dan loot memberi umpan balik singkat. Tidak ada suara atau getaran wajib. Semua aset harus memiliki catatan asal dan hak penggunaan sebelum publikasi.

## 10. Monetisasi dan ekspansi

Tidak ada iklan, gacha berbayar, pembelian gold/XP, booster berbayar, jual kekuatan, atau pembelian slot antrean. Kosmetik dijual langsung dengan isi paket dan harga jelas: outfit, penampilan senjata, skin pet, dekorasi desa, serta efek visual.

Ekspansi dibeli sekali per paket, menawarkan cerita dan wilayah tambahan. Game dasar mempunyai kampanye dan endgame sendiri. Ekspansi tidak diperlukan untuk memperbaiki progres game dasar yang sengaja diperlambat.

Ekspansi boleh memiliki progres dan perlengkapan untuk tantangannya sendiri. Untuk mode bersama di masa depan, peserta dinormalisasi ke aturan yang sama atau dipisahkan menurut konten; pembeli tidak mendapat keunggulan leaderboard dasar hanya karena membeli paket.

Pembelian awal dan pemulihan kepemilikan membutuhkan koneksi. Konten yang telah diunduh dan diverifikasi dapat dimainkan offline dengan bukti kepemilikan tersimpan. Impor save tidak memberikan hak pembelian. Perubahan/refund disinkronkan saat online; item terkait dipertahankan sebagai data tetapi dinonaktifkan jika hak kontennya hilang, dan karakter dipindahkan aman ke desa dasar.

Harga akhir dan SKU disusun menjelang uji toko, setelah paket kosmetik/ekspansi nyata tersedia. Tidak ada checkout aktif dalam tahap fondasi.

## 11. Arsitektur yang diusulkan

Godot 4 dengan GDScript untuk aplikasi Android dan tampilan 2D. Desktop digunakan untuk iterasi internal. Versi engine dan dependensi dipatok saat implementasi setelah pemeriksaan lingkungan; dokumen ini tidak mengklaim toolchain telah terpasang.

| Modul | Tanggung jawab dan kontrak |
| --- | --- |
| ContentCatalog | Memuat skill, resep, item, musuh, dan unlock berdasarkan ID stabil; menolak referensi rusak |
| Simulation | Memproses state, command, elapsed time, dan RNG tersimpan; mengeluarkan state dan event tanpa bergantung pada UI |
| ActivityQueue | Memilih langkah aktif, mengecek syarat/target, mencatat alasan berhenti |
| Combat | Menyelesaikan urutan serangan, efek, konsumsi, loot, dan defeat |
| Inventory | Transaksi bahan/item, perlindungan equipment, dan kapasitas |
| Progression | XP, mastery, quest, unlock, serta bangunan |
| SaveRepository | Snapshot, validasi, migrasi, backup, serta pemulihan setelah crash |
| Presentation | Scene, animasi, suara, lokalisasi, dan pembacaan hasil simulasi |
| Entitlements | Memisahkan hak konten/kosmetik dari progres gameplay; adapter billing dan verifikasi server |
| CloudSync | Backup opsional dengan revisi save; tidak menggabungkan inventaris dua perangkat secara otomatis |

Aliran utama: UI command → validasi → simulasi/transaksi → save → event tampilan. Membuka atau menutup ringkasan hadiah tidak memberikan hadiah kedua kali.

Online dan offline menggunakan aturan domain yang sama dengan RNG tersimpan. Mesin memproses kejadian sesuai waktu berikutnya dan membagi pekerjaan berat ke beberapa batch. Agregasi hanya boleh digunakan jika setara dengan hasil referensi; tidak mengganti combat kompleks dengan perkiraan damage rata-rata tanpa pengujian.

Simpan state RNG, langkah antrean, progres parsial, waktu checkpoint, versi konten, dan versi schema. Snapshot baru ditulis ke file sementara, divalidasi, lalu menggantikan save utama sambil mempertahankan dua backup terakhir. Save invalid dipulihkan dari backup dan dilaporkan; tidak otomatis mereset akun.

Simulasi catch-up bekerja pada salinan checkpoint. Jika crash sebelum commit, aplikasi mengulangi dari checkpoint yang sama. Jika commit selesai, cursor waktu baru mencegah pengulangan hadiah.

Cloud bersifat opsional untuk game dasar. Konflik antarperangkat menawarkan pilihan save dengan waktu, level, dan pratinjau; keduanya dicadangkan sebelum pemilihan. Server verifikasi pembelian diperlukan sebelum toko produksi; kredensial layanan tidak dibundel ke aplikasi.

## 12. Tahapan dan batas penyerahan

1. Fondasi yang bisa dimainkan: satu wilayah, enam musuh, satu boss, enam skill pendukung (Woodcutting, Mining, Fishing, Cooking, Smithing, Alchemy), melee, 40 item, 20 resep, antrean, save, dan offline. Semua sistem wajib terhubung dan latar/karakter sudah menunjukkan arah visual.
2. Kedalaman build: tiga gaya combat, seluruh 15 skill, tiga wilayah, 120 item, pet, mastery, dan perkembangan desa. Angka ini milestone sementara menuju target lengkap.
3. Game dasar lengkap: delapan wilayah, target konten bagian 3, akhir kampanye, ensiklopedia, lokalisasi, dan penyesuaian ekonomi lewat playtest.
4. Kesiapan rilis: cloud opsional, pembelian kosmetik, pemulihan transaksi, pengujian perangkat, aksesibilitas, audit aset, signed AAB, dan materi toko.
5. Setelah rilis: ekspansi dengan siklus desain dan pengujian sendiri; fitur komunitas hanya setelah sistem servernya siap.

Setiap tahap harus punya hasil yang dapat dimainkan. Konten placeholder diberi label internal dan tidak boleh dilaporkan sebagai aset final. Langkah pertama yang direncanakan setelah persetujuan dokumen ini adalah menyusun rencana implementasi tahap 1 secara rinci; tidak mengerjakan seluruh tahapan sekaligus.

## 13. Kriteria penerimaan dan pengujian

- Pemain baru dapat menyelesaikan kumpulkan bahan → craft → equip → kalahkan musuh tanpa membaca panduan eksternal. Target playtest: minimal 4 dari 5 pemain baru menyelesaikan alur dalam 10 menit.
- Quest memperlihatkan target, persyaratan, dan tempat mendapatkan bahan; setiap UI terkunci menjelaskan sebab.
- Sesi online dan offline dari state/RNG yang sama menghasilkan hasil identik pada skenario referensi, termasuk kekalahan, bahan habis, pergantian antrean, dan buff kedaluwarsa.
- Tutup/buka berulang, penghentian saat save, pemuatan backup, impor save rusak, dan migrasi schema tidak menggandakan item atau diam-diam menghapus progres.
- Tidak ada XP atau jumlah item negatif; resource tidak dikonsumsi dua kali; item terkunci terlindungi; seluruh resep dan tabel drop memiliki referensi valid.
- Simulasi ekonomi mencari kebuntuan resep, sumber gold tanpa biaya yang tidak disengaja, build dominan, dan milestone terlalu lama. Playtest nyata tetap diperlukan untuk menilai kesenangan.
- Target performa: 30 FPS stabil pada perangkat uji kelas bawah yang dipilih sebelum pengujian, opsi 60 FPS, tanpa loop latar aktif ketika aplikasi ditutup. Target catch-up 24 jam kurang dari 3 detik pada perangkat referensi, atau tampilkan progres jika belum tercapai.
- Teks tidak terpotong pada lebar logis 360–480dp dan pembesaran font 130%; warna rarity disertai label/ikon; mode reduced motion benar-benar mengurangi gerak.
- Billing diuji untuk pending, pembatalan, jaringan putus, pengiriman token berulang, restore, dan pencabutan hak. Hak hanya diberikan setelah verifikasi, dan pemberian ulang harus idempoten.
- Laporan setiap milestone memisahkan fitur selesai, hasil pengujian yang benar-benar dijalankan, dan hal yang belum diverifikasi pada Android.

## 14. Keterbatasan dan dasar riset

Riset referensi mencakup listing Google Play, delapan gambar resmi, situs data game, serta ulasan. Aplikasi Realm Idle belum dimainkan langsung. Dokumen ini tidak menyatakan game referensi pasti tidak memiliki fitur yang diusulkan.

Penilaian lebih bagus akan diuji melalui keterbacaan, keberhasilan onboarding, jumlah langkah untuk mengelola aktivitas, variasi build yang layak, dan pengalaman pemain setelah beberapa hari. Menyamai jumlah item saja tidak membuktikan kualitas.

Sumber yang diperiksa:

- https://play.google.com/store/apps/details?id=com.alexb.realmidle
- https://realmidle.com/
- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
- https://developer.android.com/google/play/billing/security

Dokumentasi Godot mendukung jalur ekspor Android/AAB. Pedoman Play Billing mendasari verifikasi dan pemberian hak di backend. Persyaratan toko dan kompatibilitas library harus diperiksa kembali saat tahap integrasi/rilis; belum ada pengajuan publikasi.
