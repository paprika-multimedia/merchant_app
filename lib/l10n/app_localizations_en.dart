// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTagline => 'Take payments. See today. Keep it simple.';

  @override
  String get welcomeScan => 'Scan company QR';

  @override
  String get welcomeCode => 'Enter code';

  @override
  String get welcomeHelp => 'Don\'t have a code?';

  @override
  String get welcomeHelpCta => 'Contact your admin';

  @override
  String get scanCompanyTitle => 'Scan company QR';

  @override
  String get scanCompanySub =>
      'Point the camera at the QR on your onboarding sheet.';

  @override
  String get scanMerchantTitle => 'Scan merchant QR';

  @override
  String get scanMerchantSub => 'Each store has its own QR. Scan it to add it.';

  @override
  String get scanSimulate => 'Simulate detection';

  @override
  String get scanTorch => 'Torch';

  @override
  String get scanGallery => 'Gallery';

  @override
  String get scanCodeFallback => 'Enter code instead';

  @override
  String get scanPermissionCta => 'Enable camera in Settings';

  @override
  String codeStep(int n) {
    return 'Step $n of 2';
  }

  @override
  String get codeAdd => 'Add merchant';

  @override
  String get codeTitleCompany => 'Enter company code';

  @override
  String get codeTitleMerchant => 'Enter merchant code';

  @override
  String get codeSubCompany =>
      'Find the 20-character code printed below the QR on your onboarding sheet.';

  @override
  String get codeSubMerchant =>
      'Each merchant has a unique code. Enter the one for this store.';

  @override
  String codeCounter(int n) {
    return '$n / 20';
  }

  @override
  String get codeCamera => 'Use camera instead';

  @override
  String get codeContinue => 'Continue';

  @override
  String get codeCompanyLabel => 'Company';

  @override
  String get dashCompanyToday => 'Today across company';

  @override
  String dashCompanyMerchants(int n) {
    return '$n merchants';
  }

  @override
  String dashCompanyTxns(int n) {
    return '$n transactions';
  }

  @override
  String dashCompanyUnread(int n) {
    return '$n unread';
  }

  @override
  String get dashCompanyList => 'Merchants';

  @override
  String get dashCompanyStatMerchants => 'Merchants';

  @override
  String get dashCompanyStatTxns => 'Transactions';

  @override
  String get dashCompanyStatUnread => 'Unread';

  @override
  String get dashCompanyAdd => 'Add merchant';

  @override
  String get dashCompanyNotif =>
      'Turn on notifications for instant payment alerts';

  @override
  String get dashCompanyNotifSub =>
      'Tap a merchant to view live payments, generate a QR, or send a link.';

  @override
  String get dashMerchantToday => 'Today';

  @override
  String get dashMerchantReceived => 'Received today';

  @override
  String get dashMerchantLive => 'Live';

  @override
  String get dashMerchantAvg => 'Avg. ticket';

  @override
  String get dashMerchantMonth => 'This month';

  @override
  String dashMerchantTxns(int n) {
    return '$n transactions';
  }

  @override
  String get dashMerchantRecent => 'Recent activity';

  @override
  String get dashMerchantEmpty => 'No transactions yet today.';

  @override
  String get dashMerchantViewall => 'View all';

  @override
  String get actionQris => 'Dynamic QRIS';

  @override
  String get actionQrisSub => 'One-time QR';

  @override
  String get actionLink => 'Payment link';

  @override
  String get actionLinkSub => 'Send via chat';

  @override
  String get actionScan => 'Scan QRIS';

  @override
  String get actionScanSub => 'Customer QR';

  @override
  String get actionScanDisabled => 'Not enabled';

  @override
  String get txQris => 'QRIS payment';

  @override
  String get txLink => 'Payment link';

  @override
  String get txCpm => 'Customer QRIS';

  @override
  String get txLast => 'Last';

  @override
  String get txNone => 'No activity';

  @override
  String txNew(int n) {
    return '$n new';
  }

  @override
  String get txStatusPaid => 'Paid';

  @override
  String get txStatusPending => 'Pending';

  @override
  String get txStatusFailed => 'Failed';

  @override
  String get txStatusExpired => 'Expired';

  @override
  String get txStatusCancelled => 'Cancelled';

  @override
  String get txStatusRefunded => 'Refunded';

  @override
  String get addmerchantHeader => 'Add another merchant';

  @override
  String addmerchantTitle(String company) {
    return 'Register a new merchant under $company';
  }

  @override
  String get addmerchantBody =>
      'A company can have many merchants — each stall, outlet or branch has its own QR and notifications.';

  @override
  String get addmerchantMethodScan => 'Scan merchant QR';

  @override
  String get addmerchantMethodScanSub =>
      'Fastest if the paper sheet is nearby.';

  @override
  String get addmerchantMethodCode => 'Enter merchant code';

  @override
  String get addmerchantMethodCodeSub => '20-character code below the QR.';

  @override
  String get addmerchantTipLabel => 'Tip.';

  @override
  String get addmerchantTipBody =>
      'Most companies run a single merchant. Multiple merchants suit franchises, food courts or stalls under one owner.';

  @override
  String get qrisTitle => 'Dynamic QRIS';

  @override
  String get qrisAmount => 'Amount';

  @override
  String get qrisAmountClear => 'Clear';

  @override
  String get qrisAmountAria => 'Clear amount';

  @override
  String get qrisHeaderAmount => 'Enter amount';

  @override
  String get qrisHeaderWaiting => 'Waiting for payment';

  @override
  String get qrisHeaderPaid => 'Payment received';

  @override
  String get qrisNote => 'Note (optional)';

  @override
  String get qrisNotePh => 'e.g. Room 3 · May rent';

  @override
  String get qrisGenerate => 'Generate QR';

  @override
  String get qrisShow => 'Show to customer';

  @override
  String qrisExpires(int n) {
    return 'Expires in ${n}s';
  }

  @override
  String qrisExpiresLive(String time) {
    return 'Waiting for payment · expires in $time';
  }

  @override
  String get qrisShare => 'Share';

  @override
  String get qrisPrint => 'Print';

  @override
  String get qrisCopy => 'Copy';

  @override
  String get qrisCancel => 'Cancel';

  @override
  String get qrisLive => 'Live';

  @override
  String get qrisPaid => 'Paid';

  @override
  String get qrisPaidTitle => 'Payment received';

  @override
  String get qrisPaidDone => 'Done';

  @override
  String get qrisPaidAnother => 'New payment';

  @override
  String get qrisRowFrom => 'From';

  @override
  String get qrisRowMethod => 'Method';

  @override
  String get qrisRowRef => 'Reference';

  @override
  String get qrisRowAt => 'At';

  @override
  String qrisRowAtValue(String time) {
    return 'Today, $time';
  }

  @override
  String get linkTitle => 'Payment link';

  @override
  String get linkAmount => 'Amount';

  @override
  String get linkNote => 'Note (optional)';

  @override
  String get linkNotePh => 'e.g. May rent · Room 3';

  @override
  String get linkCreate => 'Create link';

  @override
  String get linkShare => 'Share';

  @override
  String get linkCopy => 'Copy';

  @override
  String get linkCopied => 'Copied';

  @override
  String get linkExpires => 'Link valid for 24 hours';

  @override
  String get linkExpiresIn24h => 'Expires in 24h';

  @override
  String get linkPrint => 'Print QR';

  @override
  String get linkHeaderCreate => 'Create a link';

  @override
  String get linkHeaderShare => 'Ready to share';

  @override
  String get linkFieldTitle => 'Title';

  @override
  String get linkFieldTitlePh => 'May rent · Room 3';

  @override
  String get linkFieldCustomer => 'Customer (optional)';

  @override
  String get linkFieldCustomerPh => 'Name or phone';

  @override
  String get linkFieldInvoice => 'Invoice number';

  @override
  String get linkFieldInvoiceAuto => 'AUTO';

  @override
  String get linkFieldInvoiceClear => 'Clear & enter my own';

  @override
  String get linkFieldInvoiceRegen => 'Regenerate';

  @override
  String get linkFieldInvoicePh => 'Type your own invoice number';

  @override
  String get linkFieldInvoiceHelp =>
      'Auto-generated by default. Tap \"Clear\" to link your own invoice number.';

  @override
  String get linkNoCustomer => 'No customer set';

  @override
  String get linkShowQr => 'Show QR';

  @override
  String get linkShareVia => 'Share via…';

  @override
  String get linkMessage => 'Message to share';

  @override
  String get linkMessageCopy => 'Copy message';

  @override
  String get linkMessageReset => 'Reset';

  @override
  String get linkMessageHelp =>
      'Sent as plain text — works in WhatsApp, SMS, email.';

  @override
  String linkMessageGreeting(String name) {
    return 'Hi $name,';
  }

  @override
  String get linkMessageGreetingFallback => 'Hi,';

  @override
  String linkMessageBodyWithTitle(String title) {
    return 'your payment for $title';
  }

  @override
  String get linkMessageBodyNoTitle => 'your payment';

  @override
  String linkMessageBody(
    String what,
    String amt,
    String link,
    String merchant,
  ) {
    return 'To settle $what$amt, please open this link:\nhttps://$link\n\nThanks — $merchant';
  }

  @override
  String linkMessageAmountSuffix(String amount) {
    return ' (IDR $amount)';
  }

  @override
  String get linkQrScan => 'Scan to pay';

  @override
  String get linkQrTapClose => 'Tap anywhere to close';

  @override
  String get linkQrPaymentPlaceholder => 'Payment';

  @override
  String get linkLive => 'Live';

  @override
  String get cpmTitle => 'Scan customer QRIS';

  @override
  String get cpmAim => 'Aim at customer QRIS';

  @override
  String get cpmValid => 'QRIS valid';

  @override
  String get cpmAmountTitle => 'Enter amount';

  @override
  String get cpmAmountChargeTitle => 'Enter amount to charge';

  @override
  String get cpmCharge => 'Charge';

  @override
  String cpmChargeWithAmount(String amount) {
    return 'Charge IDR $amount';
  }

  @override
  String get cpmSuccess => 'Payment successful';

  @override
  String get cpmSuccessReceived => 'Payment received';

  @override
  String get cpmSuccessMethod => 'QRIS · CPM';

  @override
  String get cpmFailed => 'Payment failed';

  @override
  String get cpmFailedSub => 'Try again or use another method.';

  @override
  String get cpmRetry => 'Try again';

  @override
  String get cpmHeader => 'QRIS · CPM';

  @override
  String get cpmPointAt => 'Point at customer\'s QR';

  @override
  String get cpmPointAtSub =>
      'Ask the customer to open their QRIS in any e-wallet or banking app.';

  @override
  String get cpmSimulate => 'Simulate QR detected';

  @override
  String cpmScanLabel(String merchant) {
    return 'Scan QRIS · $merchant';
  }

  @override
  String get cpmRowMethod => 'Method';

  @override
  String get cpmRowMerchant => 'Merchant';

  @override
  String get cpmRowRef => 'Reference';

  @override
  String get cpmDone => 'Done';

  @override
  String get cpmScanAnother => 'Scan another';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLangId => 'Bahasa Indonesia';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLogout => 'Log out';

  @override
  String settingsLogoutConfirm(String name) {
    return 'Log out of $name?';
  }

  @override
  String get settingsLogoutSub =>
      'You\'ll return to the start screen. Balances and transactions stay safe on the server.';

  @override
  String get settingsLogoutStay => 'Stay signed in';

  @override
  String get settingsLogoutGo => 'Log out';

  @override
  String get merchantSettings => 'Merchant settings';

  @override
  String get merchantShareQr => 'Share merchant QR';

  @override
  String get merchantShareQrSub => 'Let staff add this merchant to their phone';

  @override
  String get merchantDanger => 'Danger zone';

  @override
  String get merchantRemove => 'Remove from company';

  @override
  String merchantRemoveSub(String name) {
    return 'Disconnect this merchant from $name. Transaction history stays in the company archive.';
  }

  @override
  String merchantRemoveTitle(String name) {
    return 'Remove \"$name\"?';
  }

  @override
  String get merchantRemoveBody =>
      'This merchant will stop receiving payments on this device. Past transactions remain in the company archive and can be exported later.';

  @override
  String get merchantRemoveNote =>
      'You can re-link this merchant later by rescanning its QR code.';

  @override
  String get merchantRemoveTypeLabel => 'Type';

  @override
  String merchantRemoveConfirm(String name) {
    return 'Type $name to confirm';
  }

  @override
  String get merchantRemoved => 'Merchant removed';

  @override
  String merchantRemovedSub(String name) {
    return '\"$name\" is no longer linked to this device.';
  }

  @override
  String get merchantRemovedSwitch => 'Switch to';

  @override
  String get merchantRemovedBack => 'Back to company dashboard';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonBack => 'Back';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonDone => 'Done';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCurrency => 'IDR';
}
