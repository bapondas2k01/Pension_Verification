import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/pensioner_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_theme.dart';
import '../life_verification/life_verification_screen.dart';
import '../pension_info/pension_info_screen.dart';
import '../contact/contact_screen.dart';
import '../faq/faq_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final pensioner = Provider.of<PensionerProvider>(context).currentPensioner;
    final isBangla = Provider.of<LanguageProvider>(context).isBangla;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              child: Column(
                children: [
                  // Settings button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Logo - Tappable to open profile
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: pensioner?.photoUrl.isNotEmpty == true
                          ? ClipOval(
                              child: _buildProfileImage(pensioner!.photoUrl),
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                    ),
                  ),

                  if (pensioner != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      isBangla ? pensioner.name : pensioner.nameEn,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Menu grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    // Life Verification
                    _buildMenuCard(
                      context,
                      icon: Icons.face_retouching_natural,
                      iconColor: AppTheme.accentRed,
                      title: localizations.translate('lifeVerification'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LifeVerificationScreen(),
                          ),
                        );
                      },
                    ),

                    // Contact
                    _buildMenuCard(
                      context,
                      icon: Icons.mail_outline,
                      iconColor: AppTheme.primaryGreen,
                      title: localizations.translate('contact'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactScreen(),
                          ),
                        );
                      },
                    ),

                    // Pension Info
                    _buildMenuCard(
                      context,
                      icon: Icons.info_outline,
                      iconColor: AppTheme.accentRed,
                      title: localizations.translate('pensionInfo'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PensionInfoScreen(),
                          ),
                        );
                      },
                    ),

                    // FAQ
                    _buildMenuCard(
                      context,
                      icon: Icons.help_outline,
                      iconColor: AppTheme.primaryGreen,
                      title: localizations.translate('faq'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FaqScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String photoUrl) {
    // Check if it's a local file path
    if (photoUrl.startsWith('/') || photoUrl.contains(':\\')) {
      final file = File(photoUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person, size: 60, color: Colors.white),
        );
      }
    }
    // Otherwise, try to load from network
    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.person, size: 60, color: Colors.white),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
