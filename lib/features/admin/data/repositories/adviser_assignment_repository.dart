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
    final duplicateQuery = await batchRef
        .where('role', isEqualTo: 'Batch Adviser')
        .where('batch', isEqualTo: semester)
        .where('section', isEqualTo: section)
        .get();
        
    for (var doc in duplicateQuery.docs) {
      await doc.reference.update({
        'batch': null,
        'section': null,
      });
    }
    
    // 2. If a new adviser is specified, assign them
    if (adviserId != null && adviserId.isNotEmpty) {
      await batchRef.doc(adviserId).update({
        'batch': semester,
        'section': section,
      });
    }
  }
}
