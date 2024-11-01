// SeoToolScreen.dart

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:web/web.dart' as html;
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';

import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_kw_research_view_model.dart';

import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_view_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/widgets/custom_elevated_button.dart';
import 'package:rewild_bot_front/widgets/my_dialog_header_and_two_btns_widget.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';

class SeoToolScreen extends StatefulWidget {
  const SeoToolScreen({super.key});

  @override
  _SeoToolScreenState createState() => _SeoToolScreenState();
}

class _SeoToolScreenState extends State<SeoToolScreen> {
  int _selectedIndex = 0;
  bool justLoaded = true;

  static const List<String> titles = [
    'Сбор фраз',
    'Название',
    'Описание',
  ];

  static final List<Widget> _sections = <Widget>[
    const KeywordManager(),
    const TitleGeneratorScreen(),
    const DescriptionGeneratorScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kwResearchModel = context.watch<SeoToolKwResearchViewModel>();
    final isSaving = kwResearchModel.isSaving;
    final hasChange = kwResearchModel.hasChange;
    final isLoading = kwResearchModel.isLoading;
    final model = context.read<SeoToolViewModel>();
    final titleGenerator = model.titleGenerator;
    final descriptionGenerator = model.descriptionGenerator;

    if (!isLoading && justLoaded) {
      justLoaded = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final title = model.title;
        final description = model.description;
        if (title != null) {
          kwResearchModel.countKeyPhraseOccurrences(text: title, isTitle: true);
        }
        if (description != null) {
          kwResearchModel.countKeyPhraseOccurrences(
              text: description, isTitle: false);
        }
      });
    }

    return OverlayLoaderWithAppIcon(
      isLoading: isLoading || isSaving,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (!hasChange()) {
                      Navigator.of(context).pop();
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (BuildContext buildContext) {
                        return MyDialogHeaderAndTwoBtnsWidget(
                          onNoPressed: () {
                            if (buildContext.mounted) {
                              Navigator.of(buildContext).pop();
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          onYesPressed: () async {
                            if (buildContext.mounted) {
                              Navigator.of(buildContext).pop();
                            }
                            await kwResearchModel.save();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          title: 'Сохранить изменения?',
                        );
                      },
                    );
                  }),
              title: _Title(
                  title: _selectedIndex == 0
                      ? '${titles[_selectedIndex]} (${kwResearchModel.corePhrases.length})'
                      : titles[_selectedIndex]),
              scrolledUnderElevation: 2,
              shadowColor: Colors.black,
              surfaceTintColor: Colors.transparent,
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: _sections,
            ),
            floatingActionButton: _selectedIndex == 0
                ? buildSpeedDial(context)
                : _selectedIndex == 1
                    ? buildFloatingActionButton(context, titleGenerator)
                    : buildFloatingActionButton(context, descriptionGenerator),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                buildBottomNavigationBarItem(
                    Icons.search, titles[0], _selectedIndex == 0),
                buildBottomNavigationBarItem(
                    Icons.title, titles[1], _selectedIndex == 1),
                buildBottomNavigationBarItem(
                    Icons.description, titles[2], _selectedIndex == 2),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.outline,
              selectedLabelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              unselectedLabelStyle: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  FloatingActionButton buildFloatingActionButton(
    BuildContext context,
    void Function() onPressed,
  ) {
    return FloatingActionButton(
      onPressed: () {
        onPressed();
      },
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.smart_toy,
        size: 32,
      ),
    );
  }

  BottomNavigationBarItem buildBottomNavigationBarItem(
      IconData iconData, String label, bool isActive) {
    return BottomNavigationBarItem(
      icon: Icon(
        iconData,
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
        size: MediaQuery.of(context).size.width * 0.07,
      ),
      label: label,
    );
  }

  Widget buildSpeedDial(BuildContext context) {
    final kwResearchModel = context.read<SeoToolKwResearchViewModel>();

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 12,
      spaceBetweenChildren: 12,
      childPadding: const EdgeInsets.all(5),
      animationDuration: const Duration(milliseconds: 150),
      visible: true,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: const CircleBorder(),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.text_fields),
          backgroundColor: Colors.tealAccent,
          label: 'По словам',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () async {
            await kwResearchModel.goToWordsKwExpansionScreen();
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.category),
          backgroundColor: Colors.orange,
          label: 'По категории',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () async {
            await kwResearchModel.goToSubjectKwExpansionScreen();
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.autorenew),
          backgroundColor: Colors.purple,
          label: 'Автозаполнение',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () async {
            await kwResearchModel.goToAutocompliteKwExpansionScreen();
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.business),
          backgroundColor: Colors.blue,
          label: 'Из других карточек',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () async {
            await kwResearchModel.goToCompetitorsKwExpansionScreen();
          },
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final String title;
  const _Title({
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    final model = context.watch<SeoToolViewModel>();
    final imageUrl = model.imageUrl;

    return Row(
      children: [
        if (imageUrl.isNotEmpty)
          ReWildNetworkImage(
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.width * 0.1,
              image: imageUrl),
        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
        Text(title,
            maxLines: 2,
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05)),
      ],
    );
  }
}

class TitleGeneratorScreen extends StatefulWidget {
  const TitleGeneratorScreen({super.key});

  @override
  _TitleGeneratorScreenState createState() => _TitleGeneratorScreenState();
}

class _TitleGeneratorScreenState extends State<TitleGeneratorScreen> {
  final TextEditingController titleController = TextEditingController();

  bool isTitleTextFieldEmpty = true;
  String? _titleErrorMessage;

  @override
  Widget build(BuildContext context) {
    final seoToolModel = context.watch<SeoToolViewModel>();
    final title = seoToolModel.title;
    final setTitle = seoToolModel.setCardItem;

    final selectedKeywords = seoToolModel.selectedTitleKeywords;

    final kwResearchModel = context.watch<SeoToolKwResearchViewModel>();
    final corePhrases = kwResearchModel.corePhrases;
    final keywordsFromServer = kwResearchModel.keywordsFromServer;

    // Объединяем ключевые слова и удаляем выбранные
    final allKeywords = [
      ...corePhrases,
      ...keywordsFromServer
    ]..removeWhere((kw) =>
        selectedKeywords.any((selectedKw) => selectedKw.keyword == kw.keyword));

    // Сортируем по частоте
    allKeywords.sort((a, b) => b.freq.compareTo(a.freq));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Существующее наименование:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                if (title != null)
                  GestureDetector(
                    onTap: () {
                      if (titleController.text.isEmpty) {
                        titleController.text = title;
                      }
                    },
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Генерация наименования',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  onChanged: (value) {
                    if (value.isNotEmpty && isTitleTextFieldEmpty) {
                      setState(() {
                        isTitleTextFieldEmpty = false;
                      });
                      return;
                    } else if (value.isEmpty && !isTitleTextFieldEmpty) {
                      setState(() {
                        isTitleTextFieldEmpty = true;
                      });
                    }
                    if (value.length > 60) {
                      setState(() {
                        _titleErrorMessage =
                            'Превышено количество символов для поля (${value.length}). Обычно разрешается указывать не более 60 символов в поле Наименование. Ваша карточка может попасть в Черновики.';
                      });
                    } else {
                      setState(() {
                        _titleErrorMessage = null;
                      });
                    }
                  },
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Наименование',
                    border: const OutlineInputBorder(),
                    errorText: _titleErrorMessage,
                    errorMaxLines: 5,
                    suffixIcon: isTitleTextFieldEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              titleController.clear();
                              setState(() {
                                isTitleTextFieldEmpty = true;
                              });
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                if (titleController.text.isNotEmpty)
                  CustomElevatedButton(
                    onTap: () async {
                      await setTitle(title: titleController.text);

                      kwResearchModel.countKeyPhraseOccurrences(
                        text: titleController.text,
                        isTitle: true,
                      );
                    },
                    buttonStyle: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    text: 'Сохранить',
                  ),
                const SizedBox(height: 16),
                Text(
                  'Выбранные ключевые слова:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: selectedKeywords.map((keyword) {
                    return Chip(
                      label: Text(keyword.keyword),
                      onDeleted: () {
                        setState(() {
                          selectedKeywords.remove(keyword);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Все ключевые слова:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: allKeywords.map((keyword) {
                    final isFromServer = keywordsFromServer.contains(keyword);
                    final occurenceInTitle = keyword.numberOfOccurrencesInTitle;
                    final occurenceInDescription =
                        keyword.numberOfOccurrencesInDescription;
                    final hasOccurrences = (occurenceInDescription != null &&
                            occurenceInDescription > 0) ||
                        (occurenceInTitle != null && occurenceInTitle > 0);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ActionChip(
                        backgroundColor:
                            isFromServer ? Colors.lightBlue[50] : null,
                        avatar: isFromServer
                            ? const Icon(Icons.check_circle_outline_outlined,
                                size: 16)
                            : null,
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              keyword.keyword,
                              style: hasOccurrences
                                  ? TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : null,
                            ),
                            Text(
                              'Частота: ${keyword.freq}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            if (hasOccurrences)
                              Text(
                                'Точные вхождения',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            if (occurenceInDescription != null &&
                                occurenceInDescription > 0)
                              Text(
                                'В описании: $occurenceInDescription',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            if (occurenceInTitle != null &&
                                occurenceInTitle > 0)
                              Text(
                                'В названии: $occurenceInTitle',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            allKeywords.remove(keyword);
                            selectedKeywords.add(keyword);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DescriptionGeneratorScreen extends StatefulWidget {
  const DescriptionGeneratorScreen({super.key});

  @override
  _DescriptionGeneratorScreenState createState() =>
      _DescriptionGeneratorScreenState();
}

class _DescriptionGeneratorScreenState
    extends State<DescriptionGeneratorScreen> {
  final TextEditingController descriptionController = TextEditingController();
  bool isDescriptionTextFieldEmpty = true;
  String? _descriptionErrorMessage;

  @override
  Widget build(BuildContext context) {
    final seoToolModel = context.watch<SeoToolViewModel>();
    final description = seoToolModel.description;
    final setDescription = seoToolModel.setCardItem;

    final selectedKeywords = seoToolModel.selectedDescriptionKeywords;

    final kwResearchModel = context.watch<SeoToolKwResearchViewModel>();
    final corePhrases = kwResearchModel.corePhrases;
    final keywordsFromServer = kwResearchModel.keywordsFromServer;

    // Объединяем ключевые слова и удаляем выбранные
    final allKeywords = [
      ...corePhrases,
      ...keywordsFromServer
    ]..removeWhere((kw) =>
        selectedKeywords.any((selectedKw) => selectedKw.keyword == kw.keyword));

    // Сортируем по частоте
    allKeywords.sort((a, b) => b.freq.compareTo(a.freq));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Существующее описание:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                if (description != null)
                  GestureDetector(
                    onTap: () {
                      if (descriptionController.text.isEmpty) {
                        descriptionController.text = description;
                      }
                    },
                    child: Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Генерация описания',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  onChanged: (value) {
                    setState(() {
                      isDescriptionTextFieldEmpty = value.isEmpty;
                    });
                    if (value.length > 2000) {
                      setState(() {
                        _descriptionErrorMessage =
                            'Превышено количество символов для поля (${value.length}). Обычно разрешается указывать не более 2000 символов в поле Описания. Ваша карточка может попасть в Черновики.';
                      });
                    } else {
                      setState(() {
                        _descriptionErrorMessage = null;
                      });
                    }
                  },
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Описание',
                    errorText: _descriptionErrorMessage,
                    errorMaxLines: 5,
                    border: const OutlineInputBorder(),
                    suffixIcon: isDescriptionTextFieldEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              descriptionController.clear();
                              setState(() {
                                isDescriptionTextFieldEmpty = true;
                              });
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                if (descriptionController.text.isNotEmpty)
                  CustomElevatedButton(
                    onTap: () async {
                      await setDescription(
                          description: descriptionController.text);
                      kwResearchModel.countKeyPhraseOccurrences(
                        text: descriptionController.text,
                        isTitle: false,
                      );
                    },
                    buttonStyle: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    text: 'Сохранить',
                  ),
                const SizedBox(height: 16),
                Text(
                  'Выбранные ключевые слова:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: selectedKeywords.map((keyword) {
                    return Chip(
                      label: Text(keyword.keyword),
                      onDeleted: () {
                        setState(() {
                          selectedKeywords.remove(keyword);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Все ключевые слова:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: allKeywords.map((keyword) {
                    final isFromServer = keywordsFromServer.contains(keyword);
                    final occurenceInTitle = keyword.numberOfOccurrencesInTitle;
                    final occurenceInDescription =
                        keyword.numberOfOccurrencesInDescription;
                    final hasOccurrences = (occurenceInDescription != null &&
                            occurenceInDescription > 0) ||
                        (occurenceInTitle != null && occurenceInTitle > 0);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ActionChip(
                        backgroundColor:
                            isFromServer ? Colors.lightBlue[50] : null,
                        avatar: isFromServer
                            ? const Icon(Icons.check_circle_outline_outlined,
                                size: 16)
                            : null,
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              keyword.keyword,
                              style: hasOccurrences
                                  ? TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : null,
                            ),
                            Text(
                              'Частота: ${keyword.freq}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            if (hasOccurrences)
                              Text(
                                'Точные вхождения',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            if (occurenceInDescription != null &&
                                occurenceInDescription > 0)
                              Text(
                                'В описании: $occurenceInDescription',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            if (occurenceInTitle != null &&
                                occurenceInTitle > 0)
                              Text(
                                'В названии: $occurenceInTitle',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            allKeywords.remove(keyword);
                            selectedKeywords.add(keyword);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KeywordManager extends StatefulWidget {
  const KeywordManager({super.key});

  @override
  _KeywordManagerState createState() => _KeywordManagerState();
}

class _KeywordManagerState extends State<KeywordManager> {
  Set<KwByLemma> selectedKeywords = {};
  List<ListItem> buildGroupedKeywordItems(List<KwByLemma> keywords) {
    // Sort keywords by length in ascending order
    final sortedKeywords = [...keywords];
    sortedKeywords.sort((a, b) => a.keyword.length.compareTo(b.keyword.length));

    // Map to hold parent keywords and their children
    Map<String, List<KwByLemma>> keywordChildren = {};
    Set<String> keywordSet = keywords.map((k) => k.keyword).toSet();

    // Build parent-child relationships
    for (var kw in sortedKeywords) {
      bool hasParent = false;
      for (int i = kw.keyword.length - 1; i > 0; i--) {
        String prefix = kw.keyword.substring(0, i).trim();
        if (keywordSet.contains(prefix)) {
          hasParent = true;
          keywordChildren.putIfAbsent(prefix, () => []).add(kw);
          break;
        }
      }
      if (!hasParent) {
        keywordChildren.putIfAbsent(kw.keyword, () => []);
      }
    }

    // Build list items with indentation
    List<ListItem> items = [];
    Set<String> addedKeywords = {};

    void addKeywordWithChildren(String keyword, int indentLevel) {
      if (addedKeywords.contains(keyword)) return;
      addedKeywords.add(keyword);

      // Find the KwByLemma object for this keyword
      final kwObj = keywords.firstWhere((k) => k.keyword == keyword);

      items.add(KeywordItem(kwObj, indentLevel: indentLevel));

      // Recursively add children
      final children = keywordChildren[keyword];
      if (children != null) {
        for (var child in children) {
          addKeywordWithChildren(child.keyword, indentLevel + 1);
        }
      }
    }

    // Start with root keywords
    for (var keyword in keywordChildren.keys) {
      bool isChild = keywordChildren.values.any(
          (children) => children.any((childKw) => childKw.keyword == keyword));
      if (!isChild) {
        addKeywordWithChildren(keyword, 0);
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SeoToolKwResearchViewModel>();
    final corePhrases = model.corePhrases;
    final keywordsFromServer = model.keywordsFromServer;

    // Создаем объединенный список элементов для ListView
    final List<ListItem> items = [];

    if (keywordsFromServer.isNotEmpty) {
      items.add(SectionHeaderItem(
          'Ключевые слова с показами на первых двух страницах'));
      items.addAll(keywordsFromServer.map((k) => KeywordItem(k)));
    }

    // if (corePhrases.isNotEmpty) {
    //   items.add(SectionHeaderItem('Новые ключевые слова'));
    //   items.addAll(corePhrases.map((k) => KeywordItem(k)));
    // } else {
    //   items.add(
    //       EmptyStateItem('Пока не добавлено ни одного нового ключевого слова'));
    // }
    if (corePhrases.isNotEmpty) {
      items.add(SectionHeaderItem('Новые ключевые слова'));
      items.addAll(buildGroupedKeywordItems(corePhrases));
    } else {
      items.add(
        EmptyStateItem('Пока не добавлено ни одного нового ключевого слова'),
      );
    }

    // Получаем все ключевые слова для копирования
    final allKeywords = [...keywordsFromServer, ...corePhrases];

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            itemCount: items.length + 1, // +1 для кнопки копирования
            itemBuilder: (context, index) {
              if (index == 0) {
                // Добавляем кнопку копирования в начало списка
                return Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Скопировать все ключевые слова'),
                    onPressed: () {
                      final keywordsText = allKeywords
                          .map((kw) => '${kw.keyword},${kw.freq}')
                          .join('\n');
                      Clipboard.setData(ClipboardData(text: keywordsText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Ключевые слова скопированы в буфер обмена'),
                        ),
                      );
                    },
                  ),
                );
              }

              final item = items[index - 1]; // -1 из-за кнопки копирования
              if (item is SectionHeaderItem) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              } else if (item is KeywordItem) {
                final keyword = item.keyword;
                final isSelected = selectedKeywords.contains(keyword);
                final isFromServer = model.keywordsFromServer.contains(keyword);
                return KeywordCard(
                  keyword: keyword,
                  model: model,
                  isSelected: isSelected,
                  onTap: () {
                    if (isFromServer) {
                      return;
                    }
                    setState(() {
                      if (isSelected) {
                        selectedKeywords.remove(keyword);
                      } else {
                        selectedKeywords.add(keyword);
                      }
                    });
                  },
                  showKeywordOptions: _showKeywordOptions,
                  indentLevel: item.indentLevel,
                );
              } else if (item is EmptyStateItem) {
                return Center(
                  child: Text(
                    item.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        if (selectedKeywords.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 16,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 5,
                shadowColor: Theme.of(context)
                    .colorScheme
                    .errorContainer
                    .withOpacity(0.4),
              ),
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
              ),
              onPressed: () {
                model.removeKeywordsFromCore(
                  selectedKeywords.map((kw) => kw.keyword).toList(),
                );
                setState(() {
                  selectedKeywords.clear();
                });
              },
              label: Text(
                'Удалить ${selectedKeywords.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showKeywordOptions(BuildContext context, String keyword) {
    void goToAdBidsScreen(String kw) {
      Navigator.of(context).pushNamed(
        MainNavigationRouteNames.geoSearchScreen,
        arguments: kw,
      );
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Найти на маркетплейсе'),
              onTap: () {
                Navigator.of(context).pop();
                final encodedKeyword = Uri.encodeComponent(keyword);
                html.window.open(
                    'https://www.wildberries.ru/catalog/0/search.aspx?search=$encodedKeyword',
                    'wb');
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Посмотреть рекламные ставки'),
              onTap: () {
                Navigator.of(context).pop();
                goToAdBidsScreen(keyword);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Классы для представления различных типов элементов списка
abstract class ListItem {}

class SectionHeaderItem extends ListItem {
  final String title;
  SectionHeaderItem(this.title);
}

class KeywordItem extends ListItem {
  final KwByLemma keyword;
  final int indentLevel;

  KeywordItem(this.keyword, {this.indentLevel = 0});
}

class EmptyStateItem extends ListItem {
  final String message;
  EmptyStateItem(this.message);
}

// Виджет для отображения карточки ключевого слова
class KeywordCard extends StatelessWidget {
  final KwByLemma keyword;
  final SeoToolKwResearchViewModel model;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(BuildContext, String) showKeywordOptions;
  final int indentLevel;
  const KeywordCard({
    super.key,
    required this.keyword,
    required this.model,
    required this.isSelected,
    required this.onTap,
    required this.showKeywordOptions,
    this.indentLevel = 0, // Default to 0 (no indentation)
  });

  @override
  Widget build(BuildContext context) {
    final isFromServer = model.keywordsFromServer.contains(keyword);

    return Padding(
      padding:
          EdgeInsets.only(left: 16.0 * indentLevel), // Indent based on level
      child: Card(
        color: isSelected
            ? Theme.of(context).colorScheme.secondaryContainer
            : isFromServer
                ? Colors.lightBlue[50]
                : null,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            )),
        child: ListTile(
          leading: const Icon(Icons.text_fields),
          onTap: onTap,
          title: Text(
            keyword.keyword,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Частотность: ${keyword.freq}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showKeywordOptions(
                context,
                keyword.keyword,
              );
            },
          ),
        ),
      ),
    );
  }
}
