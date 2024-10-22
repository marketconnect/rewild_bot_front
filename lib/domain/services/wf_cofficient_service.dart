import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/wh_coeffs.dart';
import 'package:rewild_bot_front/presentation/home/wh_coefficients_screen/wh_coefficients_view_model.dart';

abstract class WfCofficientServiceWfCofficientApiClient {
  Future<Either<RewildError, void>> subscribe({
    required String token,
    required int chatId,
    required UserSubscription sub,
  });
  Future<Either<RewildError, void>> unsubscribe({
    required String token,
    required int warehouseId,
    required int boxTypeId,
    required int chatId,
  });
  Future<Either<RewildError, GetAllWarehousesResp>> getAllWarehouses({
    required String token,
    required int chatId,
  });
}

abstract class WhCoefficientsServiceSecureDataProvider {
  Future<Either<RewildError, String?>> getUsername();
}

class WfCofficientService
    implements WhCoefficientsViewModelWfCofficientService {
  final WfCofficientServiceWfCofficientApiClient apiClient;

  final WhCoefficientsServiceSecureDataProvider secureDataProvider;
  WfCofficientService({
    required this.apiClient,
    required this.secureDataProvider,
  });

  @override
  Future<Either<RewildError, void>> subscribe({
    required String token,
    required UserSubscription sub,
  }) async {
    // save local

    final chatIdEither = await secureDataProvider.getUsername();
    if (chatIdEither.isLeft()) {
      return chatIdEither;
    }

    final chatId = chatIdEither.fold((l) => "", (r) => r ?? "");
    final chatIdInt = int.tryParse(chatId);
    if (chatIdInt == null) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось получить chat_id",
        source: "WfCofficientService",
        name: "subscribe",
        args: [sub.warehouseId],
      ));
    }

    return await apiClient.subscribe(
      token: token,
      sub: sub,
      chatId: chatIdInt,
    );
  }

  @override
  Future<Either<RewildError, void>> unsubscribe({
    required String token,
    required int warehouseId,
    required int boxTypeId,
  }) async {
    // unsubscribe local

    final chatIdEither = await secureDataProvider.getUsername();
    if (chatIdEither.isLeft()) {
      return chatIdEither;
    }

    final chatId = chatIdEither.fold((l) => "", (r) => r ?? "");
    final chatIdInt = int.tryParse(chatId);
    if (chatIdInt == null) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось получить chat_id",
        source: "WfCofficientService",
        name: "subscribe",
        args: [],
      ));
    }
    return await apiClient.unsubscribe(
      token: token,
      warehouseId: warehouseId,
      boxTypeId: boxTypeId,
      chatId: chatIdInt,
    );
  }

  @override
  Future<Either<RewildError, GetAllWarehousesResp>> getAllWarehouses({
    required String token,
  }) async {
    final chatIdEither = await secureDataProvider.getUsername();
    if (chatIdEither.isLeft()) {
      return left(RewildError("chat_id not found",
          source: "WfCofficientService",
          name: "getAllWarehouses",
          sendToTg: true));
    }
    final chatId = chatIdEither.fold((l) => "", (r) => r ?? "");
    final chatIdInt = int.tryParse(chatId);
    if (chatIdInt == null) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось получить chat_id",
        source: "WfCofficientService",
        name: "subscribe",
        args: [],
      ));
    }

    return await apiClient.getAllWarehouses(
      token: token,
      chatId: chatIdInt,
    );
  }
}
