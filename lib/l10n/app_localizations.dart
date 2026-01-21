import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App Title
      'appTitle': 'Pensioner Verification',

      // Login Screen
      'loginStep1': 'Login Step 1',
      'loginStep2': 'Login Step 2',
      'experimentalVersion': 'Experimental Version',
      'scanNidWithCamera': 'Scan NID with mobile camera',
      'or': 'Or',
      'digit10Nid': '10 Digit NID',
      'digit17Nid': '17 Digit NID',
      'usageInstructions': 'Usage Instructions',
      'enter10DigitEppo': 'Enter 10 digit EPPO number',
      'enter17DigitNid': 'Enter 17 digit NID number',
      'enterPin': 'Enter 4-digit PIN',
      'submit': 'Submit',
      'next': 'Next',

      // Welcome Screen
      'welcomeMessage':
          'Respected Pensioner, Welcome to "Pensioner Verification"',

      // Dashboard
      'lifeVerification': 'Life Verification',
      'contact': 'Contact',
      'pensionInfo': 'Pension Information',
      'faq': 'FAQ',
      'settings': 'Settings',

      // Life Verification
      'verificationHistory': 'Verification History',
      'nextLifeVerification': 'Next Life Verification',
      'verificationDate': 'Verification Date',
      'accountingOffice': 'Accounting Office',
      'method': 'Method',
      'instruction1':
          '1. Avoid reflective objects like monitors, TV screens, mirrors etc.',
      'instruction2': '2. Take photo in adequate lighting.',
      'instruction3': '3. Remove glasses or mask if wearing.',
      'instruction4':
          '4. Follow the instructions in the next step to take photo.',
      'nextStep': 'Next Step',
      'startVerification': 'Start Verification',
      'lookStraight': 'Look straight at the camera',
      'turnLeft': 'Turn your head slightly left',
      'turnRight': 'Turn your head slightly right',
      'verificationSuccess': 'Verification Successful!',
      'verificationFailed': 'Verification Failed. Please try again.',
      'ibas': 'iBAS++',

      // Pension Info
      'paymentInfo': 'Payment Info',
      'fixationDetails': 'Fixation Details',
      'electronicPpo': 'Electronic PPO',
      'ppoNumber': 'PPO Number',
      'birthDateByPpo': 'Birth Date as per PPO',
      'pensionStartDate': 'Pension Start Date',
      'netPensionAtStart':
          'Net Pension at Retirement/Family Pension Start Date',
      'fixationDate': 'Fixation Date',
      'pensionAmount': 'Pension Amount',
      'remarks': 'Remarks',
      'fiscalYear': 'Fiscal Year',
      'month': 'Month',
      'amount': 'Amount',
      'downloadPpo': 'Download Electronic PPO',

      // Contact
      'contactUs': 'Contact Us',
      'email': 'Email',
      'phone': 'Phone',
      'address': 'Address',
      'officeAddress':
          'Sector-7, Road-6, House-10\nUttara-Dhaka-1230, Bangladesh',
      'hotline': 'Hotline',

      // FAQ
      'faqTitle': 'Frequently Asked Questions',
      'faq1Question': 'How do I complete life verification?',
      'faq1Answer':
          'Go to Life Verification from the dashboard and follow the on-screen instructions to complete facial verification.',
      'faq2Question': 'How often should I do life verification?',
      'faq2Answer':
          'Life verification should be completed as per the schedule set by your accounting office, typically once a year.',
      'faq3Question': 'What if my verification fails?',
      'faq3Answer':
          'Ensure you are in a well-lit area, remove glasses/mask, and try again. If the problem persists, contact your accounting office.',
      'faq4Question': 'How can I view my pension payment history?',
      'faq4Answer':
          'Go to Pension Information > Payment Info to view your yearly payment history.',

      // Settings
      'language': 'Language',
      'english': 'English',
      'bangla': 'বাংলা',
      'logout': 'Logout',
      'about': 'About',
      'version': 'Version',

      // Profile
      'profile': 'Profile',
      'personalInfo': 'Personal Information',
      'officeInfo': 'Office Information',
      'verificationStatus': 'Verification Status',
      'verified': 'Verified',
      'pendingVerification': 'Pending Verification',
      'lastVerified': 'Last Verified',
      'name': 'Name',
      'nid': 'NID',
      'dateOfBirth': 'Date of Birth',
      'noDataAvailable': 'No data available',

      // Camera
      'cameraPermissionRequired': 'Camera Permission Required',
      'cameraPermissionMessage':
          'Please allow camera access to use this feature.',
      'openSettings': 'Open Settings',

      // Common
      'back': 'Back',
      'cancel': 'Cancel',
      'ok': 'OK',
      'error': 'Error',
      'loading': 'Loading...',
      'noData': 'No data available',
    },
    'bn': {
      // App Title
      'appTitle': 'পেনশনার ভেরিফিকেশন',

      // Login Screen
      'loginStep1': 'লগইন ধাপ ১',
      'loginStep2': 'লগইন ধাপ ২',
      'experimentalVersion': 'পরীক্ষামূলক সংস্করণ',
      'scanNidWithCamera': 'মোবাইল ক্যামেরা দিয়ে এনআইডি স্ক্যান করুন',
      'or': 'অথবা',
      'digit10Nid': '১০ ডিজিটের এনআইডি',
      'digit17Nid': '১৭ ডিজিটের এনআইডি',
      'usageInstructions': 'ব্যবহার নির্দেশিকা',
      'enter10DigitEppo': '১০ ডিজিটের ইপিপিও নম্বর লিখুন',
      'enter17DigitNid': '১৭ ডিজিটের এনআইডি নম্বর লিখুন',
      'enterPin': '৪ ডিজিটের পিন লিখুন',
      'submit': 'জমা দিন',
      'next': 'পরবর্তী',

      // Welcome Screen
      'welcomeMessage':
          'সম্মানিত পেনশনার আপনাকে "পেনশনার ভেরিফিকেশন" এ স্বাগতম',

      // Dashboard
      'lifeVerification': 'লাইফ ভেরিফিকেশন',
      'contact': 'যোগাযোগ',
      'pensionInfo': 'পেনশন তথ্য',
      'faq': 'সচরাচর জিজ্ঞাসা',
      'settings': 'সেটিংস',

      // Life Verification
      'verificationHistory': 'ভেরিফিকেশন হিস্ট্রি',
      'nextLifeVerification': 'পরবর্তী লাইফ ভেরিফিকেশন',
      'verificationDate': 'ভেরিফিকেশন তারিখ',
      'accountingOffice': 'হিসাবরক্ষণ অফিস',
      'method': 'পদ্ধতি',
      'instruction1':
          '১. আলো প্রতিফলিত হয় এমন বস্তু যেমন - মনিটর, টিভি স্ক্রিন, আয়না ইত্যাদি এড়িয়ে ছবি তুলুন।',
      'instruction2': '২. পর্যাপ্ত আলোতে ছবি তুলুন।',
      'instruction3': '৩. চশমা অথবা মাস্ক পরা থাকলে খুলে ফেলুন।',
      'instruction4':
          '৪. ছবি তুলতে পরবর্তী ধাপে বর্ণিত নির্দেশনাসমূহ অনুসরণ করুন',
      'nextStep': 'পরবর্তী ধাপ',
      'startVerification': 'ভেরিফিকেশন শুরু করুন',
      'lookStraight': 'সোজা ক্যামেরার দিকে তাকান',
      'turnLeft': 'মাথা একটু বামে ঘোরান',
      'turnRight': 'মাথা একটু ডানে ঘোরান',
      'verificationSuccess': 'ভেরিফিকেশন সফল হয়েছে!',
      'verificationFailed': 'ভেরিফিকেশন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।',
      'ibas': 'আইবাস++',

      // Pension Info
      'paymentInfo': 'পেমেন্ট তথ্য',
      'fixationDetails': 'ফিক্সেশন বিস্তারিত',
      'electronicPpo': 'ইলেক্ট্রনিক পিপিও',
      'ppoNumber': 'পিপিও নম্বর',
      'birthDateByPpo': 'পিপিও অনুযায়ী জন্ম তারিখ',
      'pensionStartDate': 'পেনশন শুরুর তারিখ',
      'netPensionAtStart': 'অবসর/পারিবারিক পেনশন শুরুর তারিখে নিট পেনশন',
      'fixationDate': 'ফিক্সেশন তারিখ',
      'pensionAmount': 'পেনশনের পরিমাণ',
      'remarks': 'মন্তব্য',
      'fiscalYear': 'অর্থবছর',
      'month': 'মাস',
      'amount': 'পরিমাণ',
      'downloadPpo': 'ইলেক্ট্রনিক পিপিও ডাউনলোড করুন',

      // Contact
      'contactUs': 'যোগাযোগ করুন',
      'email': 'ইমেইল',
      'phone': 'ফোন',
      'address': 'ঠিকানা',
      'officeAddress': 'সেক্টর-৭, রোড-৬, বাড়ি-১০\nউত্তরা-ঢাকা-১২৩০, বাংলাদেশ',
      'hotline': 'হটলাইন',

      // FAQ
      'faqTitle': 'সচরাচর জিজ্ঞাসা',
      'faq1Question': 'লাইফ ভেরিফিকেশন কীভাবে সম্পন্ন করব?',
      'faq1Answer':
          'ড্যাশবোর্ড থেকে লাইফ ভেরিফিকেশনে যান এবং স্ক্রিনে দেখানো নির্দেশনা অনুসরণ করে ফেসিয়াল ভেরিফিকেশন সম্পন্ন করুন।',
      'faq2Question': 'কত দিন পর পর লাইফ ভেরিফিকেশন করতে হবে?',
      'faq2Answer':
          'আপনার হিসাবরক্ষণ অফিস কর্তৃক নির্ধারিত সময়সূচী অনুযায়ী লাইফ ভেরিফিকেশন সম্পন্ন করতে হবে, সাধারণত বছরে একবার।',
      'faq3Question': 'ভেরিফিকেশন ব্যর্থ হলে কী করব?',
      'faq3Answer':
          'পর্যাপ্ত আলোযুক্ত স্থানে থাকুন, চশমা/মাস্ক খুলে ফেলুন এবং আবার চেষ্টা করুন। সমস্যা থাকলে আপনার হিসাবরক্ষণ অফিসে যোগাযোগ করুন।',
      'faq4Question': 'পেনশন পেমেন্ট হিস্ট্রি কীভাবে দেখব?',
      'faq4Answer':
          'পেনশন তথ্য > পেমেন্ট তথ্য তে গিয়ে আপনার বার্ষিক পেমেন্ট হিস্ট্রি দেখতে পারবেন।',

      // Settings
      'language': 'ভাষা',
      'english': 'English',
      'bangla': 'বাংলা',
      'logout': 'লগআউট',
      'about': 'সম্পর্কে',
      'version': 'সংস্করণ',

      // Profile
      'profile': 'প্রোফাইল',
      'personalInfo': 'ব্যক্তিগত তথ্য',
      'officeInfo': 'অফিস তথ্য',
      'verificationStatus': 'ভেরিফিকেশন স্ট্যাটাস',
      'verified': 'ভেরিফাইড',
      'pendingVerification': 'ভেরিফিকেশন বাকি',
      'lastVerified': 'সর্বশেষ ভেরিফাইড',
      'name': 'নাম',
      'nid': 'এনআইডি',
      'dateOfBirth': 'জন্ম তারিখ',
      'noDataAvailable': 'কোন তথ্য পাওয়া যায়নি',

      // Camera
      'cameraPermissionRequired': 'ক্যামেরা অনুমতি প্রয়োজন',
      'cameraPermissionMessage':
          'এই ফিচার ব্যবহার করতে ক্যামেরা অ্যাক্সেস অনুমতি দিন।',
      'openSettings': 'সেটিংস খুলুন',

      // Common
      'back': 'পেছনে',
      'cancel': 'বাতিল',
      'ok': 'ঠিক আছে',
      'error': 'ত্রুটি',
      'loading': 'লোড হচ্ছে...',
      'noData': 'কোন তথ্য পাওয়া যায়নি',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'bn'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
