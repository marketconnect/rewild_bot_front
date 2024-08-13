import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/card_of_product.dart';
import 'package:rewild_bot_front/domain/services/all_cards_filter_service.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CardOfProductDataProvider
    implements
        UpdateServiceCardOfProductDataProvider,
        AllCardsFilterServiceCardsOfProductDataProvider,
        CardOfProductServiceCardOfProductDataProvider {
  const CardOfProductDataProvider();

  Box<CardOfProduct> get _box =>
      Hive.box<CardOfProduct>(HiveBoxes.cardOfProducts);

  @override
  Future<Either<RewildError, List<int>>> getAllNmIds() async {
    try {
      final nmIds = _box.values.map((e) => e.nmId).toList();
      return right(nmIds);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getAllNmIds",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> insertOrUpdate({
    required CardOfProduct card,
  }) async {
    try {
      await _box.put(card.nmId, card);
      return right(card.nmId);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось обновить карточку в памяти телефона: ${e.toString()}',
        source: runtimeType.toString(),
        name: "insertOrUpdate",
        args: [card],
      ));
    }
  }

  @override
  Future<Either<RewildError, String>> getImage({required int id}) async {
    try {
      final card = _box.get(id);
      if (card == null || card.img == null) {
        return right("");
      }
      return right(card.img!);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getImage",
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> delete({required int id}) async {
    try {
      await _box.delete(id);
      return right(id);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "delete",
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, CardOfProduct?>> get({
    required int nmId,
  }) async {
    try {
      final card = _box.get(nmId);
      return right(card);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "get",
        args: [nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<CardOfProduct>>> getAll(
      [List<int>? nmIds]) async {
    try {
      List<CardOfProduct> cards;
      if (nmIds != null) {
        cards = _box.values.where((card) => nmIds.contains(card.nmId)).toList();
      } else {
        cards = _box.values.toList();
      }
      return right(cards);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось получить карточки из памяти телефона: ${e.toString()}',
        source: runtimeType.toString(),
        name: "getAll",
        args: [nmIds],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<CardOfProduct>>> getAllBySupplierId({
    required int supplierId,
  }) async {
    try {
      final cards =
          _box.values.where((card) => card.supplierId == supplierId).toList();
      return right(cards);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getAllBySupplierId",
        args: [supplierId],
      ));
    }
  }
}
