import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @welcomeTagline.
  ///
  /// In id, this message translates to:
  /// **'Terima pembayaran. Pantau hari ini. Tetap sederhana.'**
  String get welcomeTagline;

  /// No description provided for @welcomeScan.
  ///
  /// In id, this message translates to:
  /// **'Pindai QR perusahaan'**
  String get welcomeScan;

  /// No description provided for @welcomeCode.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode'**
  String get welcomeCode;

  /// No description provided for @welcomeHelp.
  ///
  /// In id, this message translates to:
  /// **'Belum punya kode?'**
  String get welcomeHelp;

  /// No description provided for @welcomeHelpCta.
  ///
  /// In id, this message translates to:
  /// **'Hubungi admin Anda'**
  String get welcomeHelpCta;

  /// No description provided for @scanCompanyTitle.
  ///
  /// In id, this message translates to:
  /// **'Pindai QR perusahaan'**
  String get scanCompanyTitle;

  /// No description provided for @scanCompanySub.
  ///
  /// In id, this message translates to:
  /// **'Arahkan kamera ke QR di lembar onboarding.'**
  String get scanCompanySub;

  /// No description provided for @scanMerchantTitle.
  ///
  /// In id, this message translates to:
  /// **'Pindai QR merchant'**
  String get scanMerchantTitle;

  /// No description provided for @scanMerchantSub.
  ///
  /// In id, this message translates to:
  /// **'Setiap toko punya QR sendiri. Pindai untuk menambahkan.'**
  String get scanMerchantSub;

  /// No description provided for @scanSimulate.
  ///
  /// In id, this message translates to:
  /// **'Simulasikan deteksi'**
  String get scanSimulate;

  /// No description provided for @scanTorch.
  ///
  /// In id, this message translates to:
  /// **'Senter'**
  String get scanTorch;

  /// No description provided for @scanGallery.
  ///
  /// In id, this message translates to:
  /// **'Galeri'**
  String get scanGallery;

  /// No description provided for @scanCodeFallback.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode saja'**
  String get scanCodeFallback;

  /// No description provided for @scanPermissionCta.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan kamera di Pengaturan'**
  String get scanPermissionCta;

  /// No description provided for @scanOpenSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka Pengaturan'**
  String get scanOpenSettings;

  /// No description provided for @codeStep.
  ///
  /// In id, this message translates to:
  /// **'Langkah {n} dari 2'**
  String codeStep(int n);

  /// No description provided for @codeAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah merchant'**
  String get codeAdd;

  /// No description provided for @codeTitleCompany.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode perusahaan'**
  String get codeTitleCompany;

  /// No description provided for @codeTitleMerchant.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode merchant'**
  String get codeTitleMerchant;

  /// No description provided for @codeSubCompany.
  ///
  /// In id, this message translates to:
  /// **'Cari kode 20 karakter di bawah QR pada lembar onboarding Anda.'**
  String get codeSubCompany;

  /// No description provided for @codeSubMerchant.
  ///
  /// In id, this message translates to:
  /// **'Setiap merchant punya kode unik. Masukkan kode untuk toko ini.'**
  String get codeSubMerchant;

  /// No description provided for @codeCounter.
  ///
  /// In id, this message translates to:
  /// **'{n} / 20'**
  String codeCounter(int n);

  /// No description provided for @codeCamera.
  ///
  /// In id, this message translates to:
  /// **'Pakai kamera saja'**
  String get codeCamera;

  /// No description provided for @codeContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get codeContinue;

  /// No description provided for @codeCompanyLabel.
  ///
  /// In id, this message translates to:
  /// **'Perusahaan'**
  String get codeCompanyLabel;

  /// No description provided for @dashCompanyToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini di seluruh perusahaan'**
  String get dashCompanyToday;

  /// No description provided for @dashCompanyMerchants.
  ///
  /// In id, this message translates to:
  /// **'{n} merchant'**
  String dashCompanyMerchants(int n);

  /// No description provided for @dashCompanyTxns.
  ///
  /// In id, this message translates to:
  /// **'{n} transaksi'**
  String dashCompanyTxns(int n);

  /// No description provided for @dashCompanyUnread.
  ///
  /// In id, this message translates to:
  /// **'{n} baru'**
  String dashCompanyUnread(int n);

  /// No description provided for @dashCompanyList.
  ///
  /// In id, this message translates to:
  /// **'Merchant'**
  String get dashCompanyList;

  /// No description provided for @dashCompanyStatMerchants.
  ///
  /// In id, this message translates to:
  /// **'Merchant'**
  String get dashCompanyStatMerchants;

  /// No description provided for @dashCompanyStatTxns.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get dashCompanyStatTxns;

  /// No description provided for @dashCompanyStatUnread.
  ///
  /// In id, this message translates to:
  /// **'Belum dibaca'**
  String get dashCompanyStatUnread;

  /// No description provided for @dashCompanyAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah merchant'**
  String get dashCompanyAdd;

  /// No description provided for @dashCompanyNotif.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan notifikasi untuk pembayaran instan'**
  String get dashCompanyNotif;

  /// No description provided for @dashCompanyNotifSub.
  ///
  /// In id, this message translates to:
  /// **'Ketuk merchant untuk melihat pembayaran live, membuat QR, atau mengirim tautan.'**
  String get dashCompanyNotifSub;

  /// No description provided for @dashMerchantToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get dashMerchantToday;

  /// No description provided for @dashMerchantReceived.
  ///
  /// In id, this message translates to:
  /// **'Diterima hari ini'**
  String get dashMerchantReceived;

  /// No description provided for @dashMerchantLive.
  ///
  /// In id, this message translates to:
  /// **'Live'**
  String get dashMerchantLive;

  /// No description provided for @dashMerchantAvg.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata'**
  String get dashMerchantAvg;

  /// No description provided for @dashMerchantMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan ini'**
  String get dashMerchantMonth;

  /// No description provided for @dashMerchantTxns.
  ///
  /// In id, this message translates to:
  /// **'{n} transaksi'**
  String dashMerchantTxns(int n);

  /// No description provided for @dashMerchantRecent.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas terbaru'**
  String get dashMerchantRecent;

  /// No description provided for @dashMerchantEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi hari ini.'**
  String get dashMerchantEmpty;

  /// No description provided for @dashMerchantViewall.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get dashMerchantViewall;

  /// No description provided for @actionQris.
  ///
  /// In id, this message translates to:
  /// **'QRIS Dinamis'**
  String get actionQris;

  /// No description provided for @actionQrisSub.
  ///
  /// In id, this message translates to:
  /// **'QR sekali pakai'**
  String get actionQrisSub;

  /// No description provided for @actionLink.
  ///
  /// In id, this message translates to:
  /// **'Tautan bayar'**
  String get actionLink;

  /// No description provided for @actionLinkSub.
  ///
  /// In id, this message translates to:
  /// **'Kirim via chat'**
  String get actionLinkSub;

  /// No description provided for @actionScan.
  ///
  /// In id, this message translates to:
  /// **'Pindai QRIS'**
  String get actionScan;

  /// No description provided for @actionScanSub.
  ///
  /// In id, this message translates to:
  /// **'QR pelanggan'**
  String get actionScanSub;

  /// No description provided for @actionScanDisabled.
  ///
  /// In id, this message translates to:
  /// **'Belum aktif'**
  String get actionScanDisabled;

  /// No description provided for @txQris.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran QRIS'**
  String get txQris;

  /// No description provided for @txLink.
  ///
  /// In id, this message translates to:
  /// **'Tautan bayar'**
  String get txLink;

  /// No description provided for @txCpm.
  ///
  /// In id, this message translates to:
  /// **'QRIS pelanggan'**
  String get txCpm;

  /// No description provided for @txLast.
  ///
  /// In id, this message translates to:
  /// **'Terakhir'**
  String get txLast;

  /// No description provided for @txNone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada aktivitas'**
  String get txNone;

  /// No description provided for @txNew.
  ///
  /// In id, this message translates to:
  /// **'{n} baru'**
  String txNew(int n);

  /// No description provided for @txStatusPaid.
  ///
  /// In id, this message translates to:
  /// **'Dibayar'**
  String get txStatusPaid;

  /// No description provided for @txStatusPending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get txStatusPending;

  /// No description provided for @txStatusFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal'**
  String get txStatusFailed;

  /// No description provided for @txStatusExpired.
  ///
  /// In id, this message translates to:
  /// **'Kedaluwarsa'**
  String get txStatusExpired;

  /// No description provided for @txStatusCancelled.
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan'**
  String get txStatusCancelled;

  /// No description provided for @txStatusRefunded.
  ///
  /// In id, this message translates to:
  /// **'Dikembalikan'**
  String get txStatusRefunded;

  /// No description provided for @addmerchantHeader.
  ///
  /// In id, this message translates to:
  /// **'Tambah merchant lain'**
  String get addmerchantHeader;

  /// No description provided for @addmerchantTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftarkan merchant baru di bawah {company}'**
  String addmerchantTitle(String company);

  /// No description provided for @addmerchantBody.
  ///
  /// In id, this message translates to:
  /// **'Satu perusahaan bisa punya banyak merchant — setiap kios, outlet, atau cabang punya QR dan notifikasi sendiri.'**
  String get addmerchantBody;

  /// No description provided for @addmerchantMethodScan.
  ///
  /// In id, this message translates to:
  /// **'Pindai QR merchant'**
  String get addmerchantMethodScan;

  /// No description provided for @addmerchantMethodScanSub.
  ///
  /// In id, this message translates to:
  /// **'Tercepat jika lembar onboarding ada di dekat Anda.'**
  String get addmerchantMethodScanSub;

  /// No description provided for @addmerchantMethodCode.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode merchant'**
  String get addmerchantMethodCode;

  /// No description provided for @addmerchantMethodCodeSub.
  ///
  /// In id, this message translates to:
  /// **'Kode 20 karakter di bawah QR.'**
  String get addmerchantMethodCodeSub;

  /// No description provided for @addmerchantTipLabel.
  ///
  /// In id, this message translates to:
  /// **'Tips.'**
  String get addmerchantTipLabel;

  /// No description provided for @addmerchantTipBody.
  ///
  /// In id, this message translates to:
  /// **'Sebagian besar perusahaan menjalankan satu merchant. Beberapa merchant cocok untuk franchise, food court, atau kios di bawah satu pemilik.'**
  String get addmerchantTipBody;

  /// No description provided for @qrisTitle.
  ///
  /// In id, this message translates to:
  /// **'QRIS Dinamis'**
  String get qrisTitle;

  /// No description provided for @qrisAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get qrisAmount;

  /// No description provided for @qrisAmountClear.
  ///
  /// In id, this message translates to:
  /// **'Bersihkan'**
  String get qrisAmountClear;

  /// No description provided for @qrisAmountAria.
  ///
  /// In id, this message translates to:
  /// **'Bersihkan jumlah'**
  String get qrisAmountAria;

  /// No description provided for @qrisHeaderAmount.
  ///
  /// In id, this message translates to:
  /// **'Masukkan jumlah'**
  String get qrisHeaderAmount;

  /// No description provided for @qrisHeaderWaiting.
  ///
  /// In id, this message translates to:
  /// **'Menunggu pembayaran'**
  String get qrisHeaderWaiting;

  /// No description provided for @qrisHeaderPaid.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran diterima'**
  String get qrisHeaderPaid;

  /// No description provided for @qrisNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get qrisNote;

  /// No description provided for @qrisNotePh.
  ///
  /// In id, this message translates to:
  /// **'mis. Kamar 3 · Sewa Mei'**
  String get qrisNotePh;

  /// No description provided for @qrisGenerate.
  ///
  /// In id, this message translates to:
  /// **'Buat QR'**
  String get qrisGenerate;

  /// No description provided for @qrisShow.
  ///
  /// In id, this message translates to:
  /// **'Tunjukkan ke pelanggan'**
  String get qrisShow;

  /// No description provided for @qrisExpires.
  ///
  /// In id, this message translates to:
  /// **'Kedaluwarsa dalam {n} dtk'**
  String qrisExpires(int n);

  /// No description provided for @qrisExpiresLive.
  ///
  /// In id, this message translates to:
  /// **'Menunggu pembayaran · kedaluwarsa {time}'**
  String qrisExpiresLive(String time);

  /// No description provided for @qrisShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get qrisShare;

  /// No description provided for @qrisPrint.
  ///
  /// In id, this message translates to:
  /// **'Cetak'**
  String get qrisPrint;

  /// No description provided for @qrisCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin'**
  String get qrisCopy;

  /// No description provided for @qrisCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get qrisCancel;

  /// No description provided for @qrisLive.
  ///
  /// In id, this message translates to:
  /// **'Live'**
  String get qrisLive;

  /// No description provided for @qrisPaid.
  ///
  /// In id, this message translates to:
  /// **'Dibayar'**
  String get qrisPaid;

  /// No description provided for @qrisPaidTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran diterima'**
  String get qrisPaidTitle;

  /// No description provided for @qrisPaidDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get qrisPaidDone;

  /// No description provided for @qrisPaidAnother.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran baru'**
  String get qrisPaidAnother;

  /// No description provided for @qrisRowFrom.
  ///
  /// In id, this message translates to:
  /// **'Dari'**
  String get qrisRowFrom;

  /// No description provided for @qrisRowMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode'**
  String get qrisRowMethod;

  /// No description provided for @qrisRowRef.
  ///
  /// In id, this message translates to:
  /// **'Referensi'**
  String get qrisRowRef;

  /// No description provided for @qrisRowAt.
  ///
  /// In id, this message translates to:
  /// **'Pada'**
  String get qrisRowAt;

  /// No description provided for @qrisRowAtValue.
  ///
  /// In id, this message translates to:
  /// **'Hari ini, {time}'**
  String qrisRowAtValue(String time);

  /// No description provided for @linkTitle.
  ///
  /// In id, this message translates to:
  /// **'Tautan bayar'**
  String get linkTitle;

  /// No description provided for @linkAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get linkAmount;

  /// No description provided for @linkNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get linkNote;

  /// No description provided for @linkNotePh.
  ///
  /// In id, this message translates to:
  /// **'mis. Sewa Mei · Kamar 3'**
  String get linkNotePh;

  /// No description provided for @linkCreate.
  ///
  /// In id, this message translates to:
  /// **'Buat tautan'**
  String get linkCreate;

  /// No description provided for @linkShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get linkShare;

  /// No description provided for @linkCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin'**
  String get linkCopy;

  /// No description provided for @linkCopied.
  ///
  /// In id, this message translates to:
  /// **'Disalin'**
  String get linkCopied;

  /// No description provided for @linkExpires.
  ///
  /// In id, this message translates to:
  /// **'Tautan berlaku 24 jam'**
  String get linkExpires;

  /// No description provided for @linkExpiresIn24h.
  ///
  /// In id, this message translates to:
  /// **'Kedaluwarsa dalam 24 jam'**
  String get linkExpiresIn24h;

  /// No description provided for @linkPrint.
  ///
  /// In id, this message translates to:
  /// **'Cetak QR'**
  String get linkPrint;

  /// No description provided for @linkHeaderCreate.
  ///
  /// In id, this message translates to:
  /// **'Buat tautan'**
  String get linkHeaderCreate;

  /// No description provided for @linkHeaderShare.
  ///
  /// In id, this message translates to:
  /// **'Siap dibagikan'**
  String get linkHeaderShare;

  /// No description provided for @linkFieldTitle.
  ///
  /// In id, this message translates to:
  /// **'Judul'**
  String get linkFieldTitle;

  /// No description provided for @linkFieldTitlePh.
  ///
  /// In id, this message translates to:
  /// **'Sewa Mei · Kamar 3'**
  String get linkFieldTitlePh;

  /// No description provided for @linkFieldCustomer.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan (opsional)'**
  String get linkFieldCustomer;

  /// No description provided for @linkFieldCustomerPh.
  ///
  /// In id, this message translates to:
  /// **'Nama atau nomor HP'**
  String get linkFieldCustomerPh;

  /// No description provided for @linkFieldInvoice.
  ///
  /// In id, this message translates to:
  /// **'Nomor invoice'**
  String get linkFieldInvoice;

  /// No description provided for @linkFieldInvoiceAuto.
  ///
  /// In id, this message translates to:
  /// **'OTOMATIS'**
  String get linkFieldInvoiceAuto;

  /// No description provided for @linkFieldInvoiceClear.
  ///
  /// In id, this message translates to:
  /// **'Bersihkan & isi sendiri'**
  String get linkFieldInvoiceClear;

  /// No description provided for @linkFieldInvoiceRegen.
  ///
  /// In id, this message translates to:
  /// **'Buat ulang'**
  String get linkFieldInvoiceRegen;

  /// No description provided for @linkFieldInvoicePh.
  ///
  /// In id, this message translates to:
  /// **'Ketik nomor invoice Anda'**
  String get linkFieldInvoicePh;

  /// No description provided for @linkFieldInvoiceHelp.
  ///
  /// In id, this message translates to:
  /// **'Dibuat otomatis. Ketuk \"Bersihkan\" untuk pakai nomor invoice Anda sendiri.'**
  String get linkFieldInvoiceHelp;

  /// No description provided for @linkNoCustomer.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pelanggan'**
  String get linkNoCustomer;

  /// No description provided for @linkShowQr.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan QR'**
  String get linkShowQr;

  /// No description provided for @linkShareVia.
  ///
  /// In id, this message translates to:
  /// **'Bagikan via…'**
  String get linkShareVia;

  /// No description provided for @linkMessage.
  ///
  /// In id, this message translates to:
  /// **'Pesan untuk dibagikan'**
  String get linkMessage;

  /// No description provided for @linkMessageCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin pesan'**
  String get linkMessageCopy;

  /// No description provided for @linkMessageReset.
  ///
  /// In id, this message translates to:
  /// **'Reset'**
  String get linkMessageReset;

  /// No description provided for @linkMessageHelp.
  ///
  /// In id, this message translates to:
  /// **'Dikirim sebagai teks biasa — cocok untuk WhatsApp, SMS, email.'**
  String get linkMessageHelp;

  /// No description provided for @linkMessageGreeting.
  ///
  /// In id, this message translates to:
  /// **'Halo {name},'**
  String linkMessageGreeting(String name);

  /// No description provided for @linkMessageGreetingFallback.
  ///
  /// In id, this message translates to:
  /// **'Halo,'**
  String get linkMessageGreetingFallback;

  /// No description provided for @linkMessageBodyWithTitle.
  ///
  /// In id, this message translates to:
  /// **'pembayaran Anda untuk {title}'**
  String linkMessageBodyWithTitle(String title);

  /// No description provided for @linkMessageBodyNoTitle.
  ///
  /// In id, this message translates to:
  /// **'pembayaran Anda'**
  String get linkMessageBodyNoTitle;

  /// No description provided for @linkMessageBody.
  ///
  /// In id, this message translates to:
  /// **'Untuk menyelesaikan {what}{amt}, silakan buka tautan ini:\nhttps://{link}\n\nTerima kasih — {merchant}'**
  String linkMessageBody(String what, String amt, String link, String merchant);

  /// No description provided for @linkMessageAmountSuffix.
  ///
  /// In id, this message translates to:
  /// **' (IDR {amount})'**
  String linkMessageAmountSuffix(String amount);

  /// No description provided for @linkQrScan.
  ///
  /// In id, this message translates to:
  /// **'Pindai untuk membayar'**
  String get linkQrScan;

  /// No description provided for @linkQrTapClose.
  ///
  /// In id, this message translates to:
  /// **'Ketuk di mana saja untuk menutup'**
  String get linkQrTapClose;

  /// No description provided for @linkQrPaymentPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran'**
  String get linkQrPaymentPlaceholder;

  /// No description provided for @linkLive.
  ///
  /// In id, this message translates to:
  /// **'Live'**
  String get linkLive;

  /// No description provided for @cpmTitle.
  ///
  /// In id, this message translates to:
  /// **'Pindai QRIS pelanggan'**
  String get cpmTitle;

  /// No description provided for @cpmAim.
  ///
  /// In id, this message translates to:
  /// **'Arahkan ke QRIS pelanggan'**
  String get cpmAim;

  /// No description provided for @cpmValid.
  ///
  /// In id, this message translates to:
  /// **'QRIS valid'**
  String get cpmValid;

  /// No description provided for @cpmAmountTitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan jumlah'**
  String get cpmAmountTitle;

  /// No description provided for @cpmAmountChargeTitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan jumlah tagihan'**
  String get cpmAmountChargeTitle;

  /// No description provided for @cpmCharge.
  ///
  /// In id, this message translates to:
  /// **'Tagih'**
  String get cpmCharge;

  /// No description provided for @cpmChargeWithAmount.
  ///
  /// In id, this message translates to:
  /// **'Tagih IDR {amount}'**
  String cpmChargeWithAmount(String amount);

  /// No description provided for @cpmSuccess.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran berhasil'**
  String get cpmSuccess;

  /// No description provided for @cpmSuccessReceived.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran diterima'**
  String get cpmSuccessReceived;

  /// No description provided for @cpmSuccessMethod.
  ///
  /// In id, this message translates to:
  /// **'QRIS · CPM'**
  String get cpmSuccessMethod;

  /// No description provided for @cpmFailed.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran gagal'**
  String get cpmFailed;

  /// No description provided for @cpmFailedSub.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi atau gunakan metode lain.'**
  String get cpmFailedSub;

  /// No description provided for @cpmRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get cpmRetry;

  /// No description provided for @cpmHeader.
  ///
  /// In id, this message translates to:
  /// **'QRIS · CPM'**
  String get cpmHeader;

  /// No description provided for @cpmPointAt.
  ///
  /// In id, this message translates to:
  /// **'Arahkan ke QR pelanggan'**
  String get cpmPointAt;

  /// No description provided for @cpmPointAtSub.
  ///
  /// In id, this message translates to:
  /// **'Minta pelanggan membuka QRIS di e-wallet atau aplikasi banking mereka.'**
  String get cpmPointAtSub;

  /// No description provided for @cpmSimulate.
  ///
  /// In id, this message translates to:
  /// **'Simulasikan QR terdeteksi'**
  String get cpmSimulate;

  /// No description provided for @cpmScanLabel.
  ///
  /// In id, this message translates to:
  /// **'Pindai QRIS · {merchant}'**
  String cpmScanLabel(String merchant);

  /// No description provided for @cpmRowMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode'**
  String get cpmRowMethod;

  /// No description provided for @cpmRowMerchant.
  ///
  /// In id, this message translates to:
  /// **'Merchant'**
  String get cpmRowMerchant;

  /// No description provided for @cpmRowRef.
  ///
  /// In id, this message translates to:
  /// **'Referensi'**
  String get cpmRowRef;

  /// No description provided for @cpmDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get cpmDone;

  /// No description provided for @cpmScanAnother.
  ///
  /// In id, this message translates to:
  /// **'Pindai lagi'**
  String get cpmScanAnother;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingsLanguage;

  /// No description provided for @settingsAccount.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get settingsAccount;

  /// No description provided for @settingsLangId.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get settingsLangId;

  /// No description provided for @settingsLangEn.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get settingsLangEn;

  /// No description provided for @settingsLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari {name}?'**
  String settingsLogoutConfirm(String name);

  /// No description provided for @settingsLogoutSub.
  ///
  /// In id, this message translates to:
  /// **'Anda akan kembali ke layar awal. Saldo dan transaksi tetap aman di server.'**
  String get settingsLogoutSub;

  /// No description provided for @settingsLogoutStay.
  ///
  /// In id, this message translates to:
  /// **'Tetap masuk'**
  String get settingsLogoutStay;

  /// No description provided for @settingsLogoutGo.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get settingsLogoutGo;

  /// No description provided for @merchantSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan merchant'**
  String get merchantSettings;

  /// No description provided for @merchantShareQr.
  ///
  /// In id, this message translates to:
  /// **'Bagikan QR merchant'**
  String get merchantShareQr;

  /// No description provided for @merchantShareQrSub.
  ///
  /// In id, this message translates to:
  /// **'Biar staf bisa menambahkan merchant ini ke ponsel mereka'**
  String get merchantShareQrSub;

  /// No description provided for @merchantDanger.
  ///
  /// In id, this message translates to:
  /// **'Zona berbahaya'**
  String get merchantDanger;

  /// No description provided for @merchantRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus dari perusahaan'**
  String get merchantRemove;

  /// No description provided for @merchantRemoveSub.
  ///
  /// In id, this message translates to:
  /// **'Putuskan merchant ini dari {name}. Riwayat transaksi tetap tersimpan di arsip perusahaan.'**
  String merchantRemoveSub(String name);

  /// No description provided for @merchantRemoveTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus \"{name}\"?'**
  String merchantRemoveTitle(String name);

  /// No description provided for @merchantRemoveBody.
  ///
  /// In id, this message translates to:
  /// **'Merchant ini akan berhenti menerima pembayaran di perangkat ini. Transaksi sebelumnya tetap ada di arsip perusahaan dan bisa diekspor nanti.'**
  String get merchantRemoveBody;

  /// No description provided for @merchantRemoveNote.
  ///
  /// In id, this message translates to:
  /// **'Anda bisa menghubungkan kembali merchant ini dengan memindai ulang QR-nya.'**
  String get merchantRemoveNote;

  /// No description provided for @merchantRemoveTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'Ketik'**
  String get merchantRemoveTypeLabel;

  /// No description provided for @merchantRemoveConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ketik {name} untuk konfirmasi'**
  String merchantRemoveConfirm(String name);

  /// No description provided for @merchantRemoved.
  ///
  /// In id, this message translates to:
  /// **'Merchant dihapus'**
  String get merchantRemoved;

  /// No description provided for @merchantRemovedSub.
  ///
  /// In id, this message translates to:
  /// **'\"{name}\" tidak lagi terhubung dengan perangkat ini.'**
  String merchantRemovedSub(String name);

  /// No description provided for @merchantRemovedSwitch.
  ///
  /// In id, this message translates to:
  /// **'Ganti ke'**
  String get merchantRemovedSwitch;

  /// No description provided for @merchantRemovedBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke dashboard perusahaan'**
  String get merchantRemovedBack;

  /// No description provided for @commonCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get commonCancel;

  /// No description provided for @commonBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get commonBack;

  /// No description provided for @commonContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get commonContinue;

  /// No description provided for @commonDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get commonDone;

  /// No description provided for @commonClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get commonClose;

  /// No description provided for @commonCurrency.
  ///
  /// In id, this message translates to:
  /// **'IDR'**
  String get commonCurrency;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'id':
      return AppL10nId();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
