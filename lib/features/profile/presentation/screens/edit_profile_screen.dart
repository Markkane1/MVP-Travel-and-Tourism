import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/profile_repository.dart';

/// Screen allowing the user to edit their profile settings.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  
  bool _isSaving = false;
  String? _uploadedPhotoUrl;
  File? _selectedLocalImage;

  @override
  void initState() {
    super.initState();
    // Load initial values from auth service
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _uploadedPhotoUrl = user.photoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _selectedLocalImage = File(pickedFile.path);
    });
  }

  Future<void> _saveProfile(String uid) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? photoUrl = _uploadedPhotoUrl;

      // 1. Upload photo if a new local image was picked
      if (_selectedLocalImage != null) {
        final storage = ref.read(storageServiceProvider);
        final String path = 'users/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.png';
        photoUrl = await storage.uploadImage(_selectedLocalImage!, path);
      }

      // 2. Update Firebase Auth display name and photoUrl
      final auth = ref.read(authServiceProvider);
      await auth.updateProfile(
        displayName: _nameController.text.trim(),
        photoUrl: photoUrl,
      );

      // 3. Update Firestore /users/{uid} document
      final result = await ref.read(profileRepositoryProvider).updateProfile(
        uid: uid,
        name: _nameController.text.trim(),
        photoUrl: photoUrl ?? '',
      );

      await result.when(
        onSuccess: (_) {
          if (mounted) {
            // Force refresh user profile document stream
            ref.invalidate(userFirestoreDataProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully.')),
            );
            context.pop();
          }
        },
        onFailure: (exception) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile update failed: ${exception.message}')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not signed in.')));
    }

    final theme = Theme.of(context);
    final String email = user.email;

    ImageProvider? avatarImage;
    if (_selectedLocalImage != null) {
      avatarImage = FileImage(_selectedLocalImage!);
    } else if (_uploadedPhotoUrl != null) {
      avatarImage = NetworkImage(_uploadedPhotoUrl!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isSaving
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              child: Column(
                children: [
                  // Avatar with Change Photo overlay
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 56.0,
                          backgroundColor: AppColors.primaryContainer,
                          backgroundImage: avatarImage,
                          child: avatarImage == null
                              ? const Icon(Icons.person, size: 56.0, color: AppColors.primary)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6.0),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text(
                      'Change Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  AppSpacing.gapLg,

                  // Full name field
                  AppTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your name',
                  ),
                  AppSpacing.gapMd,

                  // Email (Read-only)
                  AppTextField(
                    controller: TextEditingController(text: email),
                    labelText: 'Email Address',
                    enabled: false,
                  ),
                  const SizedBox(height: 6.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'Contact support to change your email',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapLg,

                  // Save Button
                  PrimaryButton(
                    label: 'Save Changes',
                    onPressed: () => _saveProfile(user.uid),
                  ),
                ],
              ),
            ),
    );
  }
}
