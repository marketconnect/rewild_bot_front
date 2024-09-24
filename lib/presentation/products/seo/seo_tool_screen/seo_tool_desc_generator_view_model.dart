// import 'package:fpdart/fpdart.dart';

// import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
// import 'package:rewild_bot_front/core/utils/rewild_error.dart';
// import 'package:rewild_bot_front/core/utils/strings_utils.dart';
// import 'package:rewild_bot_front/domain/entities/card_catalog.dart';
// import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';

// // token
// abstract class SeoToolDescriptionGeneratorTokenService {
//   Future<Either<RewildError, String>> getToken();
// }

// abstract class SeoToolDescriptionGeneratorContentService {
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

// class SeoToolDescriptionGeneratorViewModel extends ResourceChangeNotifier {
//   final SeoToolDescriptionGeneratorTokenService tokenService;

//   final SeoToolDescriptionGeneratorContentService contentService;
//   SeoToolDescriptionGeneratorViewModel({
//     required super.context,
//     required this.tokenService,
//     required this.contentService,
//   });

//   // Keywords that user selected
//   // ignore: prefer_final_fields
//   List<KwByLemma> _selectedKeywords = [];
//   @override
//   List<KwByLemma> get selectedKeywords => _selectedKeywords;

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

//   // Methods ===================================================================

//   Future<String> generateDescription() async {
//     setWasGenerated(true);
//     return removeEdgeQuotes("");
//   }
//   // final llmRespOrNull = await fetch(() => gigachatService.askLLM(clientId: _gigachatClientId!, clientSecret: _gigachatClientSecret!, prompt: _savedPrompt!.prompt, role: _savedPrompt!.role, maxTokens: ReWildPrompts.titleMaxToken, model: ));
// }
