import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/icon_constant.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/extensions/date_time.dart';
import 'package:rewild_bot_front/core/utils/strings_utils.dart';
import 'package:rewild_bot_front/domain/entities/question_model.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/all_questions_screen/all_questions_view_model.dart';
import 'package:rewild_bot_front/widgets/popum_menu_item.dart';

class AllQuestionsScreen extends StatefulWidget {
  const AllQuestionsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AllQuestionsScreenState createState() => _AllQuestionsScreenState();
}

class _AllQuestionsScreenState extends State<AllQuestionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllQuestionsViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final questions = model.questions;
    // Search
    final setSearchQuery = model.setSearchQuery;
    final clearSearchQuery = model.clearSearchQuery;
    final searchQuery = model.searchQuery;
    final isLoading = model.isLoading;
    final productname = model.name;
    final displayedQuestions = questions.where((q) {
      if (q.answer != null) {
        return q.text.toLowerCase().contains(searchQuery.toLowerCase()) ||
            q.answer!.text.toLowerCase().contains(searchQuery.toLowerCase());
      }
      return q.text.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    List<QuestionModel> unAnsweredQuestions = [];
    List<QuestionModel> answeredQuestions = [];
    List<QuestionModel> editableQuestions = [];
    for (final question in displayedQuestions) {
      if (question.answer != null) {
        if (question.answer!.editable) {
          editableQuestions.add(question);
        } else {
          answeredQuestions.add(question);
        }
      } else {
        unAnsweredQuestions.add(question);
      }
    }

    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 2,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    clearSearchQuery();
                  }
                });
              },
            ),
          ],
          title: _isSearching
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setSearchQuery(value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Поиск...',
                      border: InputBorder.none,
                      // icon: Icon(Icons.search),
                    ),
                  ),
                )
              : SizedBox(
                  width: screenWidth * 0.6,
                  child: Center(
                    child: Text(
                      productname,
                    ),
                  ),
                ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenWidth * 0.035),
              ...unAnsweredQuestions.map((e) => _UnAnsweredQuestionCard(
                    question: e,
                  )),
              SizedBox(height: screenWidth * 0.035),
              ...editableQuestions.map((e) => _EditableQuestionCard(
                    question: e,
                  )),
              ...answeredQuestions.map((e) => _AnsweredQuestionCard(
                    question: e,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// The rest of your code remains unchanged

class _UnAnsweredQuestionCard extends StatelessWidget {
  const _UnAnsweredQuestionCard({
    required this.question,
  });

  final QuestionModel question;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final model = context.watch<AllQuestionsViewModel>();
    final routeToSingleQuestionScreen = model.routeToSingleQuestionScreen;
    final dif = DateTime.now().difference(question.createdDate);

    final ago = dif.inDays > 1
        ? getNoun(dif.inDays, "${dif.inDays} день назад",
            "${dif.inDays} дня назад", "${dif.inDays} дней назад")
        : dif.inHours > 1
            ? getNoun(dif.inHours, '${dif.inHours} час назад',
                '${dif.inHours} часа назад', '${dif.inHours} часов назад')
            : dif.inMinutes > 1
                ? getNoun(
                    dif.inMinutes,
                    '${dif.inMinutes} минута назад',
                    '${dif.inMinutes} минуты назад',
                    '${dif.inMinutes} минуты назад)')
                : 'только что';
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.17),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.027),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.027),
                      child: Text(question.productDetails.supplierArticle,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                    )
                  ],
                ),
                SizedBox(
                  height: screenWidth * 0.04,
                ),
                Row(
                  children: [
                    SizedBox(
                        width: screenWidth * 0.86,
                        child: Text(
                          question.text,
                          maxLines: 20,
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.w500),
                        )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Задан $ago',
                      style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5)),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenWidth * 0.08,
                ),
              ],
            ),
          ),
          Container(
            width: screenWidth,
          ),
          GestureDetector(
            onTap: () => routeToSingleQuestionScreen(question),
            child: SizedBox(
              width: screenWidth,
              height: screenWidth * 0.15,
              child: Stack(children: [
                Positioned(
                  top: screenWidth * 0.075 - 1,
                  child: Container(
                    width: screenWidth,
                    height: 1,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
                Positioned(
                  left: screenWidth * 0.3,
                  child: Container(
                    alignment: Alignment.center,
                    width: screenWidth * 0.4,
                    height: screenWidth * 0.15,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.075),
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.onSurface,
                            spreadRadius: 0,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          )
                        ]),
                    child: Text(
                      "ОТВЕТИТЬ",
                      style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }
}

class _EditableQuestionCard extends StatelessWidget {
  const _EditableQuestionCard({
    required this.question,
  });

  final QuestionModel question;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dateOfAnswer = fromIso8601String(question.answer!.createDate);
    final dateOfQuestion = question.createdDate;
    final answerDateText = _dateText(dateOfAnswer);
    final questionDateText = _dateText(dateOfQuestion);
    // final model = context.read<AllQuestionsViewModel>();
    // final isAnswerSaved = model.isAnswerSaved(question.id);
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.17),
      child: Column(
        children: [
          Column(
            children: [
              SizedBox(
                width: screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.07),
                      child: Text(
                        "Задан $questionDateText",
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5)),
                      ),
                    ),
                    _PopupMenu(
                      isEditable: true,
                      isAnswerSaved: false,
                      questionId: question.id,
                      answerText: question.answer!.text,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenWidth * 0.04,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                            width: screenWidth * 0.86,
                            child: Text(
                              question.text,
                              maxLines: 20,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.w500),
                            )),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenWidth * 0.07, bottom: screenWidth * 0.03),
                      child: Row(
                        children: [
                          Text("Ответ:",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ))
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          answerDateText,
                          style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenWidth * 0.01,
                    ),
                    Row(
                      children: [
                        SizedBox(
                            width: screenWidth * 0.86,
                            child: Text(
                              question.answer!.text,
                              maxLines: 20,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.w500),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: screenWidth * 0.08,
          ),
          SizedBox(
            width: screenWidth,
            height: screenWidth * 0.08,
            child: Stack(children: [
              _BottomLine(screenWidth: screenWidth),
              _Btn(
                screenWidth: screenWidth,
              ),
            ]),
          )
        ],
      ),
    );
  }
}

class _AnsweredQuestionCard extends StatelessWidget {
  const _AnsweredQuestionCard({
    required this.question,
  });

  final QuestionModel question;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dateOfAnswer = fromIso8601String(question.answer!.createDate);
    final answerDateText = _dateText(dateOfAnswer);
    final questionDateText = _dateText(question.createdDate);
    // final model = context.read<AllQuestionsViewModel>();
    // final isAnswerSaved = model.isAnswerSaved(question.id);
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.17),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Column(
            children: [
              SizedBox(
                width: screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.07),
                      child: Text(
                        "Задан $questionDateText",
                        style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5)),
                      ),
                    ),
                    _PopupMenu(
                      isEditable: true,
                      isAnswerSaved: false,
                      questionId: question.id,
                      answerText: question.answer!.text,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenWidth * 0.04,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                            width: screenWidth * 0.86,
                            child: Text(
                              question.text,
                              maxLines: 20,
                              style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.w500),
                            )),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenWidth * 0.07, bottom: screenWidth * 0.03),
                      child: Row(
                        children: [
                          Text("Ответ:",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ))
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          answerDateText,
                          style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenWidth * 0.01,
                    ),
                    Row(
                      children: [
                        SizedBox(
                            width: screenWidth * 0.86,
                            child: Text(
                              question.answer!.text,
                              maxLines: 20,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.w500),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenWidth * 0.08,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PopupMenu extends StatelessWidget {
  const _PopupMenu(
      {this.isEditable = false,
      required this.questionId,
      required this.isAnswerSaved,
      required this.answerText});

  final bool isEditable;
  final bool isAnswerSaved;
  final String questionId;
  final String answerText;
  @override
  Widget build(BuildContext context) {
    final model = context.read<AllQuestionsViewModel>();
    // final saveAnswer = model.saveAnswer;
    // final delete = model.deleteAnswer;
    // final save = model.saveAnswer;
    final getQuestion = model.question;
    final routeToSingleQuestionScreen = model.routeToSingleQuestionScreen;
    return PopupMenuButton(
      // Menu ============================================ Menu
      onSelected: (value) => Navigator.popAndPushNamed(context, value),
      icon: const Icon(
        Icons.more_vert,
        size: 20,
      ),
      itemBuilder: (BuildContext context) {
        return [
          if (isEditable)
            PopupMenuItem(
              child: GestureDetector(
                onTap: () {
                  final question = getQuestion(questionId);
                  if (question == null) {
                    Navigator.of(context).pop();
                    return;
                  }
                  routeToSingleQuestionScreen(question);
                },
                child: ReWildPopumMenuItemChild(
                  text: "Редактировать",
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      IconConstant.iconPencil,
                    ),
                  ),
                ),
              ),
            ),
          // if (!isAnswerSaved)
          //   PopupMenuItem(
          //     child: GestureDetector(
          //       onTap: () {
          //         // saveAnswer(questionId);
          //         Navigator.of(context).pop();
          //       },
          //       child: ReWildPopumMenuItemChild(
          //         text: "Использовать ответ",
          //         child: SizedBox(
          //           width: 20,
          //           height: 20,
          //           child: Image.asset(
          //             IconConstant.iconReuse,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          PopupMenuItem(
            child: GestureDetector(
              onTap: () async {
                // if (isAnswerSaved) {
                //   await delete(questionId);
                // } else {
                //   await save(questionId);
                // }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: ReWildPopumMenuItemChild(
                text:
                    isAnswerSaved ? "Удалить шаблон" : "Создать шаблон ответа",
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    isAnswerSaved
                        ? IconConstant.iconBin
                        : IconConstant.iconSave,
                  ),
                ),
              ),
            ),
          ),
        ];
      },
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.screenWidth,
    // required this.onTap,
  });

  final double screenWidth;
  // final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
          ),
        ),
        width: screenWidth * 0.2,
        height: screenWidth * 0.08,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.08,
          height: MediaQuery.of(context).size.width * 0.08,
          padding: EdgeInsets.all(screenWidth * 0.02),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Image.asset(IconConstant.iconPencil,
              color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}

class _BottomLine extends StatelessWidget {
  const _BottomLine({
    required this.screenWidth,
  });

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: screenWidth * 0.04 - 1,
      child: Container(
        width: screenWidth,
        height: 1,
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}

String _dateText(DateTime dateOfAnswer) {
  final dif = DateTime.now().difference(dateOfAnswer);
  return dif.inDays > 30
      ? dateOfAnswer.formatDate()
      : dif.inDays > 1
          ? getNoun(dif.inDays, "${dif.inDays} день назад",
              "${dif.inDays} дня назад", "${dif.inDays} дней назад")
          : dif.inHours > 1
              ? getNoun(dif.inHours, '${dif.inHours} час назад',
                  '${dif.inHours} часа назад', '${dif.inHours} часов назад')
              : dif.inMinutes > 1
                  ? getNoun(
                      dif.inMinutes,
                      '${dif.inMinutes} минута назад',
                      '${dif.inMinutes} минуты назад',
                      '${dif.inMinutes} минуты назад)')
                  : 'только что';
}
