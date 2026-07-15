import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/chairman_complaints_tab.dart';
import '../widgets/create_adviser_form.dart';

class ChairmanDashboardPage extends ConsumerWidget {
  const ChairmanDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chairman Portal'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authStateProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Complaints'),
              Tab(text: 'Manage Advisers'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Tab 1: Complaints
            ChairmanComplaintsTab(),
            
            // Tab 2: Manage Advisers
            CreateAdviserForm(),
          ],
        ),
      ),
    );
  }
}
