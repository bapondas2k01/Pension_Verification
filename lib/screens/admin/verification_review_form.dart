import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/verification_request.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';

class VerificationReviewForm extends StatefulWidget {
  final VerificationRequest verification;
  final Function(String action, String? reason, String? notes) onSubmit;

  const VerificationReviewForm({
    super.key,
    required this.verification,
    required this.onSubmit,
  });

  @override
  State<VerificationReviewForm> createState() => _VerificationReviewFormState();
}

class _VerificationReviewFormState extends State<VerificationReviewForm> {
  late TextEditingController _notesController;
  late TextEditingController _reasonController;
  String _reviewAction = 'approve'; // approve, reject, under_review
  String _rejectionReason = '';
  bool _isSelfieVerified = false;
  bool _isNIDVerified = false;
  bool _isLocationVerified = false;
  bool _isBiometricMatch = false;
  bool _isProcessing = false;

  final List<String> _rejectionReasons = [
    'Blurry selfie photo',
    'Unclear NID document',
    'Location mismatch',
    'Biometric mismatch',
    'NID expired',
    'Suspicious activity',
    'Incomplete information',
    'Other (please specify)',
  ];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.verification.notes ?? '',
    );
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Verification Review Form',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Pensioner: ${widget.verification.pensionerName} (${widget.verification.nid})',
            style: const TextStyle(fontSize: 12, color: AppTheme.darkGrey),
          ),
          const SizedBox(height: 24),

          // Review Checklist
          _buildChecklistSection(),
          const SizedBox(height: 24),

          // Action Selection
          _buildActionSelection(),
          const SizedBox(height: 24),

          // Rejection Reason (if rejecting)
          if (_reviewAction == 'reject') _buildRejectionReasonSection(),
          const SizedBox(height: 24),

          // Admin Notes
          _buildNotesSection(),
          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildChecklistSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification Checklist',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildChecklistItem(
              'Selfie Photo Verified',
              _isSelfieVerified,
              (value) => setState(() => _isSelfieVerified = value ?? false),
              'Confirm selfie is clear and matches NID photo',
            ),
            _buildChecklistItem(
              'NID Document Verified',
              _isNIDVerified,
              (value) => setState(() => _isNIDVerified = value ?? false),
              'Confirm NID front and back are clear and readable',
            ),
            _buildChecklistItem(
              'Location Verified',
              _isLocationVerified,
              (value) => setState(() => _isLocationVerified = value ?? false),
              'Confirm location data is valid and matches record',
            ),
            _buildChecklistItem(
              'Biometric Match',
              _isBiometricMatch,
              (value) => setState(() => _isBiometricMatch = value ?? false),
              'Confirm facial recognition match is successful',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(
    String title,
    bool value,
    Function(bool?) onChanged,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              hint,
              style: const TextStyle(fontSize: 11, color: AppTheme.darkGrey),
            ),
            value: value,
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSelection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review Decision',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionRadio(
              'approve',
              'Approve',
              'Approve this verification',
              Icons.check_circle,
              Colors.green,
            ),
            _buildActionRadio(
              'under_review',
              'Under Review',
              'Mark for further review',
              Icons.hourglass_bottom,
              Colors.orange,
            ),
            _buildActionRadio(
              'reject',
              'Reject',
              'Reject this verification',
              Icons.cancel,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRadio(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _reviewAction == value ? color : Colors.grey[300]!,
            width: _reviewAction == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _reviewAction == value ? color.withOpacity(0.05) : null,
        ),
        child: RadioListTile<String>(
          value: value,
          groupValue: _reviewAction,
          onChanged: (val) => setState(() => _reviewAction = val ?? 'approve'),
          dense: true,
          contentPadding: const EdgeInsets.all(8),
          title: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRejectionReasonSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rejection Reason',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _rejectionReason.isEmpty ? null : _rejectionReason,
              items: _rejectionReasons
                  .map(
                    (reason) =>
                        DropdownMenuItem(value: reason, child: Text(reason)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _rejectionReason = value ?? '');
                if (value != 'Other (please specify)') {
                  _reasonController.clear();
                }
              },
              decoration: InputDecoration(
                labelText: 'Select rejection reason',
                hintText: 'Choose a reason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.info_outline),
              ),
            ),
            if (_rejectionReason == 'Other (please specify)')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  controller: _reasonController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Please specify the reason',
                    hintText: 'Enter detailed reason...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Notes (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Add any additional notes about this verification review...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'These notes will be visible to other admins',
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isProcessing ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getActionColor(_reviewAction),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _reviewAction == 'approve'
                        ? 'Approve'
                        : _reviewAction == 'reject'
                        ? 'Reject'
                        : 'Mark Under Review',
                  ),
          ),
        ),
      ],
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'approve':
        return Colors.green;
      case 'reject':
        return Colors.red;
      case 'under_review':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _submitReview() {
    // Validate
    if (_reviewAction == 'reject' && _rejectionReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rejection reason'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_reviewAction == 'approve') {
      // Check if all verifications are done
      if (!_isSelfieVerified ||
          !_isNIDVerified ||
          !_isLocationVerified ||
          !_isBiometricMatch) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Incomplete Checklist'),
            content: const Text(
              'Please verify all items in the checklist before approving.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    final reason = _reviewAction == 'reject'
        ? (_rejectionReason == 'Other (please specify)'
              ? _reasonController.text
              : _rejectionReason)
        : null;

    widget.onSubmit(_reviewAction, reason, _notesController.text);
  }
}
