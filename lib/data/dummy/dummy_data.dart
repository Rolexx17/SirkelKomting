import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../models/app_user.dart';
import '../models/lencana.dart';
import '../models/materi.dart';
import '../models/notifikasi.dart';
import '../models/sesi.dart';
import '../models/sirkel.dart';

/// Data contoh seluruh aplikasi (Bagian 11 brief), disimpan di memori selama aplikasi berjalan.
///
/// List disimpan privat; layar hanya membaca lewat getter dan mengubah lewat
/// fungsi [gabung] dan [tambahSirkel], sehingga perubahan data terkendali di satu tempat.
class DummyData {
  DummyData._();

  // ---------------- Pengguna ----------------
  static const _nadia = AppUser(
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
  // ada 6 pengguna (termasuk mentornya). Mereka tidak masuk getter [pengguna]
  // dan memakai ulang gambar avatar yang ada (aset avatar hanya 6).
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

  static const _pengguna = [_nadia, _raka, _sinta, _dimas, _lia, _kevin];

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

  // `final` (bukan const) karena list ini bisa bertambah dan diganti isinya.
  static final List<Sirkel> _sirkel = [
    const Sirkel(
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
      anggota: [_nadia, _sinta, _dimas, _lia, _kevin],
      mode: ModeBelajar.online,
      kuota: 8,
    ),
    const Sirkel(
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
      anggota: [_nadia, _raka, _dimas, _lia, _kevin, _bima],
      mode: ModeBelajar.offline,
      kuota: 10,
    ),
    const Sirkel(
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
      anggota: [_nadia, _lia, _dimas],
      mode: ModeBelajar.offline,
      kuota: 6,
    ),
    const Sirkel(
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
    const Sirkel(
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
    const Sirkel(
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

  /// Id sirkel yang diikuti Nadia (pengguna aktif).
  static final List<String> _diikuti = ['s1', 's2', 's3'];

  /// Nomor id sirkel baru berikutnya (s7, s8, ...).
  static int _nomorBerikut = 7;

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
    ),
  ];

  // ---------------- Notifikasi ----------------
  static const _notifikasi = [
    Notifikasi(
      id: 'n1',
      teks: '**Sesi Kalkulus I** dimulai 1 jam lagi. Siapkan soal yang mau dibahas.',
      waktu: '18.00',
      grup: 'Hari ini',
      jenis: JenisNotifikasi.sesi,
      belumDibaca: true,
      gambar: AppAssets.avatarRaka,
      sirkelId: 's1',
    ),
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

  // ---------------- Sesi & lencana ----------------
  // Tahun 2025 dipakai agar nama hari cocok dengan brief (9 Okt 2025 = Kamis).
  static final _sesi = [
    Sesi(sirkelId: 's1', waktu: DateTime(2025, 10, 9, 19)),
    Sesi(sirkelId: 's2', waktu: DateTime(2025, 10, 11, 10)),
    Sesi(sirkelId: 's3', waktu: DateTime(2025, 10, 15, 16)),
  ];

  static const _lencana = [
    Lencana(nama: 'Rajin Hadir', ikon: Icons.emoji_events),
    Lencana(nama: 'Anggota Aktif', ikon: Icons.groups),
    Lencana(nama: 'Pembagi Materi', ikon: Icons.menu_book),
    Lencana(nama: 'Sesi Pertama', ikon: Icons.star),
  ];

  // ---------------- Getter (hanya baca) ----------------
  static AppUser get penggunaAktif => _nadia;
  static List<AppUser> get pengguna => _pengguna;

  /// Salinan tak-bisa-diubah; perubahan hanya lewat [gabung] dan [tambahSirkel].
  static List<Sirkel> get semuaSirkel => List.unmodifiable(_sirkel);

  static List<Sirkel> get sirkelDiikuti =>
      _diikuti.map(cariSirkel).whereType<Sirkel>().toList();

  static List<Materi> get semuaMateri => _materi;
  static List<Notifikasi> get notifikasi => _notifikasi;
  static List<Sesi> get jadwalSesi => List.unmodifiable(_sesi);
  static List<Lencana> get lencanaTerbaru => _lencana;
  static List<String> get daftarMataKuliah => _mataKuliah;

  // ---------------- Fungsi ----------------
  static Sirkel? cariSirkel(String id) =>
      _sirkel.where((s) => s.id == id).firstOrNull;

  static Materi? cariMateri(String id) =>
      _materi.where((m) => m.id == id).firstOrNull;

  static bool sudahGabung(String sirkelId) => _diikuti.contains(sirkelId);

  /// Menambah Nadia ke anggota sirkel dan ke [sirkelDiikuti].
  /// Diabaikan bila id tidak ada, sudah bergabung, atau sirkel penuh.
  static void gabung(String sirkelId) {
    final i = _sirkel.indexWhere((s) => s.id == sirkelId);
    if (i == -1 || sudahGabung(sirkelId) || _sirkel[i].penuh) return;

    final lama = _sirkel[i];
    // Objek Sirkel tidak bisa diubah, jadi diganti dengan salinan berisi anggota baru.
    _sirkel[i] = lama.copyWith(anggota: [...lama.anggota, _nadia]);
    _diikuti.add(sirkelId);
  }

  /// Membuat sirkel baru dengan Nadia sebagai mentornya, lalu mengembalikan id barunya.
  /// Sirkel baru diletakkan paling atas agar langsung terlihat di Jelajah, dan ikut
  /// masuk [sirkelDiikuti] karena pembuatnya pasti terlibat di sirkel itu.
  static String tambahSirkel({
    required String mataKuliah,
    required String judul,
    required ModeBelajar mode,
    required String hari,
    required String jam,
    required int kuota,
    required String cover,
  }) {
    final id = 's${_nomorBerikut++}';
    _sirkel.insert(
      0,
      Sirkel(
        id: id,
        mataKuliah: mataKuliah,
        judul: judul,
        deskripsi:
            'Sirkel baru dari ${_nadia.nama}. Detail materi akan dibagikan mentor sebelum sesi pertama.',
        cover: cover,
        hari: hari,
        jam: jam,
        lokasi: mode == ModeBelajar.online
            ? lokasiOnlineBawaan
            : lokasiOfflineBawaan,
        level: levelBawaan,
        mentor: _nadia,
        anggota: const [],
        mode: mode,
        kuota: kuota,
      ),
    );
    _diikuti.add(id);
    return id;
  }
}
