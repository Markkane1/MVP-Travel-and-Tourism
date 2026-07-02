import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/safe_stream.dart';
import '../../../../core/errors/app_exception.dart';
import '../../auth/auth.dart';
import '../../explore/explore.dart';
import 'search_repository.dart';

part 'saved_tours_repository.g.dart';

/// Repository responsible for bookmarking and saving tours to users/{uid}/savedTours.
class SavedToursRepository {
  final FirebaseFirestore _firestore;

  SavedToursRepository(this._firestore);

  /// Streams the list of saved tour IDs for a user.
  Stream<List<String>> watchSavedTourIds(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('savedTours')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList())
        .mapAppException('Failed to load saved tours');
  }

  /// Saves a tour.
  Future<Result<void>> saveTour(String uid, String tourId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('savedTours')
          .doc(tourId)
          .set({
        'tourId': tourId,
        'savedAt': FieldValue.serverTimestamp(),
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException.unknown('Failed to save tour: ${e.toString()}'));
    }
  }

  /// Removes a saved tour.
  Future<Result<void>> unsaveTour(String uid, String tourId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('savedTours')
          .doc(tourId)
          .delete();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException.unknown('Failed to unsave tour: ${e.toString()}'));
    }
  }
}

@riverpod
SavedToursRepository savedToursRepository(Ref ref) {
  return SavedToursRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<String>> savedTourIds(Ref ref) {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(savedToursRepositoryProvider).watchSavedTourIds(user.uid);
}

@riverpod
class OptimisticSavedTours extends _$OptimisticSavedTours {
  @override
  FutureOr<Set<String>> build() async {
    final streamVal = ref.watch(savedTourIdsProvider);
    return streamVal.when(
      data: (list) => list.toSet(),
      error: (err, stack) => <String>{},
      loading: () => <String>{},
    );
  }

  /// Optimistically toggles a saved tour, rolling back the state automatically if Firestore errors out.
  Future<Result<void>> toggleSave(String tourId) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) {
      return const Result.failure(AppException.unknown('User not authenticated'));
    }

    final repo = ref.read(savedToursRepositoryProvider);
    final previousState = state.value ?? <String>{};
    final isSaved = previousState.contains(tourId);

    // 1. Optimistic Update: Modify list instantly in UI
    final updated = Set<String>.from(previousState);
    if (isSaved) {
      updated.remove(tourId);
    } else {
      updated.add(tourId);
    }
    state = AsyncData(updated);

    // 2. Dispatch Firestore write in background
    try {
      Result<void> res;
      if (isSaved) {
        res = await repo.unsaveTour(user.uid, tourId);
      } else {
        res = await repo.saveTour(user.uid, tourId);
      }

      return res.when(
        onSuccess: (_) => const Result.success(null),
        onFailure: (err) {
          // Rollback local state on write failure
          state = AsyncData(previousState);
          return Result.failure(err);
        },
      );
    } catch (e) {
      // 3. Rollback local state on write failure
      state = AsyncData(previousState);
      return Result.failure(AppException.unknown('Failed to update bookmark: ${e.toString()}'));
    }
  }
}

@riverpod
AsyncValue<List<Tour>> savedToursList(Ref ref) {
  final savedIdsState = ref.watch(savedTourIdsProvider);
  final allToursState = ref.watch(searchResultsProvider(const SearchFilters()));

  if (savedIdsState.isLoading || allToursState.isLoading) {
    return const AsyncValue.loading();
  }
  if (savedIdsState.hasError) {
    return AsyncValue.error(savedIdsState.error!, savedIdsState.stackTrace!);
  }
  if (allToursState.hasError) {
    return AsyncValue.error(allToursState.error!, allToursState.stackTrace!);
  }

  final ids = savedIdsState.value ?? [];
  final tours = allToursState.value ?? [];
  return AsyncValue.data(tours.where((tour) => ids.contains(tour.id)).toList());
}
