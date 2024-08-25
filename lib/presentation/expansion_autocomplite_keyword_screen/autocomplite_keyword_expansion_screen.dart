import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/presentation/expansion_autocomplite_keyword_screen/autocomplite_keyword_expansion_view_model.dart';
import 'package:rewild_bot_front/widgets/custom_elevated_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AutocompliteKeywordExpansionViewModel>();
    final goBack = model.goBack;
    final fetchAndAddKeywords = model.fetchAndAddKeywords;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Автозаполнение WB'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            goBack();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Введите фразу или слово ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            CustomElevatedButton(
              text: "Получить",
              onTap: () => fetchAndAddKeywords(_controller.text),
              buttonStyle: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.1,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
                right: MediaQuery.of(context).size.height * 0.1,
                left: MediaQuery.of(context).size.height * 0.1,
              ),
            ),
            const SizedBox(height: 10.0),
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
      ),
    );
  }
}

class _KwTile extends StatelessWidget {
  final KwByLemma kw;

  const _KwTile({required this.kw});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AutocompliteKeywordExpansionViewModel>(context,
        listen: false);
    Color primaryC = Theme.of(context).colorScheme.primaryContainer;
    Color onSurface = Theme.of(context).colorScheme.onSurface;
    Color primary = Theme.of(context).colorScheme.primary;
    final isSelected = model.addedKeywords.contains(kw);
    final addKeyword = model.addKeyword;
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
            addKeyword(kw);
            // if (isSelected) {
            //   // model.removeKeyword(kw.keyword);
            //   print("REMOVE ${kw.keyword}");
            // } else {
            //   print("ADD ${kw.keyword}");
            // }
          },
        ),
      ),
    );
  }
}
