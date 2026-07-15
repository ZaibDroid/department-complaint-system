import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import '../../../../features/complaints/presentation/providers/complaint_provider.dart';
import '../../../../features/dashboard/presentation/widgets/staff_complaint_card.dart';
import '../../../../features/dashboard/presentation/widgets/complaint_status_card.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ComplaintArchivePage extends ConsumerStatefulWidget {
  const ComplaintArchivePage({super.key});

  @override
  ConsumerState<ComplaintArchivePage> createState() => _ComplaintArchivePageState();
}

class _ComplaintArchivePageState extends ConsumerState<ComplaintArchivePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider).value;
    final isStudent = authState?.role.toLowerCase() == 'student';
    final asyncComplaints = isStudent ? ref.watch(studentComplaintsProvider) : ref.watch(departmentComplaintsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(),
      body: Column(
        children: [
          // Header & Search
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Access and review all historical resolution records.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by ID, keyword, or student name...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: asyncComplaints.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (complaints) {
                final archived = complaints.where((c) {
                  // Filter by search
                  final query = _searchController.text.toLowerCase();
                  if (query.isNotEmpty) {
                    if (!c.id.toLowerCase().contains(query) && 
                        !c.title.toLowerCase().contains(query) &&
                        !c.studentName.toLowerCase().contains(query)) {
                      return false;
                    }
                  }
                  
                  return true;
                }).toList();

                if (archived.isEmpty) {
                  return const Center(child: Text('No archived records found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: archived.length,
                  itemBuilder: (context, index) {
                    final c = archived[index];
                    
                    if (isStudent) {
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
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => context.push('/complaint_details', extra: c),
                        child: StaffComplaintCard(
                          studentName: c.studentName,
                          batch: c.studentBatch ?? 'N/A',
                          title: c.title,
                          status: c.status,
                          date: 'Archived', 
                          onForward: () {}, 
                          onResolve: () {}, 
                          onReject: () {}, 
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
