import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user.dart';

final crListProvider = StreamProvider<List<User>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('isCR', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
  });
});
