import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skrolz_app/data/supabase/profile_repository.dart';
import 'package:skrolz_app/data/supabase/supabase_client.dart';
import 'package:skrolz_app/providers/auth_provider.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Edit profile: name and avatar upload.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  String? _avatarUrl;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = ref.read(authUserProvider).value;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    
    final profile = await ProfileRepository.getProfile(user.id);
    if (profile != null && mounted) {
      setState(() {
        _nameController.text = profile['display_name'] as String? ?? '';
        _avatarUrl = profile['avatar_url'] as String?;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadAvatar() async {
    if (_selectedImage == null) return _avatarUrl;
    
    final user = AppSupabase.auth.currentUser;
    if (user == null) return null;
    
    try {
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await _selectedImage!.readAsBytes();
      
      await AppSupabase.client.storage
          .from('avatars')
          .uploadBinary(fileName, fileBytes);
      
      final url = AppSupabase.client.storage.from('avatars').getPublicUrl(fileName);
      return url;
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    final user = ref.read(authUserProvider).value;
    if (user == null) return;
    
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name cannot be empty');
      return;
    }
    
    setState(() {
      _saving = true;
      _error = null;
    });
    
    try {
      String? newAvatarUrl = _avatarUrl;
      if (_selectedImage != null) {
        newAvatarUrl = await _uploadAvatar();
        if (newAvatarUrl == null) {
          setState(() {
            _error = 'Failed to upload avatar';
            _saving = false;
          });
          return;
        }
      }
      
      await ProfileRepository.updateProfile(
        user.id,
        displayName: name,
        avatarUrl: newAvatarUrl,
      );
      
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to save: ${e.toString()}';
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.darkGradient,
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GlassSurface(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(8),
                      blur: 20,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Edit Profile',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GlassSurface(
                      borderRadius: BorderRadius.circular(16),
                      padding: EdgeInsets.zero,
                      blur: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _saving ? null : _save,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'common.save'.tr(),
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                      ? CachedNetworkImageProvider(_avatarUrl!)
                                      : null),
                              child: _selectedImage == null && (_avatarUrl == null || _avatarUrl!.isEmpty)
                                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GlassSurface(
                                borderRadius: BorderRadius.circular(20),
                                padding: const EdgeInsets.all(8),
                                blur: 20,
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GlassSurface(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(20),
                      blur: 25,
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        enabled: !_saving,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      GlassSurface(
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.all(16),
                        blur: 20,
                        child: Text(
                          _error!,
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
