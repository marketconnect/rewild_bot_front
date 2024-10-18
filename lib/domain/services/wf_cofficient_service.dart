import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/wh_coeffs.dart';
import 'package:rewild_bot_front/presentation/wh_coefficients_screen/wh_coefficients_view_model.dart';

abstract class WfCofficientServiceWfCofficientApiClient {
  Future<Either<RewildError, void>> subscribe({
    required String token,
    required int warehouseId,
    required double threshold,
  });
  Future<Either<RewildError, void>> unsubscribe({
    required String token,
    required int warehouseId,
  });
  Future<Either<RewildError, List<WarehouseCoeffs>>> getAllWarehouses({
    required String token,
  });
}

abstract class WhCoefficientsServiceDataProvider {
  Future<Either<RewildError, void>> subscribe(WarehouseCoeffs warehouseCoeffs);
  Future<Either<RewildError, void>> unsubscribe(int warehouseId, int boxTypeId);
  Future<Either<RewildError, List<WarehouseCoeffs>>> getAll();
}

class WfCofficientService
    implements WhCoefficientsViewModelWfCofficientService {
  final WfCofficientServiceWfCofficientApiClient apiClient;
  final WhCoefficientsServiceDataProvider dataProvider;
  WfCofficientService({
    required this.apiClient,
    required this.dataProvider,
  });

  @override
  Future<Either<RewildError, void>> subscribe({
    required String token,
    required WarehouseCoeffs warehouseCoeffs,
  }) async {
    // save local
    await dataProvider.subscribe(warehouseCoeffs);

    return await apiClient.subscribe(
      token: token,
      warehouseId: warehouseCoeffs.warehouseId,
      threshold: warehouseCoeffs.coefficient,
    );
  }

  @override
  Future<Either<RewildError, void>> unsubscribe({
    required String token,
    required int warehouseId,
    required int boxTypeId,
  }) async {
    // unsubscribe local
    await dataProvider.unsubscribe(warehouseId, boxTypeId);

    return await apiClient.unsubscribe(
      token: token,
      warehouseId: warehouseId,
    );
  }

  @override
  Future<Either<RewildError, List<WarehouseCoeffs>>> getAllWarehouses({
    required String token,
  }) async {
    return await apiClient.getAllWarehouses(
      token: token,
    );
  }

  @override
  Future<Either<RewildError, List<WarehouseCoeffs>>>
      getCurrentSubscriptions() async {
    return await dataProvider.getAll();
  }
}
