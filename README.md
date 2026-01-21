# Pension Verification Application

A Flutter mobile application for pensioner life verification in Bangladesh. This app allows pensioners to verify their identity using facial recognition and submit verification proofs to Firebase.

## Features

- 🔐 **Secure Login** - Login with NID (17-digit) or EPPO number (10-digit) + 4-digit PIN
- 📸 **Face Verification** - AI-powered face detection for life verification
- 🔥 **Firebase Integration** - Real-time database for pensioner data and verification records
- 🌐 **Bilingual Support** - English and বাংলা (Bangla) language support
- 📱 **NID Scanner** - Scan NID cards using mobile camera (OCR)
- 📊 **Dashboard** - View pension information, payment history, and verification status

## Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK
- Firebase account
- Android Studio / VS Code
- Node.js (for Firebase CLI)

## Firebase Setup Guide

### Step 1: Install Firebase CLI & FlutterFire CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### Step 2: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Name your project (e.g., `pension-verification-bd`)
4. Click **Create Project**

### Step 3: Configure Flutter App with Firebase

Run this command in your project folder:

```bash
flutterfire configure
```

- Select your Firebase project
- Choose platforms: **Android** and **iOS**
- This auto-generates `lib/firebase_options.dart` with your credentials

### Step 4: Set Up Firestore Database

1. In Firebase Console → **Build** → **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location (e.g., `asia-south1` for Bangladesh)

### Step 5: Create Firestore Collections

#### `pensioners` Collection

Add sample documents with this structure:

```json
{
  "nid": "12345678901234567",
  "eppoNumber": "1234567890",
  "pin": "1234",
  "name": "মোহাম্মদ করিম",
  "nameEn": "Mohammad Karim",
  "ppoNumber": "PPO-123456",
  "birthDate": "1955-01-15T00:00:00.000Z",
  "pensionStartDate": "2010-07-01T00:00:00.000Z",
  "netPensionAtStart": 8000,
  "monthlyAmount": 15000,
  "photoUrl": "",
  "accountingOffice": "Finance Controller, Pay 2",
  "phone": "+8801712345678",
  "email": "karim@example.com",
  "address": "ঢাকা, বাংলাদেশ",
  "pensionType": "Government",
  "lastVerificationDate": null,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

#### `verifications` Collection

This collection stores verification submissions:

```json
{
  "pensionerId": "<document_id>",
  "nid": "12345678901234567",
  "eppoNumber": "1234567890",
  "selfieUrl": "https://firebasestorage...",
  "nidFrontUrl": null,
  "nidBackUrl": null,
  "locationData": {
    "timestamp": "2024-01-09T10:30:00.000Z",
    "device": "mobile_app"
  },
  "status": "pending",
  "submittedAt": "2024-01-09T10:30:00.000Z",
  "reviewedAt": null,
  "reviewedBy": null,
  "notes": null
}
```

### Step 6: Set Up Firebase Storage

1. In Firebase Console → **Build** → **Storage**
2. Click **Get started**
3. Choose **Start in test mode**
4. Select same location as Firestore

### Step 7: Firestore Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Pensioners - read only from app
    match /pensioners/{pensionerId} {
      allow read: if true;
      allow write: if false;
    }
    
    // Verifications - create from app, no update/delete
    match /verifications/{verificationId} {
      allow read, create: if true;
      allow update, delete: if false;
    }
  }
}
```

### Step 8: Storage Security Rules (Production)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /verifications/{pensionerId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd pension_verification_application

# Install dependencies
flutter pub get

# Configure Firebase (if not already done)
flutterfire configure

# Run the app
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── l10n/
│   └── app_localizations.dart  # Translations (EN/BN)
├── models/
│   ├── pensioner.dart        # Pensioner data model
│   ├── verification_history.dart
│   ├── payment_info.dart
│   └── fixation_info.dart
├── providers/
│   ├── pensioner_provider.dart  # State management
│   └── language_provider.dart
├── screens/
│   ├── login/                # Login flow screens
│   ├── welcome/              # Welcome screen
│   ├── dashboard/            # Main dashboard
│   ├── life_verification/    # Face verification
│   ├── pension_info/         # Pension details
│   ├── profile/              # User profile
│   ├── settings/             # App settings
│   ├── contact/              # Contact info
│   └── faq/                  # FAQ screen
├── services/
│   └── firebase_service.dart # Firebase CRUD operations
└── utils/
    └── app_theme.dart        # App styling
```

## Dependencies

- `firebase_core` - Firebase initialization
- `cloud_firestore` - Firestore database
- `firebase_storage` - File storage for selfies
- `firebase_auth` - Authentication (optional)
- `provider` - State management
- `camera` - Camera access
- `google_mlkit_face_detection` - Face detection
- `google_mlkit_text_recognition` - NID text scanning
- `permission_handler` - Permission management

## Test Credentials

For development, create a pensioner in Firestore with these credentials:

- **EPPO Number**: `1234567890`
- **PIN**: `1234`

Or:

- **NID**: `12345678901234567`
- **PIN**: `1234`

## License

This project is for demonstration purposes.

## Contact

For issues or questions, please open an issue on GitHub.
