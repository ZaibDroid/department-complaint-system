import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../widgets/advisers_list.dart'; // We can reuse this or create a similar CoordinatorsList
import '../widgets/add_faculty_dialog.dart';

final coordinatorsStreamProvider = StreamProvider.autoDispose<List<User>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'Coordinator')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
  });
});

class ManageCoordinatorsPage extends ConsumerWidget {
  const ManageCoordinatorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinatorsAsync = ref.watch(coordinatorsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FC),
      appBar: AppBar(
        title: const Text('Manage Coordinators', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF010F32))),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: coordinatorsAsync.when(
        data: (coordinators) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Department Coordinators',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF010F32)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage the coordinators who oversee batch advisers and handle escalated complaints.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              AdvisersList(advisers: coordinators), // Reusing AdvisersList since the UI is identical
              const SizedBox(height: 80), // Padding for FAB
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddFacultyDialog(defaultRole: 'Coordinator'),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Coordinator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
