import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/complaint_model.dart';
import '../../data/repositories/complaint_repository.dart';

// Provides the list of complaints submitted by the currently logged-in student.
final studentComplaintsProvider = StreamProvider<List<ComplaintModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  
  if (user == null || user.role.toLowerCase() != 'student') {
    return Stream.value([]);
  }
  
  final repository = ref.watch(complaintRepositoryProvider);
  return repository.streamStudentComplaints(user.id);
});

// Provides the list of complaints assigned to the logged-in staff's department.
final departmentComplaintsProvider = StreamProvider<List<ComplaintModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  
  if (user == null || user.role.toLowerCase() == 'student') {
    return Stream.value([]);
  }
  
  final repository = ref.watch(complaintRepositoryProvider);
  return repository.streamDepartmentComplaints(adviserName: user.name);
});

// Provides the list of all complaints in the system (typically for Admins)
final allComplaintsProvider = StreamProvider<List<ComplaintModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  
  if (user == null || user.role.toLowerCase() != 'admin') {
    return Stream.value([]);
  }
  
  final repository = ref.watch(complaintRepositoryProvider);
  return repository.streamAllComplaints();
});

// AsyncNotifier for submitting a complaint to handle loading state from UI
class SubmitComplaintNotifier extends AsyncNotifier<void> {
  late final ComplaintRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(complaintRepositoryProvider);
  }

  Future<bool> submit(ComplaintModel complaint, {List<File>? images}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.submitComplaint(complaint, images: images);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
  
  Future<bool> updateStatus(String complaintId, String status, String remarks, {String? assignedTo, List<String>? newInvolvedStaff}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateComplaintStatus(complaintId, status, adminRemarks: remarks, assignedTo: assignedTo, newInvolvedStaff: newInvolvedStaff);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final submitComplaintProvider = AsyncNotifierProvider<SubmitComplaintNotifier, void>(() {
  return SubmitComplaintNotifier();
});
