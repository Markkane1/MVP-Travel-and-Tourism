import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { assertActiveAdmin } from './authz';

/**
 * Callable Cloud Function to allow admins to reply to a user's concierge thread.
 */
export const adminReplyToConciergeThreadLogic = async (
  db: admin.firestore.Firestore,
  callerAuth: any,
  targetUserId: string,
  text: string
) => {
  await assertActiveAdmin(db, callerAuth);

  const threadRef = db.collection('concierge_threads').doc(targetUserId);
  const messagesRef = threadRef.collection('messages');

  return db.runTransaction(async (transaction) => {
    // We check if thread exists, though it might not exist yet if admin is starting the conversation.
    // In that case, we can implicitly create it via set with merge.
    
    const messageDocRef = messagesRef.doc();
    
    // 2. Add message to subcollection
    transaction.set(messageDocRef, {
      senderId: callerAuth.uid,
      senderType: 'concierge',
      text: text,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 3. Update thread root metadata
    transaction.set(threadRef, {
      lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
      lastMessageText: text,
      lastMessageSender: 'concierge',
      // Optionally we can track unread count for the user here
      hasUnreadUserMessage: false, // Because staff replied
    }, { merge: true });

    // 4. Write audit log
    const auditRef = db.collection('admin_audit_logs').doc();
    transaction.set(auditRef, {
      actorUid: callerAuth.uid,
      actorEmail: callerAuth.token.email || 'unknown',
      actorRole: callerAuth.token.role || 'admin',
      action: 'adminReplyToConciergeThread',
      targetType: 'concierge_thread',
      targetId: targetUserId,
      summary: `Sent message to user thread`,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, messageId: messageDocRef.id };
  });
};

export const adminReplyToConciergeThread = onCall({ enforceAppCheck: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be logged in.');
  }

  const { targetUserId, text } = request.data;
  if (!targetUserId || typeof targetUserId !== 'string') {
    throw new HttpsError('invalid-argument', 'A valid targetUserId must be provided.');
  }
  if (!text || typeof text !== 'string') {
    throw new HttpsError('invalid-argument', 'A valid text must be provided.');
  }

  return await adminReplyToConciergeThreadLogic(admin.firestore(), request.auth, targetUserId, text);
});
