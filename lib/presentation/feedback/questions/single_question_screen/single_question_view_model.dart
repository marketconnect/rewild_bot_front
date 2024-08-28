import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/prices.dart';
import 'package:rewild_bot_front/domain/entities/question_model.dart';

// card of product
abstract class SingleQuestionViewModelCardOfProductService {
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

// Spell checker
// abstract class SingleQuestionViewModelSpellChecker {
//   Future<Either<RewildError, List<SpellResult>>> checkText(
//       {required String text});
// }

// price
abstract class SingleQuestionViewModelPriceService {
  Future<Either<RewildError, Prices>> getPrice(String token);
}

// balance
abstract class SingleQuestionViewModelBalanceService {
  Future<Either<RewildError, double>> getUserBalance();
  Future<Either<RewildError, bool>> subtractBalance(double amountToSubtract);
}

// gigachat
// abstract class SingleQuestionViewModelGigachatService {
//   Future<Either<RewildError, String>> askLLM(
//       {required String clientId,
//       required String clientSecret,
//       required String prompt,
//       required String role,
//       required int maxTokens,
//       required String model});
//   Future<Either<RewildError, double>> calculateCost(
//       {required String prompt,
//       required String role,
//       required String clientId,
//       required String clientSecret,
//       required int maxTokens,
//       required String model,
//       required int costPerMillionTokens});
// }

class SingleQuestionViewModel extends ResourceChangeNotifier {
  final QuestionModel question;
  final SingleQuestionViewModelAnswerService answerService;
  final SingleQuestionViewModelQuestionService questionService;
  final SingleQuestionViewModelCardOfProductService cardOfProductService;

  final SingleQuestionViewModelPriceService priceService;
  final SingleQuestionViewModelBalanceService balanceService;
  SingleQuestionViewModel(this.question,
      {required super.context,
      required this.questionService,
      required this.cardOfProductService,
      required this.balanceService,
      required this.priceService,
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
    _cardImage = await fetch(() => cardOfProductService.getImageForNmId(
        nmId: question.productDetails.nmId));
    setStoredAnswers(answers);
    if (question.answer != null) {
      setAnswer(question.answer!.text);
    }

    final price = await fetch(() => priceService.getPrice(apiKey));
    if (price == null) {
      notify();
      return;
    }

    // _gigachatClientId = price.clienId;
    // _gigachatClientSecret = price.clientSecret;
    // for (final llm in llms) {
    //   final modelName = llm.name;
    //   int p = price.gigaChatLitePerMillion;
    //   if (modelName == 'GigaChat-Plus') {
    //     p = price.gigaChatLitePlusPerMillion;
    //   } else if (modelName == 'GigaChat-Pro') {
    //     p = price.gigaChatProPerMillion;
    //   }
    //   if (p == 0) {
    //     continue;
    //   }
    //   // Gigachat
    //   final costOrNull = await fetch(() => gigachatService.calculateCost(
    //       prompt: prompt,
    //       role: role,
    //       maxTokens: ReWildPrompts.questionMaxToken,
    //       model: modelName,
    //       clientId: _gigachatClientId!,
    //       clientSecret: _gigachatClientSecret!,
    //       costPerMillionTokens: p));
    //   if (costOrNull != null) {
    //     setGigachatCost(modelName, costOrNull);
    //   }
    // }

    // balance
    final balanceOrNull = await fetch(() => balanceService.getUserBalance());
    if (balanceOrNull != null) {
      setBalance(balanceOrNull);
    }

    notify();
  }

  // balance
  double? _balance;
  double? get balance => _balance;
  void setBalance(double balance) {
    _balance = balance;
    notify();
  }

  // gigachat clientId clientSecret

  Future<void> updateBalance() async {
    final balanceOrNull = await fetch(() => balanceService.getUserBalance());
    if (balanceOrNull != null) {
      setBalance(balanceOrNull);
    }
  }

  // void setGigachatClient(String clientId, String clientSecret) {
  //   _gigachatClientId = clientId;
  //   _gigachatClientSecret = clientSecret;
  // }

  // gigachat cost
  Map<String, double>? _gigachatCost;
  Map<String, double>? get gigachatCost => _gigachatCost;
  void setGigachatCost(String key, double cost) {
    _gigachatCost ??= {};
    _gigachatCost![key] = cost;
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

  // Spell checker
  // List<SpellResult>? _spellResults;

  // List<SpellResult> get spellResults => _spellResults ?? [];

  String _prompt = "Напиши ответ на вопрос о товаре.";
  String get prompt => '$_promptВопрос:${question.text}';
  void changePrompt(String text) {
    _prompt = text;
  }

  // String _role = '';
  // String get role => _role == '' ? ReWildPrompts.questionRole : _role;
  // void changeRole(String text) {
  //   _role = text;
  // }

  bool _isAnswered = false;
  bool get isAnswered => _isAnswered;
  void setIsAnswered() {
    _isAnswered = true;
    notify();
  }

  // Publish
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

  // Future<List<SpellResult>> checkSpellText(String text) async {
  //   final spellResults = await fetch(() => spellChecker.checkText(text: text));
  //   if (spellResults == null) {
  //     return [];
  //   }
  //   return spellResults;
  // }

//   Future<String> askGigachat(
//       String model, double cost, String role, String prompt) async {
//     if (_gigachatClientId == null || _gigachatClientSecret == null) {
//       return "";
//     }

//     if (balance == null || balance! < cost) {
//       return "";
//     }
//     // subtract from balance
//     final okOrNull = await fetch(() => balanceService.subtractBalance(cost));
//     if (okOrNull == null) {
//       return "";
//     }
//     // get balance
//     final balanceOrNull = await fetch(() => balanceService.getUserBalance());
//     if (balanceOrNull != null) {
//       setBalance(balanceOrNull);
//     }

//     final resultOrNull = await fetch(() => gigachatService.askLLM(
//           prompt: prompt,
//           role: ReWildPrompts.reviewRole,
//           maxTokens: ReWildPrompts.questionMaxToken,
//           clientId: _gigachatClientId!,
//           clientSecret: _gigachatClientSecret!,
//           model: model,
//         ));
//     if (resultOrNull == null) {
//       _answer = '';
//     }
//     _answer = resultOrNull;
//     notify();
//     return _answer ?? "";
//   }
}
