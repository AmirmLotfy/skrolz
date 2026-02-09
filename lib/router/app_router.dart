import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skrolz_app/features/auth/screens/auth_screen.dart';
import 'package:skrolz_app/features/create/screens/ai_post_screen.dart';
import 'package:skrolz_app/features/create/screens/create_lesson_screen.dart';
import 'package:skrolz_app/features/create/screens/study_buddy_screen.dart';
import 'package:skrolz_app/features/create/screens/write_post_screen.dart';
import 'package:skrolz_app/features/create/widgets/create_sheet.dart';
import 'package:skrolz_app/features/discovery/screens/discovery_screen.dart';
import 'package:skrolz_app/features/explore/screens/explore_screen.dart';
import 'package:skrolz_app/features/feed/screens/story_detail_screen.dart';
import 'package:skrolz_app/features/home/screens/home_screen.dart';
import 'package:skrolz_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:skrolz_app/features/onboarding/screens/follow_suggestions_screen.dart';
import 'package:skrolz_app/features/onboarding/screens/interests_screen.dart';
import 'package:skrolz_app/features/onboarding/screens/language_style_screen.dart';
import 'package:skrolz_app/features/onboarding/screens/paywall_preview_screen.dart';
import 'package:skrolz_app/features/onboarding/screens/permissions_screen.dart';
import 'package:skrolz_app/features/onboarding/screens/splash_screen.dart';
import 'package:skrolz_app/features/bookmarks/screens/bookmarks_screen.dart';
import 'package:skrolz_app/features/notifications/screens/notifications_screen.dart';
import 'package:skrolz_app/features/premium/screens/premium_hub_screen.dart';
import 'package:skrolz_app/features/profile/screens/drafts_screen.dart';
import 'package:skrolz_app/features/profile/screens/edit_profile_screen.dart';
import 'package:skrolz_app/features/profile/screens/profile_screen.dart';
import 'package:skrolz_app/features/profile/screens/user_profile_screen.dart';
import 'package:skrolz_app/features/safety/screens/report_block_mute_screen.dart';
import 'package:skrolz_app/features/search/screens/search_screen.dart';
import 'package:skrolz_app/features/settings/screens/accessibility_screen.dart';
import 'package:skrolz_app/features/settings/screens/ai_prefs_screen.dart';
import 'package:skrolz_app/features/settings/screens/content_prefs_screen.dart';
import 'package:skrolz_app/features/settings/screens/settings_screen.dart';
import 'package:skrolz_app/features/settings/screens/account_screen.dart';
import 'package:skrolz_app/features/settings/screens/privacy_screen.dart';
import 'package:skrolz_app/features/collections/screens/collections_list_screen.dart';
import 'package:skrolz_app/features/collections/screens/collection_play_screen.dart';
import 'package:skrolz_app/features/collections/models/collection.dart';
import 'package:skrolz_app/theme/app_colors.dart';
import 'package:skrolz_app/theme/glass_surface.dart';

/// Route names for type-safe navigation.
abstract class AppRoutes {
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const languageStyle = 'language-style';
  static const auth = 'auth';
  static const interests = 'interests';
  static const followSuggestions = 'follow-suggestions';
  static const paywallPreview = 'paywall-preview';
  static const permissions = 'permissions';
  static const main = 'main';
  static const home = 'home';
  static const explore = 'explore';
  static const discovery = 'discovery';
  static const profile = 'profile';
  static const story = 'story';
  static const comments = 'comments';
  static const notifications = 'notifications';
  static const bookmarks = 'bookmarks';
  static const search = 'search';
  static const reportBlockMute = 'report-block-mute';
  static const settings = 'settings';
  static const premiumHub = 'premium-hub';
  static const accessibility = 'accessibility';
  static const contentPrefs = 'content-prefs';
  static const aiPrefs = 'ai-prefs';
  static const editProfile = 'edit-profile';
  static const drafts = 'drafts';
  static const account = 'account';
  static const privacy = 'privacy';
  static const collections = 'collections';
  static const collectionPlay = 'collection-play';
  static const userProfile = 'user-profile';
}

/// Paths used by go_router.
abstract class AppPaths {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const languageStyle = '/language-style';
  static const auth = '/auth';
  static const interests = '/interests';
  static const followSuggestions = '/follow-suggestions';
  static const paywallPreview = '/paywall-preview';
  static const permissions = '/permissions';
  static const main = '/';
  static const home = '/home';
  static const explore = '/explore';
  static const discovery = '/discovery';
  static const profile = '/profile';
  static const story = '/story';
  static const comments = '/comments';
  static const notifications = '/notifications';
  static const bookmarks = '/bookmarks';
  static const search = '/search';
  static const reportBlockMute = '/report-block-mute';
  static const settings = '/settings';
  static const premiumHub = '/premium-hub';
  static const accessibility = '/settings/accessibility';
  static const contentPrefs = '/settings/content-prefs';
  static const aiPrefs = '/settings/ai-prefs';
  static const editProfile = '/edit-profile';
  static const drafts = '/drafts';
  static const account = '/settings/account';
  static const privacy = '/settings/privacy';
  static const collections = '/collections';
  static const collectionPlay = '/collections/:id';
  static const userProfile = '/user/:userId';
  static const writePost = '/create/write-post';
  static const aiPost = '/create/ai-post';
  static const createLesson = '/create/lesson';
  static const studyBuddy = '/create/study-buddy';
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppPaths.splash,
    debugLogDiagnostics: false, // Disabled for production
    routes: [
      GoRoute(
        path: AppPaths.splash,
        name: AppRoutes.splash,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppPaths.onboarding,
        name: AppRoutes.onboarding,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppPaths.languageStyle,
        name: AppRoutes.languageStyle,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LanguageStyleScreen(),
      ),
      GoRoute(
        path: AppPaths.auth,
        name: AppRoutes.auth,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppPaths.interests,
        name: AppRoutes.interests,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const InterestsScreen(),
      ),
      GoRoute(
        path: AppPaths.followSuggestions,
        name: AppRoutes.followSuggestions,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FollowSuggestionsScreen(),
      ),
      GoRoute(
        path: AppPaths.paywallPreview,
        name: AppRoutes.paywallPreview,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PaywallPreviewScreen(),
      ),
      GoRoute(
        path: AppPaths.permissions,
        name: AppRoutes.permissions,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PermissionsScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => _MainShell(
          currentPath: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppPaths.main,
            name: AppRoutes.main,
            redirect: (context, state) => AppPaths.home,
          ),
          GoRoute(
            path: AppPaths.home,
            name: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppPaths.explore,
            name: AppRoutes.explore,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExploreScreen(),
            ),
          ),
          GoRoute(
            path: AppPaths.discovery,
            name: AppRoutes.discovery,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DiscoveryScreen(),
            ),
          ),
          GoRoute(
            path: AppPaths.profile,
            name: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '${AppPaths.story}/:id',
        name: AppRoutes.story,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final type = state.uri.queryParameters['type'] ?? 'post';
          return StoryDetailScreen(id: id, contentType: type);
        },
      ),
      // Comments route removed - comments are shown in story detail screen via bottom sheet
      GoRoute(
        path: AppPaths.notifications,
        name: AppRoutes.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppPaths.bookmarks,
        name: AppRoutes.bookmarks,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: AppPaths.search,
        name: AppRoutes.search,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppPaths.reportBlockMute,
        name: AppRoutes.reportBlockMute,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return ReportBlockMuteScreen(
            contentId: q['contentId'],
            contentType: q['contentType'] ?? 'post',
            creatorId: q['creatorId'],
          );
        },
      ),
      GoRoute(
        path: AppPaths.settings,
        name: AppRoutes.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppPaths.accessibility,
        name: AppRoutes.accessibility,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AccessibilityScreen(),
      ),
      GoRoute(
        path: AppPaths.contentPrefs,
        name: AppRoutes.contentPrefs,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ContentPrefsScreen(),
      ),
      GoRoute(
        path: AppPaths.aiPrefs,
        name: AppRoutes.aiPrefs,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiPrefsScreen(),
      ),
      GoRoute(
        path: AppPaths.account,
        name: AppRoutes.account,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: AppPaths.privacy,
        name: AppRoutes.privacy,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: AppPaths.editProfile,
        name: AppRoutes.editProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppPaths.drafts,
        name: AppRoutes.drafts,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DraftsScreen(),
      ),
      GoRoute(
        path: AppPaths.premiumHub,
        name: AppRoutes.premiumHub,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PremiumHubScreen(),
      ),
      GoRoute(
        path: AppPaths.writePost,
        name: 'write-post',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WritePostScreen(),
      ),
      GoRoute(
        path: AppPaths.aiPost,
        name: 'ai-post',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiPostScreen(),
      ),
      GoRoute(
        path: AppPaths.createLesson,
        name: 'create-lesson',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateLessonScreen(),
      ),
      GoRoute(
        path: AppPaths.studyBuddy,
        name: 'study-buddy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StudyBuddyScreen(),
      ),
      GoRoute(
        path: AppPaths.collections,
        name: AppRoutes.collections,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CollectionsListScreen(),
      ),
      GoRoute(
        path: AppPaths.collectionPlay,
        name: AppRoutes.collectionPlay,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Collection) {
            return CollectionPlayScreen(collection: extra);
          }
          final id = state.pathParameters['id'] ?? '';
          // Fallback: create a minimal collection (shouldn't happen if navigation is correct)
          return CollectionPlayScreen(
            collection: Collection(
              id: id,
              ownerId: '',
              title: 'Collection',
              description: null,
              coverUrl: null,
              isPublic: true,
              itemIds: [],
              itemTypes: [],
            ),
          );
        },
      ),
      GoRoute(
        path: AppPaths.userProfile,
        name: AppRoutes.userProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return UserProfileScreen(userId: userId);
        },
      ),
    ],
  );
}

class _MainShell extends StatelessWidget {
  const _MainShell({required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _FloatingNavBar(currentPath: currentPath),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: GlassSurface(
            borderRadius: BorderRadius.circular(32),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            blur: 30,
            shadow: BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  path: AppPaths.home,
                  currentPath: currentPath,
                ),
                const SizedBox(width: 8),
                _NavItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Explore',
                  path: AppPaths.explore,
                  currentPath: currentPath,
                ),
                const SizedBox(width: 8),
                _NavItem(
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle,
                  path: AppPaths.home,
                  currentPath: currentPath,
                  isCreate: true,
                ),
                const SizedBox(width: 8),
                _NavItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Discovery',
                  path: AppPaths.discovery,
                  currentPath: currentPath,
                ),
                const SizedBox(width: 8),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  path: AppPaths.profile,
                  currentPath: currentPath,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.path,
    required this.currentPath,
    this.activeIcon,
    this.label,
    this.isCreate = false,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String? label;
  final String path;
  final String currentPath;
  final bool isCreate;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentPath == path && !isCreate;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        horizontal: isSelected ? 16 : 12,
        vertical: isSelected ? 10 : 8,
      ),
      decoration: isSelected
          ? BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isCreate) {
              showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CreateSheet(),
              ).then((value) {
                if (value == 'write') context.push(AppPaths.writePost);
                if (value == 'ai') context.push(AppPaths.aiPost);
                if (value == 'lesson') context.push(AppPaths.createLesson);
                if (value == 'buddy') context.push(AppPaths.studyBuddy);
              });
            } else {
              context.go(path);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isCreate
                        ? (isSelected ? Icons.add_circle : Icons.add_circle_outline)
                        : (isSelected ? (activeIcon ?? icon) : icon),
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
                    size: 22,
                  ),
                ),
                if (label != null && isSelected) ...[
                  const SizedBox(width: 6),
                  Text(
                    label!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

