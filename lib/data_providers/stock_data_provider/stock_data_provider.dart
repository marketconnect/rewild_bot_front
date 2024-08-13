import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/stock.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class StockDataProvider
    implements
        UpdateServiceStockDataProvider,
        CardOfProductServiceStockDataProvider {
  // Получаем доступ к коробке Hive
  Box<Stock> get _box => Hive.box<Stock>(HiveBoxes.stocks);

  const StockDataProvider();

  @override
  Future<Either<RewildError, int>> insert({required Stock stock}) async {
    try {
      // Добавляем данные в Hive
      await _box.put(stock.nmId, stock);
      return right(stock.key as int); // Возвращаем ID (ключ)
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось сохранить остатки $e',
        source: runtimeType.toString(),
        name: "insert",
        args: [stock],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> delete(int nmId) async {
    try {
      await _box.delete(nmId); // Удаляем элемент по ключу
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось удалить остатки $e',
        source: runtimeType.toString(),
        name: "delete",
        args: [nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<Stock>>> get({required int nmId}) async {
    try {
      final stock = _box.get(nmId); // Получаем элемент по ключу
      if (stock != null) {
        return right([stock]);
      } else {
        return right([]);
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось получить остатки $e',
        source: runtimeType.toString(),
        name: "get",
        args: [nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, Stock>> getOne({
    required int nmId,
    required int wh,
    required int sizeOptionId,
  }) async {
    try {
      final stock = _box.values.firstWhere(
        (s) => s.nmId == nmId && s.wh == wh && s.sizeOptionId == sizeOptionId,
        orElse: () => throw Exception('Not Found'),
      );
      return right(stock);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось получить остатки $e',
        source: runtimeType.toString(),
        name: "getOne",
        args: [nmId, wh, sizeOptionId],
      ));
    }
  }

  Future<Either<RewildError, int>> update({
    required Stock stock,
    required int nmId,
  }) async {
    try {
      // Обновляем данные в Hive
      await _box.put(nmId, stock);
      return right(stock.key as int); // Возвращаем ID (ключ)
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось обновить остатки $e',
        source: runtimeType.toString(),
        name: "update",
        args: [stock, nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<Stock>>> getAll() async {
    try {
      final stocks = _box.values.toList();
      return right(stocks);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось получить остатки $e',
        source: runtimeType.toString(),
        name: "getAll",
        args: [],
      ));
    }
  }

  Future<Either<RewildError, List<Stock>>> getAllByWh(String wh) async {
    try {
      final stocks = _box.values.where((s) => s.wh.toString() == wh).toList();
      return right(stocks);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось Получить остатки $e',
        source: runtimeType.toString(),
        name: "getAllByWh",
        args: [wh],
      ));
    }
  }
}
