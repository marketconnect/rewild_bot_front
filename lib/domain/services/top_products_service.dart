import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/top_product.dart';
import 'package:rewild_bot_front/presentation/products/top_products_screen/top_products_view_model.dart';

abstract class TopProductsServiceApiClient {
  Future<Either<RewildError, List<TopProduct>>> getTopProducts({
    required String token,
    required int subjectId,
  });
}

abstract class TopProductsServiceDataProvider {
  Future<Either<RewildError, List<TopProduct>>> getTodayForSubjectId(
      int subjectId);
  Future<Either<RewildError, void>> insertAll(List<TopProduct> products);
}

class TopProductsService implements TopProductsViewModelTopProductsService {
  const TopProductsService(
      {required this.topProductsServiceApiClient,
      required this.topProductsServiceDataProvider});

  final TopProductsServiceApiClient topProductsServiceApiClient;
  final TopProductsServiceDataProvider topProductsServiceDataProvider;

  @override
  Future<Either<RewildError, List<TopProduct>>> getTopProducts({
    required String token,
    required int subjectId,
  }) async {
    // try to get data from cache
    final localTopProductsEither =
        await topProductsServiceDataProvider.getTodayForSubjectId(subjectId);
    if (localTopProductsEither.isLeft()) {
      return localTopProductsEither;
    }

    final localTopProducts =
        localTopProductsEither.fold((l) => <TopProduct>[], (r) => r);

    if (localTopProducts.isNotEmpty) {
      return right(localTopProducts);
    }

    final topProductsEither = await topProductsServiceApiClient.getTopProducts(
      token: token,
      subjectId: subjectId,
    );

    if (topProductsEither.isLeft()) {
      return topProductsEither;
    }
    // save to cache
    await topProductsServiceDataProvider
        .insertAll(topProductsEither.fold((l) => <TopProduct>[], (r) => r));

    return topProductsEither;
  }
}
