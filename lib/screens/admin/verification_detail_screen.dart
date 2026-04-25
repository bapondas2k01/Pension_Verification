import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/verification_request.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';
import 'verification_review_form.dart';

class VerificationDetailScreen extends StatefulWidget {
  final VerificationRequest verification;

  const VerificationDetailScreen({super.key, required this.verification});

  @override
  State<VerificationDetailScreen> createState() =>
      _VerificationDetailScreenState();
}

class _VerificationDetailScreenState extends State<VerificationDetailScreen> {
  late TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.verification.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Details'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pensioner Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pensioner Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Name (Bangla):',
                      widget.verification.pensionerName,
                    ),
                    _buildInfoRow(
                      'Name (English):',
                      widget.verification.pensionerEn,
                    ),
                    _buildInfoRow('NID:', widget.verification.nid),
                    _buildInfoRow('EPPO:', widget.verification.eppoNumber),
                    _buildInfoRow(
                      'Method:',
                      widget.verification.method
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Submission Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submission Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Submitted At:',
                      _formatDateTime(widget.verification.submittedAt),
                    ),
                    _buildInfoRow(
                      'Status:',
                      widget.verification.status
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                      statusColor: _getStatusColor(widget.verification.status),
                    ),
                    if (widget.verification.reviewedAt != null)
                      _buildInfoRow(
                        'Reviewed At:',
                        _formatDateTime(widget.verification.reviewedAt!),
                      ),
                    if (widget.verification.reviewedBy != null)
                      _buildInfoRow(
                        'Reviewed By:',
                        widget.verification.reviewedBy ?? 'N/A',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Documents Card
            if (widget.verification.selfieUrl != null ||
                widget.verification.nidFrontUrl != null ||
                widget.verification.nidBackUrl != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submitted Documents',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.verification.selfieUrl != null)
                        _buildDocumentPreview(
                          'Selfie Photo',
                          widget.verification.selfieUrl!,
                        ),
                      if (widget.verification.nidFrontUrl != null)
                        _buildDocumentPreview(
                          'NID (Front)',
                          widget.verification.nidFrontUrl!,
                        ),
                      if (widget.verification.nidBackUrl != null)
                        _buildDocumentPreview(
                          'NID (Back)',
                          widget.verification.nidBackUrl!,
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Location Data (if available)
            if (widget.verification.locationData != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Latitude:',
                        widget.verification.locationData?['latitude']
                                ?.toString() ??
                            'N/A',
                      ),
                      _buildInfoRow(
                        'Longitude:',
                        widget.verification.locationData?['longitude']
                                ?.toString() ??
                            'N/A',
                      ),
                      _buildInfoRow(
                        'Address:',
                        widget.verification.locationData?['address'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Notes Section
            if (widget.verification.status == 'pending' ||
                widget.verification.status == 'under_review')
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Notes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add notes about this verification...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (widget.verification.notes != null &&
                widget.verification.notes!.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Notes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.verification.notes!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Action Buttons
            if (widget.verification.status == 'pending' ||
                widget.verification.status == 'under_review')
              _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGrey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: statusColor != null
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(String title, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppTheme.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 40),
                    SizedBox(height: 8),
                    Text('Image not available'),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => _showRejectDialog(context),
                icon: const Icon(Icons.close),
                label: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => _markAsUnderReview(context),
                icon: const Icon(Icons.hourglass_bottom),
                label: const Text('Under Review'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting
                ? null
                : () => _approveVerification(context),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle),
            label: Text(_isSubmitting ? 'Processing...' : 'Approve'),
          ),
        ),
      ],
    );
  }

  Future<void> _approveVerification(BuildContext context) async {
    setState(() => _isSubmitting = true);

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.approveVerification(
      verificationId: widget.verification.id,
      notes: _notesController.text,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to approve verification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsUnderReview(BuildContext context) async {
    setState(() => _isSubmitting = true);

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.markUnderReview(widget.verification.id);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as under review'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final reasonController = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Verification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please provide a reason for rejection:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Reason for rejection...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason')),
                  );
                  return;
                }

                Navigator.pop(context);
                await _rejectVerification(context, reasonController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _rejectVerification(BuildContext context, String reason) async {
    setState(() => _isSubmitting = true);

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.rejectVerification(
      verificationId: widget.verification.id,
      reason: reason,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification rejected'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject verification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return AppTheme.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
