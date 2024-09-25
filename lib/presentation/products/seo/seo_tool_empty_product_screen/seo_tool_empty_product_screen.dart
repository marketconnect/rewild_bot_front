import 'package:rewild_bot_front/presentation/products/seo/seo_tool_empty_product_screen/seo_tool_empty_product_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_empty_product_screen/seo_tool_empty_product_kw_research_view_model.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/core/constants/llms.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';

import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

import 'package:rewild_bot_front/widgets/my_dialog_header_and_two_btns_widget.dart';

class SeoToolEmptyProductScreen extends StatefulWidget {
  const SeoToolEmptyProductScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SeoToolEmptyProductScreenState createState() =>
      _SeoToolEmptyProductScreenState();
}

class _SeoToolEmptyProductScreenState extends State<SeoToolEmptyProductScreen> {
  int _selectedIndex = 0;
  bool justLoaded = true;

  static const List<String> titles = [
    'Сбор фраз',
    'Название',
    'Описание',
    // 'Конкуренты',
    // 'Отчёты',
  ];

  static final List<Widget> _sections = <Widget>[
    const KeywordManager(),
    const TitleGeneratorScreen(),
    const DescriptionGeneratorScreen(),
    // const CompetitorAnalysisScreen(),
    // const ReportsAndRecommendationsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<SeoToolEmptyProductViewModel>();
    final kwResearchModel =
        context.watch<SeoToolEmptyProductKwResearchViewModel>();
    final isSaving = kwResearchModel.isSaving;
    final hasChange = kwResearchModel.hasChange;
    final goToSubjectKwExpansionScreen =
        kwResearchModel.goToSubjectKwExpansionScreen;
    final goToAutocompliteKwExpansionScreen =
        kwResearchModel.goToAutocompliteKwExpansionScreen;
    final goToWordsKwExpansionScreen =
        kwResearchModel.goToWordsKwExpansionScreen;

    final goToCompetitorsKwExpansionScreen =
        kwResearchModel.goToCompetitorsKwExpansionScreen;
    final isLoading = kwResearchModel.isLoading;
    final titleGenerator = model.titleGenerator;
    final descriptionGenerator = model.descriptionGenerator;

    if (!isLoading && justLoaded) {
      justLoaded = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final model = context.read<SeoToolEmptyProductViewModel>();
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
              actions: [
                _selectedIndex == 0
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Text(
                                        'Расширение запросов',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20.0),
                                      ListTile(
                                        leading: const Icon(Icons.text_fields),
                                        title: const Text('По словам'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await goToWordsKwExpansionScreen();
                                        },
                                      ),
                                      const Divider(),
                                      ListTile(
                                        leading: const Icon(Icons.category),
                                        title: const Text('По категории'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await goToSubjectKwExpansionScreen();
                                        },
                                      ),
                                      const Divider(),
                                      ListTile(
                                        leading: const Icon(Icons.autorenew),
                                        title: const Text('Автозаполнение'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await goToAutocompliteKwExpansionScreen();
                                        },
                                      ),
                                      const Divider(),
                                      ListTile(
                                        leading: const Icon(Icons.business),
                                        title: const Text('Из других карточек'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await goToCompetitorsKwExpansionScreen();
                                        },
                                      ),
                                      const Divider(),
                                      const SizedBox(height: 10.0),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Отмена'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.search))
                    : Container(),
              ],
              scrolledUnderElevation: 2,
              shadowColor: Colors.black,
              surfaceTintColor: Colors.transparent,
            ),
            body: _sections.elementAt(_selectedIndex),
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
    final kwResearchModel =
        context.read<SeoToolEmptyProductKwResearchViewModel>();

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
} // End of _SeoToolCategoryScreenState

class _Title extends StatelessWidget {
  final String title;
  const _Title({
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
  // ignore: library_private_types_in_public_api
  _TitleGeneratorScreenState createState() => _TitleGeneratorScreenState();
}

class _TitleGeneratorScreenState extends State<TitleGeneratorScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController promptController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  String selectedModel = const LLM.gigaChat().name;
  bool isTitleTextFieldEmpty = true;
  @override
  Widget build(BuildContext context) {
    final seoToolModel = context.watch<SeoToolEmptyProductViewModel>();
    final title = seoToolModel.title;

    final selectedKeywords = seoToolModel.selectedTitleKeywords;
    final kwResearchModel =
        context.watch<SeoToolEmptyProductKwResearchViewModel>();
    final kwResearchModelKeywords = kwResearchModel.corePhrases;
    final keywords = kwResearchModelKeywords
        .where((kw) => !selectedKeywords
            .any((selectedKw) => selectedKw.keyword == kw.keyword))
        .toList();
    keywords.sort((a, b) => b.freq.compareTo(a.freq));

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
                    }
                    if (value.isEmpty && !isTitleTextFieldEmpty) {
                      setState(() {
                        isTitleTextFieldEmpty = true;
                      });
                    }
                  },
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Наименование',
                    border: const OutlineInputBorder(),
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
                const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Выбранные ключевые слова:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
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
                Wrap(
                  spacing: 8.0,
                  children: keywords.map((keyword) {
                    final occurenceInTitle = keyword.numberOfOccurrencesInTitle;
                    final occurenceInDescription =
                        keyword.numberOfOccurrencesInDescription;
                    final hasOccurrences = (occurenceInDescription != null &&
                            occurenceInDescription > 0) ||
                        (occurenceInTitle != null && occurenceInTitle > 0);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ActionChip(
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
                                ' описании: $occurenceInDescription',
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
                            keywords.remove(keyword);
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
  // ignore: library_private_types_in_public_api
  _DescriptionGeneratorScreenState createState() =>
      _DescriptionGeneratorScreenState();
}

class _DescriptionGeneratorScreenState
    extends State<DescriptionGeneratorScreen> {
  final TextEditingController descriptionController = TextEditingController();
  bool isDescriptionTextFieldEmpty = true;

  @override
  Widget build(BuildContext context) {
    // Access SeoToolViewModel
    final seoToolModel = context.watch<SeoToolEmptyProductViewModel>();
    final description = seoToolModel.description;

    // Use selectedDescriptionKeywords from SeoToolViewModel
    final selectedKeywords = seoToolModel.selectedDescriptionKeywords;

    final kwResearchModel =
        context.watch<SeoToolEmptyProductKwResearchViewModel>();
    final kwResearchModelKeywords = kwResearchModel.corePhrases;

    // Filter out selected keywords from the list of all keywords
    final keywords = kwResearchModelKeywords
        .where((kw) => !selectedKeywords
            .any((selectedKw) => selectedKw.keyword == kw.keyword))
        .toList();
    keywords.sort((a, b) => b.freq.compareTo(a.freq));

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
                  },
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Описание',
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
                const SizedBox(height: 16),
                Text(
                  'Выбранные ключевые слова:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
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
                Wrap(
                  spacing: 8.0,
                  children: keywords.map((keyword) {
                    final occurenceInTitle = keyword.numberOfOccurrencesInTitle;
                    final occurenceInDescription =
                        keyword.numberOfOccurrencesInDescription;
                    final hasOccurrences = (occurenceInDescription != null &&
                            occurenceInDescription > 0) ||
                        (occurenceInTitle != null && occurenceInTitle > 0);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ActionChip(
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
                            keywords.remove(keyword);
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
  // ignore: library_private_types_in_public_api
  _KeywordManagerState createState() => _KeywordManagerState();
}

class _KeywordManagerState extends State<KeywordManager> {
  // ignore: unused_element
  void _searchKeywords(String keyword) async {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSemanticCoreSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSemanticCoreSection() {
    final model = context.watch<SeoToolEmptyProductKwResearchViewModel>();
    final corePhrases = List<KwByLemma>.from(model.corePhrases)
      ..sort((a, b) => b.freq.compareTo(a.freq));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: corePhrases.length,
          itemBuilder: (context, index) {
            final keyword = corePhrases[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  keyword.keyword,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Частотность: ${keyword.freq}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    // Дополнительная информация может быть добавлена здесь
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'geoSearch') {
                      Navigator.of(context).pushNamed(
                        MainNavigationRouteNames.geoSearchScreen,
                        arguments: keyword.keyword,
                      );
                    } else if (value == 'delete') {
                      model.removeKeywordFromCore(keyword.keyword);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'geoSearch',
                      child: ListTile(
                        leading: Icon(Icons.map),
                        title: Text('Ставки и поиск'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Удалить'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
