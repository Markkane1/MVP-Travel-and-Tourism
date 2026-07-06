import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audit_model.dart';

final auditLogsProvider = StreamProvider.autoDispose<List<AuditModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('admin_audit_logs')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => AuditModel.fromFirestore(doc.data(), doc.id)).toList();
  });
});
