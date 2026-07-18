import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/adviser_assignment.dart';
import '../../data/repositories/adviser_assignment_repository.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/batch/presentation/providers/batch_provider.dart';

final batchAdvisersStreamProvider = StreamProvider.autoDispose<List<User>>((ref) {
  return ref.watch(adviserAssignmentRepositoryProvider).getBatchAdvisers();
});

final adviserAssignmentsProvider = Provider.autoDispose<List<AdviserAssignment>>((ref) {
  final advisersAsync = ref.watch(batchAdvisersStreamProvider);
  final batchesAsync = ref.watch(batchesStreamProvider);
  
  final advisers = advisersAsync.value ?? [];
  final batches = batchesAsync.value ?? [];

  final List<AdviserAssignment> list = [];

  for (var batch in batches) {
    for (var sec in batch.sections) {
      // Find if an adviser has this batch and section in their assignedSections
      final matchedAdviser = advisers.firstWhere(
        (a) {
          if (a.assignedSections == null) return false;
          return a.assignedSections!.any((assignment) => 
            assignment['batch'] == batch.name && assignment['section'] == sec
          );
        },
        orElse: () => User(id: '', name: '', email: '', role: 'Batch Adviser'),
      );

      list.add(AdviserAssignment(
        semester: batch.name,
        section: sec,
        adviserId: matchedAdviser.id.isEmpty ? null : matchedAdviser.id,
        adviserName: matchedAdviser.id.isEmpty ? null : matchedAdviser.name,
      ));
    }
  }
  return list;
});

class AdviserAssignmentNotifier extends AsyncNotifier<void> {
  late final AdviserAssignmentRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(adviserAssignmentRepositoryProvider);
  }

  Future<bool> assign({
    String? adviserId,
    required String semester,
    required String section,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.assignAdviser(
        adviserId: adviserId,
        semester: semester,
        section: section,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final assignAdviserActionProvider = AsyncNotifierProvider<AdviserAssignmentNotifier, void>(() {
  return AdviserAssignmentNotifier();
});

class SelectedAssignmentState {
  final String semester;
  final String section;
  SelectedAssignmentState({required this.semester, required this.section});
}

class SelectedAssignmentNotifier extends Notifier<SelectedAssignmentState> {
  @override
  SelectedAssignmentState build() {
    return SelectedAssignmentState(semester: '', section: '');
  }

  void select(String semester, String section) {
    state = SelectedAssignmentState(semester: semester, section: section);
  }
}

final selectedAssignmentProvider = NotifierProvider<SelectedAssignmentNotifier, SelectedAssignmentState>(() {
  return SelectedAssignmentNotifier();
});
