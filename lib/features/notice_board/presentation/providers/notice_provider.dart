import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notice_model.dart';
import '../../data/repositories/notice_repository.dart';

final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return NoticeRepository(FirebaseFirestore.instance);
});

final noticesStreamProvider = StreamProvider<List<NoticeModel>>((ref) {
  final repository = ref.watch(noticeRepositoryProvider);
  return repository.streamAllNotices();
});
