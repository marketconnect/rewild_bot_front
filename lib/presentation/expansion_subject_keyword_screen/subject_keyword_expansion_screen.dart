// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';

import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/entities/lemma_by_filter.dart';
import 'package:rewild_bot_front/presentation/expansion_subject_keyword_screen/subject_keyword_expansion_model.dart';
import 'package:rewild_bot_front/widgets/custom_elevated_button.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';

class SubjectKeywordExpansionScreen extends StatefulWidget {
  const SubjectKeywordExpansionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SubjectKeywordExpansionScreenState createState() =>
      _SubjectKeywordExpansionScreenState();
}

class _SubjectKeywordExpansionScreenState
    extends State<SubjectKeywordExpansionScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isSearchVisible = false;
  final ScrollController _wordsScrollController = ScrollController();
  final ScrollController _phrasesScrollController = ScrollController();
  // final ScrollController _selectedPhrasesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController!.removeListener(_handleTabSelection);
    _tabController!.dispose();
    _wordsScrollController.dispose();
    _phrasesScrollController.dispose();

    super.dispose();
  }

  void _handleTabSelection() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SubjectKeywordExpansionViewModel>();
    final isSaving = model.isSaving;
    final goBack = model.goBack;
    final isLoading = model.isLoading;
    final selectedPhrases = model.selectedPhrases;
    Map<String, int> freqMap = {};
    for (var entry in selectedPhrases) {
      freqMap[entry.keyword] = entry.freq;
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                goBack();
              },
            ),
            title: const Text('SEO карточки'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Слова'),
                Tab(text: 'Фразы'),
                // Tab(text: 'Семантика'),
              ],
            ),
            actions: [
              if (_tabController!.index == 0)
                IconButton(
                  icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearchVisible = !_isSearchVisible;
                      if (!_isSearchVisible) {
                        model.clearSearch();
                      }
                    });
                  },
                ),
            ],
          ),
          body: OverlayLoaderWithAppIcon(
            isLoading: isLoading,
            overlayBackgroundColor: Colors.black,
            circularProgressColor: const Color(0xff83735c),
            appIcon: Image.asset(ImageConstant.imgLogoForLoading),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWordsTab(model),
                _buildPhrasesTab(model),
              ],
            ),
          ),
          floatingActionButton: model.selectedCount == 0 ||
                  _tabController!.index == 2 ||
                  _tabController!.index == 1
              ? null
              : _buildFloatingActionButton(model),
        ),
        if (isSaving)
          const Opacity(
            opacity: 0.2,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (isSaving)
          const Center(
            child: MyProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildFloatingActionButton(SubjectKeywordExpansionViewModel model) {
    if (model.selectedCount == 0) {
      return Container();
    }
    return FloatingActionButton(
      onPressed: model.clearSelection,
      child: const Icon(Icons.clear),
    );
  }

  Widget _buildWordsTab(SubjectKeywordExpansionViewModel model) {
    final filteredQueries = model.filteredQueries;
    filteredQueries
        .sort((a, b) => b.totalFrequency.compareTo(a.totalFrequency));
    return Column(
      children: [
        if (_isSearchVisible)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Поиск',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: model.filterQueries,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Всего: ${filteredQueries.length}'),
              Text('Выбрано: ${model.selectedCount}'),
            ],
          ),
        ),
        Expanded(
          child: filteredQueries.isEmpty
              ? Center(
                  child: CustomElevatedButton(
                    onTap: () async {
                      await model.updateLemmas();
                    },
                    text: "Загрузить",
                    buttonStyle: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.onPrimary)),
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                )
              : Scrollbar(
                  controller: _wordsScrollController,

                  interactive: true,
                  thickness: 6.0,
                  radius: const Radius.circular(10), // Радиус закругления
                  child: ListView.builder(
                    controller: _wordsScrollController,
                    itemCount: filteredQueries.length,
                    itemBuilder: (context, index) {
                      return _LemmaTile(lemma: filteredQueries[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPhrasesTab(SubjectKeywordExpansionViewModel model) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Всего: ${model.allKws.length}'),
              Text('Сохранено: ${model.selectedPhrases.length}'),
            ],
          ),
        ),
        Expanded(
          child: model.allKws.isEmpty
              ? Center(
                  child: CustomElevatedButton(
                    onTap: () async {
                      await model.updatePhrases();
                    },
                    text: "Загрузить",
                    buttonStyle: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.onPrimary)),
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                )
              : Scrollbar(
                  controller: _phrasesScrollController,
                  interactive: true,
                  thickness: 6.0,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    controller: _phrasesScrollController,
                    itemCount: model.allKws.length,
                    itemBuilder: (context, index) {
                      return _KwTile(kw: model.allKws[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _LemmaTile extends StatelessWidget {
  final LemmaByFilterId lemma;

  const _LemmaTile({required this.lemma});

  @override
  Widget build(BuildContext context) {
    final model =
        Provider.of<SubjectKeywordExpansionViewModel>(context, listen: false);
    bool isSelected = model.isSelectedLemma(lemma);
    Color primaryC = Theme.of(context).colorScheme.primaryContainer;
    Color onSurface = Theme.of(context).colorScheme.onSurface;
    Color primary = Theme.of(context).colorScheme.primary;

    return Container(
      color: isSelected ? primaryC.withOpacity(0.2) : Colors.white,
      child: ListTile(
        title: Text(
          lemma.lemma,
          style: TextStyle(
            color: isSelected ? onSurface : Colors.black,
          ),
        ),
        subtitle: Text(
          'Частота: ${lemma.totalFrequency}',
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
            if (isSelected) {
              model.removeLemma(lemma);
            } else {
              model.addLemma(lemma);
            }
          },
        ),
      ),
    );
  }
}

class _KwTile extends StatelessWidget {
  final KwByLemma kw;

  const _KwTile({
    required this.kw,
  });

  @override
  Widget build(BuildContext context) {
    final model =
        Provider.of<SubjectKeywordExpansionViewModel>(context, listen: false);
    final wordIsSelected = model.wordIsSelected(kw.lemma);

    return Container(
      color: Colors.white,
      child: ListTile(
        title: Text(
          kw.keyword,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Частота: ${kw.freq}',
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            Text(
              kw.lemma,
              style: TextStyle(
                decoration: wordIsSelected ? TextDecoration.lineThrough : null,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.library_add,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            model.selectPhrase(kw);
          },
        ),
      ),
    );
  }
}
