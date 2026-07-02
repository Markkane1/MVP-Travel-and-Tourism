// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:mvp_travel/core/utils/result.dart';
import 'package:mvp_travel/features/search/data/saved_tours_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockSavedToursCollection;
  late MockDocumentReference mockSavedTourDoc;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockSavedToursCollection = MockCollectionReference();
    mockSavedTourDoc = MockDocumentReference();

    when(() => mockFirestore.collection('users'))
        .thenReturn(mockUsersCollection);
    when(() => mockUsersCollection.doc('user-1')).thenReturn(mockUserDoc);
    when(() => mockUserDoc.collection('savedTours'))
        .thenReturn(mockSavedToursCollection);
    when(() => mockSavedToursCollection.doc('tour-1'))
        .thenReturn(mockSavedTourDoc);
  });

  group('SavedToursRepository', () {
    test('saveTour returns Failure instead of throwing on backend error', () async {
      when(
        () => mockSavedTourDoc.set(any()),
      ).thenThrow(Exception('write failed'));

      final repo = SavedToursRepository(mockFirestore);
      final result = await repo.saveTour('user-1', 'tour-1');

      expect(result, isA<Failure<void>>());
    });

    test('unsaveTour returns Failure instead of throwing on backend error', () async {
      when(
        () => mockSavedTourDoc.delete(),
      ).thenThrow(Exception('delete failed'));

      final repo = SavedToursRepository(mockFirestore);
      final result = await repo.unsaveTour('user-1', 'tour-1');

      expect(result, isA<Failure<void>>());
    });
  });
}
