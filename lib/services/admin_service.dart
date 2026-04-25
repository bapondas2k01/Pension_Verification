import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/verification_request.dart';
import '../models/admin.dart';

class AdminService {
  static final SupabaseClient client = Supabase.instance.client;

  // ==================== VERIFICATION REQUESTS ====================

  /// Get all pending verification requests
  static Future<List<VerificationRequest>> getPendingVerifications({
    String? accountingOffice,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = client.from('verifications').select();

    query = query.eq('status', 'pending');

    if (accountingOffice != null) {
      query = query.eq('accountingOffice', accountingOffice);
    }

    final response = await query
        .order('submittedAt', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((e) => VerificationRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get all verification requests with filters
  static Future<List<VerificationRequest>> getVerifications({
    String? status,
    String? accountingOffice,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final List response = await client
          .from('verifications')
          .select()
          .order('submittedAt', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((e) => VerificationRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a single verification request by ID
  static Future<VerificationRequest?> getVerificationById(String id) async {
    try {
      final response = await client
          .from('verifications')
          .select()
          .eq('id', id)
          .single();
      return VerificationRequest.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Approve a verification request
  static Future<bool> approveVerification({
    required String verificationId,
    required String adminId,
    String? notes,
  }) async {
    try {
      final verification = await getVerificationById(verificationId);
      if (verification == null) return false;

      // Update verification status
      await client
          .from('verifications')
          .update({
            'status': 'approved',
            'reviewedAt': DateTime.now().toIso8601String(),
            'reviewedBy': adminId,
            'notes': notes,
          })
          .eq('id', verificationId);

      // Update pensioner's last verification date
      await client
          .from('pensioners')
          .update({
            'lastVerificationDate': DateTime.now().toIso8601String(),
            'verificationStatus': 'alive',
          })
          .eq('id', verification.pensionerId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reject a verification request
  static Future<bool> rejectVerification({
    required String verificationId,
    required String adminId,
    required String reason,
  }) async {
    try {
      await client
          .from('verifications')
          .update({
            'status': 'rejected',
            'reviewedAt': DateTime.now().toIso8601String(),
            'reviewedBy': adminId,
            'notes': reason,
          })
          .eq('id', verificationId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark verification as under review
  static Future<bool> markUnderReview({
    required String verificationId,
    required String adminId,
  }) async {
    try {
      await client
          .from('verifications')
          .update({'status': 'under_review', 'reviewedBy': adminId})
          .eq('id', verificationId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== PENSIONER MANAGEMENT ====================

  /// Get all pensioners
  static Future<List<Map<String, dynamic>>> getAllPensioners({
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = client.from('pensioners').select();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
        'name.ilike.%$searchQuery%,nameEn.ilike.%$searchQuery%,nid.eq.$searchQuery,eppoNumber.eq.$searchQuery',
      );
    }

    final response = await query.range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get pensioners by accounting office
  static Future<List<Map<String, dynamic>>> getPensionersByOffice({
    required String accountingOffice,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await client
        .from('pensioners')
        .select()
        .eq('accountingOffice', accountingOffice)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get pensioners with pending verifications
  static Future<List<Map<String, dynamic>>>
  getPensionersWithPendingVerifications({
    String? accountingOffice,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final List response = await client
          .from('pensioners')
          .select('*, verifications!inner(id, status, submittedAt)')
          .order('name', ascending: true)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Update pensioner
  static Future<bool> updatePensioner({
    required String pensionerId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await client.from('pensioners').update(data).eq('id', pensionerId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark pensioner as verified (alive)
  static Future<bool> markPensionerAsAlive({
    required String pensionerId,
    required String adminId,
  }) async {
    try {
      await client
          .from('pensioners')
          .update({
            'lastVerificationDate': DateTime.now().toIso8601String(),
            'verificationStatus': 'alive',
            'lastVerifiedBy': adminId,
          })
          .eq('id', pensionerId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get pensioner verification history
  static Future<List<Map<String, dynamic>>> getPensionerVerificationHistory({
    required String pensionerId,
    int limit = 20,
  }) async {
    final response = await client
        .from('verifications')
        .select()
        .eq('pensionerId', pensionerId)
        .order('submittedAt', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  // ==================== STATISTICS ====================

  /// Get verification statistics
  static Future<Map<String, dynamic>> getVerificationStats({
    String? accountingOffice,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = client.from('verifications').select('status');

    if (accountingOffice != null) {
      query = query.eq('accountingOffice', accountingOffice);
    }

    if (startDate != null) {
      query = query.gte('submittedAt', startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.lte('submittedAt', endDate.toIso8601String());
    }

    final response = await query;
    final verifications = List<Map<String, dynamic>>.from(response);

    int pending = 0;
    int approved = 0;
    int rejected = 0;
    int underReview = 0;

    for (var v in verifications) {
      switch (v['status']) {
        case 'pending':
          pending++;
          break;
        case 'approved':
          approved++;
          break;
        case 'rejected':
          rejected++;
          break;
        case 'under_review':
          underReview++;
          break;
      }
    }

    return {
      'total': verifications.length,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'underReview': underReview,
      'approvalRate': approved > 0
          ? (approved / (approved + rejected) * 100).toStringAsFixed(2)
          : '0.0',
    };
  }

  /// Get admin stats
  static Future<Map<String, dynamic>> getAdminStats({
    String? accountingOffice,
  }) async {
    final pensioners = await getAdminDashboardStats(accountingOffice);
    return pensioners;
  }

  /// Get dashboard stats for admin
  static Future<Map<String, dynamic>> getAdminDashboardStats(
    String? accountingOffice,
  ) async {
    try {
      print('DEBUG: Fetching dashboard stats for office: $accountingOffice');

      // Get total pensioners - fetch all and count
      final pensionerResponse = await client.from('pensioners').select();
      final pensionerCount = (pensionerResponse as List).length;
      print('DEBUG: Total pensioners: $pensionerCount');

      // Get pending verifications - filter by status
      final pendingResponse = await client
          .from('verifications')
          .select()
          .eq('status', 'pending');
      final pendingCount = (pendingResponse as List).length;
      print('DEBUG: Pending verifications: $pendingCount');

      // Get approved verifications - filter by status
      final approvedResponse = await client
          .from('verifications')
          .select()
          .eq('status', 'approved');
      final approvedCount = (approvedResponse as List).length;
      print('DEBUG: Approved verifications: $approvedCount');

      final result = {
        'totalPensioners': pensionerCount,
        'pendingVerifications': pendingCount,
        'approvedVerifications': approvedCount,
        'pendingPercentage': pensionerCount > 0
            ? (pendingCount / pensionerCount * 100).toStringAsFixed(2)
            : '0.0',
      };
      
      print('DEBUG: Dashboard stats result: $result');
      return result;
    } catch (e) {
      print('DEBUG: Error fetching dashboard stats: $e');
      return {
        'totalPensioners': 0,
        'pendingVerifications': 0,
        'approvedVerifications': 0,
        'pendingPercentage': '0.0',
      };
    }
  }

  // ==================== ADMIN OPERATIONS ====================

  /// Get admin user
  static Future<Admin?> getAdminUser(String adminId) async {
    try {
      final response = await client
          .from('admins')
          .select()
          .eq('id', adminId)
          .single();
      return Admin.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Update admin last login
  static Future<bool> updateAdminLastLogin(String adminId) async {
    try {
      await client
          .from('admins')
          .update({'lastLogin': DateTime.now().toIso8601String()})
          .eq('id', adminId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get verification count for admin
  static Future<int> getVerificationCount({String? status}) async {
    try {
      final response = await client.from('verifications').select();
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  // ==================== ADMIN AUTHENTICATION ====================

  /// Helper to check if value is truthy (handles bool, string, int)
  /// Returns true unless explicitly false/0/"false"/"no"
  static bool _isTruthy(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      // Return false only for explicit false values
      return lower != 'false' && lower != 'no' && lower != '0' && lower != '';
    }
    if (value is int) return value != 0;
    // Default: treat null as inactive
    return value != null;
  }

  /// Authenticate admin user by email and password
  /// Simple validation: email must exist and password must match
  static Future<Admin?> authenticateAdminByEmail({
    required String email,
    required String password,
  }) async {
    try {
      final trimmedEmail = email.trim().toLowerCase();
      final trimmedPassword = password.trim();

      // Find admin by email (case-insensitive)
      final List<dynamic> response = await client
          .from('admins')
          .select()
          .ilike('email', trimmedEmail);

      if (response.isEmpty) {
        print('DEBUG: Admin not found with email: $trimmedEmail');
        return null;
      }

      final adminData = response[0] as Map<String, dynamic>;
      print('DEBUG: Found admin data: $adminData');

      // Only validate password - everything else is optional
      final storedPassword = (adminData['password'] ?? '').toString().trim();
      print('DEBUG: Password check - stored: "$storedPassword", entered: "$trimmedPassword"');
      
      if (storedPassword.isEmpty || storedPassword != trimmedPassword) {
        print('DEBUG: Password mismatch');
        return null;
      }

      print('DEBUG: Authentication successful, creating admin');
      // All validations passed - return the admin
      final admin = Admin.fromJson(adminData);
      return admin;
    } catch (e) {
      print('DEBUG: Authentication error: $e');
      return null;
    }
  }

  /// Legacy method for ID-based authentication (for backward compatibility)
  static Future<Admin?> authenticateAdmin({
    required String adminId,
    required String password,
  }) async {
    try {
      final trimmedAdminId = adminId.trim().toLowerCase();
      final trimmedPassword = password.trim();

      // Try to find admin by ID first, then by email
      List<dynamic> response;
      try {
        response = await client
            .from('admins')
            .select()
            .eq('id', adminId);
      } catch (e) {
        // If ID search fails, try email search (case-insensitive)
        response = await client
            .from('admins')
            .select()
            .ilike('email', trimmedAdminId);
      }

      if (response.isEmpty) {
        return null; // Admin not found
      }

      final adminData = response[0] as Map<String, dynamic>;

      // Only check password - everything else is optional
      final storedPassword = (adminData['password'] ?? '').toString().trim();
      if (storedPassword.isEmpty || storedPassword != trimmedPassword) {
        return null; // Password mismatch
      }

      // All validations passed - return the admin
      final admin = Admin.fromJson(adminData);
      return admin;
    } catch (e) {
      return null;
    }
  }

  /// Helper method to get validation error message for email-based auth
  static Future<String> getAuthenticationErrorMessageByEmail({
    required String email,
    required String password,
  }) async {
    try {
      final trimmedEmail = email.trim().toLowerCase();
      final trimmedPassword = password.trim();

      // Find admin by email (case-insensitive)
      final List<dynamic> response = await client
          .from('admins')
          .select()
          .ilike('email', trimmedEmail);

      if (response.isEmpty) {
        return 'Email not found in the system';
      }

      // Only check password
      final adminData = response[0] as Map<String, dynamic>;
      final storedPassword = (adminData['password'] ?? '').toString().trim();
      
      if (storedPassword.isEmpty || storedPassword != trimmedPassword) {
        return 'Invalid password. Please try again';
      }

      return 'Authentication failed';
    } catch (e) {
      return 'System error: Unable to verify credentials';
    }
  }

  /// Helper method to get validation error message (legacy - for ID-based auth)
  static Future<String> getAuthenticationErrorMessage({
    required String adminId,
    required String password,
  }) async {
    try {
      final trimmedAdminId = adminId.trim().toLowerCase();
      final trimmedPassword = password.trim();

      // Try to find admin by ID first, then by email
      List<dynamic> response;
      try {
        response = await client
            .from('admins')
            .select()
            .eq('id', adminId);
      } catch (e) {
        response = await client
            .from('admins')
            .select()
            .ilike('email', trimmedAdminId);
      }

      if (response.isEmpty) {
        return 'Admin ID or email not found in the system';
      }

      // Only check password
      final adminData = response[0] as Map<String, dynamic>;
      final storedPassword = (adminData['password'] ?? '').toString().trim();
      
      if (storedPassword.isEmpty || storedPassword != trimmedPassword) {
        return 'Invalid password. Please try again';
      }

      return 'Authentication failed';
    } catch (e) {
      return 'System error: Unable to verify credentials';
    }
  }

  // ==================== ADMIN MANAGEMENT ====================

  /// Get all admin users
  static Future<List<Admin>> getAllAdmins({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('admins')
          .select()
          .order('name', ascending: true)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((e) => Admin.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get admins by accounting office
  static Future<List<Admin>> getAdminsByOffice({
    required String accountingOffice,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('admins')
          .select()
          .eq('accountingOffice', accountingOffice)
          .order('name', ascending: true)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((e) => Admin.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Create a new admin user
  static Future<Admin?> createAdmin({
    required String id,
    required String name,
    required String email,
    required String password,
    required String role,
    required String accountingOffice,
  }) async {
    try {
      final response = await client
          .from('admins')
          .insert({
            'id': id,
            'name': name,
            'email': email,
            'password': password, // In production, this should be hashed!
            'role': role,
            'accountingOffice': accountingOffice,
            'isActive': true,
            'createdAt': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Admin.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Update admin user
  static Future<bool> updateAdmin({
    required String adminId,
    String? name,
    String? email,
    String? role,
    String? accountingOffice,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (role != null) updateData['role'] = role;
      if (accountingOffice != null)
        updateData['accountingOffice'] = accountingOffice;
      if (isActive != null) updateData['isActive'] = isActive;

      await client.from('admins').update(updateData).eq('id', adminId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Deactivate admin user
  static Future<bool> deactivateAdmin(String adminId) async {
    try {
      await client.from('admins').update({'isActive': false}).eq('id', adminId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete admin user
  static Future<bool> deleteAdmin(String adminId) async {
    try {
      await client.from('admins').delete().eq('id', adminId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Change admin password
  static Future<bool> changeAdminPassword({
    required String adminId,
    required String newPassword,
  }) async {
    try {
      await client
          .from('admins')
          .update({'password': newPassword})
          .eq('id', adminId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Search admins by name or email
  static Future<List<Admin>> searchAdmins({
    required String query,
    int limit = 50,
  }) async {
    try {
      final response = await client
          .from('admins')
          .select()
          .or('name.ilike.%$query%,email.ilike.%$query%')
          .limit(limit);

      return (response as List)
          .map((e) => Admin.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
