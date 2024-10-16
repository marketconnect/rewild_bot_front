import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/top_product.dart';

abstract class TopProductsServiceApiClient {
  Future<Either<RewildError, List<TopProduct>>> getTopProducts({
    required String token,
    required int subjectId,
  });
}

class TopProductsService {
  final TopProductsServiceApiClient topProductsServiceApiClient;

  const TopProductsService({required this.topProductsServiceApiClient});

  Future<Either<RewildError, List<TopProduct>>> getTopProducts({
    required String token,
    required int subjectId,
  }) async {
    return topProductsServiceApiClient.getTopProducts(
      token: token,
      subjectId: subjectId,
    );
  }
}
