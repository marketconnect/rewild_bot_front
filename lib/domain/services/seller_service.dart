import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/seller_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/single_card_screen/single_card_screen_view_model.dart';

abstract class SellerServiceSellerDataProvider {
  Future<Either<RewildError, SellerModel?>> get({required int supplierId});
  Future<Either<RewildError, int>> insert({required SellerModel seller});
}

abstract class SellerServiceSelerApiClient {
  Future<Either<RewildError, SellerModel>> get({required int supplierId});
}

class SellerService implements SingleCardScreenSellerService {
  final SellerServiceSellerDataProvider sellerDataProvider;
  final SellerServiceSelerApiClient sellerApiClient;
  SellerService(
      {required this.sellerDataProvider, required this.sellerApiClient});
  // list for sellers to get rid of unnecessary requests to WB
  List<SellerModel> sellersCache = [];

  @override
  Future<Either<RewildError, SellerModel>> get(
      {required int supplierId}) async {
    // if the seller is already in cache
    final storedSeller =
        sellersCache.where((element) => element.supplierId == supplierId);
    if (storedSeller.isNotEmpty) {
      return right(storedSeller.first);
    } else {
      // if the seller is not in cache
      // try to get the seller from local db
      final localStoredSellerEither =
          await sellerDataProvider.get(supplierId: supplierId);
      return localStoredSellerEither.fold((l) => left(l), (seller) async {
        // the seller is in db
        if (seller != null) {
          sellersCache.add(seller);
          return right(seller);
        }
        final sellerEither = await sellerApiClient.get(supplierId: supplierId);
        return sellerEither.fold((l) => left(l), (sellerFromWB) async {
          final sellerModel = SellerModel(
              name: sellerFromWB.name,
              supplierId: supplierId,
              legalAddress: sellerFromWB.legalAddress,
              fineName: sellerFromWB.fineName,
              ogrn: sellerFromWB.ogrn,
              trademark: sellerFromWB.trademark);
          final insertEither =
              await sellerDataProvider.insert(seller: sellerModel);
          return insertEither.fold((l) => left(l), (r) {
            sellersCache.add(sellerModel);
            return right(sellerModel);
          });
        });
      });
    }
  }
}
