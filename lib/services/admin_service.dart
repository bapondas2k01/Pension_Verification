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
      var pensionerQuery = client.from('pensioners').select('id');
      if (accountingOffice != null) {
        pensionerQuery = pensionerQuery.eq(
          'accountingOffice',
          accountingOffice,
        );
      }
      final pensionerCount = (await pensionerQuery).length;

      var verificationQuery = client
          .from('verifications')
          .select('id')
          .eq('status', 'pending');
      if (accountingOffice != null) {
        verificationQuery = verificationQuery.eq(
          'accountingOffice',
          accountingOffice,
        );
      }
      final pendingCount = (await verificationQuery).length;

      var approvedQuery = client
          .from('verifications')
          .select('id')
          .eq('status', 'approved');
      if (accountingOffice != null) {
        approvedQuery = approvedQuery.eq('accountingOffice', accountingOffice);
      }
      final approvedCount = (await approvedQuery).length;

      return {
        'totalPensioners': pensionerCount,
        'pendingVerifications': pendingCount,
        'approvedVerifications': approvedCount,
        'pendingPercentage': pensionerCount > 0
            ? (pendingCount / pensionerCount * 100).toStringAsFixed(2)
            : '0.0',
      };
    } catch (e) {
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
}
