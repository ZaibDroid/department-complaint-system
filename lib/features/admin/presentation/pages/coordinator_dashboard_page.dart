import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import '../../../../features/dashboard/presentation/widgets/staff_complaint_card.dart';
import '../../../../features/complaints/presentation/providers/complaint_provider.dart';
import 'package:go_router/go_router.dart';

class CoordinatorDashboardPage extends ConsumerStatefulWidget {
  const CoordinatorDashboardPage({super.key});

  @override
  ConsumerState<CoordinatorDashboardPage> createState() => _CoordinatorDashboardPageState();
}

class _CoordinatorDashboardPageState extends ConsumerState<CoordinatorDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncComplaints = ref.watch(departmentComplaintsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.white,
            width: double.infinity,
            child: const Text(
              'Coordinator Portal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF172548)),
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: theme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.primaryColor,
              tabs: const [
                Tab(text: 'Incoming Cases'),
                Tab(text: 'Processed'),
              ],
            ),
          ),
          Expanded(
            child: asyncComplaints.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (complaints) {
                final newComplaints = complaints.where((c) => c.status != 'resolved' && c.status != 'rejected').toList();
                final processedComplaints = complaints.where((c) => c.status == 'resolved' || c.status == 'rejected').toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: newComplaints.length,
                      itemBuilder: (context, index) {
                        final c = newComplaints[index];
                        return StaffComplaintCard(
                          studentName: c.studentName,
                          batch: c.studentBatch ?? 'N/A',
                          title: c.title,
                          status: c.status,
                          date: 'Just now',
                          onForward: () {
                             context.push('/select_recipient', extra: c);
                          },
                          onResolve: () {
                            ref.read(submitComplaintProvider.notifier).updateStatus(c.id, 'resolved', 'Resolved by Coordinator');
                          },
                          onReject: () {
                            ref.read(submitComplaintProvider.notifier).updateStatus(c.id, 'rejected', 'Returned by Coordinator');
                          },
                        );
                      },
                    ),
                    ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: processedComplaints.length,
                      itemBuilder: (context, index) {
                        final c = processedComplaints[index];
                        return StaffComplaintCard(
                          studentName: c.studentName,
                          batch: c.studentBatch ?? 'N/A',
                          title: c.title,
                          status: c.status,
                          date: 'Processed',
                          onForward: () {},
                          onResolve: () {},
                          onReject: () {},
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
