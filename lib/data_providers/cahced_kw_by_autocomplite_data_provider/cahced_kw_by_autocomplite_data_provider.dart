import 'package:hive/hive.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/cached_keyword.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CachedKwByAutocompliteDataProvider
    implements UpdateServiceKwByAutocompliteDataProvider {
  const CachedKwByAutocompliteDataProvider();

  Future<Box<CachedKeyword>> _openBox() async {
    return await Hive.openBox<CachedKeyword>(HiveBoxes.cachedKeywords);
  }

  @override
  Future<Either<RewildError, void>> addAll(List<(String, int)> keywords) async {
    try {
      final box = await _openBox();

      for (var keyword in keywords) {
        final cachedKeyword = CachedKeyword(
          keyword: keyword.$1,
          freq: keyword.$2,
        );
        await box.put(keyword.$1, cachedKeyword); // keyword as key
      }

      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "addAll",
        sendToTg: true,
        args: [keywords],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<(String, int)>>> getAll() async {
    try {
      final box = await _openBox();
      final keywords =
          box.values.map((keyword) => (keyword.keyword, keyword.freq)).toList();
      return right(keywords);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "getAll",
        sendToTg: true,
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final box = await _openBox();
      await box.clear();
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "deleteAll",
        sendToTg: true,
        args: [],
      ));
    }
  }
}
