/// Jenis notifikasi; menentukan gambar/ikon yang ditampilkan di daftar Notifikasi.
enum JenisNotifikasi { sesi, materi, diterima, lencana, jadwal }

/// Satu item di layar Notifikasi.
class Notifikasi {
  const Notifikasi({
    required this.id,
    required this.teks,
    required this.waktu,
    required this.grup,
    required this.jenis,
    this.belumDibaca = false,
    this.gambar,
    this.sirkelId,
  });

  final String id;

  /// Bagian yang dicetak tebal ditandai `**...**`, sama seperti penulisan di brief.
  final String teks;
  final String waktu;

  /// Nama grup tampilan: "Hari ini" atau "Minggu ini".
  final String grup;
  final JenisNotifikasi jenis;
  final bool belumDibaca;

  /// Path avatar/sampul; null untuk notifikasi lencana (memakai ikon).
  final String? gambar;

  /// Sirkel tujuan saat item diketuk; null bila tidak menuju sirkel.
  final String? sirkelId;

  /// Salinan dengan status baca baru (dipakai "Tandai dibaca").
  Notifikasi copyWith({bool? belumDibaca}) {
    return Notifikasi(
      id: id,
      teks: teks,
      waktu: waktu,
      grup: grup,
      jenis: jenis,
      belumDibaca: belumDibaca ?? this.belumDibaca,
      gambar: gambar,
      sirkelId: sirkelId,
    );
  }
}
