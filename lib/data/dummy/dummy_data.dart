import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../models/app_user.dart';
import '../models/lencana.dart';
import '../models/materi.dart';
import '../models/notifikasi.dart';
import '../models/sesi.dart';
import '../models/sirkel.dart';
import '../util/waktu_data.dart';

/// Data contoh seluruh aplikasi (Bagian 11 brief), disimpan di memori selama aplikasi berjalan.
///
/// Data awal ditulis sebagai konstanta `...Awal`; data yang bisa berubah disimpan di
/// variabel privat dan hanya diubah lewat fungsi di kelas ini, sehingga semua layar
/// membaca sumber yang sama dan selalu sinkron.
class DummyData {
  DummyData._();

  // ---------------- Pengguna ----------------
  static const _nadiaAwal = AppUser(
    id: 'u1',
    nama: 'Nadia Putri',
    prodi: 'Sistem Informasi',
    angkatan: '2025',
    avatar: AppAssets.avatarNadia,
  );
  static const _raka = AppUser(
    id: 'u2',
    nama: 'Raka Pratama',
    prodi: 'Teknik Informatika',
    angkatan: '2023',
    avatar: AppAssets.avatarRaka,
    isMentor: true,
    rating: 4.9,
  );
  static const _sinta = AppUser(
    id: 'u3',
    nama: 'Sinta Maharani',
    prodi: 'Teknik Informatika',
    angkatan: '2023',
    avatar: AppAssets.avatarSinta,
    isMentor: true,
    rating: 4.8,
  );
  static const _dimas = AppUser(
    id: 'u4',
    nama: 'Dimas Saputra',
    prodi: 'Sistem Informasi',
    angkatan: '2023',
    avatar: AppAssets.avatarDimas,
    isMentor: true,
    rating: 4.7,
  );
  static const _lia = AppUser(
    id: 'u5',
    nama: 'Lia Angelina',
    prodi: 'Manajemen',
    angkatan: '2022',
    avatar: AppAssets.avatarLia,
    isMentor: true,
    rating: 4.8,
  );
  static const _kevin = AppUser(
    id: 'u6',
    nama: 'Kevin Halim',
    prodi: 'Sistem Informasi',
    angkatan: '2022',
    avatar: AppAssets.avatarKevin,
    isMentor: true,
    rating: 4.9,
  );

  // Peserta tambahan: s2 butuh 6 anggota dan s4 butuh 7 anggota, padahal hanya
  // ada 6 pengguna utama (termasuk mentornya). Mereka memakai ulang gambar
  // avatar yang ada (aset avatar hanya 6).
  static const _bima = AppUser(
    id: 'u7',
    nama: 'Bima Aditya',
    prodi: 'Teknik Informatika',
    angkatan: '2025',
    avatar: AppAssets.avatarDimas,
  );
  static const _putri = AppUser(
    id: 'u8',
    nama: 'Putri Ayu',
    prodi: 'Akuntansi',
    angkatan: '2025',
    avatar: AppAssets.avatarSinta,
  );
  static const _rizky = AppUser(
    id: 'u9',
    nama: 'Rizky Ramadhan',
    prodi: 'Manajemen',
    angkatan: '2024',
    avatar: AppAssets.avatarKevin,
  );

  // ---------------- Mata kuliah ----------------
  // Urutannya sama dengan AppAssets.covers, jadi indeks mata kuliah = indeks sampulnya.
  static const _mataKuliah = [
    'Kalkulus I',
    'Struktur Data',
    'Basis Data',
    'Statistika',
    'Pemrograman Mobile',
    'B. Inggris Akademik',
  ];

  // ---------------- Sirkel ----------------
  static const levelBawaan = 'Pemula';
  static const lokasiOnlineBawaan = 'Google Meet';
  static const lokasiOfflineBawaan = 'Kampus (lokasi menyusul)';

  static const _sirkelAwal = [
    Sirkel(
      id: 's1',
      mataKuliah: 'Kalkulus I',
      judul: 'Limit & Turunan',
      deskripsi:
          'Bahas konsep limit sampai aturan turunan lewat contoh soal UTS tahun lalu. Bawa soal yang bikin bingung, kita kupas bareng.',
      cover: AppAssets.coverKalkulus,
      hari: 'Kamis',
      jam: '19.00',
      lokasi: 'Google Meet',
      level: levelBawaan,
      mentor: _raka,
      anggota: [_nadiaAwal, _sinta, _dimas, _lia, _kevin],
      mode: ModeBelajar.online,
      kuota: 8,
    ),
    Sirkel(
      id: 's2',
      mataKuliah: 'Struktur Data',
      judul: 'Tree & Graph',
      deskripsi:
          'Latihan traversal tree dan graph langsung di papan tulis. Cocok untuk yang masih bingung membedakan BFS dan DFS.',
      cover: AppAssets.coverStrukdat,
      hari: 'Sabtu',
      jam: '10.00',
      lokasi: 'Perpustakaan Lt. 2',
      level: levelBawaan,
      mentor: _sinta,
      anggota: [_nadiaAwal, _raka, _dimas, _lia, _kevin, _bima],
      mode: ModeBelajar.offline,
      kuota: 10,
    ),
    Sirkel(
      id: 's3',
      mataKuliah: 'Basis Data',
      judul: 'Normalisasi 1NF–3NF',
      deskripsi:
          'Kupas normalisasi tabel dari 1NF sampai 3NF memakai studi kasus sederhana. Bawa laptop kalau ada.',
      cover: AppAssets.coverBasisData,
      hari: 'Rabu',
      jam: '16.00',
      lokasi: 'Ruang Diskusi B',
      level: levelBawaan,
      mentor: _kevin,
      anggota: [_nadiaAwal, _lia, _dimas],
      mode: ModeBelajar.offline,
      kuota: 6,
    ),
    Sirkel(
      id: 's4',
      mataKuliah: 'Statistika',
      judul: 'Uji Hipotesis',
      deskripsi:
          'Belajar menentukan H0 dan H1 lalu memilih uji yang tepat. Kita kerjakan soal latihan bareng sampai paham.',
      cover: AppAssets.coverStatistika,
      hari: 'Jumat',
      jam: '20.00',
      lokasi: 'Zoom',
      level: levelBawaan,
      mentor: _lia,
      anggota: [_raka, _sinta, _dimas, _kevin, _bima, _putri, _rizky],
      mode: ModeBelajar.online,
      kuota: 8,
    ),
    Sirkel(
      id: 's5',
      mataKuliah: 'Pemrograman Mobile',
      judul: 'Layout di Flutter',
      deskripsi:
          'Praktik menyusun Row, Column, dan Stack sampai tampilan rapi di berbagai ukuran layar.',
      cover: AppAssets.coverMobile,
      hari: 'Selasa',
      jam: '18.30',
      lokasi: 'Discord',
      level: levelBawaan,
      mentor: _dimas,
      anggota: [_sinta, _kevin, _bima, _putri],
      mode: ModeBelajar.online,
      kuota: 8,
    ),
    Sirkel(
      id: 's6',
      mataKuliah: 'B. Inggris Akademik',
      judul: 'Latihan Presentasi',
      deskripsi:
          'Latihan presentasi singkat dalam bahasa Inggris dengan suasana santai. Salah ucap itu wajar, yang penting berani mencoba.',
      cover: AppAssets.coverInggris,
      hari: 'Senin',
      jam: '15.00',
      lokasi: 'Taman Kampus',
      level: levelBawaan,
      mentor: _raka,
      anggota: [_lia, _rizky],
      mode: ModeBelajar.offline,
      kuota: 6,
    ),
  ];

  static const _diikutiAwal = ['s1', 's2', 's3'];

  /// Rentang jadwal sesi yang ditampilkan, mulai sekarang.
  static const rentangJadwalHari = 14;

  // ---------------- Materi ----------------
  static const _materi = [
    Materi(
      id: 'm1',
      judul: 'Rangkuman Limit Fungsi',
      format: 'PDF',
      mataKuliah: 'Kalkulus I',
      cover: AppAssets.coverKalkulus,
      waktu: '2 hari lalu',
      halaman: 12,
      pengunggah: _raka,
      isi: [
        'Definisi limit dan notasinya',
        'Limit kiri & limit kanan',
        'Limit tak hingga',
        '5 contoh soal UTS + pembahasan',
      ],
      catatan: [
        'Limit menyatakan nilai yang didekati f(x) ketika x mendekati suatu bilangan, ditulis lim x→c f(x).',
        'Limit ada bila nilai pendekatan dari kiri dan kanan sama.',
        'Limit tak hingga terjadi bila nilai fungsi membesar atau mengecil tanpa batas saat x mendekati suatu titik.',
        'Soal disusun dari yang mudah ke sulit; coba kerjakan dulu sebelum membaca pembahasannya.',
      ],
    ),
    Materi(
      id: 'm2',
      judul: 'Cheat Sheet Traversal Tree',
      format: 'PNG',
      mataKuliah: 'Struktur Data',
      cover: AppAssets.coverStrukdat,
      waktu: '3 hari lalu',
      halaman: 1,
      pengunggah: _sinta,
      isi: [
        'Preorder, inorder, dan postorder',
        'Level order (BFS)',
        'Contoh tree dan urutan kunjungannya',
      ],
      catatan: [
        'Ketiganya berbeda pada kapan simpul akar dikunjungi: sebelum, di antara, atau sesudah anak-anaknya.',
        'Simpul dikunjungi per tingkat dari atas ke bawah dengan bantuan antrean (queue).',
        'Satu tree yang sama ditelusuri dengan keempat cara agar perbedaannya mudah dibandingkan.',
      ],
    ),
    Materi(
      id: 'm3',
      judul: 'Contoh Soal 3NF',
      format: 'PDF',
      mataKuliah: 'Basis Data',
      cover: AppAssets.coverBasisData,
      waktu: '4 hari lalu',
      halaman: 6,
      pengunggah: _kevin,
      isi: [
        'Ulasan singkat 1NF dan 2NF',
        'Ketergantungan transitif',
        '3 soal normalisasi + pembahasan',
      ],
      catatan: [
        '1NF menghapus nilai berulang dalam satu kolom; 2NF menghapus ketergantungan pada sebagian kunci.',
        'Terjadi bila kolom bukan kunci bergantung pada kolom bukan kunci lain, bukan langsung pada kunci utama.',
        'Setiap soal dimulai dari tabel mentah lalu dipecah bertahap sampai memenuhi 3NF.',
      ],
    ),
    Materi(
      id: 'm4',
      judul: 'Latihan Uji-t',
      format: 'PDF',
      mataKuliah: 'Statistika',
      cover: AppAssets.coverStatistika,
      waktu: '5 hari lalu',
      halaman: 8,
      pengunggah: _lia,
      isi: [
        'Menyusun H0 dan H1',
        'Uji-t satu sampel',
        'Uji-t dua sampel independen',
        '4 soal latihan + kunci jawaban',
      ],
      catatan: [
        'H0 menyatakan tidak ada perbedaan, sedangkan H1 adalah dugaan yang ingin dibuktikan.',
        'Uji ini membandingkan rata-rata satu sampel dengan satu nilai acuan.',
        'Uji ini membandingkan rata-rata dua kelompok yang tidak saling berhubungan.',
        'Kerjakan berurutan: hipotesis, statistik uji, nilai kritis, lalu kesimpulan.',
      ],
    ),
  ];

  // ---------------- Notifikasi ----------------
  // Notifikasi tetap (n1 "dimulai 1 jam lagi" dihapus; pengingat sesi kini dibuat
  // otomatis dari jadwal, lihat [notifikasiSejak]).
  static const _notifikasiStatis = [
    Notifikasi(
      id: 'n2',
      teks: '**Sinta** membagikan materi baru: Cheat Sheet Traversal Tree.',
      waktu: '15.20',
      grup: 'Hari ini',
      jenis: JenisNotifikasi.materi,
      belumDibaca: true,
      gambar: AppAssets.avatarSinta,
      sirkelId: 's2',
    ),
    Notifikasi(
      id: 'n3',
      teks: 'Kamu diterima di sirkel **Basis Data · Normalisasi**.',
      waktu: 'Kemarin',
      grup: 'Minggu ini',
      jenis: JenisNotifikasi.diterima,
      gambar: AppAssets.coverBasisData,
      sirkelId: 's3',
    ),
    Notifikasi(
      id: 'n4',
      teks: 'Lencana baru: **Rajin Hadir**. Kamu hadir 3 sesi berturut-turut.',
      waktu: '2 hari lalu',
      grup: 'Minggu ini',
      jenis: JenisNotifikasi.lencana,
    ),
    Notifikasi(
      id: 'n5',
      teks: '**Kevin** mengubah jadwal sirkel Basis Data menjadi Rabu, 16.00.',
      waktu: '3 hari lalu',
      grup: 'Minggu ini',
      jenis: JenisNotifikasi.jadwal,
      gambar: AppAssets.avatarKevin,
      sirkelId: 's3',
    ),
  ];

  // ---------------- Lencana & statistik ----------------
  static const _lencana = [
    Lencana(nama: 'Rajin Hadir', ikon: Icons.emoji_events),
    Lencana(nama: 'Anggota Aktif', ikon: Icons.groups),
    Lencana(nama: 'Pembagi Materi', ikon: Icons.menu_book),
    Lencana(nama: 'Sesi Pertama', ikon: Icons.star),
    Lencana(nama: 'Penanya Aktif', ikon: Icons.forum),
  ];
  static const _jumlahLencanaTerbaru = 4;
  static const _jamBelajar = 24;

  // ---------------- State yang bisa berubah ----------------
  // Diisi dari data awal; resetUntukTes() mengembalikannya ke kondisi ini.
  static AppUser _aktif = _nadiaAwal;
  static List<Sirkel> _sirkel = List.of(_sirkelAwal);
  static List<String> _diikuti = List.of(_diikutiAwal);

  /// Notifikasi dari aksi pengguna (gabung, terbitkan, ajukan mentor); terbaru di indeks 0.
  static List<Notifikasi> _notifikasiTambahan = [];

  /// Id notifikasi statis/tambahan yang sudah dibaca.
  static Set<String> _notifikasiDibaca = {};

  /// Kunci sesi (sirkel + waktu) yang pengingatnya sudah dibaca. Bila sesi terdekat
  /// berganti, kuncinya berbeda sehingga pengingat baru tampil belum dibaca lagi.
  static String? _pengingatDibaca;

  // List (bukan Set) agar urutan menyimpan tetap tercatat.
  static List<String> _sirkelDisimpan = [];
  static List<String> _materiDisimpan = [];

  static bool _mentorDiajukan = false;

  /// Nomor id sirkel baru berikutnya (s7, s8, ...).
  static int _nomorBerikut = 7;

  /// Nomor id notifikasi tambahan berikutnya (n-baru-1, n-baru-2, ...).
  static int _nomorNotifikasi = 1;

  // ---------------- Getter (hanya baca) ----------------
  /// Pengguna yang sedang masuk (awalnya Nadia); bisa berubah lewat [ubahProfil].
  static AppUser get penggunaAktif => _aktif;

  /// Peserta → menunggu (setelah [ajukanMentor]) → mentor (setelah disetujui atau
  /// menerbitkan sirkel). Diturunkan dari data, jadi tidak pernah tidak sinkron.
  static StatusMentor get statusMentor {
    if (_aktif.isMentor) return StatusMentor.mentor;
    return _mentorDiajukan ? StatusMentor.menunggu : StatusMentor.peserta;
  }

  /// Salinan tak-bisa-diubah; perubahan hanya lewat fungsi di kelas ini.
  static List<Sirkel> get semuaSirkel => List.unmodifiable(_sirkel);

  static List<Sirkel> get sirkelDiikuti =>
      _diikuti.map(cariSirkel).whereType<Sirkel>().toList();

  static List<Materi> get semuaMateri => _materi;
  static List<String> get daftarMataKuliah => _mataKuliah;

  static List<Lencana> get semuaLencana => _lencana;
  static List<Lencana> get lencanaTerbaru =>
      _lencana.take(_jumlahLencanaTerbaru).toList();
  static int get jumlahJamBelajar => _jamBelajar;

  // ---------------- Jadwal ----------------
  /// Sesi dari semua sirkel yang diikuti, dari sekarang sampai 14 hari ke depan.
  /// Dihitung ulang setiap kali dibaca, jadi tanggalnya selalu mengikuti hari ini.
  static List<Sesi> get jadwalSesi => jadwalSesiSejak(DateTime.now());

  /// Versi [jadwalSesi] dengan waktu acuan tertentu (dipakai test agar hasilnya pasti).
  static List<Sesi> jadwalSesiSejak(DateTime sekarang) {
    final batas = sekarang.add(const Duration(days: rentangJadwalHari));
    final hasil = <Sesi>[];

    for (final sirkel in sirkelDiikuti) {
      final menit = menitDariJam(sirkel.jam);
      if (menit == null) continue;
      final hariSesi = sirkel.daftarNomorHari;

      // Periksa setiap tanggal dari hari ini sampai 14 hari ke depan; ambil yang
      // harinya cocok. DateTime otomatis menyesuaikan pergantian bulan/tahun.
      for (var i = 0; i <= rentangJadwalHari; i++) {
        final waktu = DateTime(
          sekarang.year,
          sekarang.month,
          sekarang.day + i,
          menit ~/ 60,
          menit % 60,
        );
        if (!hariSesi.contains(waktu.weekday)) continue;
        // Sesi hari ini yang jamnya sudah lewat, atau yang melewati batas, tidak dihitung.
        if (waktu.isBefore(sekarang) || waktu.isAfter(batas)) continue;
        hasil.add(Sesi(sirkelId: sirkel.id, waktu: waktu));
      }
    }

    return hasil..sort((a, b) => a.waktu.compareTo(b.waktu));
  }

  // ---------------- Notifikasi ----------------
  /// Id tetap untuk notifikasi pengingat sesi.
  static const idPengingatSesi = 'n-sesi';

  static List<Notifikasi> get notifikasi => notifikasiSejak(DateTime.now());

  static bool get adaNotifikasiBaru => notifikasi.any((n) => n.belumDibaca);

  /// Menyusun daftar notifikasi pada waktu [sekarang]:
  /// pengingat sesi terdekat (bila ada) → notifikasi tambahan → notifikasi statis.
  /// Status dibaca diambil dari [_notifikasiDibaca] dan [_pengingatDibaca].
  static List<Notifikasi> notifikasiSejak(DateTime sekarang) {
    final pengingat = _pengingatSesi(sekarang);
    return [
      if (pengingat != null) pengingat,
      for (final n in [..._notifikasiTambahan, ..._notifikasiStatis])
        _notifikasiDibaca.contains(n.id) ? n.copyWith(belumDibaca: false) : n,
    ];
  }

  /// Pengingat untuk sesi pertama di jadwal; null bila tidak ada sesi.
  static Notifikasi? _pengingatSesi(DateTime sekarang) {
    final sesi = jadwalSesiSejak(sekarang).firstOrNull;
    if (sesi == null) return null;
    final sirkel = cariSirkel(sesi.sirkelId);
    if (sirkel == null) return null;

    return Notifikasi(
      id: idPengingatSesi,
      teks: '**Sesi ${sirkel.mataKuliah}** ${labelHariSesi(sesi.waktu, sekarang)} '
          'pukul ${sirkel.jam}. Siapkan soal yang mau dibahas.',
      waktu: _waktuPengingat,
      grup: _grupHariIni,
      jenis: JenisNotifikasi.sesi,
      belumDibaca: _pengingatDibaca != _kunciSesi(sesi),
      gambar: sirkel.mentor.avatar,
      sirkelId: sirkel.id,
    );
  }

  static String _kunciSesi(Sesi sesi) =>
      '${sesi.sirkelId}@${sesi.waktu.toIso8601String()}';

  static const _grupHariIni = 'Hari ini';
  static const _waktuBaru = 'Baru saja';
  static const _waktuPengingat = 'Pengingat jadwal';

  /// Menambah notifikasi baru di urutan teratas (grup "Hari ini", belum dibaca).
  static void _tambahNotifikasi({
    required String teks,
    required JenisNotifikasi jenis,
    String? gambar,
    String? sirkelId,
  }) {
    _notifikasiTambahan.insert(
      0,
      Notifikasi(
        id: 'n-baru-${_nomorNotifikasi++}',
        teks: teks,
        waktu: _waktuBaru,
        grup: _grupHariIni,
        jenis: jenis,
        belumDibaca: true,
        gambar: gambar,
        sirkelId: sirkelId,
      ),
    );
  }

  static void tandaiNotifikasiDibaca(String id) {
    if (id == idPengingatSesi) {
      final sesi = jadwalSesi.firstOrNull;
      if (sesi != null) _pengingatDibaca = _kunciSesi(sesi);
    } else {
      _notifikasiDibaca.add(id);
    }
  }

  static void tandaiSemuaNotifikasiDibaca() {
    for (final n in notifikasi) {
      tandaiNotifikasiDibaca(n.id);
    }
  }

  // ---------------- Fungsi sirkel ----------------
  static Sirkel? cariSirkel(String id) =>
      _sirkel.where((s) => s.id == id).firstOrNull;

  static Materi? cariMateri(String id) =>
      _materi.where((m) => m.id == id).firstOrNull;

  static bool sudahGabung(String sirkelId) => _diikuti.contains(sirkelId);

  /// true bila pengguna aktif adalah mentor sirkel tersebut (misalnya sirkel buatannya).
  static bool adalahMentorSirkel(String sirkelId) =>
      cariSirkel(sirkelId)?.mentor.id == _aktif.id;

  /// Menambah pengguna aktif ke anggota sirkel dan ke [sirkelDiikuti], sehingga
  /// sesinya otomatis muncul di [jadwalSesi], lalu menambah notifikasi "diterima".
  /// Diabaikan bila id tidak ada, sudah bergabung, atau sirkel penuh.
  static void gabung(String sirkelId) {
    final i = _sirkel.indexWhere((s) => s.id == sirkelId);
    if (i == -1 || sudahGabung(sirkelId) || _sirkel[i].penuh) return;

    final lama = _sirkel[i];
    // Objek Sirkel tidak bisa diubah, jadi diganti dengan salinan berisi anggota baru.
    _sirkel[i] = lama.copyWith(anggota: [...lama.anggota, _aktif]);
    _diikuti.add(sirkelId);
    _tambahNotifikasi(
      teks: 'Kamu bergabung ke sirkel **${lama.mataKuliah} · ${lama.judul}**.',
      jenis: JenisNotifikasi.diterima,
      gambar: lama.cover,
      sirkelId: sirkelId,
    );
  }

  /// Kebalikan [gabung]: menghapus pengguna aktif dari anggota dan dari [sirkelDiikuti],
  /// sehingga sesinya hilang dari [jadwalSesi]. Diabaikan bila belum bergabung atau
  /// bila pengguna adalah mentor sirkel tersebut (mentor tidak bisa meninggalkan sirkelnya).
  static void keluarSirkel(String sirkelId) {
    if (!sudahGabung(sirkelId) || adalahMentorSirkel(sirkelId)) return;

    final i = _sirkel.indexWhere((s) => s.id == sirkelId);
    if (i != -1) {
      final lama = _sirkel[i];
      _sirkel[i] = lama.copyWith(
        anggota: lama.anggota.where((a) => a.id != _aktif.id).toList(),
      );
    }
    _diikuti.remove(sirkelId);
  }

  /// Membuat sirkel baru dengan pengguna aktif sebagai mentornya, lalu mengembalikan id barunya.
  /// Pengguna otomatis berstatus mentor, sirkel diletakkan paling atas di Jelajah, masuk
  /// [sirkelDiikuti] (jadwalnya muncul di Sirkel Saya), dan ada notifikasi "diterbitkan".
  static String tambahSirkel({
    required String mataKuliah,
    required String judul,
    required ModeBelajar mode,
    required String hari,
    required String jam,
    required int kuota,
    required String cover,
  }) {
    if (!_aktif.isMentor) _gantiPenggunaAktif(_aktif.copyWith(isMentor: true));
    _mentorDiajukan = false;

    final id = 's${_nomorBerikut++}';
    _sirkel.insert(
      0,
      Sirkel(
        id: id,
        mataKuliah: mataKuliah,
        judul: judul,
        deskripsi:
            'Sirkel baru dari ${_aktif.nama}. Detail materi akan dibagikan mentor sebelum sesi pertama.',
        cover: cover,
        hari: hari,
        jam: jam,
        lokasi: mode == ModeBelajar.online
            ? lokasiOnlineBawaan
            : lokasiOfflineBawaan,
        level: levelBawaan,
        mentor: _aktif,
        anggota: const [],
        mode: mode,
        kuota: kuota,
      ),
    );
    _diikuti.add(id);
    _tambahNotifikasi(
      teks: 'Sirkel **$judul** berhasil diterbitkan.',
      jenis: JenisNotifikasi.diterima,
      gambar: cover,
      sirkelId: id,
    );
    return id;
  }

  // ---------------- Profil & mentor ----------------
  /// Mengganti nama, prodi, dan (opsional) peran pengguna aktif. Bila [akunBaru],
  /// avatar dikosongkan (UserAvatar menampilkan inisial) dan pengajuan mentor dibatalkan.
  static void ubahProfil({
    required String nama,
    required String prodi,
    bool? mentor,
    bool akunBaru = false,
  }) {
    _gantiPenggunaAktif(
      _aktif.copyWith(
        nama: nama,
        prodi: prodi,
        isMentor: mentor,
        avatar: akunBaru ? '' : null,
      ),
    );
    if (akunBaru) _mentorDiajukan = false;
  }

  /// Mengajukan diri menjadi mentor: peserta → menunggu, plus notifikasi jenis mentor.
  /// Diabaikan bila sudah menunggu atau sudah mentor.
  static void ajukanMentor() {
    if (statusMentor != StatusMentor.peserta) return;
    _mentorDiajukan = true;
    _tambahNotifikasi(
      teks: 'Pengajuan mentor sedang ditinjau tim Sirkel.',
      jenis: JenisNotifikasi.mentor,
    );
  }

  /// Mengganti pengguna aktif dan objeknya di `anggota`/`mentor` semua sirkel
  /// (dicocokkan lewat id), karena AppUser immutable dan disimpan sebagai objek.
  static void _gantiPenggunaAktif(AppUser baru) {
    _aktif = baru;
    _sirkel = [
      for (final s in _sirkel)
        s.copyWith(
          mentor: s.mentor.id == baru.id ? baru : s.mentor,
          anggota: [for (final a in s.anggota) a.id == baru.id ? baru : a],
        ),
    ];
  }

  // ---------------- Simpanan (bookmark) ----------------
  static bool sirkelDisimpan(String id) => _sirkelDisimpan.contains(id);

  static void toggleSimpanSirkel(String id) {
    // List.remove mengembalikan false bila id belum ada, jadi saat itu id ditambahkan.
    if (!_sirkelDisimpan.remove(id)) _sirkelDisimpan.add(id);
  }

  /// Sirkel yang disimpan, yang terakhir disimpan paling atas.
  static List<Sirkel> get sirkelTersimpan =>
      _sirkelDisimpan.reversed.map(cariSirkel).whereType<Sirkel>().toList();

  static bool materiDisimpan(String id) => _materiDisimpan.contains(id);

  static void toggleSimpanMateri(String id) {
    if (!_materiDisimpan.remove(id)) _materiDisimpan.add(id);
  }

  /// Materi yang disimpan, yang terakhir disimpan paling atas.
  static List<Materi> get materiTersimpan =>
      _materiDisimpan.reversed.map(cariMateri).whereType<Materi>().toList();

  // ---------------- Test ----------------
  /// Mengembalikan semua data ke kondisi awal. Data disimpan statis, jadi tanpa ini
  /// perubahan di satu test (misalnya gabung) ikut terbawa ke test berikutnya.
  @visibleForTesting
  static void resetUntukTes() {
    _aktif = _nadiaAwal;
    _sirkel = List.of(_sirkelAwal);
    _diikuti = List.of(_diikutiAwal);
    _notifikasiTambahan = [];
    _notifikasiDibaca = {};
    _pengingatDibaca = null;
    _sirkelDisimpan = [];
    _materiDisimpan = [];
    _mentorDiajukan = false;
    _nomorBerikut = 7;
    _nomorNotifikasi = 1;
  }
}
