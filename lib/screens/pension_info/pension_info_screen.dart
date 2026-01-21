import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/pensioner_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_theme.dart';

class PensionInfoScreen extends StatefulWidget {
  const PensionInfoScreen({super.key});

  @override
  State<PensionInfoScreen> createState() => _PensionInfoScreenState();
}

class _PensionInfoScreenState extends State<PensionInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with tabs
            Container(
              color: AppTheme.primaryGreen,
              child: Column(
                children: [
                  // App bar
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
                              localizations.translate('pensionInfo'),
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

                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: localizations.translate('paymentInfo')),
                      Tab(text: localizations.translate('fixationDetails')),
                      Tab(text: localizations.translate('electronicPpo')),
                    ],
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPaymentTab(context, localizations),
                  _buildFixationTab(context, localizations),
                  _buildPpoTab(context, localizations),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTab(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final provider = Provider.of<PensionerProvider>(context);
    final paymentHistory = provider.paymentHistory;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paymentHistory.length,
      itemBuilder: (context, index) {
        final payment = paymentHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              payment.fiscalYear,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: payment.months.map((month) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(month.month),
                          Text(
                            '৳ ${month.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFixationTab(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final provider = Provider.of<PensionerProvider>(context);
    final pensioner = provider.currentPensioner;
    final fixationHistory = provider.fixationHistory;
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (pensioner == null) {
      return Center(child: Text(localizations.translate('noData')));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // PPO Number dropdown
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: pensioner.ppoNumber,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: pensioner.ppoNumber,
                      child: Text(pensioner.ppoNumber),
                    ),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info cards
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    localizations.translate('birthDateByPpo'),
                    _formatDate(pensioner.birthDate, languageProvider.isBangla),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    localizations.translate('pensionStartDate'),
                    _formatDate(
                      pensioner.pensionStartDate,
                      languageProvider.isBangla,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    localizations.translate('netPensionAtStart'),
                    pensioner.netPensionAtStart.toStringAsFixed(2),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Fixation history table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          localizations.translate('fixationDate'),
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          localizations.translate('pensionAmount'),
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          localizations.translate('remarks'),
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // History items
                  ...fixationHistory.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              _formatDate(item.date, languageProvider.isBangla),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(item.amount.toStringAsFixed(2)),
                          ),
                          Expanded(flex: 1, child: Text(item.remarks)),
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
    );
  }

  Widget _buildPpoTab(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 80,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 24),
            Text(
              localizations.translate('electronicPpo'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading PPO...')),
                );
              },
              icon: const Icon(Icons.download),
              label: Text(localizations.translate('downloadPpo')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  String _formatDate(DateTime date, bool isBangla) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    if (isBangla) {
      return '${_toBanglaNumber(day)}/${_toBanglaNumber(month)}/${_toBanglaNumber(year)}';
    }
    return '$day/$month/$year';
  }

  String _toBanglaNumber(String number) {
    const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number.split('').map((d) => banglaDigits[int.parse(d)]).join('');
  }
}
