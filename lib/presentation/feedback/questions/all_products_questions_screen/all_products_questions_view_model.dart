import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/numeric_constance.dart';
import 'package:rewild_bot_front/core/utils/nums.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/feedback_qty_model.dart';
import 'package:rewild_bot_front/domain/entities/question_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// Images
abstract class AllProductsQuestionsCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

// Questions
abstract class AllProductsQuestionsViewModelQuestionService {
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, List<QuestionModel>>> getQuestions({
    int? nmId,
    required String token,
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
  });
  Future<Either<RewildError, List<QuestionModel>>> getUnansweredQuestions(
      {required String token,
      required int take,
      required int dateFrom,
      required int dateTo,
      required int skip,
      int? nmId});
}

// Unanswered Feedback Qty
abstract class AllProductsQuestionsUnansweredFeedbackQtyService {
  Future<Either<RewildError, void>> saveUnansweredFeedbackQtyList({
    required String token,
    required List<UnAnsweredFeedbacksQtyModel> feedbacks,
  });
  Future<Either<RewildError, List<UnAnsweredFeedbacksQtyModel>>>
      getAllUnansweredFeedbackQty();
}

class AllProductsQuestionsViewModel extends ResourceChangeNotifier {
  final AllProductsQuestionsViewModelQuestionService questionService;
  final AllProductsQuestionsCardOfProductService cardOfProductService;

  final AllProductsQuestionsUnansweredFeedbackQtyService
      unansweredFeedbackQtyService;
  AllProductsQuestionsViewModel(
      {required super.context,
      required this.cardOfProductService,
      required this.unansweredFeedbackQtyService,
      required this.questionService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    // check api key
    final apiKey = await fetch(() => questionService.getApiKey());
    if (apiKey == null) {
      return;
    }
    setApiKey(apiKey);

    // get current questions and reviews
    await _updateQuestions();
    await _updateSavedUnansweredFeedBacks();
    // set qty of unanswered reviews that user did not see yet
    for (final nmId in _unansweredQuestionsQty.keys) {
      final current = _unansweredQuestionsQty[nmId]!;
      final old = _savedNmIdUnansweredQuestions[nmId] ?? 0;

      difQuestions[nmId] = current - old;
    }
  }

  // Filter by period
  String _period = 'w';
  String get period => _period;
  Future<void> setPeriod(BuildContext context, String value) async {
    _period = value;
    await _updateQuestions();

    notify();
  }

  (int, int) dateFromDateTo() {
    final dateTo = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final dateFrom = _period == 'w'
        ? dateTo - 60 * 60 * 24 * 7
        : _period == 'm'
            ? dateTo - 60 * 60 * 24 * 30
            : unixTimestamp2019();
    return (dateFrom, dateTo);
  }

  // saved unanswered reviews
  Map<int, int> _savedNmIdUnansweredReviews = {};
  void setSavedNmIdUnansweredReviews(Map<int, int> value) {
    _savedNmIdUnansweredReviews = value;
  }

  void setSavedNmIdUnansweredReview(int nmId, int qty) {
    _savedNmIdUnansweredReviews[nmId] = qty;
  }

  Future<void> _updateSavedUnansweredFeedBacks() async {
    final unanswered = await fetch(
        () => unansweredFeedbackQtyService.getAllUnansweredFeedbackQty());
    if (unanswered == null) {
      return;
    }
    for (final feedback in unanswered) {
      if (feedback.type == UnAnsweredFeedbacksQtyModel.getType("review")) {
        setSavedNmIdUnansweredReview(feedback.nmId, feedback.qty);
      } else {
        setSavedNmIdUnansweredQuestion(feedback.nmId, feedback.qty);
      }
    }

    notify();
  }

  // Variables for storing new feedbacks qty
  Map<int, int> difQuestions = {};
  int difQuestion(int nmId) => difQuestions[nmId] ?? 0;

  // Questions ================================================================== QUESTIONS
  // saved unanswered questions
  Map<int, int> _savedNmIdUnansweredQuestions = {};
  void setSavedNmIdUnansweredQuestions(Map<int, int> value) {
    _savedNmIdUnansweredQuestions = value;
  }

  void setSavedNmIdUnansweredQuestion(int nmId, int qty) {
    _savedNmIdUnansweredQuestions[nmId] = qty;
  }

  // new questions qty
  Map<int, int> _unansweredQuestionsQty = {};
  void setUnansweredQuestionsQty(Map<int, int> value) {
    _unansweredQuestionsQty = value;
  }

  void resetUnansweredQuestionsQty() {
    _unansweredQuestionsQty = {};
  }

  void incrementNewQuestionsQty(int nmId) {
    if (_unansweredQuestionsQty.containsKey(nmId)) {
      _unansweredQuestionsQty[nmId] = _unansweredQuestionsQty[nmId]! + 1;
    } else {
      _unansweredQuestionsQty[nmId] = 1;
    }
  }

  int unansweredQuestionsQty(int nmId) => _unansweredQuestionsQty[nmId] ?? 0;

  int _questionsQty = 0;
  void setQuestionsQty(int value) {
    _questionsQty = value;
    notify();
  }

  int get questionsQty => _questionsQty;

  // all questions qty
  Map<int, int> _allQuestionsQty = {};
  void setAllQuestionsQty(Map<int, int> value) {
    _allQuestionsQty = value;
  }

  void _resetAllQuestionsQty() {
    _allQuestionsQty = {};
  }

  Set<int> get questions => _allQuestionsQty.keys.toSet();

  void incrementAllQuestionsQty(int nmId) {
    if (_allQuestionsQty.containsKey(nmId)) {
      _allQuestionsQty[nmId] = _allQuestionsQty[nmId]! + 1;
    } else {
      _allQuestionsQty[nmId] = 1;
    }
  }

  int allQuestionsQty(int nmId) => _allQuestionsQty[nmId] ?? 0;
  bool _isQuestionsLoading = false;
  void setQuestionsLoading(bool value) {
    _questionsQty = 0;
    _isQuestionsLoading = value;
    notify();
  }

  bool get isQuestionsLoading => _isQuestionsLoading;
  Future<void> _updateQuestions() async {
    setQuestionsLoading(true);
    resetUnansweredQuestionsQty();
    _resetAllQuestionsQty();

    // get questions
    List<QuestionModel> allQuestions = [];
    int n = 0;
    if (_apiKey == null) {
      return;
    }
    while (true) {
      final questions = await fetch(() => questionService.getQuestions(
          token: _apiKey!,
          take: NumericConstants.takeFeedbacksAtOnce,
          dateFrom: dateFromDateTo().$1,
          dateTo: dateFromDateTo().$2,
          skip: NumericConstants.takeFeedbacksAtOnce * n));
      if (questions == null) {
        break;
      }

      allQuestions.addAll(questions);
      n++;
      setQuestionsQty(allQuestions.length);
      if (questions.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
    }
    for (final question in allQuestions) {
      final nmId = question.productDetails.nmId;
      // All Questions Qty
      incrementAllQuestionsQty(nmId);

      // New Questions Qty
      if (question.state == "suppliersPortalSynch") {
        incrementNewQuestionsQty(nmId);
      }

      // Image
      if (!_images.containsKey(nmId)) {
        final image = await fetch(
          () => cardOfProductService.getImageForNmId(nmId: nmId),
        );
        if (image == null) {
          continue;
        }

        addImage(nmId, image);
      }

      // SupplierArticle
      if (!_supplierArticle.containsKey(nmId)) {
        final supplierArticle = question.productDetails.supplierArticle;
        addSupplierArticle(nmId, supplierArticle);
      }
    }

    setQuestionsLoading(false);
  }

  bool _isClosing = false;
  void setIsClosing(bool value) async {
    _isClosing = value;
    notify();
  }

  bool get isClosing => _isClosing;

  Future<void> onClose() async {
    setIsClosing(true);
    // get all last week unanswered feedbacks and add it to allUnansweredFeedbacksQtyList
    List<UnAnsweredFeedbacksQtyModel> allUnansweredFeedbacksQtyList = [];
    // get period
    final dateTo = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final dateFrom = dateTo - 60 * 60 * 24 * 7;

    // fetch unanswered questions and reviews from Api and store in allUnansweredFeedbacksQty
    final allUnansweredQuestionsForLastWeek =
        await _fetchAllUnansweredQuestionsForLatsWeek(
      dateFrom,
      dateTo,
    );

    for (final nmId in allUnansweredQuestionsForLastWeek.keys) {
      allUnansweredFeedbacksQtyList.add(UnAnsweredFeedbacksQtyModel(
        nmId: nmId,
        qty: allUnansweredQuestionsForLastWeek[nmId]!,
        type: UnAnsweredFeedbacksQtyModel.getType('question'),
      ));
    }

    await unansweredFeedbackQtyService.saveUnansweredFeedbackQtyList(
      token: _apiKey!,
      feedbacks: allUnansweredFeedbacksQtyList,
    );
    setIsClosing(false);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<Map<int, int>> _fetchAllUnansweredQuestionsForLatsWeek(
      int dateFrom, int dateTo) async {
    Map<int, int> allUnansweredQuestionsQty = {};
    int n = 0;
    while (true) {
      final questions = await fetch(() =>
          questionService.getUnansweredQuestions(
              token: _apiKey!,
              take: NumericConstants.takeFeedbacksAtOnce,
              dateFrom: dateFrom,
              dateTo: dateTo,
              skip: NumericConstants.takeFeedbacksAtOnce * n));
      if (questions == null) {
        break;
      }

      for (final question in questions) {
        final nmId = question.productDetails.nmId;
        if (allUnansweredQuestionsQty.containsKey(nmId)) {
          allUnansweredQuestionsQty[nmId] =
              allUnansweredQuestionsQty[nmId]! + 1;
        } else {
          allUnansweredQuestionsQty[nmId] = 1;
        }
      }
      n++;

      if (questions.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
    }
    return allUnansweredQuestionsQty;
  }

  // Images
  Map<int, String> _images = {};
  void setImages(Map<int, String> value) {
    _images = value;
  }

  void addImage(int nmId, String value) {
    _images[nmId] = value;
  }

  String getImage(int nmId) => _images[nmId] ?? '';

  // supplierArticles
  Map<int, String> _supplierArticle = {};
  void setSupplierArticle(Map<int, String> value) {
    _supplierArticle = value;
  }

  void addSupplierArticle(int nmId, String value) {
    if (_supplierArticle.containsKey(nmId)) {
      _supplierArticle[nmId] = value;
    } else {
      _supplierArticle[nmId] = value;
    }
  }

  String getSupplierArticle(int nmId) => _supplierArticle[nmId] ?? '';

  // ApiKeyExists
  String? _apiKey;
  void setApiKey(String value) {
    _apiKey = value;
    notify();
  }

  bool get apiKeyExists => _apiKey != null;

  void goTo(int nmId) {
    difQuestions[nmId] = 0;
    if (context.mounted) {
      Navigator.of(context).pushNamed(
          MainNavigationRouteNames.allQuestionsScreen,
          arguments: nmId);
    }
    notify();
  }

  // bool isNew = false;
  // void setIsNew(bool value) {
  //   isNew = value;
  //   notify();
  // }
}
