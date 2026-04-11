import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // ==================== PENSIONER OPERATIONS ====================

  static Future<Map<String, dynamic>?> getPensionerByNid(String nid) async {
    final response = await client
        .from('pensioners')
        .select()
        .eq('nid', nid)
        .limit(1)
        .single();
    return response;
  }

  static Future<Map<String, dynamic>?> getPensionerByEppo(String eppo) async {
    final response = await client
        .from('pensioners')
        .select()
        .eq('eppoNumber', eppo)
        .limit(1)
        .single();
    return response;
  }

  static Future<Map<String, dynamic>?> getPensionerById(String id) async {
    final response = await client
        .from('pensioners')
        .select()
        .eq('id', id)
        .limit(1)
        .single();
    return response;
  }

  static Future<bool> verifyPensionerPin(String pensionerId, String pin) async {
    final response = await client
        .from('pensioners')
        .select('pin')
        .eq('id', pensionerId)
        .single();
    return response != null && response['pin'] == pin;
  }

  static Future<bool> updatePensioner(
    String pensionerId,
    Map<String, dynamic> data,
  ) async {
    final response = await client
        .from('pensioners')
        .update(data)
        .eq('id', pensionerId);
    return response != null;
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
