import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return ComplaintRepository(FirebaseFirestore.instance);
});

class ComplaintRepository {
  final FirebaseFirestore _firestore;

  ComplaintRepository(this._firestore);

  Future<String> submitComplaint(ComplaintModel complaint, {List<File>? images}) async {
    final docRef = _firestore.collection('complaints').doc();
    
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
    
    final newComplaint = complaint.copyWith(
      id: docRef.id,
      status: 'pending',
      attachments: imageUrls,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await docRef.set(newComplaint.toMap());
    return docRef.id;
  }

  Future<ComplaintModel?> getComplaintById(String id) async {
    try {
      final docSnapshot = await _firestore.collection('complaints').doc(id).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return ComplaintModel.fromMap(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<List<ComplaintModel>> streamStudentComplaints(String studentId) {
    return _firestore
        .collection('complaints')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      final complaints = snapshot.docs
          .map((doc) {
            try {
              return ComplaintModel.fromMap(doc.data(), doc.id);
            } catch (e) {
              // print('Error parsing complaint ${doc.id}: $e');
              return null;
            }
          })
          .where((c) => c != null)
          .cast<ComplaintModel>()
          .toList();
      complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return complaints;
    });
  }

  Stream<List<ComplaintModel>> streamDepartmentComplaints({String? department, String? adviserName}) {
    Query<Map<String, dynamic>> query = _firestore.collection('complaints');
    
    if (department != null && department.isNotEmpty) {
      query = query.where('category', isEqualTo: department);
    }
    
    return query.snapshots().map((snapshot) {
      var complaints = snapshot.docs
          .map((doc) {
            try {
              return ComplaintModel.fromMap(doc.data(), doc.id);
            } catch (e) {
              return null;
            }
          })
          .where((c) => c != null)
          .cast<ComplaintModel>()
          .toList();
          
      if (adviserName != null && adviserName.isNotEmpty) {
        final myNameLower = adviserName.toLowerCase().replaceAll('dr.', '').trim();
        complaints = complaints.where((c) {
          final assignedTo = c.assignedTo ?? '';
          final assignedToLower = assignedTo.toLowerCase().replaceAll('dr.', '').trim();
          bool isAssigned = assignedToLower.isNotEmpty && assignedToLower == myNameLower;
          
          bool isInvolved = c.involvedStaffNames.any((name) {
            final nameLower = name.toLowerCase().replaceAll('dr.', '').trim();
            return nameLower.isNotEmpty && nameLower == myNameLower;
          });
          
          return isAssigned || isInvolved;
        }).toList();
      }
          
      complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return complaints;
    });
  }

  Stream<List<ComplaintModel>> streamAllComplaints() {
    return _firestore
        .collection('complaints')
        .snapshots()
        .map((snapshot) {
      final complaints = snapshot.docs
          .map((doc) {
            try {
              return ComplaintModel.fromMap(doc.data(), doc.id);
            } catch (e) {
              return null;
            }
          })
          .where((c) => c != null)
          .cast<ComplaintModel>()
          .toList();
      complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return complaints;
    });
  }

  Future<void> updateComplaintStatus(String id, String newStatus, {String? adminRemarks, String? assignedToId, String? assignedTo, List<String>? newInvolvedStaff}) async {
    final updateData = <String, dynamic>{
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (adminRemarks != null) {
      updateData['adminRemarks'] = adminRemarks;
    }
    
    if (assignedToId != null) {
      updateData['assignedToId'] = assignedToId;
    }
    
    if (assignedTo != null) {
      updateData['assignedTo'] = assignedTo;
    }

    if (newInvolvedStaff != null && newInvolvedStaff.isNotEmpty) {
      updateData['involvedStaffNames'] = FieldValue.arrayUnion(newInvolvedStaff);
    }

    await _firestore.collection('complaints').doc(id).update(updateData);
  }
}
