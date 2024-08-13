import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/seller.dart';
import 'package:rewild_bot_front/domain/services/all_cards_filter_service.dart';

class SellerDataProvider implements AllCardsFilterServiceSellerDataProvider {
  const SellerDataProvider();

  Box<Seller> get _box => Hive.box<Seller>(HiveBoxes.sellers);

  @override
  Future<Either<RewildError, int>> insert({required Seller seller}) async {
    try {
      await _box.put(seller.supplierId, seller);
      return right(seller.supplierId);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось вставить данные продавца: $e",
        source: runtimeType.toString(),
        name: 'insert',
        args: [seller],
      ));
    }
  }

  Future<Either<RewildError, void>> delete(int supplierId) async {
    try {
      await _box.delete(supplierId);
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось удалить данные продавца: $e",
        source: runtimeType.toString(),
        name: 'delete',
        args: [supplierId],
      ));
    }
  }

  @override
  Future<Either<RewildError, Seller?>> get({required int supplierId}) async {
    try {
      final seller = _box.get(supplierId);
      return right(seller);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось получить данные продавца: $e",
        source: runtimeType.toString(),
        name: "get",
        args: [supplierId],
      ));
    }
  }

  Future<Either<RewildError, int>> update(Seller seller) async {
    try {
      await _box.put(seller.supplierId, seller);
      return right(seller.supplierId);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось обновить данные продавца: $e",
        source: runtimeType.toString(),
        name: 'update',
        args: [seller],
      ));
    }
  }

  Future<Either<RewildError, List<Seller>>> getAll() async {
    try {
      final sellers = _box.values.toList();
      return right(sellers);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось получить данные продавцов: $e",
        source: runtimeType.toString(),
        name: 'getAll',
        args: [],
      ));
    }
  }
}
