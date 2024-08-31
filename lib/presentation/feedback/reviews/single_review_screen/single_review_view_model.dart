import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/prices.dart';
import 'package:rewild_bot_front/domain/entities/review_model.dart';

// Card of product
abstract class SingleReviewCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

// Review
abstract class SingleReviewViewReviewService {
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, bool>> publishReview({
    required String token,
    required String id,
    required bool wasViewed,
    required bool wasRejected,
    required String answer,
  });
  Future<Either<RewildError, List<ReviewModel>>> getReviews({
    required String token,
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
    int? nmId,
  });
}

// Answer
abstract class SingleReviewViewModelAnswerService {
  Future<Either<RewildError, List<String>>> getAllReviews();
}

// token
abstract class SingleReviewViewModelTokenService {
  Future<Either<RewildError, String>> getToken();
}

// price
abstract class SingleReviewViewModelPriceService {
  Future<Either<RewildError, Prices>> getPrice(String token);
}

// balance
abstract class SingleReviewViewModelBalanceService {
  Future<Either<RewildError, double>> getUserBalance();
  Future<Either<RewildError, bool>> subtractBalance(double amountToSubtract);
}

class SingleReviewViewModel extends ResourceChangeNotifier {
  final SingleReviewCardOfProductService singleReviewCardOfProductService;
  final SingleReviewViewReviewService reviewService;

  final SingleReviewViewModelAnswerService answerService;
  final SingleReviewViewModelTokenService tokenService;
  final SingleReviewViewModelPriceService priceService;
  final SingleReviewViewModelBalanceService balanceService;

  final ReviewModel? review;
  SingleReviewViewModel(this.review,
      {required super.context,
      required this.reviewService,
      required this.tokenService,
      required this.priceService,
      required this.answerService,
      required this.balanceService,
      required this.singleReviewCardOfProductService}) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    final apiKey = await fetch(() => reviewService.getApiKey());
    if (apiKey == null) {
      return;
    }
    setApiKey(apiKey);
    if (review != null) {
      _cardImage = await fetch(() => singleReviewCardOfProductService
          .getImageForNmId(nmId: review!.productDetails.nmId));
    }
    // Saved answers
    final answers = await fetch(() => answerService.getAllReviews());
    if (answers == null) {
      return;
    }
    setStoredAnswers(answers);
    final price = await fetch(() => priceService.getPrice(apiKey));
    if (price == null) {
      notify();
      return;
    }

    // balance
    final balanceOrNull = await fetch(() => balanceService.getUserBalance());
    if (balanceOrNull != null) {
      setBalance(balanceOrNull);
    }
    notify();
  }

  String? _cardImage;

  String? get cardImage => _cardImage;

  // balance
  double? _balance;
  double? get balance => _balance;
  void setBalance(double balance) {
    _balance = balance;
    notify();
  }

  Future<void> updateBalance() async {
    final balanceOrNull = await fetch(() => balanceService.getUserBalance());
    if (balanceOrNull != null) {
      setBalance(balanceOrNull);
    }
  }

// Api key
  String? _apiKey;
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  String? _answer;
  String? get answer => _answer;
  void setAnswer(String value) {
    _answer = value;

    notify();
  }

  // Spell checker

  // Saved answers
  List<String>? _storedAnswers;
  void setStoredAnswers(List<String> answers) {
    _storedAnswers = answers;
  }

  List<String>? get storedAnswers => _storedAnswers;

  bool _isAnswered = false;
  bool get isAnswered => _isAnswered;
  void setIsAnswered() {
    _isAnswered = true;
    notify();
  }

  Future<void> publish() async {
    if (_apiKey == null ||
        review == null ||
        _answer == null ||
        _answer!.isEmpty) {
      return;
    }

    final resultEither = await fetch(() => reviewService.publishReview(
          token: _apiKey!,
          id: review!.id,
          answer: _answer!,
          wasRejected: false,
          wasViewed: true,
        ));

    if (resultEither == null) {
      return;
    }
    setIsAnswered();
  }
}