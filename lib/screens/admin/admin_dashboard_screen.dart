import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';
import 'verification_requests_screen.dart';
import 'pensioners_list_screen.dart';
import 'verification_statistics_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String? adminId;

  const AdminDashboardScreen({super.key, this.adminId});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminHomeScreen(),
    VerificationRequestsScreen(),
    PensionersListScreen(),
    VerificationStatisticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = context.read<AdminProvider>();
      adminProvider.loadDashboardStats();
      adminProvider.loadPendingVerifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        elevation: 0,
        actions: [
          Consumer<AdminProvider>(
            builder: (context, adminProvider, _) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    adminProvider.currentAdmin?.name ?? 'Admin',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.white,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Verification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Pensioners',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final adminProvider = context.read<AdminProvider>();
        adminProvider.loadDashboardStats();
        adminProvider.loadPendingVerifications();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AdminProvider>(
                      builder: (context, adminProvider, _) {
                        return Text(
                          'Welcome, ${adminProvider.currentAdmin?.name}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage pensioner verifications and records',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Dashboard Statistics
            Text(
              'Dashboard Overview',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Consumer<AdminProvider>(
              builder: (context, adminProvider, _) {
                final stats = adminProvider.dashboardStats;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      context,
                      title: 'Total Pensioners',
                      value: (stats['totalPensioners'] ?? 0).toString(),
                      icon: Icons.people,
                      color: AppTheme.primaryGreen,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Pending Verifications',
                      value: (stats['pendingVerifications'] ?? 0).toString(),
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Approved Verifications',
                      value: (stats['approvedVerifications'] ?? 0).toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      title: 'Pending %',
                      value: '${stats['pendingPercentage']}%',
                      icon: Icons.percent,
                      color: Colors.blue,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to pending verifications
                      // This can be done through parent widget
                    },
                    icon: const Icon(Icons.assignment_turned_in),
                    label: const Text('Review Requests'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to pensioners
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('View Pensioners'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Feature Cards
            Text(
              'Admin Features',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.assignment,
                  title: 'Verification\nManagement',
                  subtitle: 'Review & approve',
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to verification requests
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.people,
                  title: 'Pensioner\nManagement',
                  subtitle: 'Browse records',
                  color: Colors.purple,
                  onTap: () {
                    // Navigate to pensioners
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Statistics &\nAnalytics',
                  subtitle: 'View reports',
                  color: Colors.teal,
                  onTap: () {
                    // Navigate to statistics
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.list_alt,
                  title: 'Verification\nHistory',
                  subtitle: 'Track changes',
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to history
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Pending Verifications',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Consumer<AdminProvider>(
              builder: (context, adminProvider, _) {
                if (adminProvider.pendingVerifications.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.assignment,
                    title: 'No Pending Verifications',
                    subtitle: 'All verifications have been reviewed',
                  );
                }

                final verifications = adminProvider.pendingVerifications.take(
                  5,
                );
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: verifications.length,
                  itemBuilder: (context, index) {
                    final verification = verifications.elementAt(index);
                    return _buildVerificationCard(
                      context,
                      verification: verification,
                      onTap: () {
                        // Navigate to verification details
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppTheme.darkGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard(
    BuildContext context, {
    required dynamic verification,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.assignment, color: Colors.orange, size: 24),
        ),
        title: Text(
          verification.pensionerName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          'EPPO: ${verification.eppoNumber}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Pending',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGrey,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: AppTheme.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(icon, size: 64, color: AppTheme.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: AppTheme.grey),
            ),
          ],
        ),
      ),
    );
  }
}
