import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/safe_stream.dart';
import '../../../../core/errors/app_exception.dart';

import '../domain/concierge_message.dart';
import '../domain/concierge_profile.dart';

part 'concierge_repository.g.dart';

class ConciergeRepository {
  final FirebaseFirestore _firestore;

  ConciergeRepository(this._firestore);

  /// Streams a single concierge profile.
  Stream<ConciergeProfile> watchConciergeProfile(String conciergeId) {
    return _firestore
        .collection('concierges')
        .doc(conciergeId)
        .snapshots()
        .map((doc) => ConciergeProfile.fromFirestore(doc))
        .mapAppException('Failed to load concierge profile');
  }

  /// Streams the chat messages for a user's thread.
  Stream<List<ConciergeMessage>> watchMessages(String uid) {
    return _firestore
        .collection('concierge_threads')
        .doc(uid)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ConciergeMessage.fromFirestore(doc)).toList())
        .mapAppException('Failed to load concierge messages');
  }

  /// Streams the thread typing and metadata state.
  Stream<Map<String, dynamic>> watchThreadMetadata(String uid) {
    return _firestore
        .collection('concierge_threads')
        .doc(uid)
        .snapshots()
        .map((snap) => snap.data() ?? const <String, dynamic>{})
        .mapAppException('Failed to load concierge thread metadata');
  }

  /// Sends a chat message.
  Future<Result<void>> sendMessage({
    required String uid,
    required String text,
    String? attachmentUrl,
  }) async {
    try {
      final batch = _firestore.batch();
      final messageRef = _firestore
          .collection('concierge_threads')
          .doc(uid)
          .collection('messages')
          .doc();
      
      final now = FieldValue.serverTimestamp();
      batch.set(messageRef, {
        'senderId': uid,
        'senderType': 'user',
        'text': text,
        'attachmentUrl': attachmentUrl,
        'createdAt': now,
      });

      final threadRef = _firestore.collection('concierge_threads').doc(uid);
      batch.set(threadRef, {
        'lastMessageAt': now,
        'lastMessageText': text,
        'lastMessageSender': 'user',
        'hasUnreadUserMessage': true,
      }, SetOptions(merge: true));

      await batch.commit();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException.unknown('Failed to send message: ${e.toString()}'));
    }
  }

  /// Automatic concierge seeding and user profile matching logic.
  Future<Result<bool>> checkAndSeedConcierges(String uid) async {
    try {
      // 1. Seed collection if empty
      final query = await _firestore.collection('concierges').limit(1).get();
      bool updated = false;
      if (query.docs.isEmpty) {
        await _firestore.collection('concierges').doc('concierge-elena').set({
          'name': 'Elena',
          'role': 'Senior Travel Specialist',
          'specialty': 'Luxury Safaris & Lodges',
          'languages': 'English, Spanish, French',
          'photoUrl': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=400',
          'isOnline': true,
        });

        await _firestore.collection('concierges').doc('concierge-marcus').set({
          'name': 'Marcus',
          'role': 'Elite Cruise & Air Charter Manager',
          'specialty': 'Private Jets & Ocean Expeditions',
          'languages': 'English, German, Italian',
          'photoUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=400',
          'isOnline': true,
        });
        updated = true;
      }

      // 2. Assure user profile document maps to a valid concierge
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data()?['conciergeId'] == null) {
        await _firestore.collection('users').doc(uid).update({
          'conciergeId': 'concierge-elena',
        });
        updated = true;
      }
      return Result.success(updated);
    } catch (e) {
      return Result.failure(AppException.unknown('Seeding concierge specialists failed: ${e.toString()}'));
    }
  }
}

@riverpod
ConciergeRepository conciergeRepository(Ref ref) {
  return ConciergeRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<ConciergeProfile> conciergeProfile(Ref ref, String conciergeId) {
  return ref.watch(conciergeRepositoryProvider).watchConciergeProfile(conciergeId);
}

@riverpod
Stream<List<ConciergeMessage>> conciergeMessages(Ref ref, String uid) {
  return ref.watch(conciergeRepositoryProvider).watchMessages(uid);
}

@riverpod
Stream<Map<String, dynamic>> conciergeThreadMetadata(Ref ref, String uid) {
  return ref.watch(conciergeRepositoryProvider).watchThreadMetadata(uid);
}
