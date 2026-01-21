import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationHistory {
  final String id;
  final String pensionerId;
  final DateTime date;
  final String accountingOffice;
  final String method;
  final String status; // pending, approved, rejected
  final String? selfieUrl;
  final String? nidFrontUrl;
  final String? nidBackUrl;
  final Map<String, dynamic>? locationData;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? notes;

  VerificationHistory({
    this.id = '',
    this.pensionerId = '',
    required this.date,
    required this.accountingOffice,
    required this.method,
    this.status = 'pending',
    this.selfieUrl,
    this.nidFrontUrl,
    this.nidBackUrl,
    this.locationData,
    this.reviewedAt,
    this.reviewedBy,
    this.notes,
  });

  factory VerificationHistory.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    return VerificationHistory(
      id: docId,
      pensionerId: json['pensionerId'] ?? '',
      date: _parseDate(json['submittedAt'] ?? json['date']),
      accountingOffice: json['accountingOffice'] ?? '',
      method: json['method'] ?? 'App',
      status: json['status'] ?? 'pending',
      selfieUrl: json['selfieUrl'],
      nidFrontUrl: json['nidFrontUrl'],
      nidBackUrl: json['nidBackUrl'],
      locationData: json['locationData'],
      reviewedAt: _parseNullableDate(json['reviewedAt']),
      reviewedBy: json['reviewedBy'],
      notes: json['notes'],
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory VerificationHistory.fromJson(Map<String, dynamic> json) {
    return VerificationHistory(
      id: json['id'] ?? '',
      pensionerId: json['pensionerId'] ?? '',
      date: DateTime.parse(json['date']),
      accountingOffice: json['accountingOffice'] ?? '',
      method: json['method'] ?? '',
      status: json['status'] ?? 'pending',
      selfieUrl: json['selfieUrl'],
      nidFrontUrl: json['nidFrontUrl'],
      nidBackUrl: json['nidBackUrl'],
      locationData: json['locationData'],
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      reviewedBy: json['reviewedBy'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pensionerId': pensionerId,
      'date': date.toIso8601String(),
      'accountingOffice': accountingOffice,
      'method': method,
      'status': status,
      'selfieUrl': selfieUrl,
      'nidFrontUrl': nidFrontUrl,
      'nidBackUrl': nidBackUrl,
      'locationData': locationData,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'notes': notes,
    };
  }
}
