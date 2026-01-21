// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class Pensioner {
  final String id; // Firestore document ID
  final String name;
  final String nameEn;
  final String nid; // 17-digit NID
  final String eppoNumber; // 10-digit EPPO number
  final String ppoNumber; // PPO number
  final String pin; // 4-digit PIN for login
  final DateTime birthDate;
  final DateTime pensionStartDate;
  final double netPensionAtStart;
  final double monthlyAmount;
  final String photoUrl;
  final String accountingOffice;
  final String phone;
  final String email;
  final String address;
  final String pensionType;
  final DateTime? lastVerificationDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pensioner({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nid,
    required this.eppoNumber,
    required this.ppoNumber,
    required this.pin,
    required this.birthDate,
    required this.pensionStartDate,
    required this.netPensionAtStart,
    required this.monthlyAmount,
    required this.photoUrl,
    required this.accountingOffice,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.pensionType = 'Government',
    this.lastVerificationDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Pensioner.fromFirestore(Map<String, dynamic> json, String docId) {
    return Pensioner(
      id: docId,
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      nid: json['nid'] ?? '',
      eppoNumber: json['eppoNumber'] ?? '',
      ppoNumber: json['ppoNumber'] ?? json['ppoNumber'] ?? '',
      pin: json['pin'] ?? '',
      birthDate: _parseDate(json['birthDate']),
      pensionStartDate: _parseDate(json['pensionStartDate']),
      netPensionAtStart: (json['netPensionAtStart'] ?? 0).toDouble(),
      monthlyAmount: (json['monthlyAmount'] ?? 0).toDouble(),
      photoUrl: json['photoUrl'] ?? '',
      accountingOffice: json['accountingOffice'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      pensionType: json['pensionType'] ?? 'Government',
      lastVerificationDate: _parseNullableDate(json['lastVerificationDate']),
      createdAt: _parseNullableDate(json['createdAt']),
      updatedAt: _parseNullableDate(json['updatedAt']),
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

  factory Pensioner.fromJson(Map<String, dynamic> json) {
    return Pensioner(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      nid: json['nid'] ?? '',
      eppoNumber: json['eppoNumber'] ?? '',
      ppoNumber: json['ppoNumber'] ?? '',
      pin: json['pin'] ?? '',
      birthDate: DateTime.parse(json['birthDate']),
      pensionStartDate: DateTime.parse(json['pensionStartDate']),
      netPensionAtStart: (json['netPensionAtStart'] ?? 0).toDouble(),
      monthlyAmount: (json['monthlyAmount'] ?? 0).toDouble(),
      photoUrl: json['photoUrl'] ?? '',
      accountingOffice: json['accountingOffice'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      pensionType: json['pensionType'] ?? 'Government',
      lastVerificationDate: json['lastVerificationDate'] != null
          ? DateTime.parse(json['lastVerificationDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'nid': nid,
      'eppoNumber': eppoNumber,
      'ppoNumber': ppoNumber,
      'pin': pin,
      'birthDate': birthDate.toIso8601String(),
      'pensionStartDate': pensionStartDate.toIso8601String(),
      'netPensionAtStart': netPensionAtStart,
      'monthlyAmount': monthlyAmount,
      'photoUrl': photoUrl,
      'accountingOffice': accountingOffice,
      'phone': phone,
      'email': email,
      'address': address,
      'pensionType': pensionType,
      'lastVerificationDate': lastVerificationDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Pensioner copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? nid,
    String? eppoNumber,
    String? ppoNumber,
    String? pin,
    DateTime? birthDate,
    DateTime? pensionStartDate,
    double? netPensionAtStart,
    double? monthlyAmount,
    String? photoUrl,
    String? accountingOffice,
    String? phone,
    String? email,
    String? address,
    String? pensionType,
    DateTime? lastVerificationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pensioner(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      nid: nid ?? this.nid,
      eppoNumber: eppoNumber ?? this.eppoNumber,
      ppoNumber: ppoNumber ?? this.ppoNumber,
      pin: pin ?? this.pin,
      birthDate: birthDate ?? this.birthDate,
      pensionStartDate: pensionStartDate ?? this.pensionStartDate,
      netPensionAtStart: netPensionAtStart ?? this.netPensionAtStart,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      photoUrl: photoUrl ?? this.photoUrl,
      accountingOffice: accountingOffice ?? this.accountingOffice,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      pensionType: pensionType ?? this.pensionType,
      lastVerificationDate: lastVerificationDate ?? this.lastVerificationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
