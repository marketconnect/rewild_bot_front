import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/warehouse.dart';
import 'package:rewild_bot_front/presentation/single_card_screen/single_card_screen_view_model.dart';

abstract class WarehouseServiceWarehouseProvider {
  Future<Either<RewildError, bool>> update(
      {required List<Warehouse> warehouses});
  Future<Either<RewildError, String?>> get({required int id});
}

abstract class WarehouseServiceWerehouseApiClient {
  Future<Either<RewildError, List<Warehouse>>> getAll();
}

class WarehouseService implements SingleCardScreenWarehouseService {
  final WarehouseServiceWarehouseProvider warehouseProvider;
  final WarehouseServiceWerehouseApiClient warehouseApiClient;
  const WarehouseService(
      {required this.warehouseProvider, required this.warehouseApiClient});

  @override
  Future<Either<RewildError, Warehouse>> getById({required int id}) async {
    // try get from db
    final getEither = await warehouseProvider.get(id: id);

    if (getEither.isRight()) {
      final name = getEither.fold((l) => null, (name) => name);
      if (name != null) {
        Warehouse warehouse = Warehouse(
          id: id,
          name: name,
        );

        return right(warehouse);
      }
    }

    // warehouse does`t exist
    final fetchedWarehusesEither = await warehouseApiClient.getAll();
    if (fetchedWarehusesEither.isLeft()) {
      return left(fetchedWarehusesEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }
    final fetchedWarehouses = fetchedWarehusesEither.fold(
        (l) => throw UnimplementedError(), (r) => r);

    final okEither =
        await warehouseProvider.update(warehouses: fetchedWarehouses);
    if (okEither.isLeft()) {
      return left(okEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    // try again get from db
    final againGetEither = await warehouseProvider.get(id: id);
    if (againGetEither.isLeft()) {
      return left(
          againGetEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final name = againGetEither.fold((l) => null, (name) => name);

    // warehouse exists
    Warehouse warehouse = Warehouse(
      id: id,
      name: name ?? "",
    );
    return right(warehouse);
  }
}
