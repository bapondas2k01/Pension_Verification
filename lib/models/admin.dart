class Admin {
  final String id;
  final String name;
  final String email;
  final String role; // admin, accountant, reviewer
  final String accountingOffice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accountingOffice,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'accountant',
      accountingOffice: json['accountingOffice'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'accountingOffice': accountingOffice,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}
