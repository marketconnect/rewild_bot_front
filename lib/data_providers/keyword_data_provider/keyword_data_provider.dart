import 'package:fpdart/fpdart.dart';
import 'package:idb_shim/idb.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword.dart';
import 'package:rewild_bot_front/domain/services/keywords_service.dart';

class KeywordDataProvider implements KeywordsServiceKeywordsDataProvider {
  const KeywordDataProvider();
  Future<Database> get _db async => await DatabaseHelper().database;
  @override
  Future<Either<RewildError, Keyword>> updateWithNormQuery(
      String keyword, String normQuery) async {
    try {
      final db = await _db;
      final txn = db.transaction('keywords', idbModeReadWrite);
      final store = txn.objectStore('keywords');

      // Обновляем normquery для указанного keyword
      final existingRecord = await store.index('keyword').get(keyword);
      if (existingRecord != null) {
        final updatedRecord = Map<String, dynamic>.from(existingRecord as Map);

        updatedRecord['normquery'] = normQuery;

        // Сохраняем обновленную запись
        await store.put(updatedRecord);

        await txn.completed;

        final updatedKeyword = Keyword(
          keyword: updatedRecord['keyword'] as String,
          count: updatedRecord['count'] as int,
          normquery: updatedRecord['normquery'] as String,
          campaignId: updatedRecord['campaignId'] as int,
        );

        return right(updatedKeyword);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Keyword not found",
          source: "KeywordDataProvider",
          name: "updateWithNormQuery",
          args: [keyword],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "KeywordDataProvider",
        name: "updateWithNormQuery",
        args: [keyword],
      ));
    }
  }

  @override
  @override
  Future<Either<RewildError, bool>> save(Keyword keyword) async {
    try {
      final db = await _db;
      final txn = db.transaction('keywords', idbModeReadWrite);
      final store = txn.objectStore('keywords');

      // Вставляем новую запись
      await store.put({
        'keyword': keyword.keyword,
        'count': keyword.count,
        'normquery': keyword.normquery,
        'campaignId': keyword.campaignId,
        'campaignIdKeyword': keyword.campaignIdKeyword,
      });

      await txn.completed;

      return right(true);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "KeywordDataProvider",
        name: "save",
        args: [keyword],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<Keyword>>> getAll(int campaignId) async {
    try {
      final db = await _db;
      final txn = db.transaction('keywords', idbModeReadOnly);
      final store = txn.objectStore('keywords');

      // Получаем все записи для указанного campaignId
      final result = await store.index('campaignId').getAll(campaignId);

      await txn.completed;

      // Преобразуем результат в список карт
      final keywords = (result as List)
          .whereType<
              Map<String,
                  dynamic>>() // Отфильтровываем только Map<String, dynamic>
          .map((e) => Keyword(
                keyword: e['keyword'] as String,
                count: e['count'] as int,
                normquery: e['normquery'] as String? ?? '',
                campaignId: e['campaignId'] as int,
              ))
          .toList();

      return right(keywords);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "KeywordDataProvider",
        name: "getAll",
        args: [campaignId],
      ));
    }
  }
}
