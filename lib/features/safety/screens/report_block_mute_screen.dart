import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/data/supabase/safety_repository.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/card_components.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Report / Block / Mute: pass contentId, contentType, creatorId via route; persist via Supabase.
class ReportBlockMuteScreen extends StatefulWidget {
  const ReportBlockMuteScreen({
    super.key,
    this.contentId,
    this.contentType = 'post',
    this.creatorId,
  });

  final String? contentId;
  final String contentType;
  final String? creatorId;

  @override
  State<ReportBlockMuteScreen> createState() => _ReportBlockMuteScreenState();
}

class _ReportBlockMuteScreenState extends State<ReportBlockMuteScreen> {
  String? _reportReason;
  bool _blocked = false;
  bool _muted = false;
  bool _reportSubmitted = false;

  static const _reportReasons = [
    'Spam',
    'Harassment',
    'Misinformation',
    'Inappropriate content',
    'Other',
  ];

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
                        'Report / Block / Mute',
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
                    GlassSurface(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(20),
                      blur: 25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Report content',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._reportReasons.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ContentCard(
                              onTap: () => setState(() => _reportReason = r),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: r,
                                    groupValue: _reportReason,
                                    fillColor: MaterialStateProperty.resolveWith<Color>(
                                      (states) => states.contains(MaterialState.selected)
                                          ? AppColors.primary
                                          : Colors.white70,
                                    ),
                                    onChanged: (v) => setState(() => _reportReason = v),
                                  ),
                                  Expanded(child: Text(r)),
                                ],
                              ),
                            ),
                          )),
                          if (_reportReason != null && !_reportSubmitted) ...[
                            const SizedBox(height: 16),
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
                                    onTap: widget.contentId == null
                                        ? null
                                        : () async {
                                            final ok = await SafetyRepository.reportContent(
                                                widget.contentType, widget.contentId!, _reportReason!);
                                            if (mounted) {
                                              setState(() => _reportSubmitted = true);
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                  content: Text(ok ? 'Report submitted.' : 'Failed to submit.')));
                                            }
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: Text(
                                          'common.done'.tr(),
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
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassSurface(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(20),
                      blur: 25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Creator',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ActionCard(
                            onTap: _blocked || widget.creatorId == null
                                ? null
                                : () async {
                                    final ok = await SafetyRepository.blockUser(widget.creatorId!);
                                    if (mounted) {
                                      setState(() => _blocked = true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(ok ? 'Blocked.' : 'Could not block.')));
                                    }
                                  },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.block,
                                    color: _blocked ? Colors.white70 : AppColors.danger,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _blocked ? 'Blocked' : 'Block',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: _blocked ? Colors.white70 : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ActionCard(
                            onTap: _muted || widget.creatorId == null
                                ? null
                                : () async {
                                    final ok = await SafetyRepository.muteUser(widget.creatorId!);
                                    if (mounted) {
                                      setState(() => _muted = true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(ok ? 'Muted.' : 'Could not mute.')));
                                    }
                                  },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.notifications_off,
                                    color: _muted ? Colors.white70 : AppColors.warning,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _muted ? 'Muted' : 'Mute',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: _muted ? Colors.white70 : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
