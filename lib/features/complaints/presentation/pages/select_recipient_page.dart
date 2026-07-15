import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/complaint_model.dart';
import '../providers/complaint_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SelectRecipientPage extends ConsumerStatefulWidget {
  final ComplaintModel complaint;

  const SelectRecipientPage({super.key, required this.complaint});

  @override
  ConsumerState<SelectRecipientPage> createState() => _SelectRecipientPageState();
}

class _SelectRecipientPageState extends ConsumerState<SelectRecipientPage> {
  String _selectedStaffId = 'staff_chairman';
  String _selectedStaffName = 'Prof. Ahmed';
  String _selectedStaffRole = 'Chairman';
  final TextEditingController _commentController = TextEditingController();

  final List<Map<String, dynamic>> _availableStaff = [
    {
      'id': 'staff_chairman',
      'name': 'Prof. Ahmed',
      'role': 'Chairman',
      'isSelectable': true,
      'isRecommended': true,
    },
    {
      'id': 'staff_coordinator',
      'name': 'Dr. Ali',
      'role': 'Coordinator',
      'isSelectable': true,
      'isRecommended': false,
    },
  ];

  void _confirmTransfer() async {
    // Show loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    // Update the complaint in the provider
    // Note: status is set to 'forwarded', and adminRemarks stores who it was forwarded to
    final commentText = _commentController.text.trim();
    final userRole = ref.read(authStateProvider).value?.role ?? 'Staff';
    final remarks = commentText.isNotEmpty ? commentText : 'There are no remarks from $userRole';

    final success = await ref.read(submitComplaintProvider.notifier).updateStatus(
      widget.complaint.id,
      'forwarded',
      remarks,
      assignedTo: '$_selectedStaffName ($_selectedStaffRole)',
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
                    Chip(label: Text('STEP 2 OF 4', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFFEFEDF1)),
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
                
                ..._availableStaff.map((staff) {
                  final isSelectable = staff['isSelectable'] as bool;
                  final isSelected = _selectedStaffId == staff['id'];
                  final isRecommended = staff['isRecommended'] as bool;
                  
                  return GestureDetector(
                    onTap: isSelectable ? () => setState(() {
                      _selectedStaffId = staff['id'];
                      _selectedStaffName = staff['name'];
                      _selectedStaffRole = staff['role'];
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
                                  Row(
                                    children: [
                                      Text(staff['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelectable ? Colors.black87 : Colors.grey.shade600)),
                                      if (isRecommended) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                          child: const Text('RECOMMENDED', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                      if (!isSelectable) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                          child: const Text('RESTRICTED', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                                        ),
                                      ]
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${staff['role']}', style: TextStyle(color: isSelectable ? theme.primaryColor : Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (isSelectable)
                              Radio<String>(
                                value: staff['id'],
                                groupValue: _selectedStaffId,
                                activeColor: theme.primaryColor,
                                onChanged: (val) => setState(() {
                                  _selectedStaffId = val!;
                                  _selectedStaffName = staff['name'];
                                  _selectedStaffRole = staff['role'];
                                }),
                              )
                            else
                              const Icon(Icons.lock_outline, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Batch Advisers are strictly authorized to escalate complaints only to the Chairman or the Coordinator. Direct escalation to the Dean or Department Office is restricted.',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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
                    Text(_selectedStaffName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.primaryColor)),
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
                        onPressed: _confirmTransfer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
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

