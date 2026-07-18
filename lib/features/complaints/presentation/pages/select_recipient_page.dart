import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/complaint_model.dart';
import '../providers/complaint_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final availableStaffProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', whereIn: ['Coordinator', 'Chairman', 'Dean', 'Department Office'])
      .snapshots()
      .map((snapshot) {
    
    final staffList = snapshot.docs.map((doc) {
      final data = doc.data();
      final roleStr = data['role']?.toString() ?? 'Staff';
      final roleLower = roleStr.toLowerCase();
      
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Unknown',
        'role': roleStr,
        'isSelectable': roleLower.contains('coordinator') || roleLower.contains('chairman'), 
        'isRecommended': roleLower.contains('coordinator'),
      };
    }).toList();

    // Inject a Chairman card artificially if one isn't found in the database yet
    final hasChairman = staffList.any((staff) => (staff['role'] as String).toLowerCase().contains('chairman'));
    if (!hasChairman) {
      staffList.add({
        'id': 'mock_chairman_id',
        'name': 'Chairman (Pending Setup)',
        'role': 'Chairman',
        'isSelectable': true,
        'isRecommended': false,
      });
    }

    return staffList;
  });
});

class SelectRecipientPage extends ConsumerStatefulWidget {
  final ComplaintModel complaint;

  const SelectRecipientPage({super.key, required this.complaint});

  @override
  ConsumerState<SelectRecipientPage> createState() => _SelectRecipientPageState();
}

class _SelectRecipientPageState extends ConsumerState<SelectRecipientPage> {
  String? _selectedStaffId;
  String? _selectedStaffName;
  final TextEditingController _commentController = TextEditingController();

  void _confirmTransfer() async {
    if (_selectedStaffId == null || _selectedStaffName == null) return;
    
    // Show loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    final commentText = _commentController.text.trim();
    final userRole = ref.read(authStateProvider).value?.role ?? 'Staff';
    final remarks = commentText.isNotEmpty ? commentText : 'There are no remarks from $userRole';

    final success = await ref.read(submitComplaintProvider.notifier).updateStatus(
      widget.complaint.id,
      'forwarded',
      remarks,
      assignedTo: _selectedStaffName, // Save raw name for involvedStaff logic
      newInvolvedStaff: [_selectedStaffName!], // Add new recipient to tracking array
    );

    if (mounted) {
      Navigator.pop(context); // close loading
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case transferred successfully!')),
        );
        context.pop(); // go back to previous dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to transfer case')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final staffAsync = ref.watch(availableStaffProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Forward Complaint', style: TextStyle(color: Color(0xFF010F32), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF010F32)),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(label: Text('STEP 3 OF 4', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFEFEDF1)),
                    Text('BATCH ACTION', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Select Recipient', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF010F32))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.swap_horiz, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text('Transferring Complaint #${widget.complaint.id.substring(0, 6).toUpperCase()}', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 32),

                const Text('AVAILABLE STAFF MEMBERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                
                staffAsync.when(
                  data: (staffList) {
                    if (staffList.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No staff members available for forwarding.'),
                      );
                    }
                    
                    return Column(
                      children: staffList.where((staff) {
                        // Prevent users from forwarding to their own role (e.g., Coordinator to Coordinator)
                        final currentUserRole = ref.read(authStateProvider).value?.role ?? '';
                        if (currentUserRole.toLowerCase() == (staff['role'] as String).toLowerCase()) {
                          return false;
                        }
                        return true;
                      }).map((staff) {
                        final isSelectable = staff['isSelectable'] as bool;
                        final isSelected = _selectedStaffId == staff['id'];
                        final isRecommended = staff['isRecommended'] as bool;
                        
                        return GestureDetector(
                          onTap: isSelectable ? () => setState(() {
                            _selectedStaffId = staff['id'];
                            _selectedStaffName = staff['name'];
                          }) : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Batch Advisers are not authorized to forward directly to the ${staff['role']}.'),
                                backgroundColor: Colors.red.shade600,
                              ),
                            );
                          },
                          child: Opacity(
                            opacity: isSelectable ? 1.0 : 0.6,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.primaryColor.withValues(alpha: 0.05) : Colors.white,
                                border: Border.all(
                                  color: isSelected ? theme.primaryColor : (isSelectable ? Colors.grey.shade300 : Colors.grey.shade200),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isSelected ? [
                                  BoxShadow(color: theme.primaryColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                                ] : [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: isSelectable ? theme.primaryColor.withValues(alpha: 0.1) : Colors.grey.shade200,
                                    child: Icon(Icons.person, color: isSelectable ? theme.primaryColor : Colors.grey, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            Text(staff['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelectable ? Colors.black87 : Colors.grey.shade600)),
                                            if (isRecommended)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                                child: const Text('RECOMMENDED', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                                              ),
                                            if (!isSelectable)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                                child: const Text('RESTRICTED', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text('${staff['role']}', style: TextStyle(color: isSelectable ? theme.primaryColor : Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  if (isSelectable)
                                    // ignore: deprecated_member_use
                                    Radio<String>(
                                      value: staff['id'],
                                      // ignore: deprecated_member_use
                                      groupValue: _selectedStaffId,
                                      activeColor: theme.primaryColor,
                                      // ignore: deprecated_member_use
                                      onChanged: (val) => setState(() {
                                        _selectedStaffId = val!;
                                        _selectedStaffName = staff['name'];
                                      }),
                                    )
                                  else
                                    const Icon(Icons.lock_outline, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
                
                
                // Restriction note removed based on user request
                const SizedBox(height: 12),
                const Text('ADDITIONAL COMMENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add instructions, reasons for forwarding, or any contextual notes...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.primaryColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 12)
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TARGET RECIPIENT:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.1)),
                    Text(_selectedStaffName ?? 'None Selected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _selectedStaffName != null ? theme.primaryColor : Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _selectedStaffId == null ? null : _confirmTransfer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Confirm Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(width: 8),
                            Icon(Icons.send_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
