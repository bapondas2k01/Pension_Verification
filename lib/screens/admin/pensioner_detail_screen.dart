import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';

class PensionerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pensioner;

  const PensionerDetailScreen({
    super.key,
    required this.pensioner,
  });

  @override
  State<PensionerDetailScreen> createState() => _PensionerDetailScreenState();
}

class _PensionerDetailScreenState extends State<PensionerDetailScreen> {
  List<Map<String, dynamic>> _verificationHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVerificationHistory();
  }

  Future<void> _loadVerificationHistory() async {
    setState(() => _isLoading = true);
    final adminProvider = context.read<AdminProvider>();
    _verificationHistory = await adminProvider.getPensionerVerificationHistory(
      widget.pensioner['id'],
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final lastVerified = widget.pensioner['lastVerificationDate'] != null
        ? DateTime.tryParse(widget.pensioner['lastVerificationDate'])
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pensioner Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Basic Information',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: lastVerified != null &&
                                    DateTime.now()
                                            .difference(lastVerified)
                                            .inDays <=
                                        180
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lastVerified != null &&
                                    DateTime.now()
                                            .difference(lastVerified)
                                            .inDays <=
                                        180
                                ? 'ALIVE'
                                : 'PENDING',
                            style: TextStyle(
                              color: lastVerified != null &&
                                      DateTime.now()
                                              .difference(lastVerified)
                                              .inDays <=
                                          180
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Name (Bangla):', widget.pensioner['name'] ?? 'N/A'),
                    _buildInfoRow(
                      'Name (English):',
                      widget.pensioner['nameEn'] ?? 'N/A',
                    ),
                    _buildInfoRow('NID:', widget.pensioner['nid'] ?? 'N/A'),
                    _buildInfoRow(
                      'EPPO Number:',
                      widget.pensioner['eppoNumber'] ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'PPO Number:',
                      widget.pensioner['ppoNumber'] ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Accounting Office:',
                      widget.pensioner['accountingOffice'] ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pension Information Card
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
                      'Pension Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Pension Type:',
                      widget.pensioner['pensionType'] ?? 'Government',
                    ),
                    _buildInfoRow(
                      'Birth Date:',
                      widget.pensioner['birthDate'] != null
                          ? _formatDate(
                              DateTime.tryParse(
                                widget.pensioner['birthDate'],
                              ) ??
                                  DateTime.now())
                          : 'N/A',
                    ),
                    _buildInfoRow(
                      'Pension Start Date:',
                      widget.pensioner['pensionStartDate'] != null
                          ? _formatDate(
                              DateTime.tryParse(
                                widget.pensioner['pensionStartDate'],
                              ) ??
                                  DateTime.now())
                          : 'N/A',
                    ),
                    _buildInfoRow(
                      'Monthly Amount:',
                      widget.pensioner['monthlyAmount']?.toString() ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Net Pension at Start:',
                      widget.pensioner['netPensionAtStart']?.toString() ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Information Card
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
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Phone:', widget.pensioner['phone'] ?? 'N/A'),
                    _buildInfoRow('Email:', widget.pensioner['email'] ?? 'N/A'),
                    _buildInfoRow(
                      'Address:',
                      widget.pensioner['address'] ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Verification Status Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Verification Status',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (lastVerified != null)
                          ElevatedButton.icon(
                            onPressed: () => _markAsAlive(),
                            icon: const Icon(Icons.check),
                            label: const Text('Mark Alive'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Last Verification:',
                      lastVerified != null
                          ? _formatDate(lastVerified)
                          : 'Never verified',
                    ),
                    if (widget.pensioner['lastVerifiedBy'] != null)
                      _buildInfoRow(
                        'Last Verified By:',
                        widget.pensioner['lastVerifiedBy'] ?? 'N/A',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Verification History
            Text(
              'Verification History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_verificationHistory.isEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 48,
                          color: AppTheme.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No verification records found',
                          style: TextStyle(
                            color: AppTheme.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _verificationHistory.length,
                itemBuilder: (context, index) {
                  final record = _verificationHistory[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(
                                  DateTime.tryParse(
                                      record['submittedAt'] ?? '') ??
                                      DateTime.now(),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                          record['status'] ?? 'pending')
                                      .withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Text(
                                  (record['status'] ?? 'pending')
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      record['status'] ?? 'pending',
                                    ),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Method: ${record['method'] ?? 'App'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkGrey,
                            ),
                          ),
                          if (record['notes'] != null &&
                              record['notes']!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Notes: ${record['notes']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsAlive() async {
    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.markPensionerAsAlive(
      widget.pensioner['id'],
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pensioner marked as alive'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadVerificationHistory();
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return AppTheme.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
