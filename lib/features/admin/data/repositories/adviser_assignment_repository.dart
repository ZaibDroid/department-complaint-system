import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/domain/entities/user.dart';

final adviserAssignmentRepositoryProvider = Provider<AdviserAssignmentRepository>((ref) {
  return AdviserAssignmentRepository(FirebaseFirestore.instance);
});

class AdviserAssignmentRepository {
  final FirebaseFirestore _firestore;

  AdviserAssignmentRepository(this._firestore);

  Stream<List<User>> getBatchAdvisers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Batch Adviser')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    });
  }

  Future<void> assignAdviser({
    String? adviserId,
    required String semester,
    required String section,
  }) async {
    final batchRef = _firestore.collection('users');
    
    // 1. Find if any adviser is currently assigned to this semester + section and unassign them
    final allAdvisersQuery = await batchRef
        .where('role', isEqualTo: 'Batch Adviser')
        .get();
        
    for (var doc in allAdvisersQuery.docs) {
      final data = doc.data();
      final assignedSections = List<Map<String, dynamic>>.from(data['assignedSections'] ?? []);
      
      final index = assignedSections.indexWhere(
        (a) => a['batch'] == semester && a['section'] == section,
      );
      
      if (index != -1) {
        assignedSections.removeAt(index);
        await doc.reference.update({'assignedSections': assignedSections});
      }
    }
    
    // 2. If a new adviser is specified, assign them
    if (adviserId != null && adviserId.isNotEmpty) {
      final newAdviserDoc = await batchRef.doc(adviserId).get();
      if (newAdviserDoc.exists) {
        final data = newAdviserDoc.data()!;
        final assignedSections = List<Map<String, dynamic>>.from(data['assignedSections'] ?? []);
        
        if (assignedSections.length >= 4) {
          throw Exception('This Batch Adviser is already assigned to the maximum of 4 sections.');
        }
        
        assignedSections.add({'batch': semester, 'section': section});
        await newAdviserDoc.reference.update({'assignedSections': assignedSections});
      }
    }
  }
}
