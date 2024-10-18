// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/wh_coeffs.dart';

abstract class WhCoefficientsViewModelWfCofficientService {
  Future<Either<RewildError, void>> subscribe({
    required String token,
    required WarehouseCoeffs warehouseCoeffs,
  });
  Future<Either<RewildError, void>> unsubscribe({
    required String token,
    required int warehouseId,
    required int boxTypeId,
  });
  Future<Either<RewildError, List<WarehouseCoeffs>>> getAllWarehouses({
    required String token,
  });
  Future<Either<RewildError, List<WarehouseCoeffs>>> getCurrentSubscriptions();
}

abstract class WhCoefficientsScreenAuthService {
  Future<Either<RewildError, String>> getToken();
}

class WhCoefficientsViewModel extends ResourceChangeNotifier {
  final WhCoefficientsViewModelWfCofficientService wfCofficientService;
  final WhCoefficientsScreenAuthService authService;
  WhCoefficientsViewModel({
    required super.context,
    required this.wfCofficientService,
    required this.authService,
  }) {
    _asyncInit();
  }

  // Fields ====================================================================
  bool _isLoading = false;

  void setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  bool get isLoading => _isLoading;

  final List<WarehouseCoeffs> _warehouses = [];
  void setWarehouses(List<WarehouseCoeffs> warehouses) {
    _warehouses.clear();
    _warehouses.addAll(warehouses);
    notify();
  }

  List<WarehouseCoeffs> get warehouses => _warehouses;

  final List<WarehouseCoeffs> _currentSubscriptions = [];
  void setSubscriptions(List<WarehouseCoeffs> subscriptions) {
    _currentSubscriptions.clear();
    _currentSubscriptions.addAll(subscriptions);
  }

  List<WarehouseCoeffs> get curentSubscriptions => _currentSubscriptions;

  // Methods ===================================================================`
  Future<void> _asyncInit() async {
    setIsLoading(true);
    final token = await fetch(() => authService.getToken());
    if (token == null) {
      setIsLoading(false);
      return;
    }

    final warehousesOrNull =
        await fetch(() => wfCofficientService.getAllWarehouses(token: token));
    print('w1 ${warehousesOrNull}');
    if (warehousesOrNull == null) {
      setIsLoading(false);
      return;
    }
    print('w1 ${warehousesOrNull.length}');
    setWarehouses(warehousesOrNull);
    setIsLoading(false);
  }

  Future<void> subscribe({required WarehouseCoeffs warehouseCoeffs}) async {
    final token = await fetch(() => authService.getToken());
    if (token == null) {
      return;
    }

    await fetch(() => wfCofficientService.subscribe(
          token: token,
          warehouseCoeffs: warehouseCoeffs,
        ));
    await _asyncInit();
  }

  Future<void> unsubscribe(WarehouseCoeffs warehouseCoeffs) async {
    final token = await fetch(() => authService.getToken());
    if (token == null) {
      return;
    }

    await fetch(() => wfCofficientService.unsubscribe(
          token: token,
          warehouseId: warehouseCoeffs.warehouseId,
          boxTypeId: warehouseCoeffs.boxTypeId,
        ));
    await _asyncInit();
  }

  Future<void> updateSubscription(WarehouseCoeffs warehouseCoeffs) async {
    final token = await fetch(() => authService.getToken());
    if (token == null) {
      return;
    }

    await fetch(() => wfCofficientService.subscribe(
          token: token,
          warehouseCoeffs: warehouseCoeffs,
        ));
    await _asyncInit();
  }
}
