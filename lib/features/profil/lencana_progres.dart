import 'package:flutter/material.dart';

import '../../data/dummy/dummy_data.dart';
import '../../data/models/app_user.dart';
import '../../data/models/lencana.dart';
import 'profil_strings.dart';

/// Satu lencana beserta syarat dan kemajuan pengguna menuju syarat itu.
class ProgresLencana {
  const ProgresLencana({
    required this.lencana,
    required this.syarat,
    required this.nilai,
    required this.target,
  });

  final Lencana lencana;
  final String syarat;

  /// Capaian pengguna saat ini, misalnya jumlah sirkel yang diikuti.
  final int nilai;

  /// Capaian yang dibutuhkan agar lencana didapat.
  final int target;

  bool get didapat => nilai >= target;

  /// Nilai yang ditampilkan tidak melebihi target ("4/4", bukan "6/4").
  int get nilaiTampil => nilai > target ? target : nilai;

  /// 0.0–1.0 untuk LinearProgressIndicator.
  double get rasio => target <= 0 ? 1.0 : nilaiTampil / target;
}

/// Target setiap lencana. Dibuat konstanta agar mudah dijelaskan dan diuji.
const targetAnggotaAktif = 4;
const targetRajinHadir = 20;
const targetKolektorMateri = 3;
const targetPenjelajah = 3;

/// Menghitung semua lencana dari capaian pengguna. Fungsi murni (tanpa membaca
/// DummyData) supaya bisa diuji dengan angka apa pun.
///
/// Urutan hasil: lencana yang sudah didapat lebih dulu, lalu yang belum didapat
/// diurutkan dari yang paling dekat tercapai (rasio terbesar).
List<ProgresLencana> hitungProgresLencana({
  required int sirkelDiikuti,
  required int jamBelajar,
  required int materiTersimpan,
  required int sirkelTersimpan,
  required bool mentor,
}) {
  final semua = [
    ProgresLencana(
      lencana: const Lencana(
        nama: ProfilStrings.lencanaSesiPertama,
        ikon: Icons.star,
      ),
      syarat: ProfilStrings.syaratSesiPertama,
      nilai: sirkelDiikuti,
      target: 1,
    ),
    ProgresLencana(
      lencana: const Lencana(
        nama: ProfilStrings.lencanaRajinHadir,
        ikon: Icons.emoji_events,
      ),
      syarat: ProfilStrings.syaratRajinHadir(targetRajinHadir),
      nilai: jamBelajar,
      target: targetRajinHadir,
    ),
    ProgresLencana(
      lencana: const Lencana(
        nama: ProfilStrings.lencanaAnggotaAktif,
        ikon: Icons.groups,
      ),
      syarat: ProfilStrings.syaratAnggotaAktif(targetAnggotaAktif),
      nilai: sirkelDiikuti,
      target: targetAnggotaAktif,
    ),
    ProgresLencana(
      lencana: const Lencana(
        nama: ProfilStrings.lencanaKolektorMateri,
        ikon: Icons.menu_book,
      ),
      syarat: ProfilStrings.syaratKolektorMateri(targetKolektorMateri),
      nilai: materiTersimpan,
      target: targetKolektorMateri,
    ),
    ProgresLencana(
      lencana: const Lencana(
        nama: ProfilStrings.lencanaPenjelajah,
        ikon: Icons.explore,
      ),
      syarat: ProfilStrings.syaratPenjelajah(targetPenjelajah),
      nilai: sirkelTersimpan,
      target: targetPenjelajah,
    ),
    ProgresLencana(
      lencana: const Lencana(
        nama: ProfilStrings.lencanaMentorSebaya,
        ikon: Icons.school,
      ),
      syarat: ProfilStrings.syaratMentorSebaya,
      nilai: mentor ? 1 : 0,
      target: 1,
    ),
  ];

  // Indeks asal jadi penentu terakhir agar urutan selalu sama (sort tidak stabil).
  final urut = [for (final (i, p) in semua.indexed) (progres: p, asal: i)]
    ..sort((a, b) {
      if (a.progres.didapat != b.progres.didapat) {
        return a.progres.didapat ? -1 : 1;
      }
      final banding = b.progres.rasio.compareTo(a.progres.rasio);
      return banding != 0 ? banding : a.asal.compareTo(b.asal);
    });
  return [for (final u in urut) u.progres];
}

/// Lencana pengguna aktif saat ini, dihitung dari DummyData. Dipanggil setiap
/// build Profil, jadi progres langsung berubah setelah gabung/simpan/jadi mentor.
List<ProgresLencana> progresLencanaSaatIni() => hitungProgresLencana(
      sirkelDiikuti: DummyData.sirkelDiikuti.length,
      jamBelajar: DummyData.jumlahJamBelajar,
      materiTersimpan: DummyData.materiTersimpan.length,
      sirkelTersimpan: DummyData.sirkelTersimpan.length,
      mentor: DummyData.statusMentor == StatusMentor.mentor,
    );
