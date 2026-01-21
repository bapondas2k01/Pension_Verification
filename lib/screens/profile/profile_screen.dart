import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/pensioner_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final pensioner = Provider.of<PensionerProvider>(context).currentPensioner;
    final isBangla = Provider.of<LanguageProvider>(context).isBangla;

    if (pensioner == null) {
      return Scaffold(
        body: Center(child: Text(localizations.translate('noDataAvailable'))),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy', isBangla ? 'bn' : 'en');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with profile picture
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  // Back button and title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              localizations.translate('profile'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Profile photo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: pensioner.photoUrl.isNotEmpty
                          ? Image.network(
                              pensioner.photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 60,
                                color: AppTheme.primaryGreen,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: AppTheme.primaryGreen,
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name
                  Text(
                    isBangla ? pensioner.name : pensioner.nameEn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // PPO Number badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'PPO: ${pensioner.ppoNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Profile information cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Personal Information Card
                    _buildInfoCard(
                      context,
                      title: localizations.translate('personalInfo'),
                      icon: Icons.person_outline,
                      children: [
                        _buildInfoRow(
                          localizations.translate('name'),
                          isBangla ? pensioner.name : pensioner.nameEn,
                        ),
                        _buildInfoRow(
                          localizations.translate('nid'),
                          pensioner.nid,
                        ),
                        _buildInfoRow(
                          localizations.translate('dateOfBirth'),
                          dateFormat.format(pensioner.birthDate),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Pension Information Card
                    _buildInfoCard(
                      context,
                      title: localizations.translate('pensionInfo'),
                      icon: Icons.account_balance_wallet_outlined,
                      children: [
                        _buildInfoRow(
                          localizations.translate('ppoNumber'),
                          pensioner.ppoNumber,
                        ),
                        _buildInfoRow(
                          localizations.translate('pensionStartDate'),
                          dateFormat.format(pensioner.pensionStartDate),
                        ),
                        _buildInfoRow(
                          localizations.translate('netPensionAtStart'),
                          '৳ ${NumberFormat('#,##0.00', 'en').format(pensioner.netPensionAtStart)}',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Office Information Card
                    _buildInfoCard(
                      context,
                      title: localizations.translate('officeInfo'),
                      icon: Icons.business_outlined,
                      children: [
                        _buildInfoRow(
                          localizations.translate('accountingOffice'),
                          pensioner.accountingOffice,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Verification Status Card
                    _buildVerificationStatusCard(context, localizations),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
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
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.grey, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatusCard(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final pensionerProvider = Provider.of<PensionerProvider>(context);
    final lastVerification = pensionerProvider.lastVerificationDate;
    final isVerified = pensionerProvider.isVerified;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isVerified
                      ? Icons.verified_user
                      : Icons.warning_amber_outlined,
                  color: isVerified ? AppTheme.primaryGreen : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.translate('verificationStatus'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isVerified
                    ? AppTheme.lightGreen
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    isVerified ? Icons.check_circle : Icons.access_time,
                    color: isVerified ? AppTheme.primaryGreen : Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isVerified
                        ? localizations.translate('verified')
                        : localizations.translate('pendingVerification'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isVerified ? AppTheme.primaryGreen : Colors.orange,
                    ),
                  ),
                  if (lastVerification != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${localizations.translate('lastVerified')}: ${DateFormat('dd MMM yyyy').format(lastVerification)}',
                      style: const TextStyle(
                        color: AppTheme.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
