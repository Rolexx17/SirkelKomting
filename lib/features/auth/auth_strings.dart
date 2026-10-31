/// Teks statis layar Masuk dan Daftar.
class AuthStrings {
  AuthStrings._();

  // Kolom bersama
  static const labelEmail = 'Email kampus';
  static const labelSandi = 'Kata sandi';

  // Masuk
  static const masukJudul = 'Selamat datang kembali';
  static const masukSubjudul = 'Masuk untuk lanjut belajar bareng sirkelmu.';
  static const lupaSandi = 'Lupa kata sandi?';
  static const masuk = 'Masuk';
  static const belumPunyaAkun = 'Belum punya akun? ';
  static const daftar = 'Daftar';

  // Lupa kata sandi (bottom sheet)
  static const lupaSandiJudul = 'Atur ulang kata sandi';
  static const lupaSandiPesan =
      'Masukkan email kampusmu. Kami akan mengirim tautan untuk membuat kata sandi baru.';
  static const kirimTautan = 'Kirim tautan';
  static String tautanTerkirim(String email) =>
      'Tautan atur ulang dikirim ke $email (simulasi).';

  // Daftar
  static const kembali = 'Kembali';
  static const daftarJudul = 'Buat akun';
  static const daftarSubjudul = 'Satu langkah lagi untuk menemukan sirkelmu.';
  static const labelNama = 'Nama lengkap';
  static const labelProdi = 'Program studi';
  static const daftarProdi = [
    'Sistem Informasi',
    'Teknik Informatika',
    'Manajemen',
    'Akuntansi',
  ];
  static const daftarSebagai = 'Daftar sebagai';
  static const peserta = 'Peserta';
  static const mentor = 'Mentor';
  static const setuju = 'Saya setuju dengan ketentuan penggunaan';
  static const buatAkun = 'Buat akun';
  static const akunDibuat = 'Akun berhasil dibuat';

  // Pesan validasi
  static const emailWajib = 'Email kampus wajib diisi';
  static const emailTidakValid =
      'Masukkan email kampus yang valid (berakhiran .ac.id)';
  static const sandiWajib = 'Kata sandi wajib diisi';
  static const sandiMinimal = 'Kata sandi minimal 6 karakter';
  static const namaWajib = 'Nama lengkap wajib diisi';
  static const prodiWajib = 'Pilih program studi';
}
