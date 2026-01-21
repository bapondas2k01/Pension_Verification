import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final List<Map<String, String>> faqs = [
      {
        'question': localizations.translate('faq1Question'),
        'answer': localizations.translate('faq1Answer'),
      },
      {
        'question': localizations.translate('faq2Question'),
        'answer': localizations.translate('faq2Answer'),
      },
      {
        'question': localizations.translate('faq3Question'),
        'answer': localizations.translate('faq3Answer'),
      },
      {
        'question': localizations.translate('faq4Question'),
        'answer': localizations.translate('faq4Answer'),
      },
    ];

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
                        localizations.translate('faq'),
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

            // FAQ List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      title: Text(
                        faqs[index]['question']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      childrenPadding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          faqs[index]['answer']!,
                          style: const TextStyle(
                            height: 1.5,
                            color: AppTheme.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
