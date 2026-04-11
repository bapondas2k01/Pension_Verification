import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/pensioner_provider.dart';
import '../../utils/app_theme.dart';
import '../welcome/welcome_screen.dart';

class LoginStep2Screen extends StatefulWidget {
  final String nidOrEppo;
  final bool is17Digit;

  const LoginStep2Screen({
    super.key,
    required this.nidOrEppo,
    required this.is17Digit,
  });

  @override
  State<LoginStep2Screen> createState() => _LoginStep2ScreenState();
}

class _LoginStep2ScreenState extends State<LoginStep2Screen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isValidating = true;
  bool _pensionerFound = false;
  String? _pensionerName;

  @override
  void initState() {
    super.initState();
    // Defer validation to after the first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validatePensioner();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _validatePensioner() async {
    if (!mounted) return;
    setState(() => _isValidating = true);

    final provider = Provider.of<PensionerProvider>(context, listen: false);
    final found = await provider.validateNidOrEppo(
      widget.nidOrEppo,
      is17Digit: widget.is17Digit,
    );

    if (mounted) {
      setState(() {
        _isValidating = false;
        _pensionerFound = found;
        if (found && provider.currentPensioner != null) {
          _pensionerName = provider.currentPensioner!.name;
        }
      });

      if (!found) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Pensioner not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _login() async {
    if (_pinController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your PIN')));
      return;
    }

    if (_pinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be exactly 4 digits')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<PensionerProvider>(context, listen: false);
    final success = await provider.verifyPinAndLogin(_pinController.text);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        localizations.translate('loginStep2'),
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

            // Green curved section
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: _isValidating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Icon(
                              _pensionerFound ? Icons.person : Icons.person_off,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                    if (_pensionerFound && _pensionerName != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _pensionerName!,
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
            ),

            Expanded(
              child: _isValidating
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Verifying pensioner...'),
                        ],
                      ),
                    )
                  : !_pensionerFound
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Pensioner not found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No record found for: ${widget.nidOrEppo}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Info card
                          Card(
                            color: AppTheme.lightGreen,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppTheme.primaryGreen,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      widget.is17Digit
                                          ? 'NID: ${widget.nidOrEppo}'
                                          : 'EPPO: ${widget.nidOrEppo}',
                                      style: const TextStyle(
                                        color: AppTheme.primaryGreen,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // PIN Input
                          TextField(
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              letterSpacing: 8,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              hintText: localizations.translate('enterPin'),
                              counterText: '',
                              prefixIcon: const Icon(Icons.lock_outline),
                            ),
                            onSubmitted: (_) => _login(),
                          ),

                          const SizedBox(height: 32),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(localizations.translate('submit')),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward),
                                      ],
                                    ),
                            ),
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
}
