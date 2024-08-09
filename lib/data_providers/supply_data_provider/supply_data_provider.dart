import 'package:hive/hive.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/supply.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class SupplyDataProvider implements UpdateServiceSupplyDataProvider {
  const SupplyDataProvider();

  Box<Supply> get _box => Hive.box<Supply>(HiveBoxes.supplies);

  @override
  Future<Either<RewildError, int>> insert({required Supply supply}) async {
    try {
      await _box.put(supply.nmId, supply);
      return right(supply.nmId);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Не удалось сохранить поставки $e',
          source: runtimeType.toString(),
          name: "insert",
          args: [supply]));
    }
  }

  @override
  Future<Either<RewildError, void>> delete({
    required int nmId,
    int? wh,
    int? sizeOptionId,
  }) async {
    try {
      if (wh == null || sizeOptionId == null) {
        await _box.delete(nmId);
        return right(null);
      }

      // Удаляем только нужную запись с учетом условий
      final supply = await _box.get(nmId);
      if (supply != null &&
          supply.wh == wh &&
          supply.sizeOptionId == sizeOptionId) {
        await _box.delete(nmId);
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Не удалось удалить поставки $e',
          source: runtimeType.toString(),
          name: "delete",
          args: [nmId]));
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
          'Не удалось удалить все поставки $e',
          source: runtimeType.toString(),
          name: "deleteAll",
          args: []));
    }
  }

  @override
  Future<Either<RewildError, Supply?>> getOne({
    required int nmId,
    required int wh,
    required int sizeOptionId,
  }) async {
    try {
      final supply = _box.values.where((s) =>
          s.nmId == nmId && s.wh == wh && s.sizeOptionId == sizeOptionId);
      if (supply.isEmpty) {
        return right(null);
      }
      return right(supply.first);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Не удалось получить поставки: $e',
          source: runtimeType.toString(),
          name: "getOne",
          args: [nmId, wh, sizeOptionId]));
    }
  }

  @override
  Future<Either<RewildError, List<Supply>?>> getForOne({
    required int nmId,
  }) async {
    try {
      final supplies = _box.values.where((s) => s.nmId == nmId).toList();
      return right(supplies);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Не удалось получить поставки: $e',
          source: runtimeType.toString(),
          name: "getForOne",
          args: [nmId]));
    }
  }

  @override
  Future<Either<RewildError, List<Supply>>> get({
    required int nmId,
  }) async {
    try {
      final supplies = _box.values.where((s) => s.nmId == nmId).toList();
      return right(supplies);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Не удалось получить поставки $e',
          source: runtimeType.toString(),
          name: "get",
          args: [nmId]));
    }
  }
}
