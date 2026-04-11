import 'package:flutter/foundation.dart';
import '../models/verification_request.dart';
import '../models/admin.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  Admin? _currentAdmin;
  List<VerificationRequest> _pendingVerifications = [];
  List<VerificationRequest> _allVerifications = [];
  List<Map<String, dynamic>> _pensioners = [];
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  final int itemsPerPage = 10;

  // Getters
  Admin? get currentAdmin => _currentAdmin;
  List<VerificationRequest> get pendingVerifications => _pendingVerifications;
  List<VerificationRequest> get allVerifications => _allVerifications;
  List<Map<String, dynamic>> get pensioners => _pensioners;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;

  // ==================== INITIALIZATION ====================

  Future<void> setCurrentAdmin(Admin admin) async {
    _currentAdmin = admin;
    await AdminService.updateAdminLastLogin(admin.id);
    await loadDashboardStats();
    notifyListeners();
  }

  // ==================== VERIFICATION REQUESTS ====================

  Future<void> loadPendingVerifications({String? accountingOffice}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingVerifications = await AdminService.getPendingVerifications(
        accountingOffice:
            accountingOffice ?? _currentAdmin?.accountingOffice,
        limit: itemsPerPage,
        offset: _currentPage * itemsPerPage,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllVerifications({
    String? status,
    String? accountingOffice,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allVerifications = await AdminService.getVerifications(
        status: status,
        accountingOffice: accountingOffice ?? _currentAdmin?.accountingOffice,
        startDate: startDate,
        endDate: endDate,
        limit: itemsPerPage,
        offset: _currentPage * itemsPerPage,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveVerification({
    required String verificationId,
    String? notes,
  }) async {
    try {
      final success = await AdminService.approveVerification(
        verificationId: verificationId,
        adminId: _currentAdmin!.id,
        notes: notes,
      );

      if (success) {
        // Remove from pending list
        _pendingVerifications
            .removeWhere((v) => v.id == verificationId);
        await loadDashboardStats();
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectVerification({
    required String verificationId,
    required String reason,
  }) async {
    try {
      final success = await AdminService.rejectVerification(
        verificationId: verificationId,
        adminId: _currentAdmin!.id,
        reason: reason,
      );

      if (success) {
        _pendingVerifications
            .removeWhere((v) => v.id == verificationId);
        await loadDashboardStats();
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markUnderReview(String verificationId) async {
    try {
      final success = await AdminService.markUnderReview(
        verificationId: verificationId,
        adminId: _currentAdmin!.id,
      );

      if (success) {
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== PENSIONER MANAGEMENT ====================

  Future<void> loadPensioners({String? searchQuery}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pensioners = await AdminService.getAllPensioners(
        searchQuery: searchQuery,
        limit: itemsPerPage,
        offset: _currentPage * itemsPerPage,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPensionersByOffice(String accountingOffice) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pensioners = await AdminService.getPensionersByOffice(
        accountingOffice: accountingOffice,
        limit: itemsPerPage,
        offset: _currentPage * itemsPerPage,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markPensionerAsAlive(String pensionerId) async {
    try {
      final success = await AdminService.markPensionerAsAlive(
        pensionerId: pensionerId,
        adminId: _currentAdmin!.id,
      );

      if (success) {
        await loadDashboardStats();
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>>
      getPensionerVerificationHistory(String pensionerId) async {
    try {
      return await AdminService.getPensionerVerificationHistory(
        pensionerId: pensionerId,
      );
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  // ==================== DASHBOARD & STATISTICS ====================

  Future<void> loadDashboardStats() async {
    try {
      _dashboardStats = await AdminService.getAdminDashboardStats(
        _currentAdmin?.accountingOffice,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getVerificationStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await AdminService.getVerificationStats(
        accountingOffice: _currentAdmin?.accountingOffice,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
      return {};
    }
  }

  // ==================== PAGINATION ====================

  void nextPage() {
    _currentPage++;
    notifyListeners();
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void resetPage() {
    _currentPage = 0;
    notifyListeners();
  }

  // ==================== ERROR HANDLING ====================

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
