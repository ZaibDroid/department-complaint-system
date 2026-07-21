import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../complaints/presentation/providers/complaint_provider.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final complaintsAsync = ref.watch(allComplaintsProvider);
    
    int totalComplaints = 0;
    int pendingComplaints = 0;
    int forwardedComplaints = 0;
    int resolvedComplaints = 0;

    complaintsAsync.whenData((complaints) {
      totalComplaints = complaints.length;
      for (var c in complaints) {
        if (c.status == 'pending') {
          pendingComplaints++;
        } else if (c.status == 'forwarded') {
          forwardedComplaints++;
        } else if (c.status == 'resolved' || c.status == 'rejected') {
          resolvedComplaints++;
        }
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "System Analytics",
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            complaintsAsync.when(
              data: (_) => GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard('Total\nComplaints', totalComplaints.toString(), Colors.blue, Icons.assessment, 'all'),
                  _buildStatCard('Pending\nComplaints', pendingComplaints.toString(), Colors.orange, Icons.pending_actions, 'pending'),
                  _buildStatCard('Forwarded\nComplaints', forwardedComplaints.toString(), Colors.purple, Icons.forward_to_inbox, 'forwarded'),
                  _buildStatCard('Resolved\nComplaints', resolvedComplaints.toString(), Colors.green, Icons.check_circle, 'resolved'),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading analytics: $err', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon, String filterValue) {
    return InkWell(
      onTap: () => context.push('/complaint_archive?filter=$filterValue'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
      ),
    );
  }
}
