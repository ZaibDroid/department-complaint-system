import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice_model.dart';

class NoticeRepository {
  final FirebaseFirestore _firestore;

  NoticeRepository(this._firestore);

  Future<void> publishNotice(NoticeModel notice) async {
    final docRef = _firestore.collection('notice_board').doc();
    final newNotice = NoticeModel(
      id: docRef.id,
      title: notice.title,
      description: notice.description,
      tag: notice.tag,
      createdAt: DateTime.now(),
      senderId: notice.senderId,
      senderName: notice.senderName,
      targetYear: notice.targetYear,
      targetBatch: notice.targetBatch,
      targetSection: notice.targetSection,
    );
    await docRef.set(newNotice.toMap());
  }

  Stream<List<NoticeModel>> streamAllNotices() {
    return _firestore
        .collection('notice_board')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoticeModel.fromMap(doc.data(), doc.id))
            .toList());
  }
  
  // Future enhancements: Add filtering logic in the repository if needed,
  // currently we stream all and filter on the UI.
}
