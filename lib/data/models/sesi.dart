/// Jadwal satu sesi belajar dari sebuah sirkel (dipakai Sirkel Saya).
class Sesi {
  const Sesi({required this.sirkelId, required this.waktu});

  /// Lama satu sesi. Sesi dianggap selesai pada [waktu] + [durasi].
  static const durasi = Duration(minutes: 90);

  final String sirkelId;
  final DateTime waktu;
}
