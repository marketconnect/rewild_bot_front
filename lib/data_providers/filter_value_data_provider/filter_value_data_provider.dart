import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/filter_value.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class FilterValuesDataProvider implements UpdateServiceFilterDataProvider {
  const FilterValuesDataProvider();

  Future<Box<FilterValue>> _openBox() async {
    return await Hive.openBox<FilterValue>(HiveBoxes.filterValues);
  }

  @override
  Future<Either<RewildError, void>> insert(
      String filterName, List<String> values) async {
    try {
      final box = await _openBox();
      final DateTime updatedAt = DateTime.now();

      for (var value in values) {
        final key =
            '$filterName-$value'; // Используем уникальный ключ для каждого значения фильтра
        final filterValue = FilterValue(
          filterName: filterName,
          value: value,
          updatedAt: updatedAt,
        );
        await box.put(key, filterValue);
      }

      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "insert",
        sendToTg: true,
        args: [filterName, values],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<String>>> getAllForFilterName(
      String filterName) async {
    try {
      final box = await _openBox();
      final values = box.values
          .where((filterValue) => filterValue.filterName == filterName)
          .map((filterValue) => filterValue.value)
          .toList();

      return right(values);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "getAllForFilterName",
        sendToTg: true,
        args: [filterName],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteOld() async {
    try {
      final box = await _openBox();
      final today = DateTime.now();

      final oldValues = box.values.where((filterValue) {
        return filterValue.updatedAt
            .isBefore(DateTime(today.year, today.month, today.day));
      }).toList();

      for (var oldValue in oldValues) {
        await oldValue.delete();
      }

      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "deleteOld",
        sendToTg: true,
        args: [],
      ));
    }
  }
}
