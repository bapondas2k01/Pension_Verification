import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_theme.dart';
import 'login_step2_screen.dart';
import 'nid_scanner_screen.dart';

class LoginStep1Screen extends StatefulWidget {
  const LoginStep1Screen({super.key});

  @override
  State<LoginStep1Screen> createState() => _LoginStep1ScreenState();
}

class _LoginStep1ScreenState extends State<LoginStep1Screen> {
  bool _is17Digit = false;
  final TextEditingController _nidController = TextEditingController();

  @override
  void dispose() {
    _nidController.dispose();
    super.dispose();
  }

  void _navigateToStep2() {
    if (_nidController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _is17Digit
                ? 'Please enter 17 digit NID'
                : 'Please enter 10 digit NID',
          ),
        ),
      );
      return;
    }

    // Validate exact length
    final requiredLength = _is17Digit ? 17 : 10;
    if (_nidController.text.length != requiredLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _is17Digit
                ? 'NID must be exactly 17 digits'
                : 'NID must be exactly 10 digits',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginStep2Screen()),
    );
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.primaryGreen,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60),
                  Text(
                    localizations.translate('loginStep1'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Language Toggle Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      onTap: () => languageProvider.toggleLanguage(),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          languageProvider.isBangla ? 'English' : 'বাংলা',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Green curved section with logo
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
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Person icon
                        const Icon(
                          Icons.person_outline,
                          size: 80,
                          color: Colors.white,
                        ),
                        // NID card icon
                        Positioned(
                          right: 10,
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.primaryGreen),
                            ),
                            child: const Text(
                              '৳',
                              style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        // Arrow
                        Positioned(
                          right: 25,
                          bottom: 35,
                          child: Transform.rotate(
                            angle: 0.5,
                            child: const Icon(
                              Icons.arrow_forward,
                              color: AppTheme.accentRed,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.translate('experimentalVersion'),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Scan NID option
                    Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        title: Text(
                          localizations.translate('scanNidWithCamera'),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          final scannedNid = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NidScannerScreen(is17Digit: _is17Digit),
                            ),
                          );

                          if (scannedNid != null && mounted) {
                            setState(() {
                              _nidController.text = scannedNid;
                            });
                            // Optionally auto-navigate to step 2
                            if (!mounted) return;
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('NID scanned: $scannedNid'),
                                backgroundColor: AppTheme.primaryGreen,
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider with "Or"
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            localizations.translate('or'),
                            style: const TextStyle(color: AppTheme.grey),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Toggle buttons for 10 digit / 17 digit
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryGreen),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _is17Digit = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: !_is17Digit
                                      ? AppTheme.primaryGreen
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(30),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    localizations.translate('digit10Nid'),
                                    style: TextStyle(
                                      color: !_is17Digit
                                          ? Colors.white
                                          : AppTheme.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _is17Digit = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _is17Digit
                                      ? AppTheme.primaryGreen
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(30),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    localizations.translate('digit17Nid'),
                                    style: TextStyle(
                                      color: _is17Digit
                                          ? Colors.white
                                          : AppTheme.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Input field
                    TextField(
                      controller: _nidController,
                      keyboardType: TextInputType.text,
                      maxLength: _is17Digit ? 17 : 10,
                      decoration: InputDecoration(
                        hintText: _is17Digit
                            ? localizations.translate('enter17DigitNid')
                            : localizations.translate('enter10DigitEppo'),
                        counterText: '',
                      ),
                      onSubmitted: (_) => _navigateToStep2(),
                    ),

                    const SizedBox(height: 24),

                    // Next button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToStep2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(localizations.translate('next')),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Usage instructions
                    OutlinedButton(
                      onPressed: () {
                        _showUsageInstructions(context);
                      },
                      child: Text(localizations.translate('usageInstructions')),
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

  void _showUsageInstructions(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('usageInstructions'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(localizations.translate('instruction1')),
            const SizedBox(height: 8),
            Text(localizations.translate('instruction2')),
            const SizedBox(height: 8),
            Text(localizations.translate('instruction3')),
            const SizedBox(height: 8),
            Text(localizations.translate('instruction4')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.translate('ok')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
