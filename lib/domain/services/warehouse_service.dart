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
    final getEither = await warehouseProvider.get(id: id);
    return getEither.fold((l) => left(l), (name) async {
      // warehouse exists
      if (name != null) {
        Warehouse warehouse = Warehouse(
          id: id,
          name: name,
        );
        return right(warehouse);
      }
      // warehouse does`t exist
      final fetchedWarehusesEither = await warehouseApiClient.getAll();
      return fetchedWarehusesEither.fold((l) => left(l),
          (fetchedWarehouses) async {
        final okEither =
            await warehouseProvider.update(warehouses: fetchedWarehouses);
        return okEither.fold((l) => left(l), (ok) async {
          final againGetEither = await warehouseProvider.get(id: id);
          return againGetEither.fold((l) => left(l), (name) {
            // warehouse exists

            Warehouse warehouse = Warehouse(
              id: id,
              name: name ?? "",
            );
            return right(warehouse);
          });
        });
      });
    });
  }
}
