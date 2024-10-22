// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/wh_coeffs.dart';

abstract class WhCoefficientsViewModelWfCofficientService {
  Future<Either<RewildError, void>> subscribe({
    required String token,
    required UserSubscription sub,
  });
  Future<Either<RewildError, void>> unsubscribe({
    required String token,
    required int warehouseId,
    required int boxTypeId,
  });
  Future<Either<RewildError, GetAllWarehousesResp>> getAllWarehouses({
    required String token,
  });
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

  final List<UserSubscription> _currentSubscriptions = [];
  void setSubscriptions(List<UserSubscription> subscriptions) {
    _currentSubscriptions.clear();
    _currentSubscriptions.addAll(subscriptions);
  }

  List<UserSubscription> get currentSubscriptions => _currentSubscriptions;

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
    if (warehousesOrNull == null) {
      setIsLoading(false);
      return;
    }
    setWarehouses(warehousesOrNull.warehouses);
    setSubscriptions(warehousesOrNull.userSubscriptions);
    setIsLoading(false);
  }

  Future<void> subscribe({required UserSubscription sub}) async {
    final token = await fetch(() => authService.getToken());
    if (token == null) {
      return;
    }

    await fetch(() => wfCofficientService.subscribe(
          token: token,
          sub: sub,
        ));
    await _asyncInit();
  }

  Future<void> unsubscribe(UserSubscription sub) async {
    final token = await fetch(() => authService.getToken());
    if (token == null) {
      return;
    }

    await fetch(() => wfCofficientService.unsubscribe(
          token: token,
          warehouseId: sub.warehouseId,
          boxTypeId: sub.boxTypeId,
        ));
    await _asyncInit();
  }

  Future<void> updateSubscription(UserSubscription sub) async {
    final token = await fetch(() => authService.getToken());
    if (token == null) {
      return;
    }

    await fetch(() => wfCofficientService.subscribe(
          token: token,
          sub: sub,
        ));
    await _asyncInit();
  }

  String getBoxTypeName(int boxTypeId) {
    for (var element in warehouses) {
      for (var boxType in element.boxTypes) {
        if (boxType.boxTypeId == boxTypeId) {
          return boxType.boxTypeName;
        }
      }
    }

    return "";
  }
}
