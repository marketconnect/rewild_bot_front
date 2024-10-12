import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

abstract class AllCategoriesScreenCategoriesService {
  Future<Either<RewildError, List<String>>> getAll({
    required String token,
  });
}

abstract class AllCategoriesScreenAuthService {
  Future<Either<RewildError, String>> getToken();
}

class AllCategoriesScreenViewModel extends ResourceChangeNotifier {
  final AllCategoriesScreenCategoriesService categoriesService;
  final AllCategoriesScreenAuthService authService;

  AllCategoriesScreenViewModel(
      {required super.context,
      required this.authService,
      required this.categoriesService}) {
    _asyncInit();
  }

  _asyncInit() async {
    // SqfliteService.printTableContent('categories');
    setIsLoading(true);

    final token = await fetch(() => authService.getToken());
    if (token == null) {
      setIsLoading(false);
      return;
    }
    final allCategoriesOrNull =
        await fetch(() => categoriesService.getAll(token: token));
    if (allCategoriesOrNull == null) {
      setIsLoading(false);
      return;
    }

    setCategories(allCategoriesOrNull);
    setIsLoading(false);
  } // async ==========================================

  // is loading
  bool _isLoading = false;
  void setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  bool get isLoading => _isLoading;

  bool _subscriptionsIsEmpty = false;
  void setSubscriptionsIsEmpty(bool value) {
    _subscriptionsIsEmpty = value;
    notify();
  }

  bool get subscriptionsIsEmpty => _subscriptionsIsEmpty;

  Map<String, bool> _categories = {};
  void setCategories(List<String> catNames) {
    _categories = {for (var e in catNames) e: false};
    _categories["Все"] = false;
  }

  void _resetCategories() {
    _categories = {for (var e in _categories.keys) e: false};
    _categories["Все"] = false;
    notify();
  }

  Map<String, bool> get categories => _categories;

  void setCheckedCategories(String catName, bool value) {
    if (catName == "Все") {
      _categories.forEach((k, v) {
        _categories[k] = value;
      });
    } else {
      _categories[catName] = value;
    }
    notify();
  }

  bool get isAnyCategoryChecked => _categories.values.any((v) => v);

  void navigateToAllSubjectsScreen() {
    final checkedCategories = _categories.entries
        .where((element) => element.value)
        .map((e) => e.key)
        .toList();
    if (checkedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Выберите хотя бы одну категорию"),
        ),
      );
      return;
    }
    _resetCategories();
    Navigator.of(context).pushNamed(MainNavigationRouteNames.allSubjectsScreen,
        arguments: checkedCategories);
  }
}
