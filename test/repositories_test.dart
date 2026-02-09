import 'package:flutter_test/flutter_test.dart';
import 'package:skrolz_app/data/local/drafts_repository.dart';

void main() {
  group('DraftsRepository', () {
    test('save and retrieve draft', () async {
      final draft = Draft(
        id: 'test_1',
        type: 'post',
        data: {'body': 'Test post'},
        createdAt: DateTime.now(),
      );
      
      await DraftsRepository.saveDraft(draft);
      final retrieved = await DraftsRepository.getDraft('test_1');
      
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test_1'));
      expect(retrieved.type, equals('post'));
      expect(retrieved.data['body'], equals('Test post'));
      
      await DraftsRepository.deleteDraft('test_1');
    });

    test('get all drafts', () async {
      final draft1 = Draft(
        id: 'test_1',
        type: 'post',
        data: {'body': 'Post 1'},
        createdAt: DateTime.now(),
      );
      final draft2 = Draft(
        id: 'test_2',
        type: 'lesson',
        data: {'title': 'Lesson 1'},
        createdAt: DateTime.now(),
      );
      
      await DraftsRepository.saveDraft(draft1);
      await DraftsRepository.saveDraft(draft2);
      
      final all = await DraftsRepository.getAllDrafts();
      expect(all.length, greaterThanOrEqualTo(2));
      
      await DraftsRepository.deleteDraft('test_1');
      await DraftsRepository.deleteDraft('test_2');
    });
  });
}
