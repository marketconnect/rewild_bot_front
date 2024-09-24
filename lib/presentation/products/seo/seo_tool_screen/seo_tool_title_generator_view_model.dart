// import 'package:flutter/material.dart';
// import 'package:fpdart/fpdart.dart';
// import 'package:rewild_bot_front/core/constants/llms.dart';

// import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
// import 'package:rewild_bot_front/core/utils/rewild_error.dart';
// import 'package:rewild_bot_front/core/utils/strings_utils.dart';
// import 'package:rewild_bot_front/domain/entities/card_catalog.dart';
// import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
// import 'package:rewild_bot_front/domain/entities/prices.dart';
// import 'package:rewild_bot_front/domain/entities/prompt_details.dart';
// import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_desc_generator_view_model.dart';

// // token
// abstract class SeoToolTitleGeneratorTokenService {
//   Future<Either<RewildError, String>> getToken();
// }

// abstract class SeoToolTitleGeneratorContentService {
//   Future<Either<RewildError, bool>> updateProductCard({
//     required int nmID,
//     required String vendorCode,
//     required List<CardItemSize> sizes,
//     required Dimension dimension,
//     String? title,
//     String? description,
//     List<Characteristic>? characteristics,
//   });
// }

// class SeoToolTitleGeneratorViewModel extends ResourceChangeNotifier {
//   final SeoToolTitleGeneratorTokenService tokenService;

//   final SeoToolTitleGeneratorContentService contentService;
//   SeoToolTitleGeneratorViewModel({
//     required super.context,
//     required this.tokenService,
//     required this.contentService,
//   });

//   // Keywords that user selected
//   // ignore: prefer_final_fields
//   // List<KwByLemma> _selectedKeywords = [];

//   // List<KwByLemma> get selectedKeywords => _selectedKeywords;

//   // init model

//   // content
//   CardItem? _cardItem;
//   CardItem? get cardItem => _cardItem;
//   void setCardItem(CardItem cardItem) {
//     _cardItem = cardItem;
//   }

//   bool _wasGenerated = false;
//   bool get wasGenerated => _wasGenerated;

//   void setWasGenerated(bool value) {
//     _wasGenerated = value;
//     notify();
//   }

//   Future<String> generateTitle() async {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Чтобы начать генерацию надо выбрать модель и промпт'),
//       ),
//     );
//     return "";
//   }

//   // final llmRespOrNull = await fetch(() => gigachatService.askLLM(clientId: _gigachatClientId!, clientSecret: _gigachatClientSecret!, prompt: _savedPrompt!.prompt, role: _savedPrompt!.role, maxTokens: ReWildPrompts.titleMaxToken, model: ));
// }
