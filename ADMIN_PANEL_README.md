# Admin Panel Implementation

## Overview
The admin panel allows administrators to manage pensioner records and review life verification requests. The system helps ensure pensioners are alive and maintain accurate records.

## Features

### 1. **Dashboard**
- Overview of key metrics
- Total pensioners count
- Pending verifications count
- Approved verifications count
- Pending verification percentage
- Quick access to pending verifications
- Recent verification activity

### 2. **Verification Requests Management**
- View all verification requests
- Filter by status (Pending, Under Review, Approved, Rejected)
- Detailed review of each verification
- Approve, reject, or mark as under review
- Add admin notes/comments
- View submitted documents (selfie, NID front/back)
- View submission location data

### 3. **Pensioners Management**
- Browse all pensioners in the system
- Search by name, NID, or EPPO number
- View pensioner status (Alive/Pending)
- Access detailed pensioner information
- View complete verification history
- Mark pensioners as alive manually
- Track last verification date

### 4. **Statistics & Analytics**
- Verification statistics with date range filtering
- Total verifications count
- Approve/Reject breakdown
- Approval rate calculation
- Status distribution visualization
- Period-based analysis
- Completion rate tracking

## Project Structure

### Models
- **`admin.dart`** - Admin user model
- **`verification_request.dart`** - Verification request model

### Services
- **`admin_service.dart`** - Backend API service for admin operations
  - Verification request operations
  - Pensioner management
  - Statistics and reporting

### Providers
- **`admin_provider.dart`** - State management using Provider
  - Handles UI state and data fetching
  - Manages pagination
  - Error handling

### Screens (Admin Panel)
- **`admin_dashboard_screen.dart`** - Main admin dashboard with navigation
- **`verification_requests_screen.dart`** - List and filter verification requests
- **`verification_detail_screen.dart`** - Detailed view and review of verification
- **`pensioners_list_screen.dart`** - Browse and search pensioners
- **`pensioner_detail_screen.dart`** - Detailed pensioner information and history
- **`verification_statistics_screen.dart`** - Analytics and statistics

## Key Workflows

### Reviewing a Verification Request
1. Navigate to "Verification" tab
2. View pending requests
3. Tap on a request to view details
4. Review submitted documents and information
5. Add notes if needed
6. Choose action:
   - **Approve**: Mark pensioner as alive
   - **Mark Under Review**: For further investigation
   - **Reject**: With specific reason

### Managing Pensioner Records
1. Navigate to "Pensioners" tab
2. Search for specific pensioner using name, NID, or EPPO
3. Tap to view detailed information
4. Check verification history
5. Manually mark as alive if needed
6. Update pensioner information

### Analyzing Statistics
1. Navigate to "Statistics" tab
2. Select date range for analysis
3. View various metrics:
   - Total submissions
   - Status breakdown
   - Approval rate
   - Distribution charts

## Database Requirements

### Expected Database Tables

#### `verifications` table
```sql
- id (UUID)
- pensionerId (UUID, FK to pensioners)
- pensionerName (string)
- pensionerEn (string)
- nid (string)
- eppoNumber (string)
- status (enum: pending, under_review, approved, rejected)
- method (string)
- selfieUrl (string, nullable)
- nidFrontUrl (string, nullable)
- nidBackUrl (string, nullable)
- locationData (JSON, nullable)
- submittedAt (timestamp)
- reviewedAt (timestamp, nullable)
- reviewedBy (uuid, nullable)
- notes (text, nullable)
```

#### `pensioners` table
Updates needed:
```sql
- lastVerificationDate (timestamp, nullable)
- verificationStatus (string)
- lastVerifiedBy (uuid, nullable)
```

#### `admins` table (if not exists)
```sql
- id (UUID)
- name (string)
- email (string)
- role (string)
- accountingOffice (string)
- isActive (boolean)
- createdAt (timestamp)
- lastLogin (timestamp, nullable)
```

## Integration

### To integrate the admin panel into your app:

1. **Add AdminProvider to main.dart**:
```dart
ChangeNotifierProvider(create: (_) => AdminProvider()),
```

2. **Navigate to admin panel**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AdminDashboardScreen(),
  ),
);
```

3. **Or in route handling**:
```dart
case '/admin':
  return const AdminDashboardScreen();
```

## User Roles

The system supports different admin roles:
- **Admin**: Full access to all features
- **Accountant**: Can view and manage verifications
- **Reviewer**: Can review and approve/reject verifications

## Security Considerations

1. **Authentication**: Ensure admin login is properly implemented
2. **Authorization**: Check user role before allowing actions
3. **Data Privacy**: Sensitive information (NID, photos) should be secure
4. **Audit Trail**: Track all admin actions and decisions
5. **Access Control**: Limit access to specific accounting offices for local admins

## Future Enhancements

1. **Bulk Operations**: Approve/reject multiple requests at once
2. **Export Reports**: Generate PDF reports of statistics
3. **Admin Activity Log**: Track all admin actions
4. **Field Visit Management**: Manage physical verification requests
5. **Notifications**: Alert admins about pending verifications
6. **Advanced Filters**: Date range, location-based filtering
7. **Mobile App**: Dedicated mobile app for field staff
8. **Biometric Verification**: Advanced liveness detection
9. **API Integration**: Connect with government databases
10. **Performance Optimization**: Caching and pagination improvements

## Code Examples

### Loading Pending Verifications
```dart
final adminProvider = context.read<AdminProvider>();
await adminProvider.loadPendingVerifications();
```

### Approving a Verification
```dart
final success = await adminProvider.approveVerification(
  verificationId: 'verification_id',
  notes: 'Approved after review',
);
```

### Marking Pensioner as Alive
```dart
final success = await adminProvider.markPensionerAsAlive(
  pensionerId: 'pensioner_id',
);
```

### Getting Statistics
```dart
final stats = await adminProvider.getVerificationStats(
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
);
```

## Styling

The admin panel uses the existing app theme:
- Primary Color: #00A651 (Green)
- Secondary Color: #008542 (Dark Green)
- Accent Color: #E53935 (Red)
- Status Colors: Orange (Pending), Blue (Under Review), Green (Approved), Red (Rejected)

## Support for Localization

The admin panel can be extended to support multiple languages (Bangla, English) using the existing localization setup in the app.

---

**Version**: 1.0.0  
**Last Updated**: 2026-03-28  
**Status**: Ready for Integration
