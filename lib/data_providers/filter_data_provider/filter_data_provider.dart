import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/filter_model.dart';
import 'package:rewild_bot_front/domain/services/all_cards_filter_service.dart';

class FilterDataProvider implements AllCardsFilterFilterDataProvider {
  const FilterDataProvider();

  Box<FilterModel> get _box => Hive.box<FilterModel>(HiveBoxes.filters);

  @override
  Future<Either<RewildError, void>> insert(
      {required FilterModel filter}) async {
    try {
      await _box.put('current_filter', filter);
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "insert",
        args: [filter],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> delete() async {
    try {
      await _box.delete('current_filter');
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "delete",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, FilterModel>> get() async {
    try {
      final filter = _box.get('current_filter');
      if (filter == null) {
        return right(FilterModel.empty());
      }
      return right(filter);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "get",
        args: [],
      ));
    }
  }
}
