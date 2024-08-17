import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/prices.dart';
import 'package:rewild_bot_front/presentation/payment_screen/payment_screen_view_model.dart';

// Token
// abstract class PriceServiceTokenDataProvider {
//   Future<Either<RewildError, String?>> getServerToken();
// }

// Price
abstract class PriceServicePriceApiClient {
  Future<Either<RewildError, int>> addSubscriptionInfo(
      {required String token, required int price});
  Future<Either<RewildError, Prices>> getCurrentPrice({required String token});
}

class PriceService implements PaymentScreenPriceService {
  final PriceServicePriceApiClient apiClient;
  // final PriceServiceTokenDataProvider tokenDataProvider;
  const PriceService({
    required this.apiClient,
  });

  @override
  Future<Either<RewildError, Prices>> getPrice(String token) async {
    final pricesEither = await apiClient.getCurrentPrice(token: token);
    if (pricesEither.isLeft()) {
      return left(
          pricesEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final prices =
        pricesEither.fold((l) => throw UnimplementedError(), (r) => r);

    return right(prices);
  }
}
