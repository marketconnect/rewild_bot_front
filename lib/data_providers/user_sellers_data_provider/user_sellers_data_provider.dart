import 'package:hive/hive.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/user_seller.dart';
import 'package:rewild_bot_front/domain/services/api_keys_service.dart';

class UserSellersDataProvider
    implements ApiKeysServiceActiveSellerDataProvider {
  const UserSellersDataProvider();

  Box<UserSeller> get _box => Hive.box<UserSeller>(HiveBoxes.userSellers);

  @override
  Future<Either<RewildError, void>> addOne(UserSeller seller) async {
    try {
      await _box.put(seller.sellerId, seller);
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to add user seller: $e",
        source: runtimeType.toString(),
        name: "addOne",
        args: [seller],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<UserSeller>>> getAll() async {
    try {
      final sellers = _box.values.toList();
      return right(sellers);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve all user sellers: $e",
        source: runtimeType.toString(),
        name: "getAll",
        args: [],
        sendToTg: true,
      ));
    }
  }

  Future<Either<RewildError, void>> rename(
      String sellerId, String sellerName) async {
    try {
      final seller = _box.get(sellerId);
      if (seller != null) {
        // Создаем новый объект с обновленным именем
        final updatedSeller = UserSeller(
          sellerId: seller.sellerId,
          sellerName: sellerName, // Обновляем имя
          isActive: seller.isActive, // Сохраняем текущее значение isActive
        );

        // Сохраняем обновленный объект в Hive
        await _box.put(sellerId, updatedSeller);
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to rename user seller: $e",
        source: runtimeType.toString(),
        name: "rename",
        args: [sellerId, sellerName],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<UserSeller>>> getActive() async {
    try {
      final activeSellers =
          _box.values.where((seller) => seller.isActive).toList();
      if (activeSellers.isEmpty) {
        return right(
            [UserSeller(sellerId: '', sellerName: '', isActive: true)]);
      }
      return right(activeSellers);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve active user sellers: $e",
        source: runtimeType.toString(),
        name: "getActive",
        args: [],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> setActive(String sellerId) async {
    try {
      await resetAll();
      final seller = _box.get(sellerId);
      if (seller != null) {
        final updatedSeller = UserSeller(
          sellerId: seller.sellerId,
          sellerName: seller.sellerName,
          isActive: true,
        );
        await _box.put(sellerId, updatedSeller);
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to set active status for user seller: $e",
        source: runtimeType.toString(),
        name: "setActive",
        args: [sellerId],
        sendToTg: true,
      ));
    }
  }

  Future<Either<RewildError, void>> resetAll() async {
    try {
      // Проходим по всем объектам в Hive Box
      for (var seller in _box.values) {
        // Создаем новый объект с теми же значениями, но с isActive = false
        final updatedSeller = UserSeller(
          sellerId: seller.sellerId,
          sellerName: seller.sellerName,
          isActive: false, // Обновляем значение isActive
        );
        // Сохраняем обновленный объект в Hive
        await _box.put(seller.sellerId, updatedSeller);
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to reset all user sellers: $e",
        source: runtimeType.toString(),
        name: "resetAll",
        args: [],
        sendToTg: true,
      ));
    }
  }

  static Future<Either<RewildError, List<UserSeller>>> getAllInBg() async {
    try {
      final box = Hive.box<UserSeller>('user_sellers');
      final sellers = box.values.toList();
      return right(sellers);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve all user sellers: $e",
        source: 'getAllInBg',
        name: "getAll",
        args: [],
        sendToTg: true,
      ));
    }
  }
}
