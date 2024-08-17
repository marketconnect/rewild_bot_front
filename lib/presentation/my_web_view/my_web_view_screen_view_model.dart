import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';

abstract class MyWebViewScreenViewModelUpdateService {
  Future<Either<RewildError, int>> insert(
      {required String token,
      required List<CardOfProductModel> cardOfProductsToInsert});
}

abstract class MyWebViewScreenViewModelAuthService {
  Future<Either<RewildError, String>> getToken();
}

class MyWebViewScreenViewModel extends ResourceChangeNotifier {
  MyWebViewScreenViewModel(
      {required this.updateService,
      required this.tokenProvider,
      required super.context});
  final MyWebViewScreenViewModelUpdateService updateService;
  final MyWebViewScreenViewModelAuthService tokenProvider;
  bool isLoading = false;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  set errorMessage(String? errorMessage) {
    _errorMessage = errorMessage;
    notify();
  }

  Future<int> saveSiblingCards(String jsonString) async {
    isLoading = true;
    notify();
    if (jsonString.isEmpty) {
      return 0;
    }
    final cardsListEither = _parseCards(jsonString);
    if (cardsListEither.isLeft()) {
      errorMessage = cardsListEither.fold(
          (l) => l.message, (r) => throw UnimplementedError());
      isLoading = false;
      notify();
      return 0;
    }
    // if (cardsListResource is Error) {
    //   errorMessage = cardsListResource.message;
    //   isLoading = false;
    //   notify();
    //   return 0;
    // }

    final cardsList =
        cardsListEither.fold((l) => throw UnimplementedError(), (r) => r);
    // get token
    final tokenEither = await tokenProvider.getToken();
    if (tokenEither.isLeft()) {
      errorMessage =
          tokenEither.fold((l) => l.message, (r) => throw UnimplementedError());

      isLoading = false;
      notify();
    }

    final token = tokenEither.fold((l) => null, (r) => r);
    if (tokenEither.isRight() && token != null) {
      final insertEither = await updateService.insert(
          token: token, cardOfProductsToInsert: cardsList);
      if (insertEither.isRight()) {
        isLoading = false;
        notify();
        return insertEither.fold((l) => 0, (r) => r);
      }
    }

    return 0;
  }

  Either<RewildError, List<CardOfProductModel>> _parseCards(String jsonString) {
    try {
      List<dynamic> jsonList = json.decode(jsonString);
      List<CardOfProductModel> cards = [];

      for (final jsonObject in jsonList) {
        cards.add(
            CardOfProductModel(nmId: jsonObject['id'], img: jsonObject['img']));
      }
      return right(cards);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          e.toString(),
          source: "MyWebViewScreenViewModel",
          name: "_parseCards",
          args: [jsonString]));
    }
  }
}
