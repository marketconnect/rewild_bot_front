import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/icon_constant.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/single_review_screen/single_review_view_model.dart';
import 'package:rewild_bot_front/widgets/empty_widget.dart';
import 'package:rewild_bot_front/widgets/expandable_image.dart';
import 'package:rewild_bot_front/widgets/my_dialog_header_and_two_btns_widget.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';
import 'package:rewild_bot_front/widgets/rate_stars.dart';
import 'package:rewild_bot_front/widgets/rewild_text_editing_controller.dart';

class SingleReviewScreen extends StatelessWidget {
  const SingleReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final model = context.watch<SingleReviewViewModel>();
    final review = model.review;
    if (review == null) return const EmptyWidget(text: "Что-то пошло не так.");
    final cardImage = model.cardImage;
    final brandName = review.productDetails.brandName;
    final publish = model.publish;
    final setAnswer = model.setAnswer;

    final isAnswered = model.isAnswered;
    final answerText = model.answer;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(isAnswered);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
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
                        Navigator.of(context).pop(isAnswered);
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
        ],
        scrolledUnderElevation: 2,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
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
                    image: cardImage,
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
                        review.productDetails.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenWidth * 0.01),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.05),
                          ),
                          child: Text(
                            brandName,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _SingleFeedbackBody(
        content: answerText,
        setAnswer: setAnswer,
        rootContext: context,
      ),
    );
  }
}

class _SingleFeedbackBody extends StatefulWidget {
  final String? content;
  final Function(String) setAnswer;

  final BuildContext rootContext;
  const _SingleFeedbackBody({
    this.content,
    required this.setAnswer,
    required this.rootContext,
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
    final model = context.watch<SingleReviewViewModel>();
    final review = model.review;
    if (review == null) return const EmptyWidget(text: "Что-то пошло не так.");
    final createdDate = review.createdDate;
    final reviewText = review.text;
    final listOfTemplates = model.storedAnswers ?? [];
    final productValuation = review.productValuation;
    final isAnswered = model.isAnswered;
    final userName = review.userName;
    final photos = review.photoLinks;
    final generateResponse = model.generatedResponse;

    // final balance = model.balance;

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
                      RateStars(valuation: productValuation),
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
                  Row(
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenWidth * 0.05,
                  ),
                  Row(
                    children: [
                      SizedBox(
                          width: screenWidth * 0.7,
                          child: Text(
                            reviewText,
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
                    width: screenWidth,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: photos.map((e) {
                          return Padding(
                            padding: EdgeInsets.only(right: screenWidth * 0.02),
                            child: ReWildExpandableImage(
                              width: screenWidth * 0.2,
                              expandedImagePath: e.fullSize,
                              colapsedImagePath: e.miniSize,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
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
                        onTap: () => _showTemplatesBottomSheet(
                            context, listOfTemplates.length, listOfTemplates),
                        child: Text(
                          "Использвать шаблон",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: screenWidth * 0.05),
                        ),
                      ),
                    ),
                  if (!isAnswered)
                    SizedBox(
                      width: screenWidth * 0.7,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.smart_toy),
                        label: const Text('Сгенерировать ответ'),
                        onPressed: generateResponse,
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

  void _showTemplatesBottomSheet(
      BuildContext context, int itemCount, List<String> listOfTemplates) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          itemCount: itemCount,
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
