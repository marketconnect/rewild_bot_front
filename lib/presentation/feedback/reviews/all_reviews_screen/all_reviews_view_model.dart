import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/numeric_constance.dart';
import 'package:rewild_bot_front/core/utils/nums.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/review_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// Reviews service
abstract class AllReviewsViewModelReviewService {
  Future<Either<RewildError, bool>> apiKeyExists();
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, List<ReviewModel>>> getReviews({
    required String token,
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
    int? nmId,
  });
}

// Answers service
abstract class AllReviewsViewModelAnswerService {
  Future<Either<RewildError, bool>> insertReview(
      {required String reviewId, required String answer});
  Future<Either<RewildError, bool>> deleteReview({
    required String reviewId,
  });

  Future<Either<RewildError, List<String>>> getAllReviewIds();
}

class AllReviewsViewModel extends ResourceChangeNotifier {
  final AllReviewsViewModelReviewService reviewService;
  final AllReviewsViewModelAnswerService answerService;
  final int nmId;

  AllReviewsViewModel(this.nmId,
      {required super.context,
      required this.answerService,
      required this.reviewService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    setIsLoading(true);
    // check api key
    final apiKey = await fetch(() => reviewService.getApiKey());
    if (apiKey == null) {
      return;
    }

    setApiKey(apiKey);
    if (apiKey.isEmpty) {
      return;
    }

    // get questions
    List<ReviewModel> allReviews = [];
    // await _firstLoad();
    int n = 0;
    while (true) {
      final reviews = await fetch(() => reviewService.getReviews(
            token: apiKey,
            nmId: nmId,
            take: NumericConstants.takeFeedbacksAtOnce,
            skip: NumericConstants.takeFeedbacksAtOnce * n,
            dateFrom: unixTimestamp2019(),
            dateTo: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          ));
      if (reviews == null) {
        break;
      }
      allReviews.addAll(reviews);
      if (reviews.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
      n++;
    }

    // Reviews
    setReviews(allReviews);

    // Name
    final firstReview = allReviews.first;

    setName(firstReview.productDetails.supplierArticle);

    // Rating
    _calculateRatingStatistics();
    // Saved answers
    final answers = await fetch(() => answerService.getAllReviewIds());
    if (answers == null) {
      return;
    }

    setSavedAnswersQuestionsIds(answers);

    setIsLoading(false);
  }

  // loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  // name
  String _name = '';
  String get name => _name;
  void setName(String value) {
    _name = value;
    notify();
  }

  // Rating
  RatingStatistics? _ratingStatistics;
  // Call this method after fetching all reviews
  void _calculateRatingStatistics() {
    if (_reviews == null || _reviews!.isEmpty) {
      return;
    }

    Map<int, int> ratingCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    double totalRating = 0;
    double totalRatingLastWeek = 0;
    double totalRatingLastMonth = 0;
    int countLastWeek = 0;
    int countLastMonth = 0;

    DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));

    for (var review in _reviews!) {
      totalRating += review.productValuation;
      ratingCount[review.productValuation] =
          (ratingCount[review.productValuation] ?? 0) + 1;

      if (review.createdDate.isAfter(oneWeekAgo)) {
        totalRatingLastWeek += review.productValuation;
        countLastWeek++;
      }

      if (review.createdDate.isAfter(oneMonthAgo)) {
        totalRatingLastMonth += review.productValuation;
        countLastMonth++;
      }
    }

    double averageRating = totalRating / _reviews!.length;
    double lastWeekAverage =
        countLastWeek == 0 ? 0 : totalRatingLastWeek / countLastWeek;
    double lastMonthAverage =
        countLastMonth == 0 ? 0 : totalRatingLastMonth / countLastMonth;

    _ratingStatistics = RatingStatistics(
      ratingCount: ratingCount,
      averageRating: averageRating,
      lastWeekRating: lastWeekAverage,
      lastMonthRating: lastMonthAverage,
    );

    notify();
  }

  RatingStatistics? get ratingStatistics => _ratingStatistics;

  // ApiKeyExists
  String? _apiKey;
  void setApiKey(String value) {
    _apiKey = value;
    notify();
  }

  bool get apiKeyExists => _apiKey != null;

  // Questions
  List<ReviewModel>? _reviews;
  void setReviews(List<ReviewModel> value) {
    // Sort the reviews by createdAt in descending order
    _reviews = value..sort((a, b) => b.createdDate.compareTo(a.createdDate));
  }

  List<ReviewModel> get reviews => _reviews ?? [];

  // Answer to reuse
  String? _answerToReuseQuestionId;
  String get answerToReuseQuestionId => _answerToReuseQuestionId ?? "";

  String? _answerToReuseText;
  void setAnswerToReuse(String value, String questionId) {
    _answerToReuseQuestionId = questionId;

    _answerToReuseText = value;
  }

  void clearAnswerToReuse() {
    _answerToReuseQuestionId = "";
    _answerToReuseText = null;
  }

  void routeToSingleReviewScreen(ReviewModel review) {
    if (_answerToReuseText != null) {
      review.setReusedAnswerText(_answerToReuseText!);

      _answerToReuseText = null;
    }
    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.singleQuestionScreen,
        arguments: review);
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  void setSearchQuery(String query) {
    _searchQuery = query;

    notify();
  }

  void clearSearchQuery() {
    _searchQuery = "";
    notify();
  }

  List<String>? _savedAnswersQuestionsIds;
  void setSavedAnswersQuestionsIds(List<String> savedAnswersQuestionsIds) {
    _savedAnswersQuestionsIds = savedAnswersQuestionsIds;
  }

  bool isAnswerSaved(String questionId) =>
      _savedAnswersQuestionsIds != null &&
      _savedAnswersQuestionsIds!.contains(questionId);

  // save answer in db
  Future<bool> saveAnswer(String questionId) async {
    final answer =
        reviews.firstWhere((element) => element.id == questionId).answer;
    if (answer == null) {
      return false;
    }
    if (_savedAnswersQuestionsIds != null) {
      _savedAnswersQuestionsIds!.add(questionId);
    } else {
      _savedAnswersQuestionsIds = [questionId];
    }
    final answerText = answer.text;
    final ok = await fetch(() =>
        answerService.insertReview(reviewId: questionId, answer: answerText));
    if (ok == null) {
      return false;
    }
    notify();
    return ok;
  }

  // Delete answer from db
  Future<bool> deleteAnswer(String questionId) async {
    if (_savedAnswersQuestionsIds != null) {
      _savedAnswersQuestionsIds!.remove(questionId);
    }

    final ok =
        await fetch(() => answerService.deleteReview(reviewId: questionId));
    if (ok == null) {
      return false;
    }
    notify();
    return ok;
  }

  Future<void> navigateToReviewDetailsScreen(ReviewModel review) async {
    final result = await Navigator.of(context).pushNamed(
      MainNavigationRouteNames.singleReviewScreen,
      arguments: review,
    );

    if (result != null && result == true) {
      _asyncInit();
    }
  }
}

class RatingStatistics {
  final Map<int, int> ratingCount; // Store count of each rating value (1-5)
  final double averageRating;
  final double lastWeekRating;
  final double lastMonthRating;

  RatingStatistics({
    required this.ratingCount,
    required this.averageRating,
    required this.lastWeekRating,
    required this.lastMonthRating,
  });
}
