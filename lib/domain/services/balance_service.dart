import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/presentation/payment_web_view/payment_webview_model.dart';

abstract class BalanceServiceBalanceDataProvider {
  Future<Either<RewildError, double>> getUserBalance();
  Future<Either<RewildError, void>> addBalance(double amountToAdd);
  Future<Either<RewildError, void>> subtractBalance(double amountToSubtract);
}

class BalanceService implements PaymentWebViewViewModelBalanceService {
  final BalanceServiceBalanceDataProvider balanceDataProvider;
  const BalanceService({required this.balanceDataProvider});

  Future<Either<RewildError, double>> getUserBalance() async {
    return balanceDataProvider.getUserBalance();
  }

  @override
  Future<Either<RewildError, void>> addBalance(double amountToAdd) async {
    return balanceDataProvider.addBalance(amountToAdd);
  }

  Future<Either<RewildError, bool>> subtractBalance(
      double amountToSubtract) async {
    final balanceEither = await balanceDataProvider.getUserBalance();
    if (balanceEither.isLeft()) {
      return left(balanceEither.fold(
        (l) => l,
        (r) => throw UnimplementedError(),
      ));
    }
    final balance =
        balanceEither.fold((l) => throw UnimplementedError(), (r) => r);
    if (balance < amountToSubtract) {
      return right(false);
    }

    final okEither =
        await balanceDataProvider.subtractBalance(amountToSubtract);
    if (okEither.isLeft()) {
      return left(okEither.fold(
        (l) => l,
        (r) => throw UnimplementedError(),
      ));
    }
    return right(true);
  }
}
