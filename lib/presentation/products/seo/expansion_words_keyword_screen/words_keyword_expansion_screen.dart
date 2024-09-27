import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_words_keyword_screen/words_keyword_expansion_model.dart';
import 'package:rewild_bot_front/widgets/custom_elevated_button.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';

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
  void dispose() {
    _keywordController.dispose();
    _wordsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WordsKeywordExpansionViewModel>();
    final keywords = model.keywords;
    final isLoading = model.isLoading;

    final sekectedCount = model.selectedCount;
    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Расширение запросов'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            if (sekectedCount > 0)
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  model.resetSelectedPhrases();
                },
                tooltip: 'Сбросить выбранные',
              ),
          ],
        ),
        floatingActionButton: sekectedCount > 0
            ? FloatingActionButton.extended(
                onPressed: () {
                  model.goBack();
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                label: Text('Добавить ($sekectedCount)',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary)),
                icon: Icon(Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary),
              )
            : null,
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
                              final text = _keywordController.text.trim();
                              if (text.isEmpty) {
                                setState(() {
                                  _errorMessage = 'Поле не должно быть пустым';
                                });
                                return;
                              }

                              final words = text
                                  .split(RegExp(r'[\s,]+'))
                                  .map((e) => e.trim())
                                  .toList();
                              if (words.any((word) => word.contains(' '))) {
                                setState(() {
                                  _errorMessage =
                                      'Пожалуйста, вводите только отдельные слова';
                                });
                              } else {
                                setState(() {
                                  _errorMessage = null;

                                  model.addKeywords(words);

                                  _keywordController.clear();
                                });
                              }

                              // }
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
                if (model.suggestedKeywords.isNotEmpty)
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
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: ListView.builder(
                          controller: _wordsScrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0), // Добавили отступы
                          itemCount: model.suggestedKeywords.length,
                          itemBuilder: (context, index) {
                            return _KwTile(kw: model.suggestedKeywords[index]);
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
class _KwTile extends StatelessWidget {
  final KwByLemma kw;

  const _KwTile({required this.kw});

  @override
  Widget build(BuildContext context) {
    final model =
        Provider.of<WordsKeywordExpansionViewModel>(context, listen: false);
    final isSelected =
        model.selectedPhrases.any((kw0) => kw0.keyword == kw.keyword);

    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 4.0), // Добавляем отступы между карточками
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.white,
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0), // Закругленные углы
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // Смещение тени
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(
          kw.keyword,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          'Частота: ${kw.freq}',
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isSelected ? Icons.check_circle : Icons.add_circle_outline,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
          onPressed: () {
            model.selectPhrase(kw.keyword);
          },
        ),
        onTap: () {
          model.selectPhrase(kw.keyword);
        },
      ),
    );
  }
}
