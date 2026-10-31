import '../util/waktu_data.dart';
import 'app_user.dart';

/// Cara sesi sirkel berlangsung. Ditaruh di file ini karena selalu dipakai bersama [Sirkel].
enum ModeBelajar { online, offline }

/// Satu kelompok belajar (sirkel) per mata kuliah yang dipandu mentor sebaya.
class Sirkel {
  const Sirkel({
    required this.id,
    required this.mataKuliah,
    required this.judul,
    required this.deskripsi,
    required this.cover,
    required this.hari,
    required this.jam,
    required this.lokasi,
    required this.level,
    required this.mentor,
    required this.anggota,
    required this.mode,
    required this.kuota,
  });

  final String id;
  final String mataKuliah;
  final String judul;
  final String deskripsi;

  /// Path sampul dari `AppAssets`.
  final String cover;

  /// Nama hari lengkap, misalnya "Kamis", atau beberapa hari hasil Buat Sirkel
  /// seperti "Senin & Rabu" dan "Senin, Rabu & Jumat".
  final String hari;

  /// Jam mulai format "HH.MM", misalnya "19.00".
  final String jam;
  final String lokasi;
  final String level;
  final AppUser mentor;
  final List<AppUser> anggota;
  final ModeBelajar mode;
  final int kuota;

  /// Kursi kosong = kuota dikurangi jumlah anggota. Dihitung, bukan disimpan,
  /// sehingga selalu benar setelah anggota bertambah.
  int get sisaKursi => kuota - anggota.length;

  /// Sirkel penuh bila tidak ada kursi tersisa (<= 0 untuk berjaga-jaga).
  bool get penuh => sisaKursi <= 0;

  /// Nomor hari ISO (Senin = 1 … Minggu = 7) dari [hari], misalnya "Senin & Rabu" → [1, 3].
  /// Dipakai jadwal sesi dan filter hari agar sirkel multi-hari dikenali semua harinya.
  List<int> get daftarNomorHari => nomorHariDariTeks(hari);

  /// Membuat salinan dengan sebagian field diganti. Karena semua field `final`,
  /// menambah anggota dilakukan dengan membuat objek baru, bukan mengubah objek lama.
  Sirkel copyWith({
    String? id,
    String? mataKuliah,
    String? judul,
    String? deskripsi,
    String? cover,
    String? hari,
    String? jam,
    String? lokasi,
    String? level,
    AppUser? mentor,
    List<AppUser>? anggota,
    ModeBelajar? mode,
    int? kuota,
  }) {
    return Sirkel(
      id: id ?? this.id,
      mataKuliah: mataKuliah ?? this.mataKuliah,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      cover: cover ?? this.cover,
      hari: hari ?? this.hari,
      jam: jam ?? this.jam,
      lokasi: lokasi ?? this.lokasi,
      level: level ?? this.level,
      mentor: mentor ?? this.mentor,
      anggota: anggota ?? this.anggota,
      mode: mode ?? this.mode,
      kuota: kuota ?? this.kuota,
    );
  }
}
