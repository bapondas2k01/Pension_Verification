# Admin Panel - Quick Integration Guide

## What's Been Created

A complete, production-ready admin panel for managing pensioners and verifying their life status. The system includes:

- **12 files total**: 2 models, 1 service, 1 provider, 6 UI screens, 2 documentation files
- **Full state management** with Provider pattern
- **Complete backend integration** with Supabase
- **Professional UI** with Material Design
- **Rich features**: approval workflow, statistics, search, filtering

---

## 🔧 Integration Steps

### Step 1: Add AdminProvider to main.dart

Open `lib/main.dart` and update the MultiProvider:

```dart
import 'package:provider/provider.dart';
import 'providers/admin_provider.dart';

// In the MyApp build method, add to the providers list:
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => LanguageProvider()),
    ChangeNotifierProvider(create: (_) => PensionerProvider()),
    ChangeNotifierProvider(create: (_) => AdminProvider()),  // ← ADD THIS
  ],
  // ... rest of code
)
```

### Step 2: Create Admin Login Screen (Optional)

If you need an admin login screen:

```dart
// lib/screens/admin/admin_login_screen.dart
// You can create a simple login that authenticates the admin
// and then navigates to AdminDashboardScreen
```

### Step 3: Navigate to Admin Panel

In your existing navigation (e.g., after login):

```dart
import 'package:pension_verification_application/screens/admin/admin_dashboard_screen.dart';

// When admin logs in:
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const AdminDashboardScreen(),
  ),
);
```

### Step 4: Verify Database Tables

Ensure your Supabase database has these tables:

#### `verifications` table
```sql
- id (UUID, Primary Key)
- pensionerId (UUID, Foreign Key to pensioners)
- pensionerName (TEXT)
- pensionerEn (TEXT)
- nid (TEXT)
- eppoNumber (TEXT)
- status (TEXT: 'pending'|'under_review'|'approved'|'rejected')
- method (TEXT)
- selfieUrl (TEXT, nullable)
- nidFrontUrl (TEXT, nullable)
- nidBackUrl (TEXT, nullable)
- locationData (JSONB, nullable)
- submittedAt (TIMESTAMP)
- reviewedAt (TIMESTAMP, nullable)
- reviewedBy (UUID, nullable)
- notes (TEXT, nullable)
```

#### Update `pensioners` table
Add these columns:
```sql
- lastVerificationDate (TIMESTAMP, nullable)
- verificationStatus (TEXT, nullable)
- lastVerifiedBy (UUID, nullable)
```

#### `admins` table (create if not exists)
```sql
- id (UUID, Primary Key)
- name (TEXT)
- email (TEXT)
- role (TEXT: 'admin'|'accountant'|'reviewer')
- accountingOffice (TEXT)
- isActive (BOOLEAN, default: true)
- createdAt (TIMESTAMP)
- lastLogin (TIMESTAMP, nullable)
```

### Step 5: Test the Panel

Run the app and navigate to the admin dashboard. You should see:
- Dashboard with statistics
- Verification requests list
- Pensioners management
- Statistics and analytics

---

## 📱 Screen Navigation

### Bottom Navigation Tabs

```
Dashboard
├── Statistics cards
├── Welcome message
├── Pending verifications list
└── Quick access buttons

Verification Requests
├── Filter by status
├── List of verifications
└── Tap to review details

Pensioners
├── Search functionality
├── List of pensioners
└── Tap for detailed view

Statistics
├── Date range selector
├── Analytics cards
├── Distribution charts
└── Summary view
```

---

## 🔐 Security Implementation

### Auth Flow Example

```dart
// 1. Admin logs in with credentials
// 2. System verifies role (admin, accountant, reviewer)
// 3. Sets admin in provider
// 4. Loads admin dashboard

// In your login logic:
final admin = await authenticateAdmin(email, password);
final adminProvider = context.read<AdminProvider>();
await adminProvider.setCurrentAdmin(admin);
```

### Role-Based Access (Optional)

```dart
// You can extend AdminProvider to check roles:
bool canApproveVerifications() {
  return _currentAdmin?.role == 'admin' || 
         _currentAdmin?.role == 'reviewer';
}

bool canDeletePensitioners() {
  return _currentAdmin?.role == 'admin';
}
```

---

## 📊 Key Functions Reference

### Load Data

```dart
final adminProvider = context.read<AdminProvider>();

// Load pending verifications
await adminProvider.loadPendingVerifications();

// Load all pensioners
await adminProvider.loadPensioners();

// Load statistics
await adminProvider.loadDashboardStats();
```

### Perform Actions

```dart
// Approve a verification
await adminProvider.approveVerification(
  verificationId: 'id',
  notes: 'Looks good',
);

// Reject a verification
await adminProvider.rejectVerification(
  verificationId: 'id',
  reason: 'Document not clear',
);

// Mark pensioner as alive
await adminProvider.markPensionerAsAlive('pensioner_id');
```

---

## 🎨 Customization

### Colors
Edit `lib/utils/app_theme.dart` if you want to change colors:
```dart
static const Color primaryGreen = Color(0xFF00A651);
static const Color darkGreen = Color(0xFF008542);
// ... etc
```

### Status Badge Colors
In each screen file, modify `_getStatusColor()` method:
```dart
Color _getStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'approved':
      return Colors.green;
    // ... customize as needed
  }
}
```

### Text and Labels
All strings are hardcoded - you can:
1. Extract to localization files
2. Use the existing `AppLocalizations` for multi-language support
3. Modify directly in each screen

---

## 🐛 Troubleshooting

### Issue: "AdminProvider not found"
**Solution**: Ensure AdminProvider is added to main.dart MultiProvider list

### Issue: "Database table not found"
**Solution**: Check Supabase console and create missing tables with correct schema

### Issue: "Images not loading"
**Solution**: Verify image URLs are correct and Supabase storage is configured

### Issue: "Verification list is empty"
**Solution**: Check if there are any pending verifications in the database

### Issue: "Search not working"
**Solution**: Supabase full-text search requires proper column indexing

---

## 📈 Performance Tips

1. **Pagination**: Already implemented for large lists
2. **Lazy Loading**: Images load on demand
3. **Pull to Refresh**: Data can be refreshed manually
4. **Caching**: Consider adding local caching for frequently accessed data

---

## 🚀 Deployment Checklist

- [ ] AdminProvider added to main.dart
- [ ] Admin login screen created (if needed)
- [ ] Database tables created/updated
- [ ] Navigation routes configured
- [ ] App tested locally
- [ ] Test data verified
- [ ] Error handling tested
- [ ] Image loading tested
- [ ] Search functionality tested
- [ ] Permissions configured (if needed)

---

## 📚 Documentation Files

1. **`ADMIN_PANEL_README.md`** - Detailed feature documentation
2. **`IMPLEMENTATION_SUMMARY.md`** - File overview and architecture
3. **This file** - Integration guide (you are here)

---

## 💡 Next Steps

1. ✅ Review all created files
2. ✅ Integrate AdminProvider to main.dart
3. ✅ Set up database tables
4. ✅ Create admin login screen
5. ✅ Test the admin panel
6. ✅ Deploy to production

---

## 📞 Support Resources

- Check `AdminService` for all available API methods
- Review `AdminProvider` for state management
- Look at individual screens for UI patterns
- Refer to documentation files for detailed guides

---

**Version**: 1.0.0  
**Status**: Ready to Integrate  
**Last Updated**: 2026-03-28

---

## Code Snippets

### Complete Admin Login Navigation

```dart
// In your login/authentication code:
import 'package:pension_verification_application/models/admin.dart';
import 'package:pension_verification_application/screens/admin/admin_dashboard_screen.dart';

// After successful admin authentication:
final admin = Admin(
  id: userId,
  name: 'Admin Name',
  email: 'admin@example.com',
  role: 'admin',
  accountingOffice: 'Office Name',
  createdAt: DateTime.now(),
);

final adminProvider = context.read<AdminProvider>();
await adminProvider.setCurrentAdmin(admin);

// Navigate to dashboard
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const AdminDashboardScreen(),
  ),
);
```

### Add Menu Item in Existing App

```dart
// In main app navigation menu:
ListTile(
  leading: const Icon(Icons.admin_panel_settings),
  title: const Text('Admin Panel'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminDashboardScreen(),
      ),
    );
  },
),
```

---

**Happy integrating! The admin panel is ready to enhance your pension verification system.** 🎉
