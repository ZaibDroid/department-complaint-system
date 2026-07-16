import 'package:flutter/material.dart';
import '../../../../features/auth/domain/entities/user.dart';

class AdvisersList extends StatelessWidget {
  final List<User> advisers;

  const AdvisersList({
    super.key,
    required this.advisers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (advisers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No batch advisers registered yet.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: advisers.length,
      itemBuilder: (context, index) {
        final adviser = advisers[index];
        final isAssigned = adviser.batch != null && adviser.batch!.isNotEmpty;

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
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: theme.primaryColor),
            ),
            title: Text(
              adviser.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                adviser.email,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isAssigned ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isAssigned ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Text(
                isAssigned ? '${adviser.batch} (${adviser.section})' : 'Not Assigned',
                style: TextStyle(
                  color: isAssigned ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
