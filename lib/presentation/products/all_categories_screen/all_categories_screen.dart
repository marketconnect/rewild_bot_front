import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/presentation/products/all_categories_screen/all_categories_view_model.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllCategoriesScreenViewModel>();
    final categories = model.categories.entries.toList()
      ..sort((a, b) {
        if (a.key == "Все") return -1;
        if (b.key == "Все") return 1;
        return a.key.compareTo(b.key);
      });
    final navigateToAllSubjects = model.navigateToAllSubjectsScreen;

    final isLoading = model.isLoading;
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Выберите категорию',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1f1f1f),
            ),
            // textScaler: TextScaler()
          ),
          scrolledUnderElevation: 2,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryMap = categories[index];
                final category = categoryMap.key;
                final checked = categoryMap.value;

                return CheckboxListTile(
                  title: Text(category),
                  value: checked,
                  onChanged: (bool? value) {
                    model.setCheckedCategories(category, value!);
                  },
                );
              },
            ),
      floatingActionButton: model.isAnyCategoryChecked
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                // Perform your action here
                navigateToAllSubjects();
              },
              child: const Icon(Icons.arrow_forward),
            )
          : null,
    );
  }
}
