import 'package:flutter/material.dart';

class AddCardOptionScreen extends StatefulWidget {
  const AddCardOptionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddCardOptionScreenState createState() => _AddCardOptionScreenState();
}

class _AddCardOptionScreenState extends State<AddCardOptionScreen> {
  final TextEditingController _skuController = TextEditingController();

  void _addSkuOrLink() {
    final input = _skuController.text.trim();
    if (input.isNotEmpty) {
      // Логика добавления SKU или ссылки
      print('Добавлено SKU/ссылка: $input');
      _skuController.clear();
    } else {
      _showErrorMessage('Введите SKU или ссылку.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _addFromWildberries() {
    // Логика добавления карточек с сайта Wildberries
    print('Добавление карточек с сайта Wildberries');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить карточки'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Выберите способ добавления карточек:',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _skuController,
                      decoration: InputDecoration(
                        labelText: 'Введите SKU или ссылку',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _skuController.clear();
                          },
                        ),
                      ),
                      onSubmitted: (_) => _addSkuOrLink(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addSkuOrLink,
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить SKU/ссылку'),
                      // style: ElevatedButton.styleFrom(
                      //   primary: Theme.of(context).primaryColor,
                      // ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.language,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text('Добавить с сайта Wildberries'),
                      subtitle: const Text(
                        'Загрузите карточки товаров с сайта Wildberries.',
                      ),
                      trailing: ElevatedButton(
                        onPressed: _addFromWildberries,
                        child: const Text('Перейти'),
                        // style: ElevatedButton.styleFrom(

                        //   primary: Theme.of(context).primaryColor,
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
