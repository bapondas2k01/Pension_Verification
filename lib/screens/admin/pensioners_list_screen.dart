import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';
import 'pensioner_detail_screen.dart';

class PensionersListScreen extends StatefulWidget {
  const PensionersListScreen({super.key});

  @override
  State<PensionersListScreen> createState() => _PensionersListScreenState();
}

class _PensionersListScreenState extends State<PensionersListScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPensioners();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pensioners Management'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
                context.read<AdminProvider>().loadPensioners(
                      searchQuery: value.isEmpty ? null : value,
                    );
              },
              decoration: InputDecoration(
                hintText: 'Search by name, NID, or EPPO...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Pensioners List
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, _) {
                if (adminProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (adminProvider.pensioners.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people,
                          size: 64,
                          color: AppTheme.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No pensioners found'
                              : 'No results for "$_searchQuery"',
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
                    await adminProvider
                        .loadPensioners(searchQuery: _searchQuery.isEmpty ? null : _searchQuery);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: adminProvider.pensioners.length,
                    itemBuilder: (context, index) {
                      final pensioner = adminProvider.pensioners[index];
                      return _buildPensionerCard(
                        context,
                        pensioner: pensioner,
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

  Widget _buildPensionerCard(
    BuildContext context, {
    required Map<String, dynamic> pensioner,
  }) {
    final lastVerified = pensioner['lastVerificationDate'] != null
        ? DateTime.tryParse(pensioner['lastVerificationDate'])
        : null;
    
    final daysAgo = lastVerified != null
        ? DateTime.now().difference(lastVerified).inDays
        : null;

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
            color: daysAgo != null && daysAgo <= 180
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.person,
            color: daysAgo != null && daysAgo <= 180
                ? Colors.green
                : Colors.orange,
            size: 24,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pensioner['nameEn'] ?? pensioner['name'] ?? 'Unknown',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'EPPO: ${pensioner['eppoNumber']} | NID: ${pensioner['nid']}',
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today,
                size: 12,
                color: AppTheme.grey,
              ),
              const SizedBox(width: 4),
              Text(
                lastVerified != null
                    ? '$daysAgo days ago'
                    : 'Never verified',
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
                  color: daysAgo != null && daysAgo <= 180
                      ? Colors.green.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  daysAgo != null && daysAgo <= 180 ? 'ALIVE' : 'PENDING',
                  style: TextStyle(
                    color: daysAgo != null && daysAgo <= 180
                        ? Colors.green
                        : Colors.orange,
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
              builder: (context) => PensionerDetailScreen(
                pensioner: pensioner,
              ),
            ),
          );
        },
      ),
    );
  }
}
