import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
import 'package:rewild_bot_front/domain/entities/question_model.dart';
import 'package:rewild_bot_front/domain/entities/user_seller.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';

abstract class QuestionServiceQuestionApiClient {
  Future<Either<RewildError, List<QuestionModel>>> getUnansweredQuestions(
      {required String token,
      required int take,
      required int dateFrom,
      required int dateTo,
      required int skip,
      int? nmId});
  Future<Either<RewildError, List<QuestionModel>>> getAnsweredQuestions(
      {required String token,
      required int take,
      required int dateFrom,
      required int dateTo,
      required int skip,
      int? nmId});
  Future<Either<RewildError, bool>> handleQuestion(
      {required String token, required String id, required String answer});
}

// Api key
abstract class QuestionServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getWBApiKey(
      {required String type, required String sellerId});
  Future<Either<RewildError, String?>> getUsername();
}

// active seller
abstract class QuestionServiceActiveSellerDataProvider {
  Future<Either<RewildError, List<UserSeller>>> getActive();
}

class QuestionService implements MainNavigationQuestionService {
  final QuestionServiceQuestionApiClient questionApiClient;
  final QuestionServiceApiKeyDataProvider apiKeysDataProvider;
  final QuestionServiceActiveSellerDataProvider activeSellerDataProvider;
  QuestionService(
      {required this.apiKeysDataProvider,
      required this.questionApiClient,
      required this.activeSellerDataProvider});

  static final keyType = ApiKeyConstants.apiKeyTypes[ApiKeyType.question] ?? "";

  // Function to get api key
  @override
  Future<Either<RewildError, String?>> getApiKey() async {
    // Get active seller
    final activeSellerOrElse = await activeSellerDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);

    // Get Api key
    final result = await apiKeysDataProvider.getWBApiKey(
        type: keyType, sellerId: activeSeller.first.sellerId);
    return result.fold((l) => left(l), (r) {
      if (r == null) {
        return right(null);
      }
      return right(r.token);
    });
  }

  // Function to get username
  @override
  Future<Either<RewildError, String?>> getUsername() async {
    final result = await apiKeysDataProvider.getUsername();
    return result.fold((l) => left(l), (r) {
      if (r == null) {
        return left(RewildError(
          sendToTg: true,
          "Username not found",
          name: "getUsername",
          source: "QuestionService",
          args: [],
        ));
      }
      return right(r);
    });
  }

  // Function to get unanswered questions by nmId
  Future<Either<RewildError, List<QuestionModel>>> getUnansweredQuestions(
      {required String token,
      required int take,
      required int dateFrom,
      required int dateTo,
      required int skip,
      int? nmId}) async {
    return questionApiClient.getUnansweredQuestions(
        token: token,
        take: take,
        dateFrom: dateFrom,
        dateTo: dateTo,
        skip: skip,
        nmId: nmId);
  }

  // Function to get unanswered questions and answered questions by nmId
  Future<Either<RewildError, List<QuestionModel>>> getQuestions({
    int? nmId,
    required String token,
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
  }) async {
    List<QuestionModel> allQuestions = [];

    // Unanswered questions
    final unAnsweredEither = await questionApiClient.getUnansweredQuestions(
        token: token,
        take: take,
        dateFrom: dateFrom,
        dateTo: dateTo,
        skip: skip,
        nmId: nmId);

    if (unAnsweredEither.isRight()) {
      unAnsweredEither.fold((l) => left(l), (r) {
        allQuestions = r;
      });
    }

    // Answered questions
    final answeredEither = await questionApiClient.getAnsweredQuestions(
        token: token,
        take: take,
        dateFrom: dateFrom,
        dateTo: dateTo,
        skip: skip,
        nmId: nmId);
    if (answeredEither.isRight()) {
      answeredEither.fold((l) => left(l), (r) {
        allQuestions.addAll(r);
      });
    }

    return right(allQuestions);
  }

  // Function to publish question on wb server
  Future<Either<RewildError, bool>> publishQuestion(
      {required String token,
      required String id,
      required String answer}) async {
    final result = await questionApiClient.handleQuestion(
        token: token, id: id, answer: answer);

    return result.fold((l) => left(l), (r) {
      return right(r);
    });
  }
}
