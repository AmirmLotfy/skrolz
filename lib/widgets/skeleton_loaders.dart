import 'package:flutter/material.dart';
import 'package:skrolz_app/theme/app_colors.dart';

/// Standardized skeleton loaders for consistent loading states.

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: itemCount,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _SkeletonCard(),
      ),
    );
  }
}

class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: itemCount,
      itemBuilder: (context, i) => _SkeletonCard(),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Avatar skeleton
        _SkeletonCircle(radius: 50),
        const SizedBox(height: 16),
        // Name skeleton
        _SkeletonBox(width: 150, height: 24),
        const SizedBox(height: 8),
        // Username skeleton
        _SkeletonBox(width: 100, height: 16),
        const SizedBox(height: 32),
        // Stats skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SkeletonStat(),
            _SkeletonStat(),
            _SkeletonStat(),
          ],
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(width: double.infinity, height: 20),
          const SizedBox(height: 12),
          _SkeletonBox(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          _SkeletonBox(width: 120, height: 16),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SkeletonStat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SkeletonBox(width: 40, height: 24),
        const SizedBox(height: 8),
        _SkeletonBox(width: 50, height: 14),
      ],
    );
  }
}
