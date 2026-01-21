import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../providers/pensioner_provider.dart';
import '../../utils/app_theme.dart';
import '../login/login_step1_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              color: AppTheme.primaryGreen,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        localizations.translate('settings'),
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

            // Settings list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Language selection
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.language,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                localizations.translate('language'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        RadioGroup<String>(
                          groupValue: languageProvider.currentLocale.languageCode,
                          onChanged: (value) {
                            if (value != null) {
                              languageProvider.changeLanguage(value);
                            }
                          },
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(localizations.translate('bangla')),
                                leading: Radio<String>(
                                  value: 'bn',
                                  toggleable: false,
                                  fillColor: WidgetStateProperty.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.selected)
                                        ? AppTheme.primaryGreen
                                        : null,
                                  ),
                                ),
                                onTap: () =>
                                    languageProvider.changeLanguage('bn'),
                              ),
                              ListTile(
                                title: Text(localizations.translate('english')),
                                leading: Radio<String>(
                                  value: 'en',
                                  toggleable: false,
                                  fillColor: WidgetStateProperty.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.selected)
                                        ? AppTheme.primaryGreen
                                        : null,
                                  ),
                                ),
                                onTap: () =>
                                    languageProvider.changeLanguage('en'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // About
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryGreen,
                      ),
                      title: Text(localizations.translate('about')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showAboutDialog(context, localizations);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: AppTheme.accentRed,
                      ),
                      title: Text(
                        localizations.translate('logout'),
                        style: const TextStyle(color: AppTheme.accentRed),
                      ),
                      onTap: () {
                        _showLogoutDialog(context, localizations);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('about')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.translate('appTitle')),
            const SizedBox(height: 8),
            Text('${localizations.translate('version')}: 1.0.0'),
            const SizedBox(height: 16),
            const Text(
              'Developed by Finance Division,\nMinistry of Finance,\nGovernment of Bangladesh',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('ok')),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('logout')),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              Provider.of<PensionerProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginStep1Screen(),
                ),
                (route) => false,
              );
            },
            child: Text(
              localizations.translate('logout'),
              style: const TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}
