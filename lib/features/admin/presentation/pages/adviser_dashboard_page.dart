import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import '../../../../features/dashboard/presentation/widgets/staff_complaint_card.dart';
import '../../../../features/complaints/presentation/providers/complaint_provider.dart';
import '../../../../features/complaints/data/models/complaint_model.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/profile/presentation/widgets/stat_card.dart';
import '../../../../features/profile/presentation/pages/user_profile_page.dart';

final adviserStudentsProvider = StreamProvider.autoDispose<List<User>>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'Student')
      .snapshots()
      .map((snapshot) {
    final students = snapshot.docs.map((doc) {
      try {
        final data = doc.data();
        data['id'] = doc.id; // Ensure id is present
        return User.fromJson(data);
      } catch (e) {
        return null;
      }
    }).where((u) => u != null).cast<User>().toList();
    final myNameLower = authState.name.toLowerCase().replaceAll('dr.', '').trim();
    
    return students.where((s) {
      if (s.adviser == null || s.adviser!.isEmpty) return false;
      final adviserLower = s.adviser!.toLowerCase().replaceAll('dr.', '').trim();
      return adviserLower.contains(myNameLower) || myNameLower.contains(adviserLower);
    }).toList();
  });
});

final adviserComplaintsProvider = StreamProvider.autoDispose<List<ComplaintModel>>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return Stream.value([]);
  
  // Watch the students provider to get the list of linked students
  final studentsAsync = ref.watch(adviserStudentsProvider);
  if (!studentsAsync.hasValue) return Stream.value([]);
  
  final linkedStudentsIds = studentsAsync.value!.map((s) => s.id).toSet();
  
  return FirebaseFirestore.instance
      .collection('complaints')
      .snapshots()
      .map((snapshot) {
    final complaints = snapshot.docs.map((doc) => ComplaintModel.fromMap(doc.data(), doc.id)).toList();
    
    // Show complaints from all linked students (both pending and approved requests)
    return complaints.where((c) => linkedStudentsIds.contains(c.studentId)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  });
});

class AdviserDashboardPage extends ConsumerStatefulWidget {
  const AdviserDashboardPage({super.key});

  @override
  ConsumerState<AdviserDashboardPage> createState() => _AdviserDashboardPageState();
}

class _AdviserDashboardPageState extends ConsumerState<AdviserDashboardPage> {
  String _selectedFilter = 'pending'; // 'pending', 'resolved', 'forwarded', 'processed', 'students'
  String _studentFilter = 'pending'; // 'pending', 'linked'
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final asyncComplaints = ref.watch(adviserComplaintsProvider);
    final asyncStudents = ref.watch(adviserStudentsProvider);

    List<ComplaintModel> complaints = asyncComplaints.value ?? [];
    List<User> students = asyncStudents.value ?? [];
    List<User> pendingStudents = students.where((s) => s.status == 'pending').toList();

    final user = ref.read(authStateProvider).value;
    final userName = user?.name ?? '';
    final myNameLower = userName.toLowerCase().replaceAll('dr.', '').trim();
    
    bool isAssignedToMe(String? assignedTo) {
      if (assignedTo == null || assignedTo.isEmpty) return false;
      final assignedToLower = assignedTo.toLowerCase().replaceAll('dr.', '').trim();
      return assignedToLower.contains(myNameLower) || myNameLower.contains(assignedToLower);
    }
    
    final pendingCount = complaints.where((c) => isAssignedToMe(c.assignedTo) && c.status != 'resolved' && c.status != 'rejected').length;
    final resolvedCount = complaints.where((c) => c.status == 'resolved').length;
    final forwardedCount = complaints.where((c) => !isAssignedToMe(c.assignedTo) && c.involvedStaffNames.any((name) {
      final involvedLower = name.toLowerCase().replaceAll('dr.', '').trim();
      return involvedLower.contains(myNameLower) || myNameLower.contains(involvedLower);
    }) && c.status != 'resolved').length;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: const DashboardAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                if (_bottomNavIndex == 0)
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.pending_actions,
                          iconColor: Colors.amber,
                          value: pendingCount.toString(),
                          label: 'PENDING',
                          isSelected: _selectedFilter == 'pending',
                          onTap: () => setState(() => _selectedFilter = 'pending'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.assignment_turned_in,
                          iconColor: Colors.green,
                          value: resolvedCount.toString(),
                          label: 'RESOLVED',
                          isSelected: _selectedFilter == 'resolved',
                          onTap: () => setState(() => _selectedFilter = 'resolved'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.share_rounded,
                          iconColor: Colors.indigo,
                          value: forwardedCount.toString(),
                          label: 'FORWARDED',
                          isSelected: _selectedFilter == 'forwarded',
                          onTap: () => setState(() => _selectedFilter = 'forwarded'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: _bottomNavIndex == 2
                ? const UserProfilePage(isSubPage: false)
                : _selectedFilter == 'students'
                ? _buildStudentsList(students, theme)
                : _buildComplaintsList(complaints, theme),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
            if (index == 0) _selectedFilter = 'pending';
            if (index == 1) _selectedFilter = 'students';
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.person_add),
                if (pendingStudents.isNotEmpty)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('${pendingStudents.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  )
              ],
            ),
            label: 'Requests',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }



  void _showActionDialog(BuildContext context, ComplaintModel c, String actionType) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${actionType == 'resolved' ? 'Resolve' : 'Reject'} Complaint'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a comment for this action:'),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Enter comment...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final comment = commentController.text.trim().isEmpty 
                    ? (actionType == 'resolved' ? 'Issue resolved by adviser' : 'Invalid complaint')
                    : commentController.text.trim();
                ref.read(submitComplaintProvider.notifier).updateStatus(c.id, actionType, comment);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: actionType == 'resolved' ? Colors.green : Colors.red, foregroundColor: Colors.white),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildComplaintsList(List<ComplaintModel> complaints, ThemeData theme) {
    final user = ref.read(authStateProvider).value;
    final userName = user?.name ?? '';
    final myNameLower = userName.toLowerCase().replaceAll('dr.', '').trim();
    
    bool isAssignedToMe(String? assignedTo) {
      if (assignedTo == null || assignedTo.isEmpty) return false;
      final assignedToLower = assignedTo.toLowerCase().replaceAll('dr.', '').trim();
      return assignedToLower.contains(myNameLower) || myNameLower.contains(assignedToLower);
    }

    var filtered = complaints.where((c) {
      if (_selectedFilter == 'pending') return isAssignedToMe(c.assignedTo) && c.status != 'resolved' && c.status != 'rejected';
      if (_selectedFilter == 'resolved') return c.status == 'resolved';
      if (_selectedFilter == 'forwarded') {
        return !isAssignedToMe(c.assignedTo) && c.involvedStaffNames.any((name) {
          final involvedLower = name.toLowerCase().replaceAll('dr.', '').trim();
          return involvedLower.contains(myNameLower) || myNameLower.contains(involvedLower);
        });
      }
      if (_selectedFilter == 'processed') return c.status == 'resolved' || c.status == 'rejected';
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No complaints found in this category.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final c = filtered[index];
        final myNameLower = (ref.read(authStateProvider).value?.name ?? '').toLowerCase().replaceAll('dr.', '').trim();
        final assignedToLower = (c.assignedTo ?? '').toLowerCase().replaceAll('dr.', '').trim();
        final isAssignedToMe = assignedToLower.contains(myNameLower) || myNameLower.contains(assignedToLower);
        final isPending = isAssignedToMe && c.status != 'resolved' && c.status != 'rejected';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.push('/complaint_details', extra: c),
            borderRadius: BorderRadius.circular(16),
            child: StaffComplaintCard(
              studentName: c.studentName,
              batch: c.studentBatch ?? 'N/A',
              title: c.title,
              status: c.status,
              date: '${c.createdAt.day.toString().padLeft(2, '0')}-${c.createdAt.month.toString().padLeft(2, '0')}-${c.createdAt.year} ${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')}',
              onForward: isPending ? () => context.push('/select_recipient', extra: c) : null,
              onResolve: isPending ? () => _showActionDialog(context, c, 'resolved') : null,
              onReject: isPending ? () => _showActionDialog(context, c, 'rejected') : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentsList(List<User> students, ThemeData theme) {
    final pendingStudents = students.where((s) => s.status == 'pending').toList();
    final approvedStudents = students.where((s) => s.status == 'approved').toList();

    final displayStudents = _studentFilter == 'pending' ? pendingStudents : approvedStudents;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'pending',
                  label: Text('Pending Requests'),
                  icon: Icon(Icons.person_add, size: 18),
                ),
                ButtonSegment(
                  value: 'linked',
                  label: Text('Linked Students'),
                  icon: Icon(Icons.people, size: 18),
                ),
              ],
              selected: {_studentFilter},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _studentFilter = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.white,
                selectedBackgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                selectedForegroundColor: theme.primaryColor,
              ),
            ),
          ),
        ),
        Expanded(
          child: displayStudents.isEmpty
              ? Center(
                  child: Text(
                    _studentFilter == 'pending'
                        ? 'No pending requests.'
                        : 'No linked students found.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: displayStudents.length,
                  itemBuilder: (context, index) {
                    return _buildStudentCard(
                      displayStudents[index],
                      theme,
                      isPending: _studentFilter == 'pending',
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(User s, ThemeData theme, {required bool isPending}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
          backgroundImage: s.profileImageUrl != null ? NetworkImage(s.profileImageUrl!) : null,
          child: s.profileImageUrl == null ? Icon(Icons.person, color: theme.primaryColor, size: 28) : null,
        ),
        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('${s.email}\nBatch: ${s.batch ?? 'N/A'}, Section: ${s.section ?? 'N/A'}'),
        ),
        isThreeLine: true,
        trailing: isPending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Approve Student',
                      onPressed: () async {
                        await ref.read(firebaseAuthRepositoryProvider).updateUserStatus(s.id, 'approved');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student approved successfully.')));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Reject Student',
                      onPressed: () async {
                        await ref.read(firebaseAuthRepositoryProvider).updateUserStatus(s.id, 'rejected');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student rejected.')));
                        }
                      },
                    ),
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Text('Linked', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
      ),
    );
  }
}
