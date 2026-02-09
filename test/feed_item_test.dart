import 'package:flutter_test/flutter_test.dart';
import 'package:skrolz_app/features/feed/models/feed_item.dart';

void main() {
  group('FeedItem', () {
    test('fromJson builds item with required fields', () {
      final json = {
        'id': 'abc',
        'content_type': 'post',
        'body': 'Hello world',
      };
      final item = FeedItem.fromJson(json);
      expect(item.id, 'abc');
      expect(item.contentType, 'post');
      expect(item.body, 'Hello world');
    });

    test('fromJson defaults content_type to post', () {
      final item = FeedItem.fromJson({'id': '1'});
      expect(item.contentType, 'post');
    });

    test('toJson round-trip', () {
      final item = FeedItem(id: 'x', contentType: 'lesson', title: 'Test');
      final json = item.toJson();
      expect(FeedItem.fromJson(json).id, item.id);
      expect(FeedItem.fromJson(json).title, item.title);
    });
  });
}
