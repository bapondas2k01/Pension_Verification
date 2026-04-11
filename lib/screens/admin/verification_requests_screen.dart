import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';
import 'verification_detail_screen.dart';

class VerificationRequestsScreen extends StatefulWidget {
  const VerificationRequestsScreen({super.key});

  @override
  State<VerificationRequestsScreen> createState() =>
      _VerificationRequestsScreenState();
}

class _VerificationRequestsScreenState extends State<VerificationRequestsScreen> {
  String _filterStatus = 'pending';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPendingVerifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Requests'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Pending'),
                  selected: _filterStatus == 'pending',
                  onSelected: (selected) {
                    setState(() => _filterStatus = 'pending');
                    context
                        .read<AdminProvider>()
                        .loadPendingVerifications();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Under Review'),
                  selected: _filterStatus == 'under_review',
                  onSelected: (selected) {
                    setState(() => _filterStatus = 'under_review');
                    context.read<AdminProvider>().loadAllVerifications(
                          status: 'under_review',
                        );
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Approved'),
                  selected: _filterStatus == 'approved',
                  onSelected: (selected) {
                    setState(() => _filterStatus = 'approved');
                    context.read<AdminProvider>().loadAllVerifications(
                          status: 'approved',
                        );
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Rejected'),
                  selected: _filterStatus == 'rejected',
                  onSelected: (selected) {
                    setState(() => _filterStatus = 'rejected');
                    context.read<AdminProvider>().loadAllVerifications(
                          status: 'rejected',
                        );
                  },
                ),
              ],
            ),
          ),
          // Verifications list
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, _) {
                if (adminProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final verifications = _filterStatus == 'pending'
                    ? adminProvider.pendingVerifications
                    : adminProvider.allVerifications;

                if (verifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 64,
                          color: AppTheme.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No $_filterStatus verifications',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await adminProvider.loadPendingVerifications();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: verifications.length,
                    itemBuilder: (context, index) {
                      final verification = verifications[index];
                      return _buildVerificationCard(
                        context,
                        verification: verification,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(
    BuildContext context, {
    required dynamic verification,
  }) {
    final statusColor = _getStatusColor(verification.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            _getStatusIcon(verification.status),
            color: statusColor,
            size: 24,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              verification.pensionerName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'EPPO: ${verification.eppoNumber} | NID: ${verification.nid}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 12,
                color: AppTheme.grey,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(verification.submittedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.grey,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  verification.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: AppTheme.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationDetailScreen(
                verification: verification,
              ),
            ),
          );
        },
      ),
    );
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_actions;
      case 'under_review':
        return Icons.hourglass_bottom;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
