// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppL10nId extends AppL10n {
  AppL10nId([String locale = 'id']) : super(locale);

  @override
  String get welcomeTagline =>
      'Terima pembayaran. Pantau hari ini. Tetap sederhana.';

  @override
  String get welcomeScan => 'Pindai QR perusahaan';

  @override
  String get welcomeCode => 'Masukkan kode';

  @override
  String get welcomeHelp => 'Belum punya kode?';

  @override
  String get welcomeHelpCta => 'Hubungi admin Anda';

  @override
  String get scanCompanyTitle => 'Pindai QR perusahaan';

  @override
  String get scanCompanySub => 'Arahkan kamera ke QR di lembar onboarding.';

  @override
  String get scanMerchantTitle => 'Pindai QR merchant';

  @override
  String get scanMerchantSub =>
      'Setiap toko punya QR sendiri. Pindai untuk menambahkan.';

  @override
  String get scanSimulate => 'Simulasikan deteksi';

  @override
  String get scanTorch => 'Senter';

  @override
  String get scanGallery => 'Galeri';

  @override
  String get scanCodeFallback => 'Masukkan kode saja';

  @override
  String get scanSelectImage => 'Pilih gambar';

  @override
  String get scanImageNoQr => 'Tidak ada QR pada gambar';

  @override
  String get scanPermissionCta => 'Aktifkan kamera di Pengaturan';

  @override
  String get scanOpenSettings => 'Buka Pengaturan';

  @override
  String codeStep(int n) {
    return 'Langkah $n dari 2';
  }

  @override
  String get codeAdd => 'Tambah merchant';

  @override
  String get codeTitleCompany => 'Masukkan kode perusahaan';

  @override
  String get codeTitleMerchant => 'Masukkan kode merchant';

  @override
  String get codeSubCompany =>
      'Cari kode 20 karakter di bawah QR pada lembar onboarding Anda.';

  @override
  String get codeSubMerchant =>
      'Setiap merchant punya kode unik. Masukkan kode untuk toko ini.';

  @override
  String codeCounter(int n) {
    return '$n / 20';
  }

  @override
  String get codeCamera => 'Pakai kamera saja';

  @override
  String get codeContinue => 'Lanjut';

  @override
  String get codeCompanyLabel => 'Perusahaan';

  @override
  String get dashCompanyToday => 'Hari ini di seluruh perusahaan';

  @override
  String dashCompanyMerchants(int n) {
    return '$n merchant';
  }

  @override
  String dashCompanyTxns(int n) {
    return '$n transaksi';
  }

  @override
  String dashCompanyUnread(int n) {
    return '$n baru';
  }

  @override
  String get dashCompanyList => 'Merchant';

  @override
  String get dashCompanyStatMerchants => 'Merchant';

  @override
  String get dashCompanyStatTxns => 'Transaksi';

  @override
  String get dashCompanyStatUnread => 'Belum dibaca';

  @override
  String get dashCompanyAdd => 'Tambah merchant';

  @override
  String get dashCompanyNotif => 'Aktifkan notifikasi untuk pembayaran instan';

  @override
  String get dashCompanyNotifSub =>
      'Ketuk merchant untuk melihat pembayaran live, membuat QR, atau mengirim tautan.';

  @override
  String get dashMerchantToday => 'Hari ini';

  @override
  String get dashMerchantReceived => 'Diterima hari ini';

  @override
  String get dashMerchantLive => 'Live';

  @override
  String get dashMerchantAvg => 'Rata-rata';

  @override
  String get dashMerchantMonth => 'Bulan ini';

  @override
  String dashMerchantTxns(int n) {
    return '$n transaksi';
  }

  @override
  String get dashMerchantRecent => 'Aktivitas terbaru';

  @override
  String get dashMerchantEmpty => 'Belum ada transaksi hari ini.';

  @override
  String get dashMerchantViewall => 'Lihat semua';

  @override
  String get actionQris => 'QRIS Dinamis';

  @override
  String get actionQrisSub => 'QR sekali pakai';

  @override
  String get actionLink => 'Tautan bayar';

  @override
  String get actionLinkSub => 'Kirim via chat';

  @override
  String get actionScan => 'Pindai QRIS';

  @override
  String get actionScanSub => 'QR pelanggan';

  @override
  String get actionScanDisabled => 'Belum aktif';

  @override
  String get txQris => 'Pembayaran QRIS';

  @override
  String get txLink => 'Tautan bayar';

  @override
  String get txCpm => 'QRIS pelanggan';

  @override
  String get txLast => 'Terakhir';

  @override
  String get txNone => 'Belum ada aktivitas';

  @override
  String txNew(int n) {
    return '$n baru';
  }

  @override
  String get txStatusPaid => 'Dibayar';

  @override
  String get txStatusPending => 'Menunggu';

  @override
  String get txStatusFailed => 'Gagal';

  @override
  String get txStatusExpired => 'Kedaluwarsa';

  @override
  String get txStatusCancelled => 'Dibatalkan';

  @override
  String get txStatusRefunded => 'Dikembalikan';

  @override
  String get addmerchantHeader => 'Tambah merchant lain';

  @override
  String addmerchantTitle(String company) {
    return 'Daftarkan merchant baru di bawah $company';
  }

  @override
  String get addmerchantBody =>
      'Satu perusahaan bisa punya banyak merchant — setiap kios, outlet, atau cabang punya QR dan notifikasi sendiri.';

  @override
  String get addmerchantMethodScan => 'Pindai QR merchant';

  @override
  String get addmerchantMethodScanSub =>
      'Tercepat jika lembar onboarding ada di dekat Anda.';

  @override
  String get addmerchantMethodCode => 'Masukkan kode merchant';

  @override
  String get addmerchantMethodCodeSub => 'Kode 20 karakter di bawah QR.';

  @override
  String get addmerchantTipLabel => 'Tips.';

  @override
  String get addmerchantTipBody =>
      'Sebagian besar perusahaan menjalankan satu merchant. Beberapa merchant cocok untuk franchise, food court, atau kios di bawah satu pemilik.';

  @override
  String get qrisTitle => 'QRIS Dinamis';

  @override
  String get qrisAmount => 'Jumlah';

  @override
  String get qrisAmountClear => 'Bersihkan';

  @override
  String get qrisAmountAria => 'Bersihkan jumlah';

  @override
  String get qrisHeaderAmount => 'Masukkan jumlah';

  @override
  String get qrisHeaderWaiting => 'Menunggu pembayaran';

  @override
  String get qrisHeaderPaid => 'Pembayaran diterima';

  @override
  String get qrisNote => 'Catatan (opsional)';

  @override
  String get qrisNotePh => 'mis. Kamar 3 · Sewa Mei';

  @override
  String get qrisGenerate => 'Buat QR';

  @override
  String get qrisShow => 'Tunjukkan ke pelanggan';

  @override
  String qrisExpires(int n) {
    return 'Kedaluwarsa dalam $n dtk';
  }

  @override
  String qrisExpiresLive(String time) {
    return 'Menunggu pembayaran · kedaluwarsa $time';
  }

  @override
  String get qrisShare => 'Bagikan';

  @override
  String get qrisPrint => 'Cetak';

  @override
  String get qrisCopy => 'Salin';

  @override
  String get qrisCancel => 'Batal';

  @override
  String get qrisLive => 'Live';

  @override
  String get qrisPaid => 'Dibayar';

  @override
  String get qrisPaidTitle => 'Pembayaran diterima';

  @override
  String get qrisPaidDone => 'Selesai';

  @override
  String get qrisPaidAnother => 'Pembayaran baru';

  @override
  String get qrisRowFrom => 'Dari';

  @override
  String get qrisRowMethod => 'Metode';

  @override
  String get qrisRowRef => 'Referensi';

  @override
  String get qrisRowAt => 'Pada';

  @override
  String qrisRowAtValue(String time) {
    return 'Hari ini, $time';
  }

  @override
  String get linkTitle => 'Tautan bayar';

  @override
  String get linkAmount => 'Jumlah';

  @override
  String get linkNote => 'Catatan (opsional)';

  @override
  String get linkNotePh => 'mis. Sewa Mei · Kamar 3';

  @override
  String get linkCreate => 'Buat tautan';

  @override
  String get linkShare => 'Bagikan';

  @override
  String get linkCopy => 'Salin';

  @override
  String get linkCopied => 'Disalin';

  @override
  String get linkExpires => 'Tautan berlaku 24 jam';

  @override
  String get linkExpiresIn24h => 'Kedaluwarsa dalam 24 jam';

  @override
  String get linkPrint => 'Cetak QR';

  @override
  String get linkHeaderCreate => 'Buat tautan';

  @override
  String get linkHeaderShare => 'Siap dibagikan';

  @override
  String get linkFieldTitle => 'Judul';

  @override
  String get linkFieldTitlePh => 'Sewa Mei · Kamar 3';

  @override
  String get linkFieldCustomer => 'Pelanggan (opsional)';

  @override
  String get linkFieldCustomerPh => 'Nama atau nomor HP';

  @override
  String get linkFieldInvoice => 'Nomor invoice';

  @override
  String get linkFieldInvoiceAuto => 'OTOMATIS';

  @override
  String get linkFieldInvoiceClear => 'Bersihkan & isi sendiri';

  @override
  String get linkFieldInvoiceRegen => 'Buat ulang';

  @override
  String get linkFieldInvoicePh => 'Ketik nomor invoice Anda';

  @override
  String get linkFieldInvoiceHelp =>
      'Dibuat otomatis. Ketuk \"Bersihkan\" untuk pakai nomor invoice Anda sendiri.';

  @override
  String get linkNoCustomer => 'Belum ada pelanggan';

  @override
  String get linkShowQr => 'Tampilkan QR';

  @override
  String get linkShareVia => 'Bagikan via…';

  @override
  String get linkMessage => 'Pesan untuk dibagikan';

  @override
  String get linkMessageCopy => 'Salin pesan';

  @override
  String get linkMessageReset => 'Reset';

  @override
  String get linkMessageHelp =>
      'Dikirim sebagai teks biasa — cocok untuk WhatsApp, SMS, email.';

  @override
  String linkMessageGreeting(String name) {
    return 'Halo $name,';
  }

  @override
  String get linkMessageGreetingFallback => 'Halo,';

  @override
  String linkMessageBodyWithTitle(String title) {
    return 'pembayaran Anda untuk $title';
  }

  @override
  String get linkMessageBodyNoTitle => 'pembayaran Anda';

  @override
  String linkMessageBody(
    String what,
    String amt,
    String link,
    String merchant,
  ) {
    return 'Untuk menyelesaikan $what$amt, silakan buka tautan ini:\nhttps://$link\n\nTerima kasih — $merchant';
  }

  @override
  String linkMessageAmountSuffix(String amount) {
    return ' (IDR $amount)';
  }

  @override
  String get linkQrScan => 'Pindai untuk membayar';

  @override
  String get linkQrTapClose => 'Ketuk di mana saja untuk menutup';

  @override
  String get linkQrPaymentPlaceholder => 'Pembayaran';

  @override
  String get linkLive => 'Live';

  @override
  String get cpmTitle => 'Pindai QRIS pelanggan';

  @override
  String get cpmAim => 'Arahkan ke QRIS pelanggan';

  @override
  String get cpmValid => 'QRIS valid';

  @override
  String get cpmAmountTitle => 'Masukkan jumlah';

  @override
  String get cpmAmountChargeTitle => 'Masukkan jumlah tagihan';

  @override
  String get cpmCharge => 'Tagih';

  @override
  String cpmChargeWithAmount(String amount) {
    return 'Tagih IDR $amount';
  }

  @override
  String get cpmSuccess => 'Pembayaran berhasil';

  @override
  String get cpmSuccessReceived => 'Pembayaran diterima';

  @override
  String get cpmSuccessMethod => 'QRIS · CPM';

  @override
  String get cpmFailed => 'Pembayaran gagal';

  @override
  String get cpmFailedSub => 'Coba lagi atau gunakan metode lain.';

  @override
  String get cpmRetry => 'Coba lagi';

  @override
  String get cpmHeader => 'QRIS · CPM';

  @override
  String get cpmPointAt => 'Arahkan ke QR pelanggan';

  @override
  String get cpmPointAtSub =>
      'Minta pelanggan membuka QRIS di e-wallet atau aplikasi banking mereka.';

  @override
  String get cpmSimulate => 'Simulasikan QR terdeteksi';

  @override
  String cpmScanLabel(String merchant) {
    return 'Pindai QRIS · $merchant';
  }

  @override
  String get cpmRowMethod => 'Metode';

  @override
  String get cpmRowMerchant => 'Merchant';

  @override
  String get cpmRowRef => 'Referensi';

  @override
  String get cpmDone => 'Selesai';

  @override
  String get cpmScanAnother => 'Pindai lagi';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsAccount => 'Akun';

  @override
  String get settingsLangId => 'Bahasa Indonesia';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLogout => 'Keluar';

  @override
  String settingsLogoutConfirm(String name) {
    return 'Keluar dari $name?';
  }

  @override
  String get settingsLogoutSub =>
      'Anda akan kembali ke layar awal. Saldo dan transaksi tetap aman di server.';

  @override
  String get settingsLogoutStay => 'Tetap masuk';

  @override
  String get settingsLogoutGo => 'Keluar';

  @override
  String get merchantSettings => 'Pengaturan merchant';

  @override
  String get merchantShareQr => 'Bagikan QR merchant';

  @override
  String get merchantShareQrSub =>
      'Biar staf bisa menambahkan merchant ini ke ponsel mereka';

  @override
  String get merchantDanger => 'Zona berbahaya';

  @override
  String get merchantRemove => 'Hapus dari perusahaan';

  @override
  String merchantRemoveSub(String name) {
    return 'Putuskan merchant ini dari $name. Riwayat transaksi tetap tersimpan di arsip perusahaan.';
  }

  @override
  String merchantRemoveTitle(String name) {
    return 'Hapus \"$name\"?';
  }

  @override
  String get merchantRemoveBody =>
      'Merchant ini akan berhenti menerima pembayaran di perangkat ini. Transaksi sebelumnya tetap ada di arsip perusahaan dan bisa diekspor nanti.';

  @override
  String get merchantRemoveNote =>
      'Anda bisa menghubungkan kembali merchant ini dengan memindai ulang QR-nya.';

  @override
  String get merchantRemoveTypeLabel => 'Ketik';

  @override
  String merchantRemoveConfirm(String name) {
    return 'Ketik $name untuk konfirmasi';
  }

  @override
  String get merchantRemoved => 'Merchant dihapus';

  @override
  String merchantRemovedSub(String name) {
    return '\"$name\" tidak lagi terhubung dengan perangkat ini.';
  }

  @override
  String get merchantRemovedSwitch => 'Ganti ke';

  @override
  String get merchantRemovedBack => 'Kembali ke dashboard perusahaan';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonBack => 'Kembali';

  @override
  String get commonContinue => 'Lanjut';

  @override
  String get commonDone => 'Selesai';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonCurrency => 'IDR';
}
