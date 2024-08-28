import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/numeric_constance.dart';
import 'package:rewild_bot_front/core/utils/nums.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/question_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

abstract class AllQuestionsViewModelQuestionService {
  Future<Either<RewildError, List<QuestionModel>>> getQuestions({
    int? nmId,
    required String token,
    required int take,
    required int skip,
    required int dateFrom,
    required int dateTo,
  });
  Future<Either<RewildError, String?>> getApiKey();
}

abstract class AllQuestionsViewModelAnswerService {
  Future<Either<RewildError, bool>> insertQuestion(
      {required String questionId, required String answer});
  Future<Either<RewildError, bool>> deleteQuestion({
    required String questionId,
  });

  Future<Either<RewildError, List<String>>> getAllQuestionIds();
}

class AllQuestionsViewModel extends ResourceChangeNotifier {
  final AllQuestionsViewModelQuestionService questionService;
  final AllQuestionsViewModelAnswerService answerService;
  final int nmId;

  AllQuestionsViewModel(this.nmId,
      {required super.context,
      required this.answerService,
      required this.questionService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    setIsLoading(true);
    // check api key
    final apiKey = await fetch(() => questionService.getApiKey());
    if (apiKey == null) {
      return;
    }

    setApiKey(apiKey);
    if (apiKey.isEmpty) {
      return;
    }
    // get questions
    List<QuestionModel> allQuestions = [];
    int n = 0;
    while (true) {
      final questions = await fetch(() => questionService.getQuestions(
            token: apiKey,
            nmId: nmId,
            take: NumericConstants.takeFeedbacksAtOnce,
            dateFrom: unixTimestamp2019(),
            dateTo: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            skip: NumericConstants.takeFeedbacksAtOnce * n,
          ));
      if (questions == null) {
        break;
      }
      allQuestions.addAll(questions);
      if (questions.length < NumericConstants.takeFeedbacksAtOnce) {
        break;
      }
      n++;
    }

    // Questions
    setQuestions(allQuestions);

    // Saved answers
    final answers = await fetch(() => answerService.getAllQuestionIds());
    if (answers == null) {
      return;
    }
    final productname = allQuestions.first.productDetails.supplierArticle;
    setName(productname);
    setSavedAnswersQuestionsIds(answers);
    setIsLoading(false);
  }

  // name
  String? _name;
  String get name => _name ?? "";
  void setName(String value) {
    _name = value;
    notify();
  }

  bool _isLoading = false;
  void setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  bool get isLoading => _isLoading;

  // ApiKeyExists
  String? _apiKey;
  void setApiKey(String value) {
    _apiKey = value;
    notify();
  }

  bool get apiKeyExists => _apiKey != null;

  // Questions
  List<QuestionModel>? _questions;
  void setQuestions(List<QuestionModel> value) {
    _questions = value;
  }

  QuestionModel? question(String questionId) {
    if (_questions == null) {
      return null;
    }
    return _questions!.where((element) => element.id == questionId).firstOrNull;
  }

  List<QuestionModel> get questions => _questions ?? [];

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

  Future<void> routeToSingleQuestionScreen(QuestionModel question) async {
    if (_answerToReuseText != null) {
      question.setReusedAnswerText(_answerToReuseText!);

      _answerToReuseText = null;
    }
    final result = await Navigator.of(context).pushNamed(
        MainNavigationRouteNames.singleQuestionScreen,
        arguments: question);

    if (result != null && result == true) {
      _asyncInit();
    }
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
        questions.firstWhere((element) => element.id == questionId).answer;
    if (answer == null) {
      return false;
    }
    if (_savedAnswersQuestionsIds != null) {
      _savedAnswersQuestionsIds!.add(questionId);
    } else {
      _savedAnswersQuestionsIds = [questionId];
    }
    final answerText = answer.text;
    final ok = await fetch(() => answerService.insertQuestion(
        questionId: questionId, answer: answerText));
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
        await fetch(() => answerService.deleteQuestion(questionId: questionId));
    if (ok == null) {
      return false;
    }
    notify();
    return ok;
  }
}
