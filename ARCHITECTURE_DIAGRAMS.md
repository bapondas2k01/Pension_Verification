# Admin Panel Architecture & Flow Diagrams

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        ADMIN PANEL APP                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              UI LAYER (6 Screens)                        │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                            │   │
│  │  AdminDashboardScreen (Navigation Hub)                   │   │
│  │  ├─ AdminHomeScreen (Dashboard)                          │   │
│  │  ├─ VerificationRequestsScreen                           │   │
│  │  │  └─ VerificationDetailScreen                          │   │
│  │  ├─ PensionersListScreen                                 │   │
│  │  │  └─ PensionerDetailScreen                             │   │
│  │  └─ VerificationStatisticsScreen                         │   │
│  │                                                            │   │
│  └──────────────────────────────────────────────────────────┘   │
│           ↓                                                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │        STATE MANAGEMENT LAYER                            │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                            │   │
│  │  AdminProvider (ChangeNotifier)                          │   │
│  │  ├─ currentAdmin                                          │   │
│  │  ├─ pendingVerifications                                  │   │
│  │  ├─ allVerifications                                      │   │
│  │  ├─ pensioners                                            │   │
│  │  ├─ dashboardStats                                        │   │
│  │  ├─ isLoading, error, pagination                          │   │
│  │  └─ 25+ methods for state management                      │   │
│  │                                                            │   │
│  └──────────────────────────────────────────────────────────┘   │
│           ↓                                                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │           SERVICE LAYER                                  │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                            │   │
│  │  AdminService (Supabase Integration)                     │   │
│  │  ├─ Verification Operations (get, approve, reject)       │   │
│  │  ├─ Pensioner Management (search, filter, update)        │   │
│  │  ├─ Statistics & Analytics                               │   │
│  │  └─ 40+ methods covering all backend operations          │   │
│  │                                                            │   │
│  └──────────────────────────────────────────────────────────┘   │
│           ↓                                                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         DATA MODELS                                      │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                            │   │
│  │  Admin Model                                             │   │
│  │  └─ id, name, email, role, office, status               │   │
│  │                                                            │   │
│  │  VerificationRequest Model                               │   │
│  │  └─ id, pensionerInfo, documents, status, notes          │   │
│  │                                                            │   │
│  └──────────────────────────────────────────────────────────┘   │
│           ↓                                                       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │        DATABASE (Supabase/PostgreSQL)                    │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │                                                            │   │
│  │  verifications  ← → pensioners ← → admins               │   │
│  │  (submissions)      (records)      (users)              │   │
│  │                                                            │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## User Flow Diagram

```
START
  │
  ├─→ [Admin Login]
  │
  └─→ AdminDashboardScreen
      │
      ├─ Dashboard Tab
      │  ├─ View Statistics
      │  ├─ See Pending Count
      │  └─ Quick Actions
      │
      ├─ Verification Tab
      │  ├─ View All Requests
      │  ├─ Filter by Status
      │  │  ├─ Pending
      │  │  ├─ Under Review
      │  │  ├─ Approved
      │  │  └─ Rejected
      │  │
      │  └─ [Tap Verification]
      │     └─ VerificationDetailScreen
      │        ├─ Review Details
      │        ├─ View Documents
      │        └─ Action
      │           ├─ Approve ✓
      │           ├─ Reject ✗
      │           └─ Mark Under Review ⊕
      │
      ├─ Pensioners Tab
      │  ├─ View All Pensioners
      │  ├─ Search/Filter
      │  │  ├─ By Name
      │  │  ├─ By NID
      │  │  └─ By EPPO
      │  │
      │  └─ [Tap Pensioner]
      │     └─ PensionerDetailScreen
      │        ├─ View Profile
      │        ├─ Check Status (Alive/Pending)
      │        ├─ View History
      │        └─ Mark Alive (if needed)
      │
      └─ Statistics Tab
         ├─ Select Date Range
         ├─ View Metrics
         │  ├─ Total Verifications
         │  ├─ Pending Count
         │  ├─ Approved Count
         │  └─ Rejected Count
         │
         └─ View Analytics
            ├─ Approval Rate
            ├─ Status Distribution
            └─ Completion Rate
```

---

## Data Flow: Verification Approval

```
[Admin Opens Verification]
      ↓
[VerificationDetailScreen Loads]
      ├─ Get Verification Details
      ├─ Load Images
      └─ Display Information
      ↓
[Admin Reviews Details]
      ├─ Checks Selfie Photo
      ├─ Verifies NID
      └─ Reviews Location Data
      ↓
[Admin Makes Decision]
      ├─ APPROVE PATH
      │  ├─ Clicks 'Approve' button
      │  ├─ Adds Notes (optional)
      │  └─ Confirms Action
      │     ↓
      │  [AdminProvider.approveVerification()]
      │     ↓
      │  [AdminService.approveVerification()]
      │     ├─ Update verification status → 'approved'
      │     ├─ Set reviewedAt timestamp
      │     ├─ Record adminId as reviewer
      │     ├─ Update pensioner:
      │     │  ├─ lastVerificationDate = now
      │     │  └─ verificationStatus = 'alive'
      │     └─ Return success
      │     ↓
      │  [Update UI + State]
      │     ├─ Remove from pending list
      │     ├─ Refresh dashboard stats
      │     └─ Show success message
      │
      ├─ REJECT PATH
      │  ├─ Clicks 'Reject' button
      │  ├─ Opens dialog for reason
      │  └─ Confirms rejection
      │     ↓
      │  [AdminProvider.rejectVerification()]
      │     ↓
      │  [AdminService.rejectVerification()]
      │     ├─ Update verification status → 'rejected'
      │     ├─ Record reason in notes
      │     └─ Return success
      │     ↓
      │  [Update UI + State]
      │     ├─ Remove from pending list
      │     └─ Show rejection message
      │
      └─ UNDER REVIEW PATH
         ├─ Clicks 'Under Review' button
         └─ Confirms action
            ↓
         [AdminProvider.markUnderReview()]
            ↓
         [AdminService.markUnderReview()]
            ├─ Update status → 'under_review'
            └─ Record admin reviewer
            ↓
         [Update UI]
            └─ Refresh verification list

[Return to List]
      ↓
[Dashboard/List Updates]
      ├─ Verify removed from pending
      ├─ Statistics updated
      └─ UI refreshed
```

---

## Pensioner Verification Lifecycle

```
┌─ INITIAL STATE
│  └─ lastVerificationDate: NULL
│     verificationStatus: NULL
│     Status Badge: PENDING (Orange)
│
├─→ VERIFICATION SUBMITTED
│  (App/Field/Office)
│  │
│  ├─ Create verification record
│  ├─ Upload documents
│  ├─ Send location data
│  └─ Set status: pending
│
├─→ ADMIN REVIEW
│  │
│  ├─ Admin views details
│  ├─ Reviews documents
│  └─ Makes decision
│
├─→ OUTCOMES
│  │
│  ├─ APPROVED
│  │  ├─ lastVerificationDate: NOW
│  │  ├─ verificationStatus: alive
│  │  ├─ Status Badge: ALIVE (Green)
│  │  └─ Valid for 6 months
│  │
│  ├─ REJECTED
│  │  ├─ verificationStatus: rejected
│  │  ├─ Status Badge: PENDING (Orange)
│  │  └─ Can resubmit
│  │
│  └─ UNDER REVIEW
│     ├─ Status: under_review
│     ├─ Status Badge: REVIEWING (Blue)
│     └─ Awaiting admin decision
│
└─→ VERIFICATION EXPIRY (6 months)
   └─ Auto-revert to PENDING
      (Can be automated or manual)
```

---

## Database Schema Relationships

```
┌─────────────────────┐
│    admins           │
├─────────────────────┤
│ id (PK)             │
│ name                │
│ email               │
│ role                │
│ accountingOffice    │
│ isActive            │
│ createdAt           │
│ lastLogin           │
└──────────┬──────────┘
           │
           │ FK: reviewedBy
           │
           ↓
┌─────────────────────────────────────┐         ┌──────────────────┐
│    verifications                    │────←────│    pensioners     │
├─────────────────────────────────────┤         ├──────────────────┤
│ id (PK)                             │         │ id (PK)          │
│ pensionerId (FK) ──────────────────→│         │ name             │
│ pensionerName                       │         │ nameEn           │
│ pensionerEn                         │         │ nid              │
│ nid                                 │         │ eppoNumber       │
│ eppoNumber                          │         │ photoUrl         │
│ status                              │         │ accountingOffice │
│ method                              │         │ phone            │
│ selfieUrl                           │         │ email            │
│ nidFrontUrl                         │         │ address          │
│ nidBackUrl                          │         │ birthDate        │
│ locationData (JSON)                 │         │ pensionStartDate │
│ submittedAt                         │         │ monthly Amount   │
│ reviewedAt                          │         │ lastVerification │
│ reviewedBy (FK) ──────────────────→│         │ verificationStatus
│ notes                               │         │ lastVerifiedBy   │
└─────────────────────────────────────┘         └──────────────────┘
```

---

## Screen Navigation Flow

```
                    AdminDashboardScreen
                    (Bottom Navigation)
                          │
        ┌─────────────────┼─────────────────┬──────────────────┐
        │                 │                 │                  │
        ↓                 ↓                 ↓                  ↓
    Dashboard         Verification      Pensioners        Statistics
    (Home)            Requests          Management         (Analytics)
        │                 │                 │                  │
        │         ┌───────┴────────┐       │                  │
        │         ↓                ↓       ↓                  │
        │     Pending         Verification Pensioner        Date
        │     Requests        DetailScreen DetailScreen      Range
        │     List                │          │             Selection
        │         │               │          └─→            │
        │     [Tap]              Review      View          [Select]
        │         │              Details    Profile         │
        │         └─→ Navigate to Details   History      [View]
        │                        │            │          Stats
        │                     [Approve]   [Mark Alive]      │
        │                     [Reject]         │         Charts
        │                     [Review]         └─→ Refresh   │
        │                         │                      Analytics
        └─────────────────────────┘────────────────────────→┘
                                   │
                    Update AdminProvider State
                    │
                    ├─ Refresh Lists
                    ├─ Update Stats
                    ├─ Notify UI
                    └─ Show Messages
```

---

## Admin Roles & Permissions

```
ADMIN ROLE
├─ View all verifications
├─ Approve/Reject verifications
├─ View all pensioners
├─ Update pensioner info
├─ Mark pensioner as alive
├─ View statistics
├─ Manage other admins
└─ Generate reports

ACCOUNTANT ROLE
├─ View all verifications
├─ Review verifications
├─ View all pensioners
├─ View statistics
└─ ✗ Cannot approve/reject

REVIEWER ROLE
├─ View assigned verifications
├─ Approve/Reject verifications
├─ View assigned pensioners
├─ Mark as alive
└─ ✗ Cannot access reports

(Implement with AdminProvider checks)
```

---

## Performance Optimization Strategy

```
DATA LAYERS
│
├─ API Caching (300s)
│  └─ Cache verification lists
│
├─ Pagination
│  ├─ 10 items per page (configurable)
│  ├─ Efficient list rendering
│  └─ Lazy load details
│
├─ Image Optimization
│  ├─ Network image loading
│  ├─ Error handling
│  └─ Placeholder images
│
├─ Search Optimization
│  ├─ Debounced search (500ms)
│  ├─ Case-insensitive matching
│  └─ Multiple field support
│
└─ Future Enhancements
   ├─ Local SQLite caching
   ├─ Offline support
   ├─ Background sync
   └─ Image caching
```

---

**Last Updated**: 2026-03-28  
**Status**: Complete & Ready for Reference
