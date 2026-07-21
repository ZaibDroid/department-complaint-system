import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class DeleteAdviserDialog extends ConsumerStatefulWidget {
  final User adviserToDelete;
  final List<User> allAdvisers;

  const DeleteAdviserDialog({
    super.key,
    required this.adviserToDelete,
    required this.allAdvisers,
  });

  @override
  ConsumerState<DeleteAdviserDialog> createState() => _DeleteAdviserDialogState();
}

class _DeleteAdviserDialogState extends ConsumerState<DeleteAdviserDialog> {
  String? _selectedAdviserName;
  bool _isLoading = false;

  Future<void> _submitDelete() async {
    if (_selectedAdviserName == null) return;
    
    setState(() => _isLoading = true);

    try {
      final updatedCount = await ref
          .read(firebaseAuthRepositoryProvider)
          .handoverStudents(widget.adviserToDelete.name, _selectedAdviserName!);

      await ref
          .read(firebaseAuthRepositoryProvider)
          .deleteStaffAccount(widget.adviserToDelete.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully transferred $updatedCount students and deleted adviser!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out the current adviser from the dropdown options
    final eligibleAdvisers = widget.allAdvisers
        .where((a) => a.id != widget.adviserToDelete.id)
        .toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_forever, color: Colors.red),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Delete Adviser',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to delete ${widget.adviserToDelete.name}. Before deleting, you must transfer any currently linked students to a new adviser.',
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 20),
          const Text('Select New Adviser for Students', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (eligibleAdvisers.isEmpty)
            const Text(
              'No other batch advisers available. Please create a new adviser account first to transfer the students before deleting.',
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
            )
          else
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              hint: const Text('Choose new adviser...'),
              initialValue: _selectedAdviserName,
              items: eligibleAdvisers.map((a) {
                final batchInfo = a.semester ?? a.batch ?? 'Unassigned';
                return DropdownMenuItem(
                  value: a.name,
                  child: Text('${a.name} ($batchInfo)'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedAdviserName = val);
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_isLoading || _selectedAdviserName == null) ? null : _submitDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Transfer & Delete'),
        ),
      ],
    );
  }
}
