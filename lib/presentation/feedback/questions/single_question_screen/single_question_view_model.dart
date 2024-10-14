import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/question_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// card of product
abstract class SingleQuestionViewModelUserCardService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

// Answer
abstract class SingleQuestionViewModelAnswerService {
  Future<Either<RewildError, List<String>>> getAllQuestions();
}

// Question
abstract class SingleQuestionViewModelQuestionService {
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, bool>> publishQuestion(
      {required String token, required String id, required String answer});
}

class SingleQuestionViewModel extends ResourceChangeNotifier {
  final QuestionModel question;
  final SingleQuestionViewModelAnswerService answerService;
  final SingleQuestionViewModelQuestionService questionService;
  final SingleQuestionViewModelUserCardService userCardService;

  SingleQuestionViewModel(this.question,
      {required super.context,
      required this.questionService,
      required this.userCardService,
      required this.answerService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    final apiKey = await fetch(() => questionService.getApiKey());
    if (apiKey == null) {
      return;
    }
    setApiKey(apiKey);
    // Saved answers
    final answers = await fetch(() => answerService.getAllQuestions());
    if (answers == null) {
      return;
    }
    _cardImage = await fetch(() =>
        userCardService.getImageForNmId(nmId: question.productDetails.nmId));
    setStoredAnswers(answers);
    if (question.answer != null) {
      setAnswer(question.answer!.text);
    }

    notify();
  }

  // Image
  String? _cardImage;

  String? get cardImage => _cardImage;

  // Api key
  String? _apiKey;
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  // reused answer text
  void setReusedAnswerText(String text) {
    question.setReusedAnswerText(text);
  }

  void resetReusedAnswerText() {
    question.clearReusedAnswerText();
  }

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

  void generatedResponse() async {
    if (_apiKey == null) {}
    String inputText = 'Вопрос клиента: "${question.text}"\n';
    inputText +=
        'Пожалуйста, сгенерируй информативный и профессиональный ответ.';
    Navigator.of(context).pushNamed(MainNavigationRouteNames.chatGptScreen,
        arguments: inputText);
  } // Publish

  Future<void> publish() async {
    if (_apiKey == null || _answer == null) {
      return;
    }

    final result = await fetch(() => questionService.publishQuestion(
        token: _apiKey!, id: question.id, answer: _answer!));
    if (result == null) {
      return;
    }
    setIsAnswered();
    if (context.mounted) Navigator.of(context).pop();
  }

  String? _answer;
  String? get answer => _answer;
  void setAnswer(String value) {
    _answer = value;

    notify();
  }
}
