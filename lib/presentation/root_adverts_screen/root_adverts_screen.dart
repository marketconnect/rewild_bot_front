import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rewild_bot_front/presentation/root_adverts_screen/root_adverts_screen_view_model.dart';
import 'package:rewild_bot_front/widgets/main_navigation_screen_advert_widget.dart';

class RootAdvertsScreen extends StatelessWidget {
  const RootAdvertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RootAdvertsScreenViewModel>();
    final isLoading = model.isLoading;
    final adverts = model.adverts;
    final callback = model.updateAdverts;
    final balance = model.balance;
    final advertApiKeyExists = model.advertApiKeyExists;
    final budget = model.budget;
    return Scaffold(
      body: MainNavigationScreenAdvertWidget(
          adverts: adverts,
          apiKeyExists: advertApiKeyExists,
          balance: balance,
          budget: budget,
          isLoading: isLoading,
          callbackForUpdate: callback),
    );
  }
}
