// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
  // ignore: library_private_types_in_public_api
  _SeoToolScreenState createState() => _SeoToolScreenState();
}

class _SeoToolScreenState extends State<SeoToolScreen> {
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
} // End of _SeoToolScreenState

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
  // ignore: library_private_types_in_public_api
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
  // ignore: library_private_types_in_public_api
  _KeywordManagerState createState() => _KeywordManagerState();
}

class _KeywordManagerState extends State<KeywordManager> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<SeoToolKwResearchViewModel>();
    final corePhrases = List<KwByLemma>.from(model.corePhrases)
      ..sort((a, b) => b.freq.compareTo(a.freq));

    final keywordsFromServer = List<KwByLemma>.from(model.keywordsFromServer)
      ..sort((a, b) => b.freq.compareTo(a.freq));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Раздел для ключевых слов из сервера
                  if (keywordsFromServer.isNotEmpty) ...[
                    Text(
                      'Ключевые слова по которым есть показы на первых двух страницах',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildKeywordsFromServerSection(keywordsFromServer),
                    const SizedBox(height: 16),
                  ],

                  if (corePhrases.isNotEmpty) ...[
                    Text(
                      'Новые ключевые слова',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildSemanticCoreSection(corePhrases),
                  ] else
                    Center(
                      child: Text(
                        'Пока не добавлено ни одного нового ключевого слова',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordsFromServerSection(List<KwByLemma> keywords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: keywords.map((keyword) {
        return Card(
          color: Colors.lightBlue[50], // Визуальное отличие
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
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
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'geoSearch') {
                  Navigator.of(context).pushNamed(
                    MainNavigationRouteNames.geoSearchScreen,
                    arguments: keyword.keyword,
                  );
                } else if (value == 'wb') {
                  final encodedKeyword = Uri.encodeComponent(keyword.keyword);
                  html.window.open(
                      'https://www.wildberries.ru/catalog/0/search.aspx?search=$encodedKeyword',
                      'wb');
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'geoSearch',
                  child: ListTile(
                    leading: Icon(Icons.map),
                    title: Text('Ставки и поиск'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'wb',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Перейти на WB'),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Метод для отображения выбранных ключевых слов
  Widget _buildSemanticCoreSection(List<KwByLemma> corePhrases) {
    final model = context.read<SeoToolKwResearchViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Кнопка копирования
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ключевые слова',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Скопировать все фразы',
              onPressed: () {
                final allPhrases = corePhrases
                    .map((kw) => '${kw.keyword},${kw.freq}')
                    .join('\n');
                Clipboard.setData(ClipboardData(text: allPhrases));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ключевые слова скопированы в буфер обмена'),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: corePhrases.length,
          itemBuilder: (context, index) {
            final keyword = corePhrases[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
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
