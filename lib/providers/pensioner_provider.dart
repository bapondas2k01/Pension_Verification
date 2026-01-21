import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../models/pensioner.dart';
import '../models/verification_history.dart';
import '../models/payment_info.dart';
import '../models/fixation_info.dart';
import '../services/supabase_service.dart';

class PensionerProvider extends ChangeNotifier {
  Pensioner? _currentPensioner;
  List<VerificationHistory> _verificationHistory = [];
  List<PaymentInfo> _paymentHistory = [];
  List<FixationInfo> _fixationHistory = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastVerificationDate;
  bool _isVerified = false;

  Pensioner? get currentPensioner => _currentPensioner;
  List<VerificationHistory> get verificationHistory => _verificationHistory;
  List<PaymentInfo> get paymentHistory => _paymentHistory;
  List<FixationInfo> get fixationHistory => _fixationHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentPensioner != null;
  DateTime? get lastVerificationDate => _lastVerificationDate;
  bool get isVerified => _isVerified;

  /// Login using NID and EPPONumber only
  Future<bool> loginWithNidAndEppo(String nid, String eppoNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pensionerData = await SupabaseService.getPensionerByNidAndEppo(
        nid,
        eppoNumber,
      );
      _isLoading = false;

      if (pensionerData != null) {
        _currentPensioner = Pensioner.fromFirestore(
          pensionerData,
          pensionerData['id'],
        );
        await _loadVerificationHistory();
        _loadMockPaymentData();
        notifyListeners();
        return true;
      } else {
        _error = 'No pensioner found with this NID and EPPO number';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load verification history from Supabase
  Future<void> _loadVerificationHistory() async {
    if (_currentPensioner == null) return;

    try {
      final historyData = await SupabaseService.getVerificationHistory(
        _currentPensioner!.id,
      );

      _verificationHistory = historyData.map((data) {
        return VerificationHistory.fromFirestore(data, data['id']);
      }).toList();

      // Set verification status based on history
      if (_verificationHistory.isNotEmpty) {
        _lastVerificationDate = _verificationHistory.first.date;
        // Consider verified if last verification was within 6 months
        _isVerified =
            DateTime.now().difference(_lastVerificationDate!).inDays < 180;
      } else {
        _lastVerificationDate = null;
        _isVerified = false;
      }
    } catch (e) {
      debugPrint('Error loading verification history: $e');
    }
  }

  void _loadMockPaymentData() {
    // Mock payment history (can be replaced with Supabase later)
    _paymentHistory = [
      PaymentInfo(fiscalYear: '2025-2026', months: _generateMonthlyPayments()),
      PaymentInfo(fiscalYear: '2024-2025', months: _generateMonthlyPayments()),
      PaymentInfo(fiscalYear: '2023-2024', months: _generateMonthlyPayments()),
    ];

    // Mock fixation history
    _fixationHistory = [
      FixationInfo(
        date: _currentPensioner?.pensionStartDate ?? DateTime(1996, 10, 17),
        amount: _currentPensioner?.netPensionAtStart ?? 1328.00,
        remarks: 'Initial Fixation',
      ),
    ];
  }

  List<MonthlyPayment> _generateMonthlyPayments() {
    final amount = _currentPensioner?.monthlyAmount ?? 15000.00;
    return [
      MonthlyPayment(month: 'July', amount: amount),
      MonthlyPayment(month: 'August', amount: amount),
      MonthlyPayment(month: 'September', amount: amount),
      MonthlyPayment(month: 'October', amount: amount),
      MonthlyPayment(month: 'November', amount: amount),
      MonthlyPayment(month: 'December', amount: amount),
    ];
  }

  void updatePensionerPhoto(String photoPath) {
    if (_currentPensioner != null) {
      _currentPensioner = _currentPensioner!.copyWith(photoUrl: photoPath);
      notifyListeners();
    }
  }

  /// Perform life verification with Supabase
  Future<bool> performLifeVerification({
    Uint8List? selfieBytes,
    Map<String, dynamic>? locationData,
  }) async {
    if (_currentPensioner == null) {
      _error = 'No pensioner logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      String? selfieUrl;

      // Upload selfie if provided
      if (selfieBytes != null) {
        selfieUrl = await SupabaseService.uploadVerificationSelfie(
          pensionerId: _currentPensioner!.id,
          imageBytes: selfieBytes,
        );
      }

      // Submit verification to Supabase
      final verificationId = await SupabaseService.submitVerification(
        pensionerId: _currentPensioner!.id,
        nid: _currentPensioner!.nid,
        eppoNumber: _currentPensioner!.eppoNumber,
        selfieUrl: selfieUrl ?? '',
        locationData: locationData ?? {},
      );

      if (verificationId != null) {
        // Add new verification to local history
        _verificationHistory.insert(
          0,
          VerificationHistory(
            id: verificationId,
            pensionerId: _currentPensioner!.id,
            date: DateTime.now(),
            accountingOffice: _currentPensioner!.accountingOffice,
            method: 'App',
            status: 'pending',
            selfieUrl: selfieUrl,
            locationData: locationData,
          ),
        );

        // Update verification status
        _lastVerificationDate = DateTime.now();
        _isVerified = true;

        // Update pensioner's last verification date in Supabase
        await SupabaseService.updatePensionerAuto(_currentPensioner!.nid, {
          'lastVerificationDate': DateTime.now(),
        });

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to submit verification';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check if pensioner needs verification
  Future<bool> checkNeedsVerification() async {
    if (_currentPensioner == null) return true;

    return await SupabaseService.needsVerification(_currentPensioner!.id);
  }

  void logout() {
    _currentPensioner = null;
    _verificationHistory = [];
    _paymentHistory = [];
    _fixationHistory = [];
    _lastVerificationDate = null;
    _isVerified = false;
    _error = null;
    notifyListeners();
  }
}
