import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/card_catalog.dart';

// token
abstract class SeoToolCategoryTokenService {
  Future<Either<RewildError, String>> getToken();
}

abstract class SeoToolCategoryContentService {
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

class SeoToolCategoryViewModel extends ResourceChangeNotifier {
  SeoToolCategoryViewModel({
    required super.context,
    required this.tokenService,
  });
  // _asyncInit();

  // constructor params ========================================================

  final SeoToolCategoryTokenService tokenService;

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

  Future<void> setCardItem({String? title, String? description}) async {
    if (title == null && description == null) {
      return;
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

    // final result = await fetch(() => contentService.updateProductCard(
    //     nmID: productId,
    //     vendorCode: cardItemValue.vendorCode,
    //     sizes: cardItemValue.sizes,
    //     dimension: cardItemValue.dimensions,
    //     title: cardItemValue.title,
    //     description: cardItemValue.description,
    //     characteristics: cardItemValue.characteristics));
    // if (result == null) {
    //   if (context.mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('Ошибка при обновлении карточки '),
    //       ),
    //     );
    //     return;
    //   }
    // }
  }
}
