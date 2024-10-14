import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/numeric_constance.dart';
import 'package:rewild_bot_front/core/utils/nums.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/feedback_qty_model.dart';
import 'package:rewild_bot_front/domain/entities/review_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// Images
abstract class AllProductsReviewsUserCardService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

// Reviews
abstract class AllProductsReviewsViewModelReviewService {
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, List<ReviewModel>>> getReviews({
    required String token,
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
    int? nmId,
  });
  Future<Either<RewildError, List<ReviewModel>>> getUnansweredReviews(
      {required String token,
      required int take,
      required int skip,
      required int dateFrom,
      required int dateTo,
      int? nmId});
  Future<Either<RewildError, Map<int, int>>> prevUnansweredReviewsQty(
      {required Set<int> nmIds});
}

// Unanswered Feedback Qty
abstract class AllProductsReviewsUnansweredFeedbackQtyService {
  Future<Either<RewildError, void>> saveUnansweredFeedbackQtyList({
    required String token,
    required List<UnAnsweredFeedbacksQtyModel> feedbacks,
  });
  Future<Either<RewildError, List<UnAnsweredFeedbacksQtyModel>>>
      getAllUnansweredFeedbackQty();
}

class AllProductsReviewsViewModel extends ResourceChangeNotifier {
  final AllProductsReviewsUserCardService userCardService;
  final AllProductsReviewsViewModelReviewService reviewService;
  final AllProductsReviewsUnansweredFeedbackQtyService
      unansweredFeedbackQtyService;
  AllProductsReviewsViewModel({
    required super.context,
    required this.userCardService,
    required this.unansweredFeedbackQtyService,
    required this.reviewService,
  }) {
    _asyncInit();
  }

  void _asyncInit() async {
    // check api key

    final apiKey = await fetch(() => reviewService.getApiKey());
    if (apiKey == null) {
      return;
    }
    setApiKey(apiKey);

    // get current questions and reviews
    await _updateReviews();
    await _updateSavedUnansweredFeedBacks();
    // set qty of unanswered reviews that user did not see yet

    for (final nmId in _unansweredReviewsQty.keys) {
      final current = _unansweredReviewsQty[nmId]!;
      final old = _savedNmIdUnansweredReviews[nmId] ?? 0;

      difReviews[nmId] = current - old;
    }
  }

  // Filter by period
  String _period = 'w';
  String get period => _period;
  Future<void> setPeriod(BuildContext context, String value) async {
    _period = value;
    await _updateReviews();
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
      }
    }

    notify();
  }

  // Variables for storing new feedbacks qty

  Map<int, int> difReviews = {};
  int difReview(int nmId) {
    final dif = difReviews[nmId] ?? 0;
    return dif < 0 ? 0 : dif;
  }

  // Reviews ==================================================================== REVIEWS
  bool _isReviewsLoading = false;
  void setReviewsLoading(bool value) {
    _reviewsQty = 0;
    _isReviewsLoading = value;
    notify();
  }

  bool get isReviewsLoading => _isReviewsLoading;

  Future<void> _updateReviews() async {
    setReviewsLoading(true);
    _resetAllReviewsQty();
    _resetUnansweredReviewsQty();
    // get questions
    List<ReviewModel> allReviews = [];
    int n = 0;
    if (_apiKey == null) {
      return;
    }
    while (true) {
      final reviews = await fetch(() => reviewService.getReviews(
          token: _apiKey!,
          take: NumericConstants.takeFeedbacksAtOnce,
          dateFrom: dateFromDateTo().$1,
          dateTo: dateFromDateTo().$2,
          skip: NumericConstants.takeFeedbacksAtOnce * n));
      if (reviews == null) {
        break;
      }
      // setReviewQty(allReviews.length);
      allReviews.addAll(reviews);
      n++;
      setReviewsQty(allReviews.length);
      if (reviews.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
    }

    for (final review in allReviews) {
      final nmId = review.productDetails.nmId;
      // All Reviews Qty
      incrementAllReviewsQty(nmId);

      // New Reviews Qty
      if (review.state == "none") {
        incrementUnansweredReviewsQty(nmId);
      }

      // incrementReview(nmId, review.productValuation);

      // Image
      if (!_images.containsKey(nmId)) {
        final image = await fetch(
          () => userCardService.getImageForNmId(nmId: nmId),
        );
        if (image == null) {
          continue;
        }

        addImage(nmId, image);
      }

      // SupplierArticle
      if (!_supplierArticle.containsKey(nmId)) {
        final supplierArticle = review.productDetails.supplierArticle;
        addSupplierArticle(nmId, supplierArticle);
      }
    }

    setReviewsLoading(false);
  }

  int _reviewsQty = 0;
  void setReviewsQty(int value) {
    _reviewsQty = value;
    notify();
  }

  int get reviewQty => _reviewsQty;

  Map<int, int> _allReviewsQty = {};
  void setAllReviewsQty(Map<int, int> value) {
    _allReviewsQty = value;
  }

  void _resetAllReviewsQty() {
    _allReviewsQty = {};
  }

  Set<int> get reviews => _allReviewsQty.keys.toSet();

  void incrementAllReviewsQty(int nmId) {
    if (_allReviewsQty.containsKey(nmId)) {
      _allReviewsQty[nmId] = _allReviewsQty[nmId]! + 1;
    } else {
      _allReviewsQty[nmId] = 1;
    }
  }

  int allReviewsQty(int nmId) => _allReviewsQty[nmId] ?? 0;

  // unanswered reviews for each nmId
  Map<int, int> _unansweredReviewsQty = {};
  void setUnansweredReviewsQty(Map<int, int> value) {
    _unansweredReviewsQty = value;
  }

  void _resetUnansweredReviewsQty() {
    _unansweredReviewsQty = {};
  }

  void incrementUnansweredReviewsQty(int nmId) {
    if (_unansweredReviewsQty.containsKey(nmId)) {
      _unansweredReviewsQty[nmId] = _unansweredReviewsQty[nmId]! + 1;
    } else {
      _unansweredReviewsQty[nmId] = 1;
    }
  }

  int unansweredReviewsQty(int nmId) => _unansweredReviewsQty[nmId] ?? 0;

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

    final allUnansweredReviewsQty =
        await _fetchAllUnansweredReviewsForLastWeek(dateFrom, dateTo);

    for (final nmId in allUnansweredReviewsQty.keys) {
      allUnansweredFeedbacksQtyList.add(UnAnsweredFeedbacksQtyModel(
        nmId: nmId,
        qty: allUnansweredReviewsQty[nmId]!,
        type: UnAnsweredFeedbacksQtyModel.getType('review'),
      ));
    }

    await unansweredFeedbackQtyService.saveUnansweredFeedbackQtyList(
      token: _apiKey!,
      feedbacks: allUnansweredFeedbacksQtyList,
    );
    setIsClosing(false);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<Map<int, int>> _fetchAllUnansweredReviewsForLastWeek(
      int dateFrom, int dateTo) async {
    Map<int, int> allUnansweredReviewsQty = {};
    int n = 0;
    while (true) {
      final reviews = await fetch(() => reviewService.getUnansweredReviews(
          token: _apiKey!,
          take: NumericConstants.takeFeedbacksAtOnce,
          dateFrom: dateFrom,
          dateTo: dateTo,
          skip: NumericConstants.takeFeedbacksAtOnce * n));
      if (reviews == null) {
        break;
      }

      for (final review in reviews) {
        final nmId = review.productDetails.nmId;
        if (allUnansweredReviewsQty.containsKey(nmId)) {
          allUnansweredReviewsQty[nmId] = allUnansweredReviewsQty[nmId]! + 1;
        } else {
          allUnansweredReviewsQty[nmId] = 1;
        }
      }
      n++;

      if (reviews.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
    }
    return allUnansweredReviewsQty;
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
    difReviews[nmId] = 0;

    if (context.mounted) {
      Navigator.of(context).pushNamed(MainNavigationRouteNames.allReviewsScreen,
          arguments: nmId);
    }
    notify();
  }
}
