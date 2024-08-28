import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/llms.dart';

import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/strings_utils.dart';
import 'package:rewild_bot_front/domain/entities/card_catalog.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/entities/prices.dart';
import 'package:rewild_bot_front/domain/entities/prompt_details.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_desc_generator_view_model.dart';

// token
abstract class SeoToolTitleGeneratorTokenService {
  Future<Either<RewildError, String>> getToken();
}

abstract class SeoToolTitleGeneratorContentService {
  Future<Either<RewildError, bool>> updateProductCard({
    required int nmID,
    required String vendorCode,
    required List<CardItemSize> sizes,
    required Dimension dimension,
    String? title,
    String? description,
    List<Characteristic>? characteristics,
  });
}

// gigachat
// abstract class SeoToolTitleGeneratorGigachatService {
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

// balance
abstract class SeoToolTitleGeneratorBalanceService {
  Future<Either<RewildError, double>> getUserBalance();
  Future<Either<RewildError, bool>> subtractBalance(double amountToSubtract);
}

// price
abstract class SeoToolTitleGeneratorModelPriceService {
  Future<Either<RewildError, Prices>> getPrice(String token);
}

// // prompt
// abstract class SeoToolTitleGenertorPromptService {
//   Future<Either<RewildError, PromptDetails>> getByName(String name);
//   Future<Either<RewildError, void>> insertOrReplace(
//       String name, String description, String role);
// }

class SeoToolTitleGeneratorViewModel extends ResourceChangeNotifier
    implements SeoGeneratorViewModel {
  // final SeoToolTitleGeneratorGigachatService gigachatService;
  final SeoToolTitleGeneratorBalanceService balanceService;
  final SeoToolTitleGeneratorModelPriceService priceService;
  final SeoToolTitleGeneratorTokenService tokenService;
  // final SeoToolTitleGenertorPromptService promptService;
  final SeoToolTitleGeneratorContentService contentService;
  SeoToolTitleGeneratorViewModel({
    required super.context,
    // required this.gigachatService,
    required this.balanceService,
    required this.priceService,
    required this.tokenService,
    // required this.promptService,
    required this.contentService,
  }) {
    _asyncInit();
  }

  // Keywords that user selected
  // ignore: prefer_final_fields
  List<KwByLemma> _selectedKeywords = [];
  @override
  List<KwByLemma> get selectedKeywords => _selectedKeywords;

  // init model
  // TODO MOVE THIS LATER
  @override
  String get initialSelectedModel => "Gigachat";

  // Model that user selected
  String _selectedModel = const LLM.gigaChat().name;
  @override
  String get selectedModel => _selectedModel;

  @override
  void selectModel(String model) {
    _selectedModel = model;
    notify();
  }

  // content
  CardItem? _cardItem;
  CardItem? get cardItem => _cardItem;
  void setCardItem(CardItem cardItem) {
    _cardItem = cardItem;
  }

  // gigachat
  // clientId clientSecret
  String? _gigachatClientId;
  String? _gigachatClientSecret;
  void setGigachatClient(String clientId, String clientSecret) {
    _gigachatClientId = clientId;
    _gigachatClientSecret = clientSecret;
  }

  // balance
  double? _balance;
  @override
  double? get balance => _balance != null ? _balance! : 0;
  void setBalance(double balance) {
    _balance = balance;
    notify();
  }

  // cost
  Map<String, double>? _llmsCost;
  @override
  Map<String, double>? get llmsCost => _llmsCost;
  void setGigachatCost(String key, double cost) {
    _llmsCost ??= {};
    _llmsCost![key] = cost;
  }

  // prompt
  PromptDetails? _savedPrompt;
  PromptDetails? get savedPrompt => _savedPrompt;
  void setSavedPrompt(PromptDetails prompt) {
    _savedPrompt = prompt;
  }

  bool _wasGenerated = false;
  bool get wasGenerated => _wasGenerated;

  void setWasGenerated(bool value) {
    _wasGenerated = value;
    notify();
  }

  Future<void> _asyncInit() async {
    // SqfliteService.printTableContent('prompts');
    // get token
    final token = await fetch(() => tokenService.getToken());
    if (token == null) {
      return;
    }

    // get price for fetching gigachat client id and client secret
    final price = await fetch(() => priceService.getPrice(token));
    if (price == null) {
      notify();
      return;
    }

    _gigachatClientId = price.clientId;
    _gigachatClientSecret = price.clientSecret;

    // get promt for title
    // final prompt =
    //     await fetch(() => promptService.getByName(ReWildPrompts.title));
    // if (prompt == null) {
    //   if (context.mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('Промпт не найден'),
    //       ),
    //     );
    //   }

    //   return;
    // }
    // _savedPrompt = prompt;

    // for every model get cost
    // for (final llm in llms) {
    //   final modelName = llm.name;
    //   int oneMillionTokenPrice = 0;
    //   // get one million token price for model
    //   if (llm.name == const LLM.gigaChat().name) {
    //     oneMillionTokenPrice = price.gigaChatLitePerMillion;
    //   } else if (llm.name == const LLM.gigaChatPlus().name) {
    //     oneMillionTokenPrice = price.gigaChatLitePlusPerMillion;
    //   } else if (llm.name == const LLM.gigaChatPro().name) {
    //     oneMillionTokenPrice = price.gigaChatProPerMillion;
    //   }
    //   if (oneMillionTokenPrice == 0) {
    //     continue;
    //   }

    // get and set cost for title generation
    // final costOrNull = await fetch(() => gigachatService.calculateCost(
    //     prompt: _savedPrompt!.prompt,
    //     role: _savedPrompt!.role,
    //     maxTokens: ReWildPrompts.titleMaxToken,
    //     model: modelName,
    //     clientId: _gigachatClientId!,
    //     clientSecret: _gigachatClientSecret!,
    //     costPerMillionTokens: oneMillionTokenPrice));
    // if (costOrNull != null) {
    //   setGigachatCost(modelName, costOrNull);
    // }
    // }
    notify();
  }

  Future<void> updateBalance() async {
    final balanceOrNull = await fetch(() => balanceService.getUserBalance());
    if (balanceOrNull != null) {
      setBalance(balanceOrNull);
    }
  }

  @override
  Future<void> savePrompt(String descriptionToSave, String roleToSave) async {
    _savedPrompt = PromptDetails(
      prompt: descriptionToSave,
      role: roleToSave,
    );
    // await fetch(() => promptService.insertOrReplace(
    //       ReWildPrompts.title,
    //       descriptionToSave,
    //       roleToSave,
    //     ));
  }

  Future<String> generateTitle() async {
    if (_savedPrompt == null ||
        _gigachatClientId == null ||
        _gigachatClientSecret == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Чтобы начать генерацию надо выбрать модель и промпт'),
        ),
      );
      return "";
    }
    // final prompt =
    //     "${_savedPrompt!.prompt}. Используй ключевые фразы:${_selectedKeywords.map((kw) => kw.keyword).join(',')}";
    String? llmRespOrNull;
    // if (_selectedModel == const LLM.gigaChat().name ||
    //     _selectedModel == const LLM.gigaChatPlus().name ||
    //     _selectedModel == const LLM.gigaChatPro().name) {
    //   llmRespOrNull = await fetch(() => gigachatService.askLLM(
    //       clientId: _gigachatClientId!,
    //       clientSecret: _gigachatClientSecret!,
    //       prompt: prompt,
    //       role: _savedPrompt!.role,
    //       maxTokens: ReWildPrompts.titleMaxToken,
    //       model: _selectedModel));
    // }
    // if (llmRespOrNull == null) {
    //   if (context.mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('Произошла ошибка'),
    //       ),
    //     );
    //     return "";
    //   }
    // }
    setWasGenerated(true);
    return removeEdgeQuotes(llmRespOrNull!);
  }
  // final llmRespOrNull = await fetch(() => gigachatService.askLLM(clientId: _gigachatClientId!, clientSecret: _gigachatClientSecret!, prompt: _savedPrompt!.prompt, role: _savedPrompt!.role, maxTokens: ReWildPrompts.titleMaxToken, model: ));
}
