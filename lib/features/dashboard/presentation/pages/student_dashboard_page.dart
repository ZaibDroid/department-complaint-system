import 'package:flutter/material.dart';
import '../widgets/complaint_status_card.dart';
import '../widgets/notice_card.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/quick_action_card.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../complaints/presentation/providers/complaint_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class StudentDashboardPage extends ConsumerStatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  ConsumerState<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends ConsumerState<StudentDashboardPage> {
  String? _selectedAdviser;
  final List<String> _advisers = ['Dr. Ali', 'Dr. Usman', 'Dr. Bilal', 'Engr. Sara'];
  bool _isSubmitting = false;

  Future<void> _sendAdviserRequest(String uid) async {
    if (_selectedAdviser == null) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(firebaseAuthRepositoryProvider).updateUserAdviser(uid, _selectedAdviser!);
      await ref.read(authStateProvider.notifier).refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isApproved = user.status == 'approved';
    final isPending = user.status == 'pending';
    final isRejected = user.status == 'rejected';

    if (!isApproved) {
      return Scaffold(
        backgroundColor: const Color(0xFFFBF8FC),
        appBar: const DashboardAppBar(),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.blue.shade50 : (isRejected ? Colors.red.shade50 : Colors.amber.shade50),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPending ? Icons.hourglass_empty_rounded : (isRejected ? Icons.cancel_outlined : Icons.link),
                      size: 64,
                      color: isPending ? Colors.blue : (isRejected ? Colors.red : Colors.amber.shade700),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPending ? 'Request Pending' : (isRejected ? 'Request Rejected' : 'Link Batch Adviser'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPending 
                        ? 'Your request is currently awaiting approval from ${user.adviser}. You will gain access to your dashboard once approved.'
                        : (isRejected 
                            ? 'Your previous request was rejected by the Batch Adviser. Please select a different adviser below.' 
                            : 'Welcome! Before you can access your dashboard and submit complaints, you must link your account to your Batch Adviser.'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  
                  if (!isPending) ...[
                    const Text('Select Your Batch Adviser', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedAdviser,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      hint: const Text('Choose adviser...'),
                      items: _advisers.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _selectedAdviser = val),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting || _selectedAdviser == null ? null : () => _sendAdviserRequest(user.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                          : const Text('Send Link Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],

                  if (isPending)
                    OutlinedButton(
                      onPressed: () {
                        // Reset status to unlinked if they want to cancel and choose someone else
                        ref.read(firebaseAuthRepositoryProvider).updateUserStatus(user.id, 'unlinked');
                        ref.read(authStateProvider.notifier).refreshUser();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel Request'),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // Active Complaints
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Complaints',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('View all', style: TextStyle(color: theme.primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ref.watch(studentComplaintsProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error loading complaints: $e')),
              data: (complaints) {
                if (complaints.isEmpty) {
                  return const Center(child: Text('No active complaints.'));
                }
                return Column(
                  children: complaints.take(3).map((c) {
                    ComplaintStatus status;
                    switch (c.status.toLowerCase()) {
                      case 'resolved': status = ComplaintStatus.resolved; break;
                      case 'rejected': status = ComplaintStatus.rejected; break;
                      case 'forwarded': status = ComplaintStatus.forwarded; break;
                      default: status = ComplaintStatus.pending;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => context.push('/complaint_details', extra: c),
                        borderRadius: BorderRadius.circular(12),
                        child: ComplaintStatusCard(
                          id: c.id.length > 6 ? c.id.substring(0, 6).toUpperCase() : c.id,
                          title: c.title,
                          description: c.description,
                          category: c.category,
                          assignedTo: c.assignedTo ?? 'Unassigned',
                          timeAgo: '${c.createdAt.day.toString().padLeft(2, '0')}-${c.createdAt.month.toString().padLeft(2, '0')}-${c.createdAt.year} ${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')}',
                          status: status,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // Recent Notices
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Notices',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('See archives', style: TextStyle(color: theme.primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: const [
                  NoticeCard(
                    type: NoticeType.academic,
                    title: 'System Maintenance: Grade Portal Down',
                    description: 'The grade portal will be offline this Sunday from 02:00 to 06:00 for security updates.',
                    date: 'Oct 24, 2023',
                  ),
                  NoticeCard(
                    type: NoticeType.campusLife,
                    title: 'Annual Sports Fest Registration',
                    description: 'Registration for the upcoming Sports Fest is now open at the Student Union center.',
                    date: 'Oct 22, 2023',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.help_center,
                    title: 'Filing Guide',
                    subtitle: 'Learn how to file',
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.history,
                    title: 'History',
                    subtitle: 'Check past cases',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // Padding for bottom nav
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/submit_complaint');
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
