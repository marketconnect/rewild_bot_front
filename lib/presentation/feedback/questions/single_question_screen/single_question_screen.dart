import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/icon_constant.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/domain/entities/question_model.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/single_question_screen/single_question_view_model.dart';

import 'package:rewild_bot_front/widgets/my_dialog_header_and_two_btns_widget.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';
import 'package:rewild_bot_front/widgets/rewild_text_editing_controller.dart';

class SingleQuestionScreen extends StatelessWidget {
  const SingleQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final model = context.watch<SingleQuestionViewModel>();
    final question = model.question;
    final cardImage = model.cardImage;
    final brandName = question.productDetails.brandName;
    final publish = model.publish;
    final setAnswer = model.setAnswer;
    final answerText = model.answer;
    // final checkSpellText = model.checkSpellText;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: _getActions(context, publish, screenWidth),
        scrolledUnderElevation: 2,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        bottom: _Bottom(
            screenWidth: screenWidth,
            cardImage: cardImage,
            question: question,
            brandName: brandName),
      ),
      body: _SingleFeedbackBody(
        content: answerText,
        // checkSpell: checkSpellText,
        rootContext: context,
        setAnswer: setAnswer,
      ),
    );
  }

  List<Widget> _getActions(BuildContext context,
      Future<void> Function() publish, double screenWidth) {
    return [
      InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return MyDialogHeaderAndTwoBtnsWidget(
                onNoPressed: () => Navigator.of(context).pop(),
                onYesPressed: () async {
                  await publish();
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
                title: 'Отправить ответ?',
              );
            },
          );
        },
        child: SizedBox(
          width: screenWidth * 0.07,
          child: Image.asset(
            IconConstant.iconRedo,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      SizedBox(
        width: screenWidth * 0.05,
      ),
    ];
  }
}

class _Bottom extends StatelessWidget implements PreferredSizeWidget {
  const _Bottom({
    required this.screenWidth,
    required this.cardImage,
    required this.question,
    required this.brandName,
  });

  final double screenWidth;
  final String? cardImage;
  final QuestionModel question;
  final String brandName;
  @override
  Size get preferredSize => Size.fromHeight(screenWidth * 0.30);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(screenWidth * 0.30),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            screenWidth * 0.05, 0, screenWidth * 0.05, screenWidth * 0.05),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (cardImage != null)
              ReWildNetworkImage(
                height: screenWidth * 0.25,
                image: cardImage!,
              ),
            SizedBox(
              width: screenWidth * 0.03,
            ),
            SizedBox(
              width: screenWidth * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.productDetails.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenWidth * 0.01),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      child: Text(
                        brandName,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleFeedbackBody extends StatefulWidget {
  final BuildContext rootContext;
  final String? content;
  // final Future<List<SpellResult>> Function(String) checkSpell;
  final Function(String) setAnswer;

  const _SingleFeedbackBody({
    required this.rootContext,
    this.content,
    required this.setAnswer,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SingleFeedbackBodyState createState() => _SingleFeedbackBodyState();
}

class _SingleFeedbackBodyState extends State<_SingleFeedbackBody> {
  RewildTextEdittingController _controller = RewildTextEdittingController();
  final List<String> listErrorTexts = [];

  final List<String> listTexts = [];
  @override
  void didUpdateWidget(covariant _SingleFeedbackBody oldWidget) {
    if (widget.content == null) {
      return;
    }
    super.didUpdateWidget(oldWidget);
    if (widget.content != oldWidget.content &&
        widget.content != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: widget.content,
        selection: TextSelection.collapsed(offset: widget.content!.length),
      );
    }
  }

  @override
  void initState() {
    _controller = RewildTextEdittingController(listErrorTexts: listErrorTexts);
    super.initState();
  }

  void _handleOnChange(String text) {
    widget.setAnswer(text);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final model = widget.rootContext.watch<SingleQuestionViewModel>();
    final question = model.question;
    final createdDate = question.createdDate;
    final text = question.text;

    final askGigachatCost = model.gigachatCost;
    final balance = model.balance;
    final listOfTemplates = model.storedAnswers ?? [];

    final isAnswered = model.isAnswered;
    return DefaultTextStyle(
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - screenWidth * 0.30,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.05),
            child: SizedBox(
              width: screenWidth * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatReviewDate(createdDate),
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.3)),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  Row(
                    children: [
                      SizedBox(
                          width: screenWidth * 0.7,
                          child: Text(
                            text,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  Divider(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.1),
                  ),
                  SizedBox(
                    height: screenWidth * 0.03,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(
                      "Ответ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.5),
                      ),
                    )
                  ]),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  !isAnswered
                      ? Focus(
                          onFocusChange: (hasFocus) {
                            if (!hasFocus) {
                              _handleOnChange(_controller.text);
                            }
                          },
                          child: TextFormField(
                              controller: _controller,
                              onChanged: _handleOnChange,
                              minLines: 5,
                              maxLines: 10,
                              decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  disabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)))),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.8,
                              child: Text(
                                widget.content ?? "",
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  if (balance != null && askGigachatCost != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.2,
                          child: IconButton(
                            onPressed: () {
                              _showAIBottomSheet(
                                context,
                                widget.rootContext,
                              );
                            },
                            icon: Image.asset(ImageConstant.empty),
                          ),
                        ),
                      ],
                    ),
                  if (listOfTemplates.isNotEmpty)
                    Container(
                      width: screenWidth * 0.7,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: GestureDetector(
                        onTap: () => _showTemplatesBottomSheet(context,
                            listOfTemplates: listOfTemplates),
                        child: Text(
                          "Использвать шаблон",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: screenWidth * 0.05),
                        ),
                      ),
                    ),
                  SizedBox(height: screenWidth * 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAIBottomSheet(
    BuildContext context,
    BuildContext rootContext,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _AIBottomSheetContainer(
          rootContext: rootContext,
        );
      },
    );
  }

  void _showTemplatesBottomSheet(BuildContext context,
      {required List<String> listOfTemplates}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          itemCount: listOfTemplates.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(listOfTemplates[index]),
              onTap: () {
                _controller.text = listOfTemplates[index];
                _handleOnChange(listOfTemplates[index]);
                Navigator.pop(context); // Close the bottom sheet
              },
            );
          },
        );
      },
    );
  }
}

class _AIBottomSheetContainer extends StatelessWidget {
  const _AIBottomSheetContainer({
    required this.rootContext,
  });

  final BuildContext rootContext;

  @override
  Widget build(BuildContext context) {
    final model = rootContext.read<SingleQuestionViewModel>();

    final askGigachatCost = model.gigachatCost;

    final aiEntries = askGigachatCost!.entries.toList();
    final balance = model.balance ?? 0;

    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
            child: Text(
              "Выберите AI модель для ответа на комментарий",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: aiEntries.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    aiEntries[index].key,
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    "Стоимость: ${aiEntries[index].value.toStringAsFixed(2)}₽, Баланс: ${balance.toStringAsFixed(2)}₽",
                    style: TextStyle(
                        fontSize: 14,
                        color: aiEntries[index].value > balance
                            ? Theme.of(context).colorScheme.error
                            : Colors.grey[600]),
                  ),
                  onTap: () async {
                    return;
                  },
                  trailing: aiEntries[index].value > balance
                      ? null
                      : const Icon(Icons.chevron_right),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // final result = await Navigator.of(context).popAndPushNamed(
              //   MainNavigationRouteNames.editPromptScreen,
              //   arguments: PromptDetails(prompt: prompt, role: role),
              // );
            },
            icon: const Icon(Icons.settings),
            label: const Text("Настройки"),
          ),
        ],
      ),
    );
  }
}
