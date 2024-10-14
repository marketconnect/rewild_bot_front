import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/user_auth_data.dart';
import 'package:rewild_bot_front/presentation/adverts/advert_analitics_screen/advert_analitics_view_model.dart';
import 'package:rewild_bot_front/presentation/adverts/campaign_managment_screen/campaign_managment_view_model.dart';

import 'package:rewild_bot_front/presentation/feedback/reviews/single_review_screen/single_review_view_model.dart';
import 'package:rewild_bot_front/presentation/gpt_screen/gpt_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/home/add_api_keys_screen/add_api_keys_view_model.dart';
import 'package:rewild_bot_front/presentation/home/unit_economics_all_cards_screen/unit_economics_all_cards_view_model.dart';
import 'package:rewild_bot_front/presentation/products/all_categories_screen/all_categories_view_model.dart';
import 'package:rewild_bot_front/presentation/products/all_subjects_screen/all_subjects_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/notification_card_screen/notification_card_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/all_cards_seo_screen/all_cards_seo_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_autocomplite_keyword_screen/autocomplite_keyword_expansion_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_competitor_keyword_screen/competitor_keyword_expansion_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_subject_keyword_screen/subject_keyword_expansion_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_words_keyword_screen/words_keyword_expansion_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/expense_manager_screen/expense_manager_view_model.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';

import 'package:rewild_bot_front/presentation/products/cards/wb_web_view/wb_web_view_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/payment/payment_screen/payment_screen_view_model.dart';

import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_kw_research_view_model.dart';

import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_view_model.dart';

import 'package:rewild_bot_front/presentation/products/seo/seo_tool_empty_product_screen/seo_tool_empty_product_kw_research_view_model.dart';

import 'package:rewild_bot_front/presentation/products/seo/seo_tool_empty_product_screen/seo_tool_empty_product_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/single_card_screen/single_card_screen_view_model.dart';

abstract class AuthServiceSecureDataProvider {
  Future<Either<RewildError, void>> updateUserInfo(
      {String? token, String? expiredAt, bool? freebie});
  Future<Either<RewildError, String?>> getServerToken();
  Future<Either<RewildError, String?>> getUsername();
  Future<Either<RewildError, bool>> tokenNotExpired();
}

abstract class AuthServiceAuthApiClient {
  Future<Either<RewildError, UserAuthData>> registerUser(
      {required String username, required String password});
  Future<Either<RewildError, UserAuthData>> loginUser(
      {required String username, required String password});
}

class AuthService
    implements
        MainNavigationAuthService,
        AdvertAnaliticsAuthService,
        SingleReviewViewModelTokenService,
        GptScreenTokenService,
        AddApiKeysAuthService,
        SubjectKeywordExpansionTokenService,
        WordsKeywordExpansionTokenService,
        SeoToolTokenService,
        SeoToolEmptyProductTokenService,
        AllCategoriesScreenAuthService,
        AllSubjectsViewModelAuthService,
        // SeoToolCategoryDescriptionGeneratorTokenService,
        SeoToolKwResearchTokenService,
        ExpenseManagerScreenTokenService,
        SeoToolEmptyProductKwResearchTokenService,
        // SeoToolCategoryTitleGeneratorTokenService,
        SingleCardScreenAuthService,
        PaymentScreenTokenService,
        // NotificationFeedbackTokenService,
        CampaignManagementTokenService,
        CompetitorKeywordExpansionTokenService,
        AutocompliteKeywordExpansionTokenService,
        // PaymentWebViewTokenService,
        AllCardsSeoAuthService,
        AllCardsScreenAuthService,
        UnitEconomicsAllCardsAuthService,
        NotificationCardTokenService,
        WbWebViewScreenViewModelAuthService {
  final AuthServiceSecureDataProvider secureDataProvider;
  final AuthServiceAuthApiClient authApiClient;

  const AuthService(
      {required this.secureDataProvider, required this.authApiClient});

  Future<Either<RewildError, bool>> isLogined() async {
    final getTokenEither = await secureDataProvider.getServerToken();
    if (getTokenEither.isLeft()) {
      return left(
          getTokenEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    // If token exist (registered)
    if (getTokenEither.isRight()) {
      // check expiration

      final tokenNotExpiredEither = await secureDataProvider.tokenNotExpired();
      if (tokenNotExpiredEither.isLeft()) {
        return left(tokenNotExpiredEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      return right(true);
    }
    return right(false);
  }

  // @override
  // Future<Either<RewildError, String?>> getUsername() async {
  //   final result = await secureDataProvider.getUsername();
  //   return result.fold((l) => left(l), (r) {
  //     if (r == null) {
  //       return left(RewildError(
  //         sendToTg: true,
  //         "Username not found",
  //         name: "getUsername",
  //         source: "AuthService",
  //         args: [],
  //       ));
  //     }

  //     return right(r);
  //   });
  // }

  @override
  Future<Either<RewildError, String>> getToken() async {
    final values = await Future.wait([
      secureDataProvider.getUsername(),
      secureDataProvider.getServerToken()
    ]);
    // Advert Info
    final userNameEither = values[0];
    final getTokenEither = values[1];
    // get user name
    // final userNameResource = await secureDataProvider.getUsername();
    if (userNameEither.isLeft()) {
      return left(
          userNameEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    final userName = userNameEither.fold((l) => null, (r) => r);
    if (userName == null) {
      return left(RewildError(
        sendToTg: true,
        'No username data',
        source: "AuthService",
        name: 'getToken',
      ));
    }

    // get token from secure storage
    // final getTokenResource = await secureDataProvider.getToken();
    if (getTokenEither.isLeft()) {
      return left(
          getTokenEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    // If token exist (registered)
    final token = getTokenEither.fold((l) => null, (r) => r);
    if (getTokenEither.isRight() && token != null) {
      // check expiration
      final tokenNotExpiredEither = await secureDataProvider.tokenNotExpired();
      if (tokenNotExpiredEither.isLeft()) {
        return left(tokenNotExpiredEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      final tokenNotExpired = tokenNotExpiredEither.fold(
        (l) => false,
        (r) => r,
      );

      // If token not expired return token
      if (tokenNotExpired) {
        return right(token);
      } else {
        // If token expired
        // login
        final loginEither = await _login(userName);
        if (loginEither is Left) {
          // return left(
          //     loginEither.fold((l) => l, (r) => throw UnimplementedError()));
          return await _registerWithUserName(userName);
        }
        // save received token
        final userAuthData =
            loginEither.fold((l) => throw UnimplementedError(), (r) => r);

        final token = userAuthData.token;
        final expiredAt = userAuthData.expiredAt;

        final freebie = userAuthData.freebie;
        final saveEither = await _saveAuthData(
            UserAuthData(token: token, expiredAt: expiredAt, freebie: freebie));
        if (saveEither.isLeft()) {
          return left(
              saveEither.fold((l) => l, (r) => throw UnimplementedError()));
        }
        return right(token);
      }
    } else {
      // Token does not exist (not registered)
      // register
      return await _registerWithUserName(userName);
    }
  }

  Future<Either<RewildError, String>> _registerWithUserName(
      String userName) async {
    final registerEither = await _register(userName);
    final userAuthData =
        registerEither.fold((l) => throw UnimplementedError(), (r) => r);
    if (registerEither is Error || userAuthData == null) {
      return left(
          registerEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    // save received data

    final token = userAuthData.token;
    final expiredAt = userAuthData.expiredAt;
    final freebie = userAuthData.freebie;

    final saveResource = await _saveAuthData(
        UserAuthData(token: token, expiredAt: expiredAt, freebie: freebie));

    if (saveResource.isLeft()) {
      return left(
          saveResource.fold((l) => l, (r) => throw UnimplementedError()));
    }

    return right(token);
  }

  Future<Either<RewildError, void>> _saveAuthData(UserAuthData authData) async {
    final token = authData.token;
    final freebie = authData.freebie;
    final expiredAt = authData.expiredAt;
    final saveEither = await secureDataProvider.updateUserInfo(
      token: token,
      expiredAt: expiredAt.toString(),
      freebie: freebie,
    );
    if (saveEither.isLeft()) {
      return left(saveEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    return right(null);
  }

  Future<Either<RewildError, UserAuthData?>> _register(String username) async {
    final authDataEither = await authApiClient.registerUser(
        username: username, password: username);
    if (authDataEither.isLeft()) {
      return left(
          authDataEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    return authDataEither;
  }

  Future<Either<RewildError, UserAuthData>> _login(String username) async {
    final authDataResource =
        await authApiClient.loginUser(password: username, username: username);
    if (authDataResource.isLeft()) {
      return left(
          authDataResource.fold((l) => l, (r) => throw UnimplementedError()));
    }

    return right(
        authDataResource.fold((l) => throw UnimplementedError(), (r) => r));
  }
}
