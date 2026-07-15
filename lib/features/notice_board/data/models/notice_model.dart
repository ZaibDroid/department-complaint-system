import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  final String id;
  final String title;
  final String description;
  final String tag; // e.g. Academic, Events, Urgent
  final DateTime createdAt;
  final String senderId;
  final String senderName;
  final String? targetYear;
  final String? targetBatch;
  final String? targetSection;

  NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.createdAt,
    required this.senderId,
    required this.senderName,
    this.targetYear,
    this.targetBatch,
    this.targetSection,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tag': tag,
      'createdAt': Timestamp.fromDate(createdAt),
      'senderId': senderId,
      'senderName': senderName,
      'targetYear': targetYear,
      'targetBatch': targetBatch,
      'targetSection': targetSection,
    };
  }

  factory NoticeModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NoticeModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      tag: map['tag'] ?? 'General',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      targetYear: map['targetYear'],
      targetBatch: map['targetBatch'],
      targetSection: map['targetSection'],
    );
  }
}
