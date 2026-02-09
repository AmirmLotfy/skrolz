import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/safety_repository.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _loading = true;
  List<String> _blockedUserIds = [];

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _loading = true);
    final users = await SafetyRepository.getBlockedUsers();
    if (mounted) {
      setState(() {
        _blockedUserIds = users;
        _loading = false;
      });
    }
  }

  Future<void> _unblock(String userId) async {
    final success = await SafetyRepository.unblockUser(userId);
    if (success) {
      _loadBlockedUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                        'Privacy',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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
                    Text(
                      'Blocked Users',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_blockedUserIds.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No blocked users',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._blockedUserIds.map((id) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassSurface(
                              borderRadius: BorderRadius.circular(16),
                              padding: const EdgeInsets.all(16),
                              blur: 20,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person, color: Colors.white70),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'User: ...${id.substring(0, 8)}',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _unblock(id),
                                    child: const Text('Unblock'),
                                  ),
                                ],
                              ),
                            ),
                          )),
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
