import 'package:fpdart/fpdart.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:idb_shim/idb.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/services/card_keywords_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CardKeywordsDataProvider
    implements
        UpdateServiceCardKeywordsDataProvider,
        CardKeywordsServiceCardKeywordsDataProvider {
  const CardKeywordsDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> insert(
      int cardId, List<(String keyword, int freq)> keywords) async {
    try {
      final db = await _db;
      final txn = db.transaction('card_keywords', idbModeReadWrite);
      final store = txn.objectStore('card_keywords');
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var keyword in keywords) {
        await store.put({
          'cardId': cardId,
          'keyword': keyword.$1,
          'freq': keyword.$2,
          'updatedAt': dateStr,
          'cardIdKeyword': cardId.toString() + keyword.$1,
        });
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to insert keywords for cardId $cardId: ${e.toString()}",
        source: "CardKeywordsDataProvider",
        name: "insert",
        args: [cardId, keywords],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<(String keyword, int freq)>>>
      getKeywordsByCardId(int cardId) async {
    try {
      final db = await _db;
      final txn = db.transaction('card_keywords', idbModeReadOnly);
      final store = txn.objectStore('card_keywords');
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final index = store.index('cardId');
      final range = KeyRange.only(cardId);
      final cursorStream = index.openCursor(range: range);

      final List<(String keyword, int freq)> keywords = [];

      await for (final cursor in cursorStream) {
        final value = cursor.value as Map<String, dynamic>;
        if (value['updatedAt'] == todayStr) {
          keywords.add((value['keyword'] as String, value['freq'] as int));
        }
        cursor.next();
      }

      await txn.completed;
      return right(keywords);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve keywords for cardId $cardId: ${e.toString()}",
        source: "CardKeywordsDataProvider",
        name: "getKeywordsByCardId",
        args: [cardId],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAllKeywords() async {
    try {
      final db = await _db;
      final txn = db.transaction('card_keywords', idbModeReadWrite);
      final store = txn.objectStore('card_keywords');

      final allKeywordsRequest = store.clear();

      await allKeywordsRequest;

      await txn.completed;

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete old card keywords: ${e.toString()}",
        source: "CardKeywordsDataProvider",
        name: "deleteKeywordsOlderThanOneDay",
        args: [],
        sendToTg: true,
      ));
    }
  }
}
