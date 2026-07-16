import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/adviser_assignment.dart';
import '../../data/repositories/adviser_assignment_repository.dart';
import '../../../../features/auth/domain/entities/user.dart';

final batchAdvisersStreamProvider = StreamProvider.autoDispose<List<User>>((ref) {
  return ref.watch(adviserAssignmentRepositoryProvider).getBatchAdvisers();
});

final adviserAssignmentsProvider = Provider.autoDispose<List<AdviserAssignment>>((ref) {
  final advisersAsync = ref.watch(batchAdvisersStreamProvider);
  final advisers = advisersAsync.value ?? [];

  final List<AdviserAssignment> list = [];
  final semesters = ['BSCS-1', 'BSCS-2', 'BSCS-3', 'BSCS-4', 'BSCS-5', 'BSCS-6', 'BSCS-7', 'BSCS-8'];
  final sections = ['A', 'B'];

  for (var sem in semesters) {
    for (var sec in sections) {
      // Find if an adviser matches
      final matchedAdviser = advisers.firstWhere(
        (a) => a.batch == sem && a.section == sec,
        orElse: () => User(id: '', name: '', email: '', role: 'Batch Adviser'),
      );

      list.add(AdviserAssignment(
        semester: sem,
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
    return SelectedAssignmentState(semester: 'BSCS-1', section: 'A');
  }

  void select(String semester, String section) {
    state = SelectedAssignmentState(semester: semester, section: section);
  }
}

final selectedAssignmentProvider = NotifierProvider<SelectedAssignmentNotifier, SelectedAssignmentState>(() {
  return SelectedAssignmentNotifier();
});
