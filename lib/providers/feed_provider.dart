import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skrolz_app/data/local/skrolz_cache.dart';
import 'package:skrolz_app/data/supabase/feed_repository.dart';
import 'package:skrolz_app/features/feed/models/feed_item.dart';

const _kFocusModeKey = 'skrolz_focus_mode';

/// Tab index: 0=For You, 1=Following, 2=Trending, 3=Curated.
final feedItemsProvider = FutureProvider.family<List<FeedItem>, int>((ref, tabIndex) async {
  final cache = await SkrolzCache.instance;
  final tab = tabIndex < 4 ? FeedTab.values[tabIndex] : FeedTab.forYou;
  final cached = await cache.getCachedFeed(limit: 20);
  final fallback = cached.map((r) => FeedItem.fromJson(r)).toList();

  final remote = await FeedRepository.getFeed(limit: 20, tab: tab, useCurated: tab == FeedTab.curated);
  if (remote.isNotEmpty) {
    await cache.mergeFeedItems(remote.map((e) => e.toJson()).toList());
    return remote;
  }
  return fallback;
});

/// Paginated feed provider - loads more items on demand
final paginatedFeedProvider = FutureProvider.family<List<FeedItem>, int>((ref, tabIndex) async {
  // For now, return the same as feedItemsProvider
  // Pagination will be handled in feed_pager by loading more when needed
  final cache = await SkrolzCache.instance;
  final tab = tabIndex < 4 ? FeedTab.values[tabIndex] : FeedTab.forYou;
  final cached = await cache.getCachedFeed(limit: 20);
  final fallback = cached.map((r) => FeedItem.fromJson(r)).toList();

  final remote = await FeedRepository.getFeed(limit: 20, tab: tab, useCurated: tab == FeedTab.curated);
  if (remote.isNotEmpty) {
    await cache.mergeFeedItems(remote.map((e) => e.toJson()).toList());
    return remote;
  }
  return fallback;
});

/// Focus mode: persisted to SharedPreferences.
final focusModeProvider = NotifierProvider<FocusModeNotifier, bool>(FocusModeNotifier.new);

class FocusModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kFocusModeKey) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFocusModeKey, state);
  }
}
