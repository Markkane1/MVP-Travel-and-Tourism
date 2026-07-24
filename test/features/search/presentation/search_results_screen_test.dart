import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_travel/core/utils/result.dart';
import 'package:mvp_travel/features/explore/domain/tour.dart';
import 'package:mvp_travel/features/search/data/saved_tours_repository.dart';
import 'package:mvp_travel/features/search/data/search_repository.dart';
import 'package:mvp_travel/features/search/presentation/screens/search_results_screen.dart';

class _SearchRepo implements SearchRepository {
  @override
  Stream<List<Tour>> searchTours(SearchFilters filters) =>
      Stream.value(const []);
}

class _SavedRepo implements SavedToursRepository {
  @override
  Stream<List<String>> watchSavedTourIds(String uid) => Stream.value(const []);

  @override
  Future<Result<void>> saveTour(String uid, String tourId) async =>
      const Result.success(null);

  @override
  Future<Result<void>> unsaveTour(String uid, String tourId) async =>
      const Result.success(null);
}

void main() {
  testWidgets('filter sheet opens for ranged price query', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchRepositoryProvider.overrideWithValue(_SearchRepo()),
          savedToursRepositoryProvider.overrideWithValue(_SavedRepo()),
        ],
        child: const MaterialApp(
          home: SearchResultsScreen(
            queryParameters: {'priceRange': r'$1,000–$2,500'},
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Adjust Filters'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
