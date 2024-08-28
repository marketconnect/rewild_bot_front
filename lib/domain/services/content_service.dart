import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
import 'package:rewild_bot_front/domain/entities/card_catalog.dart';
import 'package:rewild_bot_front/domain/entities/nm_id.dart';
import 'package:rewild_bot_front/domain/entities/subj_characteristic.dart';
import 'package:rewild_bot_front/domain/entities/user_seller.dart';
import 'package:rewild_bot_front/presentation/home/add_api_keys_screen/add_api_keys_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/all_cards_seo_screen/all_cards_seo_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_desc_generator_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_title_generator_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_view_model.dart';

// NmIds Data Provider
abstract class ContentServiceNmIdDataProvider {
  Future<Either<RewildError, void>> insertNmId(NmId nmId);
}

abstract class ContentServiceWbContentApiClient {
  // Future<Either<RewildError, CardCatalog>> fetchNomenclature(
  //     {required String token, required int nmId});
  Future<Either<RewildError, CardCatalog>> fetchNomenclatures({
    required String token,
  });
  Future<Either<RewildError, bool>> updateMediaFiles({
    required String token,
    required int nmId,
    required List<String> mediaUrls,
  });

  Future<Either<RewildError, bool>> updateProductCard({
    required String token,
    required int nmID,
    required String vendorCode,
    required List<CardItemSize> sizes,
    required Dimension dimension,
    String? title,
    String? description,
    List<Characteristic>? characteristics,
  });
  Future<Either<RewildError, List<SubjCharacteristic>>>
      fetchSubjectCharacteristics({
    required String token,
    required int subjectId,
    String? locale,
  });
}

// Api key
abstract class ContentServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getWBApiKey(
      {required String type, required String sellerId});
}

// active seller
abstract class ContentServiceActiveSellerDataProvider {
  Future<Either<RewildError, List<UserSeller>>> getActive();
}

class ContentService
    implements
        AllCardsSeoContentService,
        AddApiKeysContentService,
        SeoToolDescriptionGeneratorContentService,
        SeoToolTitleGeneratorContentService,
        SeoToolContentService {
  final ContentServiceWbContentApiClient wbContentApiClient;
  final ContentServiceNmIdDataProvider nmIdDataProvider;
  final ContentServiceApiKeyDataProvider apiKeyDataProvider;
  final ContentServiceActiveSellerDataProvider activeSellerDataProvider;
  const ContentService({
    required this.wbContentApiClient,
    required this.nmIdDataProvider,
    required this.activeSellerDataProvider,
    required this.apiKeyDataProvider,
  });
  static final keyType = ApiKeyConstants.apiKeyTypes[ApiKeyType.content] ?? "";

  Future<Either<RewildError, List<SubjCharacteristic>>>
      fetchSubjectCharacteristics({
    required int subjectId,
  }) async {
    // Get active seller
    final activeSellerOrElse = await activeSellerDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);

    // Get Api key
    final tokenResult = await apiKeyDataProvider.getWBApiKey(
        type: keyType, sellerId: activeSeller.first.sellerId);
    if (tokenResult.isLeft()) {
      return left(
          tokenResult.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final token = tokenResult.fold((l) => throw UnimplementedError(), (r) => r);
    if (token == null) {
      return left(RewildError(
        'Токен отсутствует',
        sendToTg: false,
        source: "ContentService",
        name: "fetchNomenclatures",
        args: [],
      ));
    }
    return wbContentApiClient.fetchSubjectCharacteristics(
        token: token.token, subjectId: subjectId);
  }

  @override
  Future<Either<RewildError, bool>> apiKeyExist() async {
    // Get active seller
    final activeSellerOrElse = await activeSellerDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);

    // Get Api key
    final apiKeyEither = await apiKeyDataProvider.getWBApiKey(
        type: keyType, sellerId: activeSeller.first.sellerId);
    if (apiKeyEither is Left) {
      return left(
          apiKeyEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final apiKey = apiKeyEither.fold((l) => null, (r) => r);
    if (apiKey == null) {
      return right(false);
    }
    if (apiKey.token.isEmpty) {
      return right(false);
    }
    return right(true);
  }

  @override
  Future<Either<RewildError, CardCatalog>> fetchNomenclatures() async {
    // Get active seller
    final activeSellerOrElse = await activeSellerDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);

    // Get Api key
    final tokenResult = await apiKeyDataProvider.getWBApiKey(
        type: keyType, sellerId: activeSeller.first.sellerId);
    if (tokenResult.isLeft()) {
      return left(
          tokenResult.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final token = tokenResult.fold((l) => throw UnimplementedError(), (r) => r);
    if (token == null) {
      return left(RewildError(
        'Токен отсутствует',
        sendToTg: false,
        source: "ContentService",
        name: "fetchNomenclatures",
        args: [],
      ));
    }

    // fetch CardCatalog from API
    final resultEither =
        await wbContentApiClient.fetchNomenclatures(token: token.token);
    if (resultEither.isLeft()) {
      return left(
          resultEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    final cardCatalog =
        resultEither.fold((l) => throw UnimplementedError(), (r) => r);

    // save user nmIds
    final nmIds = cardCatalog.cards.map((e) => e.nmID).toSet().toList();
    for (final nmId in nmIds) {
      await nmIdDataProvider.insertNmId(NmId(nmId: nmId));
    }
    return right(cardCatalog);
  }

  // ignore: annotate_overrides
  Future<Either<RewildError, bool>> updateProductCard({
    required int nmID,
    required String vendorCode,
    required List<CardItemSize> sizes,
    required Dimension dimension,
    String? title,
    String? description,
    List<Characteristic>? characteristics,
  }) async {
    // Get active seller
    final activeSellerOrElse = await activeSellerDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);

    // Get Api key

    final tokenResult = await apiKeyDataProvider.getWBApiKey(
        type: keyType, sellerId: activeSeller.first.sellerId);
    if (tokenResult.isLeft()) {
      return left(
          tokenResult.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final token = tokenResult.fold((l) => throw UnimplementedError(), (r) => r);
    if (token == null) {
      return left(RewildError(
        'Токен отсутствует',
        sendToTg: false,
        source: "ContentService",
        name: "fetchNomenclatures",
        args: [],
      ));
    }

    // update card in WB API
    return await wbContentApiClient.updateProductCard(
      token: token.token,
      nmID: nmID,
      vendorCode: vendorCode,
      dimension: dimension,
      sizes: sizes,
      title: title,
      description: description,
      characteristics: characteristics,
    );
  }
}
