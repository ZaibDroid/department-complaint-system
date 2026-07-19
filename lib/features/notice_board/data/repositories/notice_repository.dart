import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice_model.dart';

import 'dart:io';
import 'dart:convert';

class NoticeRepository {
  final FirebaseFirestore _firestore;

  NoticeRepository(this._firestore);

  Future<void> publishNotice(NoticeModel notice, {List<File>? images}) async {
    final docRef = _firestore.collection('notice_board').doc();
    
    List<String> imageUrls = [];
    if (images != null && images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        final ext = file.path.split('.').last.toLowerCase();
        final dataUrl = 'data:image/$ext;base64,$base64String';
        imageUrls.add(dataUrl);
      }
    }

    final newNotice = NoticeModel(
      id: docRef.id,
      title: notice.title,
      description: notice.description,
      tag: notice.tag,
      createdAt: DateTime.now(),
      senderId: notice.senderId,
      senderName: notice.senderName,
      targetYear: notice.targetYear,
      targetBatches: notice.targetBatches,
      targetSections: notice.targetSections,
      targetRoles: notice.targetRoles,
      targetCRsOnly: notice.targetCRsOnly,
      attachments: imageUrls,
    );
    await docRef.set(newNotice.toMap());
  }

  Future<void> deleteNotice(String id) async {
    await _firestore.collection('notice_board').doc(id).delete();
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
