import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/single_question_screen/single_question_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/single_review_screen/single_review_view_model.dart';
import 'package:rewild_bot_front/presentation/payment/payment_web_view/payment_webview_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_desc_generator_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_title_generator_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen_category/seo_tool_category_desc_generator_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen_category/seo_tool_category_title_generator_view_model.dart';

abstract class BalanceServiceBalanceDataProvider {
  Future<Either<RewildError, double>> getUserBalance();
  Future<Either<RewildError, void>> addBalance(double amountToAdd);
  Future<Either<RewildError, void>> subtractBalance(double amountToSubtract);
}

class BalanceService
    implements
        PaymentWebViewViewModelBalanceService,
        SingleReviewViewModelBalanceService,
        SingleQuestionViewModelBalanceService,
        SeoToolDescriptionGeneratorBalanceService,
        SeoToolCategoryDescriptionGeneratorBalanceService,
        SeoToolCategoryTitleGeneratorBalanceService,
        SeoToolTitleGeneratorBalanceService {
  final BalanceServiceBalanceDataProvider balanceDataProvider;
  const BalanceService({required this.balanceDataProvider});

  @override
  Future<Either<RewildError, double>> getUserBalance() async {
    return balanceDataProvider.getUserBalance();
  }

  @override
  Future<Either<RewildError, void>> addBalance(double amountToAdd) async {
    return balanceDataProvider.addBalance(amountToAdd);
  }

  @override
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
