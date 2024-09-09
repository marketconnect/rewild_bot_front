import 'package:flutter/material.dart';
import 'package:web/web.dart' as html;

class AddCardOptionScreen extends StatefulWidget {
  const AddCardOptionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddCardOptionScreenState createState() => _AddCardOptionScreenState();
}

class _AddCardOptionScreenState extends State<AddCardOptionScreen> {
  final TextEditingController _skuController = TextEditingController();
  final List<String> _skuList = [];

  void _addSkuOrLink() {
    final input = _skuController.text.trim();
    if (input.isNotEmpty) {
      setState(() {
        _skuList.add(input);
        _skuController.clear();
      });
    } else {
      _showErrorMessage('Вставьте артикул или ссылку.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  void _removeSkuOrLink(int index) {
    setState(() {
      _skuList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final model = context.watch<AddCardOptionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавление товаров'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: () {
                html.window.open(
                  'https://www.wildberries.ru/',
                  'wb',
                );
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.08,
                child: Text(
                  'Добавить с сайта Wildberries',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSkuInputSection(context),
            const SizedBox(height: 24),
            _buildSkuList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSkuInputSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.add_link, size: 40, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Добавить артикул или ссылку',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Вставьте артикул или ссылку для добавления новой карточки товара.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skuController,
              decoration: InputDecoration(
                hintText: 'Введите артикул или ссылку',
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _addSkuOrLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Добавить',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkuList(BuildContext context) {
    return _skuList.isEmpty
        ? const SizedBox.shrink()
        : Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Добавленные артикулы или ссылки:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _skuList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_skuList[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeSkuOrLink(index),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
