# Cinder Dominion: Idle RPG — Adventure preview 0.39

Idle RPG dark fantasy untuk Android. Gratis; iklan uji Android tersedia secara opsional di Settings dan bantuan antrean. Build ini untuk dimainkan dan dievaluasi, belum versi rilis publik.

## Mulai bermain

1. Pasang `build/android/cinder-dominion-0.39.apk` di Android 64-bit. APK memakai identitas aplikasi yang sama dengan 0.1–0.38 sehingga bisa dipasang sebagai pembaruan.
2. Seluruh antarmuka dan narasi game memakai **English**. Splash mengantar ke menu utama. Pilih **New game** untuk memilih Warden, Ranger, Arcanist, Reaver atau Apothecary dan memasukkan nama, lalu pilih **Show me the way** untuk panduan dengan sorotan emas. Intro opsional tersedia di About. **Continue journey** melanjutkan progres yang sudah ada.
3. Tekan **Goals** di bagian atas layar. Layar menampilkan target, angka progres, checklist dan tombol tugas. Tekan tindakannya, lalu **Begin · 4 cycles** (jumlahnya mengikuti tujuan) untuk memulai jumlah siklus yang tepat.
4. Tugas awal: 4 copper ore → 2 copper ingots → 1 ash log → Copper Sword → Equip item → 3 Ash Rats. Panduan lalu mengantar lewat musuh berikutnya hingga Bellkeeper, tanpa melompat langsung ke boss.
5. Pantau activity bar. **Queue** menampilkan tugas berjalan/menunggu, progres target, dan alasan terhambat. **Sources/Find** membantu mencari bahan yang kurang. Satu aktivitas berjalan pada satu waktu.
6. Buka **Food & survival guide** untuk belajar memancing, memasak, memilih makanan dan menyiapkan auto-heal. Perlengkapan hasil crafting harus dipasang dari **Bag**.
7. Progres tersimpan otomatis dan berlanjut maksimal 24 jam saat kembali. Menu **☰** tersedia dari dalam permainan. New Game meminta konfirmasi dan menyimpan cadangan terpisah; **Settings → Restore a previous journey** memulihkannya.

## Baru di 0.39 — Late-game progression

60 poin talent melalui level dan boss milestone, enam talent lanjutan, serta relic rank 40 dengan essence dan guardian core. Bonus awal tetap; pertumbuhan berikutnya dibatasi agar stat tidak melonjak empat kali. Lihat [laporan 0.39](docs/qa/legacy-growth-0.39-report.md). Kartu, stamina, status effect dan rotating NPC merchant masih menyusul.

## Baru di 0.38 — Accessory equipment

Necklace, belt, left ring dan right ring; sembilan resep aksesori Smithing Lv.30/60/90, refinement, perbandingan tiap tangan, serta save/loadout yang mempertahankan identitas ring. Lihat [laporan 0.38](docs/qa/accessories-0.38-report.md). Stamina, kartu dan perluasan talent/relic masih tahap berikutnya.

## Baru di 0.37 — Hero battle sprites

Lima hero memakai sprite figur kecil dengan empat pose per kelas, seperti arah animasi awal. Enemy tetap art diam. Efek skill berupa jejak tebasan, percikan dan partikel halus; tidak memakai simbol perisai, reticle atau plus besar. Thumbnail antrean memakai sprite kelas yang sama. Lihat [laporan 0.37](docs/qa/hero-battle-0.37-report.md) dan video `build/android/hero-battle-0.37-preview.mp4`.

## Baru di 0.36 — Page presentation

Empat art lingkungan baru untuk Stronghold, Explore, Skills dan Bag. Hero langsung menampilkan karakter dan slot equipment. Bag memakai grid dengan Inspect/Details; memilih makanan, menjual item dan Sources ada di detailnya. Target hunt tampil sebelum menu progression; persiapan taktik dan makanan dibuka lewat Prepare for a hunt. Bingkai, tombol sekunder, navigasi dan judul dialog lebih tenang dan konsisten. Emblem tetap transparan. Lihat [laporan visual 0.36](docs/qa/premium-pages-0.36-report.md).

## Baru di 0.35 — New identity

Nama publik menjadi **Cinder Dominion: Idle RPG**. Emblem mahkota besi dan bara memakai PNG transparan, tanpa latar kotak, pada splash/menu/header. Ikon aplikasi ikut diganti. Tab **Stronghold** menggantikan Refuge; **Town** menggantikan Refuge Services. Save dan identitas paket Android tetap kompatibel. Rekomendasi desain halaman berikutnya: [arah visual premium](docs/premium-ui-direction-0.35.md).

## Baru di 0.34 — Optional guardians & rewarded assistance

Tujuh penjaga opsional dengan lokasi bertahap, art wajah tertutup, tujuh equipment unik, blueprint dua tahap, core khusus dan pembelian pasti setelah delapan kemenangan. Hero mendapat sepuluh pilihan spesialisasi serta empat socket relic. Hollow Depths menawarkan pilihan menyimpan hadiah atau melanjutkan dengan risiko meningkat; tiga kontrak pilihan dan target mingguan tetap tersimpan sampai selesai.

Setelah beacon terbuka, masuk **Stronghold → Beyond the beacon**. Lokasi pertama terbuka setelah Crown Apex terakhir. Bantuan antrean adaptif hanya terbuka melalui **rewarded ad yang selesai**, selama empat jam; antrean manual tetap gratis. Iklan memakai ID uji Android, belum produksi. Audit kesulitan, hasil simulasi dan batas verifikasi ada di [laporan 0.34](docs/qa/endgame-0.34-report.md). Katalog kini berisi 123 item, 42 enemy definitions (termasuk tujuh penjaga baru dan satu tipe Depths), 143 aktivitas, lima karakter; batas level tetap 100.

## Baru di 0.33 — Concealed faces & five characters

Art dengan wajah lengkap diganti dengan hood, kain penutup atau helm tertutup, termasuk musuh, patung latar, cerita dan animasi kerja. Reaver dan Apothecary menambah pilihan serangan boss dan pemulihan makanan. Lima karakter gratis; save lama tetap dipertahankan. Lihat docs/qa/faceless-roster-0.33-report.md serta docs/faceless-art-0.33.json.

## Baru di 0.32 — Characters & discovery

Tiga karakter gratis dengan trade-off stat, class skill, atribut yang dapat dibagi dan art masing-masing. Save lama dapat memilih karakter dari Hero tanpa reset. Musuh yang belum terbuka disembunyikan dari daftar. Settings menyediakan banner, interstitial dan rewarded dengan ID uji resmi; belum ada iklan produksi atau pembelian. Lihat docs/qa/characters-discovery-0.32-report.md untuk hasil dan batas verifikasi.

## Baru di 0.31 — Animated task bar & hero equipment

Bar antrean bawah menampilkan thumbnail animasi kecil 64×54 mengikuti pekerjaan aktif: mining, woodcutting, fishing, smithing, cooking, alchemy, atau combat. Satu atlas baru berisi 24 pose kerja. Animasi berhenti saat menunggu bahan; pengaturan reduced motion menampilkan pose diam. Daftar antrean kini memperbarui angka dan berganti tugas otomatis.

Hero menampilkan ilustrasi seluruh tubuh dengan enam slot yang terhubung ke posisi tubuh. Tekan slot untuk memilih item milikmu, lalu Compare & equip. Slot kosong memiliki petunjuk gambar redup dan jalur crafting. Tools tersedia di bawah hero. Ilustrasi hero adalah tampilan dasar; armor tidak mengganti model tubuh secara visual. Lihat docs/qa/activity-equipment-0.31-report.md untuk verifikasi dan docs/activity-equipment-art-0.31.json untuk asal art serta prompt.

## Baru di 0.30 — Clear onboarding & Continue fix

Panduan memakai bingkai emas dan panah tanpa menggelapkan layar belakang, termasuk dialog pembuka dan tugas selama panduan aktif. Instruksi enam langkah menyebut tindakan, jumlah dan hasilnya. Bug Continue exploring setelah layar dibangun ulang diperbaiki: tombol menerima sentuhan, menutup panduan dan mengembalikan navigasi. Skip tetap tersedia. Save lama tidak direset.

## Baru di 0.29 — Training plans

Tombol Train membuka rencana target level dengan pilihan batas waktu 15 menit, 1 jam atau 4 jam. Rencana memilih resep tersedia berdasarkan XP per waktu, termasuk pengumpulan dan pengolahan bahan. Sebelum mulai, terlihat jumlah siklus, daftar bahan, perkiraan waktu, XP dan level hasil batch. Jika target belum selesai, goal tersimpan di Skills untuk dilanjutkan pada kunjungan berikutnya.

Antrean yang sedang berjalan tetap aman. Satu batch memakai satu resep sampai target atau batas waktu, maksimum 1.000 siklus; resep yang baru terbuka dipertimbangkan saat membuat batch berikutnya. Waktu merupakan perkiraan dengan bonus saat ini, bukan jaminan durasi persis. Lihat docs/qa/training-plans-0.29-report.md.

## Baru di 0.28 — Armor sets & loadout comparison

Dua bagian armor metal yang sama memberi bonus: Steel mengurangi third-hit damage, Moonsteel menekan healing musuh, Dusksteel memperkuat fourth attack, dan Dawnsteel memperkuat makanan. Shield dihitung; weapon/tools tidak. Dua set bisa dikombinasikan. Hero → Armor sets menjelaskan bonus, sementara detail item menampilkan efek pergantian terhadap set aktif.

Loadouts dan hunt planner kini memiliki Compare builds: pilih encounter lalu bandingkan waktu, makanan, damage masuk dan set aktif tanpa mengganti equipment. Apply tetap tindakan eksplisit. Auto-equip berdasarkan base stats dan dapat memutus set. Lihat docs/qa/armor-sets-0.28-report.md untuk hasil pemeriksaan dan batas balance.

## Baru di 0.27 — Audit implementation, first delivery

Target equipment dapat dilacak dari crafting/Ascension dan dilanjutkan dari Refuge. Work orders mencakup ingot empat tier lanjutan serta makanan pilihan. Latihan memilih aktivitas berdasarkan XP dan waktu bahan. Apex kini ikut progres regional Runeforge. Advanced training terbuka pada Bladecraft 25 dengan tiga trade-off, tersimpan bersama loadout. Bounty mengikuti tier skill; inventory memiliki sort, filter slot dan halaman equipment. Bestiary serta checklist kesiapan hunt membantu memilih farming.

Battle memakai atlas baru 16 pose untuk hero dan tiga archetype regional. Musik asli memakai Ogg. Progres offline dikerjakan bertahap pada salinan state dengan layar progres. Lihat docs/qa/audit-upgrade-0.27-report.md untuk verifikasi, dan docs/audit-delivery-roadmap.md untuk pekerjaan audit yang belum selesai. Ini pengiriman pertama audit, bukan seluruh scope selesai.

## Baru di 0.26 — Langkah berikutnya di Ascension

Tombol utama mengikuti progres: Train → Plan sword → View current work → Review & equip → Journey atau Apex hunts. Level skill dan jumlah equipment diperbarui langsung. Senjata yang sudah lebih kuat tidak diarahkan untuk diganti dengan tier lebih lemah. Browse Apex hunts tetap tersedia untuk melihat target lanjutannya.

## Baru di 0.25 — Ascension

Konten sekarang: **96 item, 117 aktivitas, 34 encounter, 64 resep, 39 tujuan Journey dan 25 kontrak**. Empat tier metal baru dimulai pada level 25/45/65/85, dengan Dawnsteel Cuirass pada Smithing level 100. Tiap tier membawa enam combat equipment, tiga tools, ore, ingot, log, ikan dan makanan. Gear baru bisa di-refine hingga Legendary memakai ingot yang sesuai.

Buka **Skills → Gear paths** atau **Explore → Ascension**. Halaman tier menunjukkan level yang dibutuhkan, tombol Train, rencana bahan otomatis, equipment dan makanan. Skills menampilkan Available secara default; All recipes membuka seluruh daftar.

Sembilan Apex Hunt terbuka melalui Guardian Trials dan kemenangan berurutan. Serangan khusus mencakup armor penetration, heavy strikes dan self-healing, memakai aturan yang sama di combat dan forecast. Hunt memberi advanced ore, relic fragments serta peluang gear metal baru. Tujuh belas kontrak tambahan memberi target crafting, gathering dan first clears. Journey berlanjut ke Apex setelah tiga trials.

Art baru: **29 tile lukisan dalam tiga atlas orisinal**—sembilan musuh, enam belas ikon metal/equipment, dan empat lokasi. Atlas dipakai pada inventory, crafting, halaman tier, daftar musuh dan battle. Armor, tools, log dan ikan baru masih memakai ikon lama yang sesuai kategori. Bukan 29 file gambar terpisah.

## Baru di 0.24 — Focused taps & sound room

Selama panduan, area redup menahan sentuhan sehingga hanya target yang disorot dan Skip yang dapat ditekan. Target memakai kontrol game asli; progres tetap berjalan. Skip mengembalikan navigasi normal.

Settings → Music & sound preview memberi pilihan empat musik tema serta contoh efek suara. Menutup panel mengembalikan musik sesuai situasi game dengan transisi halus. Volume serta pilihan mute tetap dihormati.

## Baru di 0.23 — Guidance when materials run out

Panduan tetap menyorot langkah berikutnya saat bahan kurang: Plan missing materials → Gather & craft → progres antrean. Jika antrean sudah terisi, tombol pengelola antrean berada di bagian bawah dialog dan ikut disorot. Proses crafting yang sudah memakai bahannya tidak lagi keliru disebut menunggu. Save dan ekonomi tetap sama.

## Baru di 0.22 — Guided onboarding & original score

Onboarding menyorot tombol yang harus ditekan, meredupkan area lain, dan memberi panah serta instruksi singkat dalam English. Enam langkah: ore → ingots → log → sword → equip → tiga Ash Rats. Sorotan berpindah ke progres saat tugas berjalan, lalu kembali ke langkah berikutnya. Skip tersedia; Goals dapat mengaktifkan kembali panduan selama enam langkah awal. Status panduan tersimpan tanpa mengulang progres.

Empat musik stereo orisinal berdurasi 64 detik menggantikan ambience sebelumnya: refuge, wilds, sanctum dan crown. Ada lapisan strings sintetis, plucked melody, bells, perkusi serta transisi silang dua detik. SFX baru untuk panduan, pukulan dan terkena serangan; efek forge, equip, hadiah, kemenangan dan kekalahan diperbarui. Volume music/SFX terpisah, preview SFX tersedia di Settings, dan audio berhenti sementara saat aplikasi dijeda.

## Baru di 0.21 — Live mastery progress

Progres Hunt Mastery kini diperbarui saat hunt berjalan: kemenangan, rank, bonus, milestone dan jumlah pertarungan pada tombol Hunt. Dialog tetap terbuka tanpa menggeser posisi scroll. Setelah rank maksimum, tombol menawarkan 25 pertarungan untuk farming lanjutan. Save serta balance tidak berubah.

## Baru di 0.20 — Hunt Mastery

Setiap musuh memiliki milestone 10, 25, 75 dan 150 kemenangan. Tiap rank memberi +1 ATK khusus terhadap musuh itu dan +1 gold per kemenangan; rank 2 dan 4 juga meningkatkan fragments. Bonus maksimum +4 ATK, +4 gold, +2 fragments. Bonus baru berlaku mulai fight berikutnya. Kemenangan lama otomatis dihitung.

Explore → Hunt mastery menunjukkan progres dan tombol hunt ke milestone berikutnya. Target fragments serta hadiah rencana hunt menghitung kenaikan bonus di tengah antrean.

## Baru di 0.19 — Bingkai dan kontrol dark fantasy

Panel, dialog, tombol, header dan activity bar memakai bingkai logam bersudut dengan ornamen sudut. Tombol utama memakai perunggu gelap; teks tetap terang. Kolom pencarian, input jumlah, dropdown, menu pilihan, toggle, slider serta scrollbar mengikuti tema yang sama.

Bingkai menyesuaikan ukuran tanpa meregangkan ornamen. Lebar tombol pendek diperbaiki agar Goals, Queue, Find dan persentase ukuran teks tidak pecah di tengah kata. Tata letak ditinjau pada teks 100% dan 130%.

## Baru di 0.18 — Lebih sedikit membaca, lebih cepat bermain

New Game langsung masuk ke satu kartu tujuan dengan bahan Copper Sword dan tombol tugas berikutnya. Intro serta cerita opsional. Goals menjadi checklist dengan progres; Farm & upgrade berisi angka dan tombol, tanpa paragraf panduan panjang.

Skills, Explore, Refuge, dialog aktivitas dan laporan kembali dipadatkan. Explore menyembunyikan battle kosong dan pilihan endgame sebelum terbuka agar target hunt lebih cepat terlihat. Petunjuk lengkap tetap di How to play, biaya dan syarat aktivitas tetap terlihat.

## Baru di 0.17 — Farming relic dengan target yang jelas

Relic farming membedakan kebutuhan fragments, siap upgrade, dan rank maksimum. Setiap hunt menunjukkan jumlah kemenangan total, batch maksimum 100, estimasi durasi, kebutuhan makanan dan hasil dasar. Target besar tidak lagi terlihat seolah selesai dalam satu batch.

Jika fragments sudah cukup, tombol utama langsung menawarkan upgrade. Rank maksimum mengarahkan ke rune; farming tambahan diberi label opsional. Halaman Relics juga memperlihatkan bonus saat ini dan bonus rank berikutnya saat dipasang.

## Baru di 0.16 — Kembali bermain dengan tujuan jelas

Welcome back membedakan total waktu pergi dari waktu progres yang dihitung (maksimum 24 jam). Laporan menampilkan hasil, persediaan terpakai, level yang naik, resep yang terbuka, dan status antrean.

Jika tugas masih berjalan atau terhenti, tombol utama membuka Queue. Jika antrean kosong, tombol mengantar ke rekomendasi berikutnya. Hasil sudah tersimpan; membuka laporan tidak memberikan hadiah tambahan.

## Baru di 0.15 — Perbandingan equipment lebih jelas

Detail equipment membandingkan total attack/armor build saat ini dengan hasil jika item dipasang. Item terpasang, rarity, slot, jumlah copy dan status Bag terlihat jelas. Preview memakai salinan state; tidak memasang item atau menghabiskan resource.

Tool gathering menampilkan waktu aktivitas nyata sebelum/sesudah, termasuk bonus mastery dan refuge. Kualitas tool tidak diberi klaim bonus speed yang tidak ada. Equip berhasil memperbarui dialog yang sama; saat combat, tombol dinonaktifkan dan alasannya ditampilkan. Lock, favorite, Workshop dan salvage tetap tersedia sesuai proteksi item.

## Baru di 0.14 — Antrean lebih mudah dilanjutkan

**Queue → Prepare missing materials** menampilkan gathering/crafting bahan yang akan disisipkan sebelum tugas terhenti. Progres produksi yang sudah selesai dan tugas sesudahnya tetap dipertahankan. Preview memakai stok yang tersedia, membatasi persiapan hingga 100 siklus produksi, dan menolak perubahan jika slot atau level belum cukup.

Task queue memiliki progress bar, status Running/Queued/Waiting, satuan hunt yang jelas, tombol refresh, dan jalan keluar saat antrean kosong. Target Smithing 10 tetap menunjukkan kebutuhan total, tetapi kini membuka batch maksimum 100 agar sesuai batas planner.

## Baru di 0.13 — Cerita, battle dan leveling

**Story journal** di Refuge berisi tujuh bab English singkat, terbuka berdasarkan First Supplies, Bellkeeper, tier kelima tiap wilayah, dan tiga trial. Tiga ilustrasi baru buatan image_gen dipasang ke jurnal. Setiap bab memisahkan cerita dari petunjuk langkah berikutnya; cerita terkunci tidak ditampilkan.

Battle mendapatkan efek khusus regional: akar Bramble crush, gelombang Drowned hymn, dan hentakan Final toll. Nama skill style tampil sebagai Cleave, Ward dan Rend. Dialog memiliki fade singkat, tombol memiliki feedback tekan dan pembungkusan teks dengan ukuran minimum yang menjaga tombol header tetap terbaca. Reduced motion menonaktifkan animasi tambahan.

Skills menampilkan XP menuju level berikutnya, resep yang akan terbuka, dan tombol rencana latihan. Level-up menampilkan notifikasi beserta unlock dari catalog. Tidak ada popup wajib atau hadiah tambahan hanya karena membuka jurnal.

## Baru di 0.12 — Preview dampak upgrade

Workshop menampilkan biaya singkat, total attack/armor sebelum dan sesudah upgrade, serta estimasi pertarungan terhadap musuh terbuka yang dipilih. Preview tidak menghabiskan bahan. Untuk item di Bag, perbandingan mengasumsikan item dipasang setelah refine; refine sendiri tidak memasang item tersebut.

Kekurangan gold dan scraps kini terhubung ke contract rewards, field records dan Bag. Planner ingot dan latihan Smithing tetap tersedia. Equipment yang sudah melewati batas refine tidak lagi menampilkan perbandingan ke kualitas lebih rendah.

## Baru di 0.11 — Review hunt dan persiapan berikutnya

Hunt reports kini menampilkan satu order terpilih, dengan daftar ringkas untuk membuka order lain. Hunt selesai menunjukkan waktu dan makanan per kemenangan, dibandingkan dengan hunt selesai sebelumnya pada musuh yang sama. Hunt yang kalah atau dihentikan tidak dipakai sebagai pembanding.

Makanan dan potion baru dicatat per jenis item. Dari laporan, **Plan … more** membuka rencana crafting untuk mengganti jumlah yang terpakai; bahan tetap harus dikumpulkan dan dibuat. **Plan this hunt again** membuka estimasi hunt. Refuge memberi akses langsung ke laporan terakhir.

Laporan lama tetap kompatibel dan hanya menampilkan rincian yang memang tersimpan. Semua hadiah sudah masuk ke inventori; tombol laporan tidak memberikan hadiah tambahan.

## Baru di 0.10 — Alur progres lebih jelas

**Stronghold → Progress & farming** menggantikan roadmap lama dengan tiga tab: **Next step**, **Farm**, dan **Upgrade**. Tujuan utama, saran persiapan, kegunaan bahan, cara menaikkan level, dan syarat membuka wilayah dijelaskan terpisah dengan tombol langsung ke aktivitas terkait.

Farming sekarang dijelaskan berdasarkan kebutuhan: makanan untuk hunt, ingot untuk equipment, XP untuk level dan talent, fragments untuk relic/rune, serta scraps dan gold untuk upgrade. Panduan upgrade mengurutkan equip gear → refine quality → pilih bonus → coba satu fight dan periksa hasil.

Tujuan Smithing 10 menghitung jumlah ingot yang masih dibutuhkan berdasarkan XP sekarang. Menu layanan, laporan hunt, onboarding dan teks progres menggunakan nama serta kalimat yang lebih langsung. Seluruh teks baru tetap English.

## Baru di 0.9 — Combat & journey polish

Animasi portrait kini memiliki ancang-ancang, lunge dan rotasi saat menyerang, recoil saat terkena pukulan, gerak menghindar, efek pemulihan, serta gelombang awakening guardian. Mode reduced motion mempertahankan informasi tanpa gerak karakter; mode battery membatasi redraw arena hingga 30 fps. Ini peningkatan animasi portrait prosedural, belum karakter skeletal atau sprite animasi penuh.

**Plan a longer hunt** pada persiapan musuh menyediakan pilihan 5/15/30 menit, diterjemahkan menjadi jumlah pertarungan tetap. Perkiraan bekal memperhitungkan HP yang berkurang sepanjang hunt, bukan mengasumsikan HP penuh pada setiap pertarungan. Perkiraan hasil mengecualikan loot acak dan bonus first clear. **Return after this fight** menyelesaikan battle berjalan lalu membatalkan sisa antrean setelah konfirmasi yang jelas; risiko kalah tetap berlaku.

Intro dan teks perjalanan diperhalus dalam English. Angka mekanik dan petunjuk tetap eksplisit. Detail: `docs/combat-journey-0.9.md`.

## Baru di 0.8 — Guardian Trials

Tiga tantangan opsional setelah tier kelima setiap wilayah: **The Thornbound Vigil**, **The Unbroken Hymn**, dan **Crown at Sundown**. Guardian memasuki fase kedua saat HP mencapai setengah; serangan khususnya menguat dan fase tetap aktif walau guardian menyembuhkan diri.

Buka **Explore → Guardian trials** atau **Stronghold → Journey → Guardian trials**. Pelajari dua fase, periksa perkiraan risiko build, lalu **Prepare one trial → Begin · 1 fight**. Kemenangan pertama memberi equipment Epic yang pasti, 120 bonus fragments, 15 scraps dan 20 grilled minnows. Kemenangan selanjutnya tetap menghasilkan fragments, gold, XP dan material. Hunt reports membedakan hasil aktual, dan kemenangan trial ikut menghitung field records.

Catatan implementasi dan batas produksi: `docs/guardian-trials-0.8.md`. Pemeriksaan terbatas: `docs/qa/guardian-trials-0.8-report.md`.

## Baru di 0.7 — iterasi menyeluruh

**Upgrade gear yang pasti.** Stronghold → Armory → Ember Workshop memperbaiki satu equipment copper/iron melalui Fine, Rare, Epic, hingga Legendary. Biaya menggunakan gold, ingot dan scraps hasil bermain; syarat Smithing meningkat sampai level 20. Tidak ada kegagalan acak. Hanya satu copy yang ditingkatkan, sementara equipment terpasang dan referensi build mengikuti hasil upgrade.

**Loadout lengkap.** Tiga slot menyimpan equipment, fighting style, talent, relic, rune, food, potion dan ambang healing sekaligus. Ganti di luar combat; persediaan tetap harus disiapkan. Item yang dipakai loadout terlindungi dari salvage. Preset gear lama tetap didukung.

**Hunt reports.** Explore → Review this journey atau Stronghold → Journey → Hunt reports memperlihatkan 12 order berburu terakhir: kemenangan, durasi, loot beserta rarity, fragment, gold, XP, makanan dan potion terpakai. Selesai, retreat dan kalah memiliki hasil yang berbeda. Progres offline ikut tercatat; hasil sudah masuk ke tas, bukan hadiah untuk diklaim dua kali.

**Refuge dan pertarungan lebih hidup.** Tujuan utama dan ilustrasi kota kini mendahului tiga kelompok layanan: Journey, Armory dan Supplies. Tiga arena orisinal dilihat dari permukaan tanah. Portrait memiliki gerak serangan/impact, partikel dan peringatan pukulan guardian; pengaturan reduced motion tetap dihormati.

**Audio dan kejelasan.** Empat ambience berlapis untuk hearth dan tiga wilayah, perpindahan suasana bertahap, serta suara berbeda untuk forge, equip, reward, kemenangan dan kekalahan. Musik berhenti sementara saat aplikasi masuk background. Panduan bermain, biaya upgrade, stok loadout, satuan tool speed dan ringkasan hasil diperjelas dalam English.

Detail serta pekerjaan produksi yang masih tersisa: `docs/production-polish-0.7.md`. Bukti pemeriksaan terbatas: `docs/qa/production-polish-0.7-report.md`.
## Baru di 0.6

**Runeforge.** Setelah Bellkeeper, kalahkan guardian suatu wilayah untuk menemukan rune-nya. Kumpulkan fragment, scraps dan gold, tinjau biaya serta perbandingan efek, lalu inscribe dan equip. Thornscript menembus armor pada serangan keempat; Stillwater mengurangi healing musuh; Dirge memperkuat serangan keempat tetapi membuat setiap serangan musuh lebih menyakitkan. Tiga rune memiliki masing-masing tiga rank. Satu rune aktif bersama fighting style dan relic; ganti gratis di luar combat.

**Field journal.** Kemenangan di seluruh tier suatu wilayah terakumulasi menuju 5, 20 dan 50 kemenangan. Setiap milestone memberi hadiah satu kali untuk mendanai rune/relic berikutnya. Kemenangan lama dan offline tetap dihitung. Journal mendahulukan hadiah siap klaim, lalu membantu merencanakan perburuan berikutnya. Taktik guardian bisa dibuka saat dibutuhkan.

**Pilihan lebih terbaca.** Tiga ilustrasi rune orisinal, perbandingan damage sebelum menghabiskan bahan, biaya dan alasan terkunci yang jelas, tombol Equip setelah forging, serta saran progres dan laporan offline yang menunjuk hadiah field journal. Save lama tetap bisa dilanjutkan. Detail efek dan batas versi: `docs/runeforge-0.6.md`.
## Baru di 0.5

**Farming sesuai build.** Relic → Find a hunting ground membandingkan wilayah yang sudah terbuka: fragment per kemenangan, estimasi waktu, kebutuhan makanan dan hasil per menit. Pilihan yang lebih aman didahulukan. Tombolnya menyiapkan jumlah kemenangan menuju rank berikutnya. Hadiah ekspedisi meningkat menurut wilayah dan tier, sehingga melawan guardian memberi alasan yang lebih kuat daripada terus berburu musuh awal.

**Tiga guardian, tiga ancaman.** Thornbound Sentinel menembus separuh armor setiap serangan ketiga. Drowned Oracle memulihkan HP. Crowned Bellkeeper menghasilkan ledakan damage lebih besar. Ketiganya memakai portrait baru; persiapan menjelaskan kemampuan dan arena menampilkan hitung mundurnya. Angka healing dan damage bersamaan tetap terbaca.

**Tindakan selalu terjangkau.** Tombol Begin, Gather & craft dan Begin this order tetap di bawah dialog ketika detail digulir. Work orders menampilkan proyeksi kenaikan level dan waktu dalam jam/menit. Angka pemulihan makanan sudah memasukkan bonus Emberheart. Semua teks baru memakai English.

Review mendalam, temuan yang dibenahi, dan pekerjaan menuju kualitas produksi ada di `docs/review-0.5.md`. Ini peningkatan preview yang dapat dimainkan, belum klaim game AAA selesai.
## Baru di 0.4

**Mulai dengan satu tujuan.** Refuge menampilkan **YOUR NEXT MOVE** di atas ilustrasi: apa yang perlu dikerjakan, alasannya, dan tombol tindakannya. Mulai dari 4 copper ore. Roadmap menjelaskan jalur senjata pertama → perlengkapan dan makanan → Bellkeeper → ekspedisi. Rekomendasi kemudian mengikuti kondisi antrean, talent, relic, gear, makanan dan Smithing.

**Work orders untuk sesi panjang.** Setelah First Supplies, Stronghold → Supplies → Work orders membuka empat jenis pesanan. Pilih 1/2/4 batch, tinjau hasil, XP dan estimasi waktu, lalu mulai. Satu batch Feed the Forge menghasilkan 500 copper ingots dari bahan yang dikumpulkan otomatis; empat batch bisa berjalan beberapa jam. Pesanan tidak memulai combat.

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

Ini preview Chapter I dan tiga rangkaian ekspedisi, belum kampanye penuh. Kampanye lengkap, ranged/magic, pet, sistem bangunan di luar tiga upgrade refuge, affix equipment, cloud save dan Google Play Billing belum tersedia. Seluruh antarmuka, katalog, lore, dan pesan sistem versi ini menggunakan English; pengaturan bahasa lama tidak lagi mengubah bahasa tampilan. Catatan historis dari save 0.1 dapat tetap memakai bahasa lamanya. Intro berupa ilustrasi bergerak dan teks, tanpa video 3D atau voice-over. Balance jangka panjang, retensi nyata, dan variasi perangkat fisik masih memerlukan playtest. Board harian menggunakan waktu perangkat; belum ada server waktu atau validasi ekonomi daring.

## Pengembangan

Buka `project.godot` dengan Godot **4.7.1** dan export template yang sama. Android menggunakan Compatibility renderer, ARM64 dan x86_64, Java 17 dan Android SDK. Preset ekspor adalah **Android**. APK saat ini ditandatangani debug; tidak siap diunggah sebagai rilis toko.

Pemeriksaan ringan: `godot --headless --path . --script tests/essential_checks.gd`. Regenerasi katalog melalui `python tools/build_content.py`. Sumber audio ada di `tools/make_audio.py` dan `tools/make_score.py`; font statis disiapkan dengan `tools/prepare_fonts.py` (fontTools).

Lihat `docs/qa/production-polish-0.7-report.md`, `docs/production-polish-0.7.md` dan `docs/qa/foundation-report.md` untuk bukti dan keterbatasan pemeriksaan, serta `assets/manifest.json` untuk asal aset.
