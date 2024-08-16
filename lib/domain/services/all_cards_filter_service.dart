import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/filter_model.dart';
import 'package:rewild_bot_front/domain/entities/seller_model.dart';
import 'package:rewild_bot_front/presentation/all_cards_screen/all_cards_screen_view_model.dart';

abstract class AllCardsFilterFilterDataProvider {
  Future<Either<RewildError, void>> insert({required FilterModel filter});
  Future<Either<RewildError, void>> delete();
  Future<Either<RewildError, FilterModel>> get();
}

abstract class AllCardsFilterServiceCardsOfProductDataProvider {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]);
}

abstract class AllCardsFilterServiceSellerDataProvider {
  Future<Either<RewildError, SellerModel?>> get({required int supplierId});
}

class AllCardsFilterService implements AllCardsScreenFilterService {
  final AllCardsFilterServiceCardsOfProductDataProvider
      cardsOfProductsDataProvider;

  final AllCardsFilterServiceSellerDataProvider sellerDataProvider;

  final AllCardsFilterFilterDataProvider filterDataProvider;
  AllCardsFilterService(
      {required this.cardsOfProductsDataProvider,
      required this.filterDataProvider,
      required this.sellerDataProvider});

  @override
  Future<Either<RewildError, FilterModel>> getCompletlyFilledFilter() async {
    Map<int, String> brands = {};
    Map<int, String> promos = {};
    Map<int, String> subjects = {};
    Map<int, String> suppliers = {};
    int promoId = 0;
    int brandId = 0;

    final getsavedCardsResult = await cardsOfProductsDataProvider.getAll();
    return getsavedCardsResult.fold((l) => left(l), (cards) async {
      for (final card in cards) {
        // get brands
        if (card.brand != null && card.brand!.isNotEmpty) {
          // if brand is not exists add it
          if (brands.values.where((e) => e == card.brand).toList().isEmpty) {
            brands[brandId] = card.brand!;
            brandId++;
          }
        }
        // get promo
        if (card.promoTextCard != null && card.promoTextCard!.isNotEmpty) {
          // if  promo is not exists add it
          if (promos.values
              .where((e) => e == card.promoTextCard)
              .toList()
              .isEmpty) {
            promos[promoId] = card.promoTextCard!;
            promoId++;
          }
        }
        // get subjects with empty values
        if (card.subjectId != null) {
          subjects[card.subjectId!] = "";
        }
        // get suppliers with empty values
        if (card.supplierId != null) {
          if (suppliers.keys
              .where((k) => k == card.supplierId)
              .toList()
              .isEmpty) {
            final getSupplierResult =
                await sellerDataProvider.get(supplierId: card.supplierId!);
            getSupplierResult.fold(
                (l) => left(l),
                (r) => r == null
                    ? suppliers[card.supplierId!] = ""
                    : suppliers[card.supplierId!] = r.name);
          }
        }
      }

      return right(
        FilterModel(
            brands: brands,
            promos: promos,
            subjects: subjects,
            suppliers: suppliers,
            withSales: null,
            withStocks: null),
      );
    });
  }

  @override
  Future<Either<RewildError, FilterModel>> getCurrentFilter() async {
    return await filterDataProvider.get();
  }

  @override
  Future<Either<RewildError, void>> deleteFilter() async {
    return await filterDataProvider.delete();
  }

  @override
  Future<Either<RewildError, void>> setFilter(
      {required FilterModel filter}) async {
    final values = await Future.wait([
      filterDataProvider.delete(),
      filterDataProvider.insert(filter: filter)
    ]);

    // Advert Info
    final deleteFilterResource = values[0];
    final insertFilterResource = values[1];

    return deleteFilterResource.fold((l) => left(l),
        (r) => insertFilterResource.fold((l) => left(l), (r) => right(null)));
  }
}
