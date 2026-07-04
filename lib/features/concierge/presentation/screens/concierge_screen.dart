import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';
import 'dart:async' show unawaited;
import '../../../../core/widgets/notification_bell_button.dart';
import '../../../profile/profile.dart';
import '../../domain/concierge_profile.dart';
import '../../domain/concierge_message.dart';
import '../../data/concierge_repository.dart';

class ConciergeScreen extends ConsumerStatefulWidget {
  const ConciergeScreen({super.key});

  @override
  ConsumerState<ConciergeScreen> createState() => _ConciergeScreenState();
}

class _ConciergeScreenState extends ConsumerState<ConciergeScreen> {
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  String? _seededUserId;

  bool _isUploadingAttachment = false;

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Automatically scrolls messages to the bottom.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  /// Automatic concierge seeding and user profile matching logic.
  Future<void> _checkAndSeedConcierges(String uid) async {
    final result = await ref
        .read(conciergeRepositoryProvider)
        .checkAndSeedConcierges(uid);
    result.when(
      onSuccess: (updated) {
        if (updated && mounted) {
          ref.invalidate(userFirestoreDataProvider);
        }
      },
      onFailure: (exception) {
        if (kDebugMode) {
          print('Concierge seeding error: ${exception.message}');
        }
      },
    );
  }

  Future<void> _sendMessage(
    String uid,
    String conciergeId, {
    String? attachmentUrl,
  }) async {
    final text = _inputController.text.trim();
    if (text.isEmpty && attachmentUrl == null) return;

    _inputController.clear();

    // OPTIMISTIC LOCAL ECHO EXCEPTION SANCTION:
    // We intentionally perform this write asynchronously without awaiting it in UI path
    // so the message is added to Firestore and immediately echoed back via stream snapshot
    // without blocking textfield entry states.
    unawaited(
      ref
          .read(conciergeRepositoryProvider)
          .sendMessage(uid: uid, text: text, attachmentUrl: attachmentUrl)
          .then(
            (res) {
              res.when(
                onSuccess: (_) {},
                onFailure: (exception) {
                  if (kDebugMode) {
                    print('Error sending message: ${exception.message}');
                  }
                },
              );
            },
            onError: (e) {
              if (kDebugMode) {
                print('Error sending message: $e');
              }
            },
          ),
    );

    _scrollToBottom();
  }

  Future<void> _pickAttachment(String uid, String conciergeId) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    setState(() {
      _isUploadingAttachment = true;
    });

    try {
      final storage = ref.read(storageServiceProvider);
      final String path =
          'concierge_threads/$uid/attachments/${DateTime.now().millisecondsSinceEpoch}.png';
      final String url = await storage.uploadImage(File(pickedFile.path), path);

      await _sendMessage(uid, conciergeId, attachmentUrl: url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image attachment: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAttachment = false;
        });
      }
    }
  }

  void _prefillInput(String msg) {
    setState(() {
      _inputController.text = msg;
    });
    _focusNode.requestFocus();
    // Scroll layout down to the input row
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    if (_seededUserId != user.uid) {
      _seededUserId = user.uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _checkAndSeedConcierges(user.uid);
        }
      });
    }

    final firestoreState = ref.watch(userFirestoreDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.common.appDisplayName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [NotificationBellButton()],
      ),
      body: firestoreState.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (err, stack) => Center(
          child: ErrorStateView(
            message: err.toString(),
            onRetry: () => ref.refresh(userFirestoreDataProvider),
          ),
        ),
        data: (profileDoc) {
          final profile = profileDoc ?? {};
          final String conciergeId =
              profile['conciergeId'] ?? 'concierge-elena';

          final conciergeState = ref.watch(
            conciergeProfileProvider(conciergeId),
          );
          final messagesState = ref.watch(conciergeMessagesProvider(user.uid));
          final threadState = ref.watch(
            conciergeThreadMetadataProvider(user.uid),
          );

          return conciergeState.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (err, stack) => Center(
              child: ErrorStateView(
                message: err.toString(),
                onRetry: () =>
                    ref.refresh(conciergeProfileProvider(conciergeId)),
              ),
            ),
            data: (concierge) {
              return messagesState.when(
                loading: () => const Center(child: LoadingIndicator()),
                error: (err, stack) => Center(
                  child: ErrorStateView(
                    message: err.toString(),
                    onRetry: () =>
                        ref.refresh(conciergeMessagesProvider(user.uid)),
                  ),
                ),
                data: (messages) {
                  return threadState.when(
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (err, stack) => Center(
                      child: ErrorStateView(
                        message: err.toString(),
                        onRetry: () => ref.refresh(
                          conciergeThreadMetadataProvider(user.uid),
                        ),
                      ),
                    ),
                    data: (threadData) {
                      final bool isTyping = threadData['isTyping'] ?? false;

                      // Trigger scroll to bottom on new messages
                      _scrollToBottom();

                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.containerMargin,
                                vertical: AppSpacing.sm,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Headline
                                  Text(
                                    'Travel Concierge',
                                    style: theme.textTheme.headlineLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSurface,
                                        ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Your personal assistant is ready to craft your next experience.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  AppSpacing.gapLg,

                                  // Assigned Concierge Card
                                  _buildConciergeCard(context, concierge),
                                  AppSpacing.gapLg,

                                  // Elite Benefits Card
                                  _buildEliteBenefitsCard(context),
                                  AppSpacing.gapLg,

                                  // Quick Help section
                                  _buildQuickHelpSection(context),
                                  AppSpacing.gapLg,

                                  // Chat messages area header
                                  const Divider(
                                    height: 32.0,
                                    color: AppColors.outlineVariant,
                                    thickness: 1.0,
                                  ),
                                  Text(
                                    'Chat History',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),

                                  // Message list
                                  if (messages.isEmpty)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 24.0,
                                        ),
                                        child: Text(
                                          'No messages yet. Send a message to start conversing with your concierge helper.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 13.0,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: messages.length,
                                      itemBuilder: (context, index) {
                                        final msg = messages[index];
                                        return _buildMessageRow(
                                          context,
                                          msg,
                                          concierge.photoUrl,
                                        );
                                      },
                                    ),

                                  // Typing indicator
                                  if (isTyping)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                        left: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12.0,
                                            backgroundImage: NetworkImage(
                                              concierge.photoUrl,
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            '${concierge.name} is typing...',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 24.0),
                                ],
                              ),
                            ),
                          ),

                          // Text Input Row
                          _buildInputRow(user.uid, conciergeId),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConciergeCard(BuildContext context, ConciergeProfile concierge) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36.0,
                    backgroundImage: concierge.photoUrl.isNotEmpty
                        ? NetworkImage(concierge.photoUrl)
                        : null,
                  ),
                  if (concierge.isOnline)
                    Positioned(
                      bottom: 2.0,
                      right: 2.0,
                      child: Container(
                        width: 14.0,
                        height: 14.0,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.0),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${concierge.name}, ${concierge.role}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.secondary,
                          size: 14.0,
                        ),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            concierge.specialty,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.translate,
                          color: AppColors.primary,
                          size: 14.0,
                        ),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            'Languages: ${concierge.languages}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          PrimaryButton(
            label: 'Message ${concierge.name}',
            onPressed: () {
              _focusNode.requestFocus();
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEliteBenefitsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary, // Dark Navy
        borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
        boxShadow: AppShadows.level2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ELITE MEMBER CONCIERGE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const Icon(
                Icons.workspace_premium,
                color: AppColors.secondary,
                size: 24.0,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildBenefitRow(
            Icons.support_agent,
            '24/7 Priority Support Desk',
            'Immediate chat responses & premium ticket assignments.',
          ),
          const SizedBox(height: 12.0),
          _buildBenefitRow(
            Icons.design_services_outlined,
            'Tailored Luxury Itineraries',
            'Custom safaris, yachts, and private dining layouts built to order.',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.secondary, size: 20.0),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 11.0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickHelpSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How can we help?',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Tap any card to automatically pre-fill your chat conversation input.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12.0),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          children: [
            _buildQuickHelpCard(
              context,
              Icons.flight_takeoff,
              'Book Private Jet',
              'Charter private flights.',
              "I'd like to book a private jet for...",
              cardKey: const Key('concierge_quick_help_private_jet'),
            ),
            _buildQuickHelpCard(
              context,
              Icons.restaurant,
              'Reservations',
              'Book fine dining tables.',
              "I'd like to make a restaurant reservation at...",
            ),
            _buildQuickHelpCard(
              context,
              Icons.map_outlined,
              'Custom Itinerary',
              'Design personalized safaris.',
              "Could you please help me draft a custom itinerary for...",
            ),
            _buildQuickHelpCard(
              context,
              Icons.health_and_safety_outlined,
              'Emergency Help',
              'Urgent support desk.',
              "I need urgent emergency assistance regarding...",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickHelpCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String prefillText,
    {Key? cardKey}
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      key: cardKey,
      onTap: () => _prefillInput(prefillText),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 24.0),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
                fontSize: 12.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 9.0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageRow(
    BuildContext context,
    ConciergeMessage msg,
    String agentPhotoUrl,
  ) {
    final isMe = msg.senderType == 'user';
    final bubbleColor = isMe
        ? AppColors.primary
        : AppColors.outlineVariant.withValues(alpha: 0.5);
    final textColor = isMe ? Colors.white : AppColors.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14.0,
              backgroundImage: agentPhotoUrl.isNotEmpty
                  ? NetworkImage(agentPhotoUrl)
                  : null,
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadii.md),
                  topRight: const Radius.circular(AppRadii.md),
                  bottomLeft: isMe
                      ? const Radius.circular(AppRadii.md)
                      : Radius.zero,
                  bottomRight: isMe
                      ? Radius.zero
                      : const Radius.circular(AppRadii.md),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.attachmentUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 180.0),
                        child: Image.network(
                          msg.attachmentUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                  ],
                  if (msg.text.isNotEmpty)
                    Text(
                      msg.text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13.0,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(String uid, String conciergeId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _isUploadingAttachment
                ? const SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () => _pickAttachment(uid, conciergeId),
                  ),
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                maxLength: 1000,
                maxLines: null,
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
                onSubmitted: (_) => _sendMessage(uid, conciergeId),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.primary),
              onPressed: () => _sendMessage(uid, conciergeId),
            ),
          ],
        ),
      ),
    );
  }
}
