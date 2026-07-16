import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/adviser_assignment_provider.dart';
import '../widgets/adviser_assignment_form.dart';
import '../widgets/advisers_list.dart';
import '../../../../features/auth/domain/entities/user.dart';

class AssignAdviserPage extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const AssignAdviserPage({super.key, this.isEmbedded = false});

  @override
  ConsumerState<AssignAdviserPage> createState() => _AssignAdviserPageState();
}

class _AssignAdviserPageState extends ConsumerState<AssignAdviserPage> {
  String _selectedTab = 'assignments'; // 'assignments', 'advisers'

  @override
  Widget build(BuildContext context) {
    final advisersAsync = ref.watch(batchAdvisersStreamProvider);
    final assignments = ref.watch(adviserAssignmentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text(
                'Assign Batch Adviser',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF010F32),
            ),
      body: advisersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error loading faculty: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (advisers) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Segmented Button for Tab Switching (On Top)
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'assignments',
                        label: Text('By Semester'),
                        icon: Icon(Icons.class_, size: 18),
                      ),
                      ButtonSegment(
                        value: 'advisers',
                        label: Text('By Adviser'),
                        icon: Icon(Icons.people, size: 18),
                      ),
                    ],
                    selected: {_selectedTab},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedTab = newSelection.first;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.white,
                      selectedBackgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      selectedForegroundColor: theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Conditional Tab Views
                if (_selectedTab == 'assignments') ...[
                  // Assignment Form Panel
                  AdviserAssignmentForm(advisers: advisers),
                  const SizedBox(height: 28),
                  const Text(
                    'Current Assignments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF010F32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (assignments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No semesters or sections configured.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = assignments[index];
                        final hasAdviser = assignment.adviserName != null;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 2,
                          shadowColor: Colors.black.withValues(alpha: 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade100),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: hasAdviser 
                                  ? theme.primaryColor.withValues(alpha: 0.1) 
                                  : Colors.red.shade50,
                              child: Icon(
                                hasAdviser ? Icons.verified_user : Icons.warning_amber_rounded,
                                color: hasAdviser ? theme.primaryColor : Colors.red,
                              ),
                            ),
                            title: Text(
                              '${assignment.semester} - Section ${assignment.section}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                hasAdviser ? 'Adviser: ${assignment.adviserName}' : 'Not Assigned',
                                style: TextStyle(
                                  color: hasAdviser ? Colors.black87 : Colors.red.shade400,
                                  fontWeight: hasAdviser ? FontWeight.w500 : FontWeight.bold,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasAdviser)
                                  IconButton(
                                    icon: const Icon(Icons.info_outline, color: Colors.blue),
                                    tooltip: 'Adviser Details',
                                    onPressed: () {
                                      final adviserUser = advisers.firstWhere(
                                        (a) => a.id == assignment.adviserId,
                                        orElse: () => User(id: '', name: assignment.adviserName ?? 'Unknown', email: 'N/A', role: 'Batch Adviser'),
                                      );
                                      _showAdviserDetailsDialog(context, adviserUser, assignment.semester, assignment.section);
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.green),
                                  tooltip: 'Edit Assignment',
                                  onPressed: () {
                                    ref.read(selectedAssignmentProvider.notifier).select(
                                      assignment.semester,
                                      assignment.section,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ] else ...[
                  const Text(
                    'Faculty Advisers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF010F32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AdvisersList(advisers: advisers),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAdviserDetailsDialog(
    BuildContext context,
    User adviser,
    String semester,
    String section,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.person, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Adviser Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(Icons.account_circle, 'Name', adviser.name),
              const Divider(height: 24),
              _detailRow(Icons.email, 'Email', adviser.email),
              const Divider(height: 24),
              _detailRow(Icons.class_, 'Assigned Semester', semester),
              const Divider(height: 24),
              _detailRow(Icons.view_module, 'Section', section),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF010F32),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
