import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/user_product_card.dart';
import 'package:rewild_bot_front/presentation/adverts/advert_analitics_screen/advert_analitics_view_model.dart';
import 'package:rewild_bot_front/presentation/adverts/all_adverts_stat_screen/all_adverts_stat_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/adverts/all_adverts_words_screen/all_adverts_words_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/all_products_questions_screen/all_products_questions_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/single_question_screen/single_question_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/all_products_reviews_screen/all_products_reviews_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/single_review_screen/single_review_view_model.dart';
import 'package:rewild_bot_front/presentation/home/add_api_keys_screen/add_api_keys_view_model.dart';
import 'package:rewild_bot_front/presentation/home/report_screen/report_view_model.dart';
import 'package:rewild_bot_front/presentation/home/unit_economics_all_cards_screen/unit_economics_all_cards_view_model.dart';

import 'package:rewild_bot_front/presentation/products/seo/all_cards_seo_screen/all_cards_seo_view_model.dart';

// Product Cards Data Provider
abstract class UserProductCardServiceDataProvider {
  Future<Either<RewildError, void>> addProductCard({
    required UserProductCard productCard,
  });
  Future<Either<RewildError, String>> getImageForNmId({
    required int nmId,
    required String mp, // добавляем параметр mp для соответствия реализации
  });

  Future<Either<RewildError, List<UserProductCard>>> getAllProductCards();
  Future<Either<RewildError, UserProductCard>> getOne({
    required int sku,
    required String mp,
  });

  Future<Either<RewildError, void>> deleteProductCard({
    required int sku,
    required String mp,
  });
}

class UserProductCardService
    implements
        AddApiKeysScreenUserCardsService,
        AllCardsSeoScreenUserCardsService,
        SingleQuestionViewModelUserCardService,
        UnitEconomicsAllCardsUserCardService,
        AdvertAnaliticsScreenUserCardService,
        AllAdvertsStatScreenUserCardService,
        AllAdvertsWordsScreenUserCardService,
        AllProductsQuestionsUserCardService,
        AllProductsReviewsUserCardService,
        SingleReviewUserCardService,
        ReportUserCardService {
  final UserProductCardServiceDataProvider dataProvider;

  const UserProductCardService({
    required this.dataProvider,
  });

  @override
  Future<Either<RewildError, void>> addProductCard({
    required int sku,
    required String img,
    required int subjectId,
    required String mp,
    required String name,
  }) async {
    final productCard = UserProductCard(
      sku: sku,
      img: img,
      subjectId: subjectId,
      mp: mp,
      name: name,
    );
    return await dataProvider.addProductCard(
      productCard: productCard,
    );
  }

  @override
  Future<Either<RewildError, List<UserProductCard>>> getAllUserCards() async {
    final cacheOrEither = await dataProvider.getAllProductCards();

    if (cacheOrEither.isRight()) {
      final cache =
          cacheOrEither.fold((l) => throw UnimplementedError(), (r) => r);

      return right(cache);
    }
    return right([]);
  }

  Future<Either<RewildError, void>> deleteProductCard({
    required int sku,
    required String mp,
  }) async {
    return await dataProvider.deleteProductCard(sku: sku, mp: mp);
  }

  @override
  Future<Either<RewildError, String>> getImageForNmId({
    required int nmId,
  }) async {
    if (nmId == 0) {
      return right("");
    }
    final imageOrEither =
        await dataProvider.getImageForNmId(nmId: nmId, mp: "wb");
    if (imageOrEither.isRight()) {
      final image =
          imageOrEither.fold((l) => throw UnimplementedError(), (r) => r);
      if (image.isNotEmpty) {
        return right(image);
      }
    }

    return imageOrEither;
  }

  Future<Either<RewildError, UserProductCard>> getOne({
    required int sku,
    required String mp,
  }) async {
    return await dataProvider.getOne(sku: sku, mp: mp);
  }
}
