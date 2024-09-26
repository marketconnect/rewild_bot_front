import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/card_catalog.dart';

// token
abstract class SeoToolEmptyProductTokenService {
  Future<Either<RewildError, String>> getToken();
}

abstract class SeoToolEmptyProductContentService {
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

class SeoToolEmptyProductViewModel extends ResourceChangeNotifier {
  SeoToolEmptyProductViewModel({
    required super.context,
    required this.tokenService,
  });
  // _asyncInit();

  // constructor params ========================================================

  final SeoToolEmptyProductTokenService tokenService;

  // Other fields ==============================================================

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

  final List<KwByLemma> _selectedTitleKeywords = [];

  List<KwByLemma> get selectedTitleKeywords => _selectedTitleKeywords;

  void titleGenerator() async {
    String text =
        'Создай текст названия. Ключевые слова: ${_selectedTitleKeywords.map((e) => e.keyword).join(', ')}';
    // if (title != null) {
    //   text += '\nНазвание: $title';
    // }
    final res = await Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.chatGptScreen, arguments: text);

    if (res != null) {
      setTitle(res as String);
    }
  }

  final List<KwByLemma> _selectedDescriptionKeywords = [];

  List<KwByLemma> get selectedDescriptionKeywords =>
      _selectedDescriptionKeywords;
  void descriptionGenerator() async {
    String text =
        'Создай текст описания товара. Ключевые слова: ${_selectedDescriptionKeywords.map((e) => e.keyword).join(', ')}';
    // if (description != null) {
    //   text += '\nОписание: $description';
    // }
    final res = await Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.chatGptScreen, arguments: text);

    if (res != null) {
      setDescription(res as String);
    }
  }
}
