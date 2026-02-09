import 'package:flutter_test/flutter_test.dart';
import 'package:skrolz_app/data/supabase/feed_repository.dart';

void main() {
  group('FeedRepository', () {
    test('getFeed returns a list when Supabase not initialized', () async {
      final items = await FeedRepository.getFeed(limit: 10);
      expect(items, isA<List>());
      expect(items.length, lessThanOrEqualTo(10));
    });

    test('getFeed respects limit', () async {
      final items = await FeedRepository.getFeed(limit: 5);
      expect(items.length, lessThanOrEqualTo(5));
    });
  });
}
