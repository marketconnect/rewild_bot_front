import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/top_product.dart';

abstract class TopProductsViewModelTopProductsService {
  Future<Either<RewildError, List<TopProduct>>> getTopProducts({
    required String token,
    required int subjectId,
  });
}

// Token
abstract class TopProductsViewModelAuthService {
  Future<Either<RewildError, String>> getToken();
}

class TopProductsViewModel extends ResourceChangeNotifier {
  TopProductsViewModel(
      {required super.context,
      required this.topProductsService,
      required this.authService,
      required this.subjectId}) {
    _asyncInit();
  }
  // Constructor parameters
  final int subjectId;
  final TopProductsViewModelTopProductsService topProductsService;
  final TopProductsViewModelAuthService authService;

  // Other properties
  bool _isLoading = false;
  void setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  bool get isLoading => _isLoading;

  final List<TopProduct> _topProducts = [];
  void setTopProducts(List<TopProduct> value) {
    _topProducts.clear();
    _topProducts.addAll(value);
  }

  List<TopProduct> get topProducts => _topProducts;

  // Methods
  Future<void> _asyncInit() async {
    setIsLoading(true);
    final tokenOrNull = await fetch(() => authService.getToken());
    if (tokenOrNull == null) {
      setIsLoading(false);
      return;
    }
    final topProductsResource = await fetch(() => topProductsService
        .getTopProducts(token: tokenOrNull, subjectId: subjectId));
    if (topProductsResource == null) {
      setIsLoading(false);
      return;
    }
    setTopProducts(topProductsResource);
    setIsLoading(false);
  }
}
