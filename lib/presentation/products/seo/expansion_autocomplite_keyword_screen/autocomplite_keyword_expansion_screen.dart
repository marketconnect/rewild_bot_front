import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_autocomplite_keyword_screen/autocomplite_keyword_expansion_view_model.dart';

class AutocompliteKwExpansionScreen extends StatefulWidget {
  const AutocompliteKwExpansionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AutocompliteKwExpansionScreenState createState() =>
      _AutocompliteKwExpansionScreenState();
}

class _AutocompliteKwExpansionScreenState
    extends State<AutocompliteKwExpansionScreen> {
  final TextEditingController _controller = TextEditingController();
  // bool _isSearchVisible = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AutocompliteKeywordExpansionViewModel>();
    // final goBack = model.goBack;
    final fetchAndAddKeywords = model.fetchAndAddKeywords;
    final addedKeywords = model.addedKeywords;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (addedKeywords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                model.clearAddedKeywords();
              },
              tooltip: 'Сбросить выбранные',
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // if (_isSearchVisible)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Поиск ключевых слов',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _focusNode.unfocus();
                  },
                ),
              ),
              onSubmitted: (value) {
                fetchAndAddKeywords(value);
                _focusNode.unfocus();
              },
            ),
          ),
          const SizedBox(height: 10.0),
          if (model.allFetchedKeywords.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Введите слово или фразу для поиска автозаполнений.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: model.allFetchedKeywords.length,
                itemBuilder: (context, index) {
                  final keyword = model.allFetchedKeywords[index];
                  return _KwTile(kw: keyword);
                },
              ),
            ),
        ],
      ),
      floatingActionButton: addedKeywords.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                model.acceptKeywords();
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: Text('Добавить (${addedKeywords.length})',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary)),
              icon: Icon(Icons.check,
                  color: Theme.of(context).colorScheme.onPrimary),
            )
          : null,
    );
  }
}

class _KwTile extends StatelessWidget {
  final KwByLemma kw;

  const _KwTile({required this.kw});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AutocompliteKeywordExpansionViewModel>(
      context,
      listen: false,
    );
    Color selectedColor =
        Theme.of(context).colorScheme.primary.withOpacity(0.1);
    Color primary = Theme.of(context).colorScheme.primary;
    final isSelected = model.addedKeywords.contains(kw);
    final addKeyword = model.addKeyword;

    return Container(
      color: isSelected ? selectedColor : Colors.transparent,
      child: ListTile(
        title: Text(
          kw.keyword,
          style: TextStyle(
            color: isSelected ? primary : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: (kw.freq > 0)
            ? Text(
                'Частота: ${kw.freq}',
                style: TextStyle(
                  color: isSelected ? primary : Colors.grey,
                ),
              )
            : null,
        trailing: IconButton(
          icon: Icon(
            isSelected ? Icons.check_circle : Icons.add_circle_outline,
            color: isSelected ? primary : Colors.grey,
          ),
          onPressed: () {
            addKeyword(kw);
          },
        ),
        onTap: () {
          addKeyword(kw);
        },
      ),
    );
  }
}
