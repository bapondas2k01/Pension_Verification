class VerificationRequest {
  final String id;
  final String pensionerId;
  final String pensionerName;
  final String pensionerEn;
  final String eppoNumber;
  final String nid;
  final DateTime submittedAt;
  final String status; // pending, under_review, approved, rejected
  final String? selfieUrl;
  final String? nidFrontUrl;
  final String? nidBackUrl;
  final Map<String, dynamic>? locationData;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? notes;
  final String method; // app, field_visit, office

  VerificationRequest({
    required this.id,
    required this.pensionerId,
    required this.pensionerName,
    required this.pensionerEn,
    required this.eppoNumber,
    required this.nid,
    required this.submittedAt,
    this.status = 'pending',
    this.selfieUrl,
    this.nidFrontUrl,
    this.nidBackUrl,
    this.locationData,
    this.reviewedAt,
    this.reviewedBy,
    this.notes,
    this.method = 'app',
  });

  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      id: json['id'] ?? '',
      pensionerId: json['pensionerId'] ?? '',
      pensionerName: json['pensionerName'] ?? '',
      pensionerEn: json['pensionerEn'] ?? '',
      eppoNumber: json['eppoNumber'] ?? '',
      nid: json['nid'] ?? '',
      submittedAt:
          DateTime.tryParse(json['submittedAt'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'pending',
      selfieUrl: json['selfieUrl'],
      nidFrontUrl: json['nidFrontUrl'],
      nidBackUrl: json['nidBackUrl'],
      locationData: json['locationData'],
      reviewedAt:
          json['reviewedAt'] != null ? DateTime.tryParse(json['reviewedAt']) : null,
      reviewedBy: json['reviewedBy'],
      notes: json['notes'],
      method: json['method'] ?? 'app',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pensionerId': pensionerId,
      'pensionerName': pensionerName,
      'pensionerEn': pensionerEn,
      'eppoNumber': eppoNumber,
      'nid': nid,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status,
      'selfieUrl': selfieUrl,
      'nidFrontUrl': nidFrontUrl,
      'nidBackUrl': nidBackUrl,
      'locationData': locationData,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'notes': notes,
      'method': method,
    };
  }
}
