import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  /// Update pensioner in the correct table based on NID length
  static Future<bool> updatePensionerAuto(
    String nid,
    Map<String, dynamic> data,
  ) async {
    String table;
    if (nid.length == 10) {
      table = 'pensioners_nid10';
    } else if (nid.length == 17) {
      table = 'pensioners_nid17';
    } else {
      return false;
    }
    final response = await client.from(table).update(data).eq('nid', nid);
    return response != null;
  }

  /// Returns pensioner from the correct table based on NID length (10 or 17 digits)
  static Future<Map<String, dynamic>?> getPensionerByNidAuto(String nid) async {
    String table;
    if (nid.length == 10) {
      table = 'pensioners_nid10';
    } else if (nid.length == 17) {
      table = 'pensioners_nid17';
    } else {
      return null; // Invalid NID length
    }
    final response = await client
        .from(table)
        .select()
        .eq('nid', nid)
        .limit(1)
        .single();
    return response;
  }

  static final SupabaseClient client = Supabase.instance.client;

  // ==================== PENSIONER OPERATIONS ====================

  /// Get pensioner by NID and EPPO number (for login/verification)
  static Future<Map<String, dynamic>?> getPensionerByNidAndEppo(
    String nid,
    String eppoNumber,
  ) async {
    String table;
    if (nid.length == 10) {
      table = 'pensioners_nid10';
    } else if (nid.length == 17) {
      table = 'pensioners_nid17';
    } else {
      return null; // Invalid NID length
    }
    final response = await client
        .from(table)
        .select()
        .eq('nid', nid)
        .eq('eppoNumber', eppoNumber)
        .limit(1)
        .single();
    return response;
  }

  // ==================== VERIFICATION OPERATIONS ====================

  static Future<String?> submitVerification({
    required String pensionerId,
    required String nid,
    required String eppoNumber,
    required String selfieUrl,
    required Map<String, dynamic> locationData,
    String? nidFrontUrl,
    String? nidBackUrl,
  }) async {
    final response = await client
        .from('verifications')
        .insert({
          'pensionerId': pensionerId,
          'nid': nid,
          'eppoNumber': eppoNumber,
          'selfieUrl': selfieUrl,
          'nidFrontUrl': nidFrontUrl,
          'nidBackUrl': nidBackUrl,
          'locationData': locationData,
          'status': 'pending',
          'submittedAt': DateTime.now().toIso8601String(),
          'reviewedAt': null,
          'reviewedBy': null,
          'notes': null,
        })
        .select()
        .single();
    return response['id'];
  }

  static Future<List<Map<String, dynamic>>> getVerificationHistory(
    String pensionerId,
  ) async {
    final response = await client
        .from('verifications')
        .select()
        .eq('pensionerId', pensionerId)
        .order('submittedAt', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> getLatestVerification(
    String pensionerId,
  ) async {
    final response = await client
        .from('verifications')
        .select()
        .eq('pensionerId', pensionerId)
        .order('submittedAt', ascending: false)
        .limit(1)
        .single();
    return response;
  }

  // ==================== STORAGE OPERATIONS ====================

  static Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String path,
  }) async {
    final result = await client.storage
        .from('images')
        .uploadBinary(path, imageBytes);
    // uploadBinary returns the path as a String if successful, or throws on error
    if (result != null && result is String) {
      final url = client.storage.from('images').getPublicUrl(path);
      return url;
    }
  }

  static Future<String?> uploadVerificationSelfie({
    required String pensionerId,
    required Uint8List imageBytes,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return uploadImage(
      imageBytes: imageBytes,
      path: 'verifications/$pensionerId/selfie_$timestamp.jpg',
    );
  }

  static Future<String?> uploadNidImage({
    required String pensionerId,
    required Uint8List imageBytes,
    required bool isFront,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final side = isFront ? 'front' : 'back';
    return uploadImage(
      imageBytes: imageBytes,
      path: 'verifications/$pensionerId/nid_${side}_$timestamp.jpg',
    );
  }

  static Future<bool> needsVerification(String pensionerId) async {
    final latest = await getLatestVerification(pensionerId);
    if (latest == null) return true;
    final submittedAt = latest['submittedAt'];
    if (submittedAt == null) return true;
    final lastDate = DateTime.tryParse(submittedAt);
    if (lastDate == null) return true;
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return lastDate.isBefore(sixMonthsAgo);
  }
}
