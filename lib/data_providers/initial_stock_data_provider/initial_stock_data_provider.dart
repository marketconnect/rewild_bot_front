import 'package:hive/hive.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/initial_stock.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class InitialStockDataProvider
    implements
        UpdateServiceInitStockDataProvider,
        CardOfProductServiceInitStockDataProvider {
  const InitialStockDataProvider();

  Box<InitialStock> get _box => Hive.box<InitialStock>(HiveBoxes.initialStocks);

  @override
  Future<Either<RewildError, int>> insert(
      {required InitialStock initialStock}) async {
    try {
      int id = await _box.add(initialStock); // Hive сам назначает ключ
      return right(id);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось сохранить остатки на начало дня: $e',
        source: runtimeType.toString(),
        name: "insert",
        args: [initialStock],
      ));
    }
  }

  Future<Either<RewildError, void>> delete({required int id}) async {
    try {
      await _box.delete(id);
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось удалить остатки на начало дня: $e',
        source: runtimeType.toString(),
        name: "delete",
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      await _box.clear();
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось удалить остатки на начало дня: $e',
        source: runtimeType.toString(),
        name: "deleteAll",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<InitialStock>>> get({
    required int nmId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final initialStocks = _box.values
          .where((stock) =>
              stock.nmId == nmId &&
              stock.date.isAfter(dateFrom) &&
              stock.date.isBefore(dateTo))
          .toList();
      return right(initialStocks);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось получить остатки на начало дня: $e',
        source: runtimeType.toString(),
        name: "get",
        args: [nmId, dateFrom, dateTo],
      ));
    }
  }

  @override
  Future<Either<RewildError, InitialStock?>> getOne({
    required int nmId,
    required DateTime dateFrom,
    required DateTime dateTo,
    required int wh,
    required int sizeOptionId,
  }) async {
    try {
      final initialStock = _box.values.where((stock) =>
          stock.nmId == nmId &&
          stock.date.isAfter(dateFrom) &&
          stock.date.isBefore(dateTo) &&
          stock.wh == wh &&
          stock.sizeOptionId == sizeOptionId);
      if (initialStock.isEmpty) {
        return right(null);
      }

      return right(initialStock.first);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось получить остатки на начало дня: $e',
        source: runtimeType.toString(),
        name: "getOne",
        args: [nmId, dateFrom, dateTo, wh, sizeOptionId],
      ));
    }
  }

  Future<Either<RewildError, int>> update({
    required InitialStock initialStock,
  }) async {
    try {
      // Проверяем, что id не null
      if (initialStock.id == null) {
        return left(RewildError(
          sendToTg: true,
          'ID не может быть null при обновлении.',
          source: runtimeType.toString(),
          name: "update",
          args: [initialStock],
        ));
      }

      await _box.put(initialStock.id!,
          initialStock); // Используем `!` для явного приведения
      return right(initialStock.id!);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось обновить остатки на начало дня: $e',
        source: runtimeType.toString(),
        name: "update",
        args: [initialStock],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<InitialStock>>> getAll({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final initialStocks = _box.values
          .where((stock) =>
              stock.date.isAfter(dateFrom) && stock.date.isBefore(dateTo))
          .toList();
      return right(initialStocks);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось получить остатки на начало дня: $e',
        source: runtimeType.toString(),
        name: "getAll",
        args: [dateFrom, dateTo],
      ));
    }
  }
}
