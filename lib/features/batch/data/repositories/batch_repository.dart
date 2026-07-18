import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/batch_model.dart';

final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  return BatchRepository(FirebaseFirestore.instance);
});

class BatchRepository {
  final FirebaseFirestore _firestore;

  BatchRepository(this._firestore);

  Stream<List<BatchModel>> getBatches() {
    return _firestore.collection('batches').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BatchModel.fromJson(doc.data()..['id'] = doc.id)).toList();
    });
  }

  Future<void> addBatch({required String name, required List<String> sections}) async {
    final docRef = _firestore.collection('batches').doc();
    final batch = BatchModel(id: docRef.id, name: name, sections: sections);
    await docRef.set(batch.toJson());
  }

  Future<void> updateBatch(BatchModel batch) async {
    await _firestore.collection('batches').doc(batch.id).update(batch.toJson());
  }

  Future<void> deleteBatch(String id) async {
    await _firestore.collection('batches').doc(id).delete();
  }
}
