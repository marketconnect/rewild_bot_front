// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/core/constants/llms.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_desc_generator_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_kw_research_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_title_generator_view_model.dart';
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
    'Фразы',
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
    final goToSubjectKwExpansionScreen =
        kwResearchModel.goToSubjectKwExpansionScreen;
    final goToAutocompliteKwExpansionScreen =
        kwResearchModel.goToAutocompliteKwExpansionScreen;
    final goToWordsKwExpansionScreen =
        kwResearchModel.goToWordsKwExpansionScreen;

    final goToCompetitorsKwExpansionScreen =
        kwResearchModel.goToCompetitorsKwExpansionScreen;
    final isLoading = kwResearchModel.isLoading;

    if (!isLoading && justLoaded) {
      justLoaded = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final model = context.read<SeoToolViewModel>();
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
                                        title: const Text('По конкурентам'),
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
            floatingActionButton: buildSpeedDial(context),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                buildBottomNavigationBarItem(
                    Icons.search, titles[0], _selectedIndex == 0),
                buildBottomNavigationBarItem(
                    Icons.title, titles[1], _selectedIndex == 1),
                buildBottomNavigationBarItem(
                    Icons.description, titles[2], _selectedIndex == 2),
                // buildBottomNavigationBarItem(
                //     Icons.analytics, titles[3], _selectedIndex == 3),
                // buildBottomNavigationBarItem(
                //     Icons.report, titles[4], _selectedIndex == 4),
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
          label: 'По конкурентам',
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
        Text('СЕО: $title',
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
    // we need a single instance of the CardItem (for the title and description management),
    // so we need to access it from the SeoToolViewModel
    final seoToolModel = context.watch<SeoToolViewModel>();
    final title = seoToolModel.title;
    final setTitle = seoToolModel.setCardItem;

    //
    final model = context.watch<SeoToolTitleGeneratorViewModel>();
    final wasGenerated = model.wasGenerated;
    final selectedKeywords = model.selectedKeywords;
    final kwResearchModel = context.watch<SeoToolKwResearchViewModel>();
    final kwResearchModelKeywords = kwResearchModel.corePhrases;
    final keywords = kwResearchModelKeywords
        .where((kw) => !selectedKeywords
            .any((selectedKw) => selectedKw.keyword == kw.keyword))
        .toList();
    keywords.sort((a, b) => b.freq.compareTo(a.freq));
    final llmsCost = model.llmsCost;
    final prompt = model.savedPrompt;
    promptController.text = prompt?.prompt ?? '';
    roleController.text = prompt?.role ?? '';
    // final savePrompt = model.savePrompt;
    final generateTitle = model.generateTitle;

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
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (llmsCost != null &&
                            llmsCost.isNotEmpty &&
                            prompt != null &&
                            selectedKeywords.isNotEmpty)
                          ElevatedButton(
                            onPressed: () async {
                              final generatedTitle = await generateTitle();
                              titleController.text = generatedTitle;
                            },
                            child: Text(wasGenerated
                                ? 'Перегенерировать'
                                : 'Генерировать'),
                          ),
                        const SizedBox(width: 8),
                        if (llmsCost != null &&
                            llmsCost.isNotEmpty &&
                            prompt != null &&
                            selectedKeywords.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              _showPromptDialog(context, model);
                            },
                            child: Icon(Icons.settings,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                      ],
                    ),
                    if (titleController.text.isNotEmpty)
                      CustomElevatedButton(
                        onTap: () async {
                          await setTitle(title: titleController.text);

                          kwResearchModel.countKeyPhraseOccurrences(
                              text: titleController.text, isTitle: false);
                        },
                        buttonStyle: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            foregroundColor: WidgetStateProperty.all(
                                Theme.of(context).colorScheme.onPrimary)),
                        height: 50,
                        margin: EdgeInsets.fromLTRB(
                            0,
                            model.screenHeight * 0.05,
                            0,
                            model.screenHeight * 0.05),
                        text: 'Заменить',
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

  Future<String?> _showPromptDialog(
    BuildContext context,
    SeoGeneratorViewModel model,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return PromptSettingsDialog(
          model: model,
          promptController: promptController,
          roleController: roleController,
          initialSelectedModel:
              model.selectedModel, // Pass the initial selected model
        );
      },
    );
  }
} // TitleGenerator end

// class PromptSettingsDialog extends StatefulWidget {
//   final SeoGeneratorViewModel model;
//   final TextEditingController promptController;
//   final TextEditingController roleController;

//   const PromptSettingsDialog({
//     super.key,
//     required this.model,
//     required this.promptController,
//     required this.roleController,
//   });

//   @override
//   // ignore: library_private_types_in_public_api
//   _PromptSettingsDialogState createState() => _PromptSettingsDialogState();
// }

// class _PromptSettingsDialogState extends State<PromptSettingsDialog> {
//   @override
//   Widget build(BuildContext context) {
//     String keywordsText =
//         widget.model.selectedKeywords.map((kw) => kw.keyword).join(', ');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Настройка промпта'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text(
//               'Отмена',
//               style: TextStyle(color: Theme.of(context).colorScheme.primary),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               widget.model.savePrompt(
//                   widget.promptController.text, widget.roleController.text);
//               Navigator.of(context).pop();
//             },
//             child: const Text('Сохранить'),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: widget.promptController,
//               decoration: const InputDecoration(
//                 labelText: 'Промпт',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: null,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Используй ключевые фразы: $keywordsText',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: widget.roleController,
//               decoration: const InputDecoration(
//                 labelText: 'Роль',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: null,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Выберите модель:',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//             ...widget.model.llmsCost!.entries.map((entry) {
//               return RadioListTile<String>(
//                 title: Text(
//                     '${entry.key} (${entry.value.toStringAsFixed(2)} рублей за запрос)'),
//                 value: entry.key,
//                 groupValue: widget.model.selectedModel,
//                 onChanged: (value) {
//                   widget.model.selectModel(value!);
//                   // setState(() {
//                   //   selectedModel = value!;
//                   // });
//                 },
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// } // End of PromptSettingsDialog

class PromptSettingsDialog extends StatefulWidget {
  final SeoGeneratorViewModel model;
  final TextEditingController promptController;
  final TextEditingController roleController;
  final String initialSelectedModel;

  const PromptSettingsDialog({
    super.key,
    required this.model,
    required this.promptController,
    required this.roleController,
    required this.initialSelectedModel,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PromptSettingsDialogState createState() => _PromptSettingsDialogState();
}

class _PromptSettingsDialogState extends State<PromptSettingsDialog> {
  late String selectedModel;
  bool useKeywords = true;
  bool useExistingDescription = true;

  @override
  void initState() {
    super.initState();
    selectedModel = widget.initialSelectedModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка промпта'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Отмена',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.model.savePrompt(
                  widget.promptController.text, widget.roleController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.promptController,
              decoration: const InputDecoration(
                labelText: 'Промпт',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            // ListTile(
            //   contentPadding: EdgeInsets.zero,
            //   title: Text(useKeywords
            //       ? 'Использовать ключевые фразы:'
            //       : 'Не использовать ключевые фразы'),
            //   trailing: Checkbox(
            //     value: useKeywords,
            //     onChanged: (bool? value) {
            //       setState(() {
            //         useKeywords = value ?? true;
            //       });
            //     },
            //   ),
            // ),
            // if (useKeywords)
            //   Text(
            //     keywordsText,
            //     style: Theme.of(context).textTheme.bodyLarge,
            //   ),
            // const SizedBox(height: 16),
            // ListTile(
            //   contentPadding: EdgeInsets.zero,
            //   title: Text(useExistingDescription
            //       ? 'Использовать существующее описание'
            //       : 'Не использовать существующее описание'),
            //   trailing: Checkbox(
            //     value: useExistingDescription,
            //     onChanged: (bool? value) {
            //       setState(() {
            //         useExistingDescription = value ?? true;
            //       });
            //     },
            //   ),
            // ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.roleController,
              decoration: const InputDecoration(
                labelText: 'Роль',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            Text(
              'Выберите модель (баланс ${widget.model.balance!.toStringAsFixed(2)} рублей):',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            ...widget.model.llmsCost!.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(
                    '${entry.key} (${entry.value.toStringAsFixed(2)} рублей за запрос)'),
                value: entry.key,
                groupValue: selectedModel,
                onChanged: (value) {
                  setState(() {
                    selectedModel = value!;
                  });
                  widget.model.selectModel(value!);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
} // End of PromptSettingsDialog

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
  final TextEditingController promptController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  String selectedModel = 'Gigachat';
  bool isDescriptionTextFieldEmpty = true;

  @override
  Widget build(BuildContext context) {
    // we need a single instance of the CardItem (for the title and description management),
    // so we need to access it from the SeoToolViewModel
    final seoToolModel = context.watch<SeoToolViewModel>();
    final description = seoToolModel.description;
    final setDescription = seoToolModel.setCardItem;

    final model = context.watch<SeoToolDescriptionGeneratorViewModel>();

    final selectedKeywords = model.selectedKeywords;
    final kwResearchModel = context.watch<SeoToolKwResearchViewModel>();
    final kwResearchModelKeywords = kwResearchModel.corePhrases;
    final keywords = kwResearchModelKeywords
        .where((kw) => !selectedKeywords
            .any((selectedKw) => selectedKw.keyword == kw.keyword))
        .toList();
    keywords.sort((a, b) => b.freq.compareTo(a.freq));
    final llmsCost = model.llmsCost;
    final prompt = model.savedPrompt;
    promptController.text = prompt?.prompt ?? '';
    roleController.text = prompt?.role ?? '';
    // final savePrompt = model.savePrompt;
    final generateDescription = model.generateDescription;

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
                    if (value.isNotEmpty && isDescriptionTextFieldEmpty) {
                      setState(() {
                        isDescriptionTextFieldEmpty = false;
                      });
                      return;
                    }
                    if (value.isEmpty && !isDescriptionTextFieldEmpty) {
                      setState(() {
                        isDescriptionTextFieldEmpty = true;
                      });
                    }
                  },
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Описание',
                    border: const OutlineInputBorder(),
                    suffixIcon: descriptionController.text.isEmpty
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
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (llmsCost != null &&
                            llmsCost.isNotEmpty &&
                            prompt != null &&
                            selectedKeywords.isNotEmpty)
                          ElevatedButton(
                            onPressed: () async {
                              final generatedDescription =
                                  await generateDescription();
                              descriptionController.text = generatedDescription;
                            },
                            child: Text(model.wasGenerated
                                ? 'Перегенерировать'
                                : 'Генерировать'),
                          ),
                        const SizedBox(width: 8),
                        if (llmsCost != null &&
                            llmsCost.isNotEmpty &&
                            prompt != null &&
                            selectedKeywords.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              _showPromptDialog(
                                context,
                                model,
                              );
                            },
                            child: Icon(Icons.settings,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                      ],
                    ),
                    if (descriptionController.text.isNotEmpty &&
                        descriptionController.text != description)
                      CustomElevatedButton(
                        onTap: () async {
                          await setDescription(
                              description: descriptionController.text);
                          kwResearchModel.countKeyPhraseOccurrences(
                              text: descriptionController.text, isTitle: false);
                        },
                        buttonStyle: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                Theme.of(context).colorScheme.primary),
                            foregroundColor: WidgetStateProperty.all(
                                Theme.of(context).colorScheme.onPrimary)),
                        height: 50,
                        margin: EdgeInsets.fromLTRB(
                            0,
                            model.screenHeight * 0.05,
                            0,
                            model.screenHeight * 0.05),
                        text: 'Заменить',
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

  Future<String?> _showPromptDialog(
    BuildContext context,
    SeoGeneratorViewModel model,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return PromptSettingsDialog(
          model: model,
          promptController: promptController,
          roleController: roleController,
          initialSelectedModel:
              model.selectedModel, // Pass the initial selected model
        );
      },
    );
  }
}

// class CompetitorAnalysisScreen extends StatelessWidget {
//   const CompetitorAnalysisScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Sample competitor data
//     final competitors = {
//       'Конкурент 1': 'Сильные стороны: ... \nСлабые стороны: ...',
//       'Конкурент 2': 'Сильные стороны: ... \nСлабые стороны: ...',
//     };

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Card(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 'Анализ конкурентов',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: competitors.length,
//               itemBuilder: (context, index) {
//                 String competitor = competitors.keys.elementAt(index);
//                 String details = competitors[competitor]!;

//                 return ListTile(
//                   title: Text(competitor),
//                   subtitle: Text(details),
//                   trailing: const Icon(Icons.chevron_right),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ReportsAndRecommendationsScreen extends StatelessWidget {
//   const ReportsAndRecommendationsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Sample report data
//     final reports = {
//       'Отчёт за неделю': 'Продажи: 1000 шт. \nКонверсия: 5%',
//       'Отчёт за месяц': 'Продажи: 4000 шт. \nКонверсия: 4.5%',
//     };

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Card(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 'Отчёты и рекомендации',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: reports.length,
//               itemBuilder: (context, index) {
//                 String report = reports.keys.elementAt(index);
//                 String details = reports[report]!;

//                 return ListTile(
//                   title: Text(report),
//                   subtitle: Text(details),
//                   trailing: const Icon(Icons.chevron_right),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
    final model = context.watch<SeoToolKwResearchViewModel>();
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
            return ListTile(
              title: Text(keyword.keyword),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Вхождения в наименование: ${keyword.lemma}'),
                  Text('Вхождения в описание: ${keyword.lemma}'),
                  Text('Частотность: ${keyword.freq}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_money),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          MainNavigationRouteNames.geoSearchScreen,
                          arguments: keyword.keyword);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        model.removeKeywordFromCore(keyword.keyword),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
