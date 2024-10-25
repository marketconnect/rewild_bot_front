import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subject_history.dart';
import 'package:rewild_bot_front/domain/entities/top_product.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_competitor_keyword_screen/competitor_keyword_expansion_model.dart';

import 'package:rewild_bot_front/presentation/products/top_products_screen/top_products_view_model.dart';

// Api
abstract class TopProductsServiceApiClient {
  Future<Either<RewildError, (List<TopProduct>, List<SubjectHistory>)>>
      getTopProducts({
    required String token,
    required int subjectId,
  });
}

// Top product data provider
abstract class TopProductsServiceDataProvider {
  Future<Either<RewildError, List<TopProduct>>> getTodayForSubjectId(
      int subjectId);
  Future<Either<RewildError, void>> insertAll(List<TopProduct> products);
}

// Subject history data provider
abstract class TopProductsServiceSubjectHistoryDataProvider {
  Future<Either<RewildError, List<SubjectHistory>>> getBySubjectId(
      int subjectId);
  Future<Either<RewildError, void>> insertAll(List<SubjectHistory> histories);
}

class TopProductsService
    implements
        TopProductsViewModelTopProductsService,
        CompetitorKeywordExpansionTopProductService {
  const TopProductsService(
      {required this.topProductsServiceApiClient,
      required this.subjectHistoryDataProvider,
      required this.topProductsServiceSubjectHistoryDataProvider,
      required this.topProductsServiceDataProvider});

  final TopProductsServiceApiClient topProductsServiceApiClient;
  final TopProductsServiceDataProvider topProductsServiceDataProvider;
  final TopProductsServiceSubjectHistoryDataProvider subjectHistoryDataProvider;
  final TopProductsServiceSubjectHistoryDataProvider
      topProductsServiceSubjectHistoryDataProvider;

  @override
  Future<Either<RewildError, (List<TopProduct>, List<SubjectHistory>)>>
      getTopProducts({
    required String token,
    required int subjectId,
  }) async {
    // try to get data from cache
    final localTopProductsEither =
        await topProductsServiceDataProvider.getTodayForSubjectId(subjectId);
    if (localTopProductsEither.isLeft()) {
      return left(RewildError('Could not get top products',
          name: 'getTopProducts',
          sendToTg: true,
          source: 'TopProductsService'));
    }

    final localTopProducts =
        localTopProductsEither.fold((l) => <TopProduct>[], (r) => r);

    if (localTopProducts.isNotEmpty) {
      final localSubjectHistoryEither =
          await subjectHistoryDataProvider.getBySubjectId(
        subjectId,
      );
      if (localSubjectHistoryEither.isLeft()) {
        return left(RewildError('Could not get top products',
            name: 'getTopProducts',
            sendToTg: true,
            source: 'TopProductsService'));
      }

      final localSubjectHistory = localSubjectHistoryEither.fold(
          (l) => throw UnimplementedError(), (r) => r);
      return right((localTopProducts, localSubjectHistory));
    }

    final topProductsSubjectHistoryEither =
        await topProductsServiceApiClient.getTopProducts(
      token: token,
      subjectId: subjectId,
    );

    if (topProductsSubjectHistoryEither.isLeft()) {
      return left(RewildError('Could not get top products from api',
          name: 'getTopProducts',
          sendToTg: true,
          source: 'TopProductsService'));
    }

    final topProductsSubjectHistory = topProductsSubjectHistoryEither.fold(
        (l) => throw UnimplementedError(), (r) => r);

    // save to cache
    // insert top products
    await topProductsServiceDataProvider
        .insertAll(topProductsSubjectHistory.$1);

    // insert subject history
    await subjectHistoryDataProvider.insertAll(topProductsSubjectHistory.$2);

    return right(topProductsSubjectHistory);
  }
}
