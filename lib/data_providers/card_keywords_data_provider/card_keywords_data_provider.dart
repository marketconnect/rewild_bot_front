import 'package:hive/hive.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/card_keyword.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CardKeywordsDataProvider
    implements UpdateServiceCardKeywordsDataProvider {
  const CardKeywordsDataProvider();

  Future<Box<CardKeyword>> _openBox() async {
    return await Hive.openBox<CardKeyword>(HiveBoxes.cardKeywords);
  }

  @override
  Future<Either<RewildError, void>> insert(
      int cardId, List<(String keyword, int freq)> keywords) async {
    try {
      final box = await _openBox();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var keyword in keywords) {
        final cardKeyword = CardKeyword(
          cardId: cardId,
          keyword: keyword.$1,
          freq: keyword.$2,
          updatedAt: dateStr,
        );
        await box.put('${cardId}_${keyword.$1}', cardKeyword);
      }

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
      final box = await _openBox();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final results = box.values.where((cardKeyword) =>
          cardKeyword.cardId == cardId && cardKeyword.updatedAt == todayStr);

      final keywords = results.map((row) => (row.keyword, row.freq)).toList();

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
  Future<Either<RewildError, void>> deleteKeywordsOlderThanOneDay() async {
    try {
      final box = await _openBox();
      final yesterdayStr = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));

      final keysToDelete = box.keys.where((key) {
        final cardKeyword = box.get(key) as CardKeyword?;
        return cardKeyword != null &&
            cardKeyword.updatedAt.compareTo(yesterdayStr) < 0;
      }).toList();

      for (var key in keysToDelete) {
        await box.delete(key);
      }

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
