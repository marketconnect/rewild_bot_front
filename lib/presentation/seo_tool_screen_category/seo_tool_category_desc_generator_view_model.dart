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

// token
abstract class SeoToolCategoryDescriptionGeneratorTokenService {
  Future<Either<RewildError, String>> getToken();
}

abstract class SeoToolCategoryDescriptionGeneratorContentService {
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

// balance
abstract class SeoToolCategoryDescriptionGeneratorBalanceService {
  Future<Either<RewildError, double>> getUserBalance();
  Future<Either<RewildError, bool>> subtractBalance(double amountToSubtract);
}

// price
abstract class SeoToolCategoryDescriptionGeneratorModelPriceService {
  Future<Either<RewildError, Prices>> getPrice(String token);
}

class SeoToolCategoryDescriptionGeneratorViewModel
    extends ResourceChangeNotifier implements SeoCategoryGeneratorViewModel {
  final SeoToolCategoryDescriptionGeneratorBalanceService balanceService;
  final SeoToolCategoryDescriptionGeneratorModelPriceService priceService;
  final SeoToolCategoryDescriptionGeneratorTokenService tokenService;

  SeoToolCategoryDescriptionGeneratorViewModel({
    required super.context,
    required this.balanceService,
    required this.priceService,
    required this.tokenService,
  }) {
    _asyncInit();
  }

  // Keywords that user selected
  // ignore: prefer_final_fields
  List<KwByLemma> _selectedKeywords = [];
  @override
  List<KwByLemma> get selectedKeywords => _selectedKeywords;

  // TODO MOVE THIS LATER
  @override
  String get initialSelectedModel => const LLM.gigaChat().name;

  // Model that user selected
  String _selectedModel = const LLM.gigaChat().name;
  // ignore: annotate_overrides
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
  // String? _gigachatClientId;
  // String? _gigachatClientSecret;
  void setGigachatClient(String clientId, String clientSecret) {
    // _gigachatClientId = clientId;
    // _gigachatClientSecret = clientSecret;
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
  void setLLMsCost(String key, double cost) {
    _llmsCost ??= {};
    _llmsCost![key] = cost;
  }

  Map<String, int>? _llmMillionTokensCost;
  void setLLMsMillionTokensCost(String key, int cost) {
    _llmMillionTokensCost ??= {};
    _llmMillionTokensCost![key] = cost;
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

  // // Prices
  // Prices? _price;
  // void setPrice(Prices price) {
  //   _price = price;
  // }

  // double _currentCost = 0;
  // double get currentCost => _currentCost;
  // Methods ===================================================================
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
    // setPrice(price);
    // _gigachatClientId = price.clientId;
    // _gigachatClientSecret = price.clientSecret;

    // get promt for title
    // final prompt =
    //     await fetch(() => promptService.getByName(ReWildPrompts.description));
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
    for (final llm in llms) {
      final modelName = llm.name;
      int oneMillionTokenPrice = 0;
      // get one million token price for model
      if (llm.name == const LLM.gigaChat().name) {
        oneMillionTokenPrice = price.gigaChatLitePerMillion;
      } else if (llm.name == const LLM.gigaChatPlus().name) {
        oneMillionTokenPrice = price.gigaChatLitePlusPerMillion;
      } else if (llm.name == const LLM.gigaChatPro().name) {
        oneMillionTokenPrice = price.gigaChatProPerMillion;
      }
      if (oneMillionTokenPrice == 0) {
        continue;
      }
      setLLMsMillionTokensCost(modelName, oneMillionTokenPrice);
      // get and set cost for title generation
      // final costOrNull = await fetch(() => gigachatService.calculateCost(
      //     prompt: _savedPrompt!.prompt,
      //     role: _savedPrompt!.role,
      //     maxTokens: ReWildPrompts.descriptionMaxToken,
      //     model: modelName,
      //     clientId: _gigachatClientId!,
      //     clientSecret: _gigachatClientSecret!,
      //     costPerMillionTokens: oneMillionTokenPrice));

      // if (costOrNull != null) {
      //   setLLMsCost(modelName, costOrNull);
      // }
    }
    await updateBalance();
    notify();
  }

  Future<void> updateBalance() async {
    final balanceOrNull = await fetch(() => balanceService.getUserBalance());
    if (balanceOrNull != null) {
      // print("Balance: $balanceOrNull");
      setBalance(balanceOrNull);
    }
  }

  @override
  Future<void> savePrompt(String descriptionToSave, String roleToSave) async {
    if (_llmMillionTokensCost == null ||
        _llmMillionTokensCost![_selectedModel] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка. Модель не выбрана'),
        ),
      );
    }
    // final prompt =
    //     "$descriptionToSave. Используй ключевые фразы:${_selectedKeywords.map((kw) => kw.keyword).join(',')}";
    // final costOrNull = await fetch(() => gigachatService.calculateCost(
    //     prompt: prompt,
    //     role: _savedPrompt!.role,
    //     maxTokens: ReWildPrompts.descriptionMaxToken,
    //     model: _selectedModel,
    //     clientId: _gigachatClientId!,
    //     clientSecret: _gigachatClientSecret!,
    //     costPerMillionTokens: _llmMillionTokensCost![_selectedModel]!));

    // if (costOrNull != null) {
    //   _currentCost = costOrNull;
    // }
    // _savedPrompt = PromptDetails(
    //   prompt: descriptionToSave,
    //   role: roleToSave,
    // );
    // await fetch(() => promptService.insertOrReplace(
    //       ReWildPrompts.description,
    //       descriptionToSave,
    //       roleToSave,
    //     ));
  }

  Future<String> generateDescription() async {
    if (_savedPrompt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Промпт не найден'),
        ),
      );
      return "";
    }
    // final prompt =
    //     "${_savedPrompt!.prompt}. Используй ключевые фразы:${_selectedKeywords.map((kw) => kw.keyword).join(',')}";
    String? llmRespOrNull;

    if (_llmsCost == null ||
        _llmsCost![_selectedModel] == null ||
        _llmMillionTokensCost == null ||
        _llmMillionTokensCost![_selectedModel] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Модель не найдена'),
        ),
      );
      return "";
    }

    if (_selectedModel == const LLM.gigaChat().name ||
        _selectedModel == const LLM.gigaChatPlus().name ||
        _selectedModel == const LLM.gigaChatPro().name) {
      // final costOrNull = await fetch(() => gigachatService.calculateCost(
      //     clientId: _gigachatClientId!,
      //     clientSecret: _gigachatClientSecret!,
      //     costPerMillionTokens: _llmMillionTokensCost![_selectedModel]!,
      //     prompt: prompt,
      //     role: _savedPrompt!.role,
      //     maxTokens: ReWildPrompts.descriptionMaxToken,
      //     model: _selectedModel));

      // if (costOrNull == null) {
      //   if (context.mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('Произошла ошибка'),
      //       ),
      //     );
      //   }
      //   return "";
      // }
      // if (balance == null || balance! < costOrNull) {
      //   return "";
      // }
      // subtract from balance
      // final okOrNull =
      //     await fetch(() => balanceService.subtractBalance(costOrNull));
      // if (okOrNull == null) {
      //   return "";
      // }
      // get balance
      final balanceOrNull = await fetch(() => balanceService.getUserBalance());
      if (balanceOrNull != null) {
        setBalance(balanceOrNull);
      }

      // llmRespOrNull = await fetch(() => gigachatService.askLLM(
      //     clientId: _gigachatClientId!,
      //     clientSecret: _gigachatClientSecret!,
      //     prompt: prompt,
      //     role: _savedPrompt!.role,
      //     maxTokens: ReWildPrompts.descriptionMaxToken,
      //     model: _selectedModel));
    }
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

abstract class SeoCategoryGeneratorViewModel {
  Future<void> savePrompt(String descriptionToSave, String roleToSave);
  void selectModel(String model);
  String get selectedModel;
  String get initialSelectedModel;
  Map<String, double>? get llmsCost;
  List<KwByLemma> get selectedKeywords;
  double? get balance;
}
