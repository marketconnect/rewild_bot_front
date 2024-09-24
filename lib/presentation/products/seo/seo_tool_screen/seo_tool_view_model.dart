import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/card_catalog.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';

// token
abstract class SeoToolTokenService {
  Future<Either<RewildError, String>> getToken();
}

abstract class SeoToolContentService {
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

class SeoToolViewModel extends ResourceChangeNotifier {
  SeoToolViewModel(
      {required super.context,
      required this.imageUrl,
      required this.cardItem,
      required this.tokenService,
      required this.contentService,
      required this.productId})
      : _cardItem = cardItem,
        _title = cardItem.title,
        _description = cardItem.description;
  // _asyncInit();

  // constructor params ========================================================
  final int productId;
  final String imageUrl;
  final SeoToolTokenService tokenService;
  final SeoToolContentService contentService;
  final CardItem cardItem;

  // Other fields ==============================================================
  CardItem _cardItem;

  // CardItem
  CardItem get cardItemValue => _cardItem;

  // Title
  String? _title;
  void setTitle(String? title) async {
    _title = title;
    // notify();
  }

  String? get title => _title;

  // Description
  String? _description;
  void setDescription(String? description) async {
    _description = description;
  }

  String? get description => _description;

  Future<void> setCardItem({String? title, String? description}) async {
    if (title == null && description == null) {
      return;
    }
    if (title != null) {
      setTitle(title);
      _cardItem = _cardItem.copyWith(title: title);
    }
    if (description != null) {
      setDescription(description);
      _cardItem = _cardItem.copyWith(description: description);
    }
    await _updateCardItem();
    notify();
  }

  Future<void> _updateCardItem() async {
    final tokenOrNull = await fetch(() => tokenService.getToken());
    if (tokenOrNull == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось получить токен'),
          ),
        );
      }
      return;
    }

    final result = await fetch(() => contentService.updateProductCard(
        nmID: productId,
        vendorCode: cardItemValue.vendorCode,
        sizes: cardItemValue.sizes,
        dimension: cardItemValue.dimensions,
        title: cardItemValue.title,
        description: cardItemValue.description,
        characteristics: cardItemValue.characteristics));
    if (result == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при обновлении карточки '),
          ),
        );
        return;
      }
    }
  }

  List<KwByLemma> _selectedTitleKeywords = [];

  List<KwByLemma> get selectedTitleKeywords => _selectedTitleKeywords;

  void titleGenerator() async {
    String text =
        'Ключевые слова: ${_selectedTitleKeywords.map((e) => e.keyword).join(', ')}';
    if (title != null) {
      text += '\nНазвание: $title';
    }
    final res = await Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.chatGptScreen, arguments: text);

    if (res != null) {
      setTitle(res as String);
    }
  }

  List<KwByLemma> _selectedDescriptionKeywords = [];

  List<KwByLemma> get selectedDescriptionKeywords =>
      _selectedDescriptionKeywords;
  void descriptionGenerator() async {
    String text =
        'Ключевые слова: ${_selectedDescriptionKeywords.map((e) => e.keyword).join(', ')}';
    if (description != null) {
      text += '\nОписание: $description';
    }
    final res = await Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.chatGptScreen, arguments: text);

    if (res != null) {
      setDescription(res as String);
    }
  }
}
