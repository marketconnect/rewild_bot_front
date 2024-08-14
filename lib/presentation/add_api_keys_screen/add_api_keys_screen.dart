import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;

import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/domain/entities/user_seller.dart';
import 'package:rewild_bot_front/presentation/add_api_keys_screen/add_api_keys_view_model.dart';
import 'package:rewild_bot_front/widgets/empty_widget.dart';

class AddApiKeysScreen extends StatefulWidget {
  const AddApiKeysScreen({super.key});

  @override
  State<AddApiKeysScreen> createState() => _AddApiKeysScreenState();
}

class _AddApiKeysScreenState extends State<AddApiKeysScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  String _value = '1';
  String? _errorText;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AddApiKeysScreenViewModel>();
    final isLoading = model.isLoading;
    final userSellers = model.userSellers;
    final apiKeys = model.apiKeys;
    final add = model.add;
    final types = model.types;
    final addedTypes = model.addedTypes;

    // final typesNum = types.length;
    final activeUserSeller = model.activeUserSeller;
    // final loading = model.isLoading;
    final renameSeller = model.renameSeller;
    final selectSeller = model.selectSeller;
    final select = model.select;
    final delete = model.delete;
    final selectionInProgress =
        apiKeys.where((apiKey) => apiKey.isSelected).isNotEmpty;

    final emptyTypes =
        types.where((type) => !addedTypes.contains(type)).toList();
    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              children: const [
                TextSpan(
                  text: 'Доступ к ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'API',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          actions: userSellers.length < 2
              ? null
              : <Widget>[
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: () => _showSellerSelection(
                        context, userSellers, selectSeller, renameSeller),
                  ),
                ],
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.all(3),
          width: model.screenWidth,
          child: !selectionInProgress && emptyTypes.isEmpty
              ? null
              : FloatingActionButton(
                  onPressed: () async {
                    if (selectionInProgress) {
                      await delete();
                      return;
                    }
                    _showModalBottomSheet(context, add)
                        .whenComplete(() => _textEditingController.clear());
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                      selectionInProgress ? "Удалить" : "Добавить токен",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary)),
                ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: apiKeys.isEmpty
            ? const EmptyWidget(text: 'Вы еще не добавили ни одного токена')
            : Padding(
                padding: EdgeInsets.all(model.screenWidth * 0.05),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: model.screenHeight * 0.01,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 16,
                          ),
                          SizedBox(
                            width: model.screenWidth * 0.8,
                            child: Text(
                              activeUserSeller != null && userSellers.length > 1
                                  ? 'Токены ${activeUserSeller.sellerName}'
                                  : 'Ваши токены',
                              style: TextStyle(
                                  fontSize: model.screenWidth * 0.06,
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5)),
                            ),
                          ),
                        ],
                      ),
                      GridView.builder(
                          itemCount: apiKeys.length,
                          shrinkWrap: true, //
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemBuilder: (context, index) => GestureDetector(
                                onTap: () => select(index),
                                child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      width: model.screenWidth * 0.3,
                                      height: model.screenWidth * 0.3,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: apiKeys[index].isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .surface,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Column(children: [
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.12,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.03,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Text(
                                                    apiKeys[index].type,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.045,
                                                      color: apiKeys[index]
                                                              .isSelected
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.03,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Text(
                                                    apiKeys[index]
                                                                .tokenReadOrWrite ==
                                                            'Токен только на чтение'
                                                        ? 'Только чтение'
                                                        : 'Чтение и запись',
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.03,
                                                      color: apiKeys[index]
                                                              .isSelected
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .surface
                                                              .withOpacity(0.5)
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onSurface
                                                              .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.03,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Text(
                                                    'до ${formatMMDDMMMYYY(apiKeys[index].expiryDate)}',
                                                    style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.03,
                                                      color: apiKeys[index]
                                                              .isSelected
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .surface
                                                              .withOpacity(0.5)
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onSurface
                                                              .withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ]),
                                          if (selectionInProgress)
                                            Positioned(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03,
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.07,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.07,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: apiKeys[index]
                                                          .isSelected
                                                      ? null
                                                      : Border.all(
                                                          width: 2,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surface,
                                                ),
                                                child: apiKeys[index].isSelected
                                                    ? Icon(
                                                        Icons.check,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      )
                                                    : Container(),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )),
                              )),
                    ],
                  ),
                ),
              ),
      )),
    );
  }

  Future<dynamic> _showModalBottomSheet(
      BuildContext context, Future<void> Function(String key) add) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    List<String> types = [
      'Wildberries', /*'Ozon'*/
    ];
    _value = types.first; // Инициализация первым значением

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(builder:
          (BuildContext context, void Function(void Function()) setState) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Wrap(children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.08,
                      ),
                      Text(
                        'Токен',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  SizedBox(
                    height: screenHeight * 0.08,
                    child: TextField(
                      showCursor: true,
                      // readOnly: true,
                      obscureText: true,
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        labelText: 'Вставьте токен API',
                        errorText: _errorText != null ? '' : null,
                        errorStyle: const TextStyle(height: 0),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 15,
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 30,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        suffixIcon: _textEditingController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _textEditingController.clear();
                                  setState(() {});
                                },
                              )
                            : IconButton(
                                icon: const Icon(Icons.paste_rounded),
                                onPressed: () async {
                                  //   ClipboardData? cdata =
                                  //       await Clipboard.getData(
                                  //           Clipboard.kTextPlain);
                                  //   if (cdata == null || cdata.text!.isEmpty) {
                                  //     setState(() {
                                  //       _errorText = 'Буфер обмена пуст';
                                  //     });
                                  //   } else {
                                  //     setState(() {
                                  //       _errorText = null;
                                  //       _textEditingController.text = cdata.text!;
                                  //     });
                                  //   }
                                  html.window.navigator.clipboard
                                      ?.readText()
                                      .then((value) {
                                    if (value == null || value.isEmpty) {
                                      print('Буфер обмена пуст');
                                    } else {
                                      print('Скопированный текст: $value');
                                      // Ваш код для обработки скопированного текста
                                      _textEditingController.text = value;
                                    }
                                  }).catchError((err) {
                                    print(
                                        'Ошибка при чтении буфера обмена: $err');
                                  });
                                },
                              ),
                      ),
                    ),
                  ),
                  if (_errorText != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                          child: Text(
                            _errorText!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.08,
                      ),
                      Text(
                        'Категория',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  SizedBox(
                    height: screenHeight * 0.08,
                    child: DropdownButtonFormField<String>(
                      value: _value,
                      decoration: InputDecoration(
                        // labelText: 'Category',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                      items: types.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _value = value ?? '';
                        });
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onPressed: () async {
                      final apiKey = _textEditingController.text;
                      if (apiKey.length < 10) {
                        setState(() {
                          _errorText = 'Слишком короткий токен';
                        });
                        return;
                      } else {
                        setState(() {
                          _errorText = null;
                        });
                      }

                      // final valueToAdd = types[int.parse(_value)];

                      await add(apiKey);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            'Сохранить',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      }),
    );
  }

  void _showSellerSelection(
    BuildContext parentContext,
    List<UserSeller> sellers,
    Future<void> Function(String sellerId) selectSeller,
    Future<void> Function(String sellerId, String newName) renameSeller,
  ) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.drag_handle),
                      ],
                    ),
                  ),
                  const Text(
                    "Выберите или обновите имя продавца",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: sellers.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(sellers[index].sellerName),
                          trailing: Wrap(
                            spacing: MediaQuery.of(context).size.height * 0.03,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                onPressed: () {
                                  _showEditSellerNameDialog(
                                    context,
                                    sellers[index],
                                    renameSeller,
                                    (String newName) {
                                      sellers[index].updateName(newName);
                                      setModalState(() {});
                                    },
                                  );
                                },
                                tooltip: 'Редактировать имя',
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward,
                                    size: MediaQuery.of(context).size.height *
                                        0.03),
                                onPressed: () {
                                  selectSeller(sellers[index].sellerId);
                                  Navigator.pop(context);
                                },
                                tooltip: 'Выбрать продавца',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditSellerNameDialog(
    BuildContext context,
    UserSeller seller,
    Future<void> Function(String sellerId, String newName) updateSellerName,
    void Function(String newName) onUpdate,
  ) {
    TextEditingController nameController =
        TextEditingController(text: seller.sellerName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Изменить имя продавца'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Новое имя',
              hintText: 'Введите новое имя',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                await updateSellerName(seller.sellerId, nameController.text);
                onUpdate(nameController.text);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}
