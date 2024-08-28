import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_words_keyword_screen/words_keyword_expansion_model.dart';
import 'package:rewild_bot_front/widgets/custom_elevated_button.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';

class WordsKeywordExpansionScreen extends StatefulWidget {
  const WordsKeywordExpansionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WordsKeywordExpansionScreenState createState() =>
      _WordsKeywordExpansionScreenState();
}

class _WordsKeywordExpansionScreenState
    extends State<WordsKeywordExpansionScreen> {
  final TextEditingController _keywordController = TextEditingController();
  final ScrollController _wordsScrollController = ScrollController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _keywordController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _keywordController.removeListener(_validateInput);
    _keywordController.dispose();
    _wordsScrollController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final text = _keywordController.text.trim();
    if (text.split(' ').length > 1) {
      setState(() {
        _errorMessage = 'Введите одно слово';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WordsKeywordExpansionViewModel>();
    final keywords = model.keywords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расширение запросов'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            model.goBack();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Добавляем SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Введите ключевые слова:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _keywordController,
                      decoration: InputDecoration(
                        labelText: 'Ключевое слово',
                        errorText: _errorMessage,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (_errorMessage == null &&
                                _keywordController.text.isNotEmpty) {
                              setState(() {
                                model
                                    .addKeyword(_keywordController.text.trim());
                                _keywordController.clear();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                children: keywords.map((keyword) {
                  return Chip(
                    label: Text(keyword),
                    onDeleted: () {
                      setState(() {
                        model.removeKeyword(keyword);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (keywords.isNotEmpty)
                CustomElevatedButton(
                  onTap: () {
                    model.fetchKeywords(keywords);
                  },
                  text: "Получить",
                  buttonStyle: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.primary,
                    ),
                    foregroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  height: model.screenWidth * 0.2,
                  margin: EdgeInsets.fromLTRB(
                    model.screenWidth * 0.1,
                    model.screenHeight * 0.01,
                    model.screenWidth * 0.1,
                    model.screenHeight * 0.01,
                  ),
                ),
              const SizedBox(height: 16),
              if (model.loadingText != null)
                const Center(child: MyProgressIndicator())
              else if (model.suggestedKeywords.isNotEmpty)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Всего: ${model.suggestedKeywords.length}'),
                          Text('Выбрано: ${model.selectedCount}'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 400, // or any other fixed height you prefer
                      child: Scrollbar(
                        controller: _wordsScrollController,
                        interactive: true,
                        thickness: 6.0,
                        radius: const Radius.circular(10),
                        child: ListView.builder(
                          controller: _wordsScrollController,
                          itemCount: model.suggestedKeywords.length,
                          itemBuilder: (context, index) {
                            return _KwTile(kw: model.suggestedKeywords[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KwTile extends StatelessWidget {
  final KwByLemma kw;

  const _KwTile({required this.kw});

  @override
  Widget build(BuildContext context) {
    final model =
        Provider.of<WordsKeywordExpansionViewModel>(context, listen: false);
    final selectedPhrases = model.selectedPhrases;
    final selectPhrase = model.selectPhrase;
    Color primaryC = Theme.of(context).colorScheme.primaryContainer;
    Color onSurface = Theme.of(context).colorScheme.onSurface;
    Color primary = Theme.of(context).colorScheme.primary;
    final isSelected =
        selectedPhrases.where((kw0) => kw0.keyword == kw.keyword).isNotEmpty;
    return Container(
      color: isSelected ? primaryC.withOpacity(0.2) : Colors.white,
      child: ListTile(
        title: Text(
          kw.keyword,
          style: TextStyle(
            color: isSelected ? onSurface : Colors.black,
          ),
        ),
        subtitle: Text(
          'Частота: ${kw.freq}',
          style: TextStyle(
            color: isSelected ? onSurface : Colors.black.withOpacity(0.6),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isSelected ? Icons.check_circle : Icons.add_circle_outline,
            color: isSelected ? primary : Colors.grey,
          ),
          onPressed: () {
            selectPhrase(kw.keyword);
          },
        ),
      ),
    );
  }
}
