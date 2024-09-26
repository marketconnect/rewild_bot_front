// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/entities/lemma_by_filter.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_subject_keyword_screen/subject_keyword_expansion_model.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';

class SubjectKeywordExpansionScreen extends StatefulWidget {
  const SubjectKeywordExpansionScreen({super.key});

  @override
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_handleTabSelection);

    // Автоматически загружаем слова при инициализации экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = context.read<SubjectKeywordExpansionViewModel>();
      model.updateLemmas();
    });
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
    // При переключении на вкладку "Фразы" загружаем фразы автоматически
    if (_tabController!.index == 1) {
      final model = context.read<SubjectKeywordExpansionViewModel>();
      if (model.allKws.isEmpty && model.selectedCount > 0) {
        model.updatePhrases();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SubjectKeywordExpansionViewModel>();
    final isSaving = model.isSaving;

    final isLoading = model.isLoading;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: const Text('SEO карточки'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Слова'),
                Tab(text: 'Фразы'),
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
          floatingActionButton: (_tabController!.index == 0 &&
                      model.selectedCount > 0) ||
                  (_tabController!.index == 1 && model.selectedPhrasesCount > 0)
              ? _buildFloatingActionButton(model)
              : null,
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
    if (_tabController!.index == 0) {
      // Вкладка "Слова"
      return FloatingActionButton.extended(
        onPressed: () async {
          _tabController!.animateTo(1);
          await model.updatePhrases();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        label: Text('Перейти к фразам',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary),
      );
    } else if (_tabController!.index == 1) {
      // Вкладка "Фразы"
      return FloatingActionButton.extended(
        onPressed: () {
          model.goBack();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        label: Text('Добавить (${model.selectedPhrasesCount})',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimary),
      );
    } else {
      return Container();
    }
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
              ? const Center(
                  child: Text('Нет слов для отображения'),
                )
              : Scrollbar(
                  controller: _wordsScrollController,
                  interactive: true,
                  thickness: 6.0,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    controller: _wordsScrollController,
                    itemCount: filteredQueries.length,
                    itemBuilder: (context, index) {
                      return _LemmaTile(lemma: filteredQueries[index]);
                    },
                  ),
                ),
        ),
        // Добавляем кнопку для перехода к фразам
        // if (model.selectedCount > 0)
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: ElevatedButton(
        //       onPressed: () {
        //         _tabController!.animateTo(1);
        //       },
        //       child: const Text('Перейти к фразам'),
        //     ),
        //   ),
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
              Text('Выбрано: ${model.selectedPhrasesCount}'),
            ],
          ),
        ),
        Expanded(
          child: model.allKws.isEmpty
              ? Center(
                  child: model.isLoading
                      ? const SizedBox()
                      : model.selectedCount == 0
                          ? const Text('Выберите слова на предыдущей вкладке')
                          : const Text('Сервер не вернул никаких данных'),
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
    final isSelected = model.isPhraseSelected(kw);

    return Container(
      color: isSelected ? Colors.grey[200] : Colors.white,
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
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isSelected ? Icons.check_circle : Icons.add_circle_outline,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
          onPressed: () {
            if (isSelected) {
              model.deselectPhrase(kw);
            } else {
              model.selectPhrase(kw);
            }
          },
        ),
        onTap: () {
          if (isSelected) {
            model.deselectPhrase(kw);
          } else {
            model.selectPhrase(kw);
          }
        },
      ),
    );
  }
}
