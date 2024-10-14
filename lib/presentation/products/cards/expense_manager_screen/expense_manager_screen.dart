import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/domain/entities/total_cost_calculator.dart';
import 'package:rewild_bot_front/presentation/products/cards/expense_manager_screen/expense_manager_view_model.dart';
import 'package:rewild_bot_front/widgets/custom_elevated_button.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';

class ExpenseManagerScreen extends StatefulWidget {
  const ExpenseManagerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExpenseManagerScreenState createState() => _ExpenseManagerScreenState();
}

class _ExpenseManagerScreenState extends State<ExpenseManagerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpenseManagerViewModel>();
    final expensesIsEmpty = model.expenses.isEmpty;
    final nmIdsIsNotEmpty = model.nmIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        scrolledUnderElevation: 2,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: const _Title(),
        bottom: _AppBarBottom(screenWidth: MediaQuery.of(context).size.width),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseBottomSheet,
        tooltip: 'Добавить расходы',
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const _Custom(),
            const SizedBox(height: 16),
            const _Header(title: 'Расходы'),
            const _DataTable(),
            if (expensesIsEmpty && nmIdsIsNotEmpty)
              TextButton(
                onPressed: _showCradsToCopyListBottomSheet,
                child: const Text('Взять данные из другого товара'),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showCradsToCopyListBottomSheet() {
    final model = context.read<ExpenseManagerViewModel>();
    final nmIds = model.nmIds;
    final cards = model.nmIdCards;
    final copyDataFromCard = model.updateWithOtherCardData;

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            shrinkWrap:
                true, // Убедитесь, что ListView может расти внутри BottomSheet
            itemCount: nmIds.length,
            itemBuilder: (context, index) {
              final nmId = nmIds[index];
              return ListTile(
                subtitle: Text(cards[nmId]?.name ?? ''),
                leading: cards[nmIds[index]] == null
                    ? null
                    : ReWildNetworkImage(
                        width: MediaQuery.of(context).size.width * 0.1,
                        image: cards[nmIds[index]]!.img),
                trailing: IconButton(
                  icon: const Icon(Icons.content_copy),
                  onPressed: () async {
                    await copyDataFromCard(nmId);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddExpenseBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext buildContext) {
        final model = context.watch<ExpenseManagerViewModel>();
        final add = model.add;
        double screenHeight = MediaQuery.of(buildContext).size.height;

        return Container(
          padding: const EdgeInsets.all(16.0),
          height: screenHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(buildContext).size.height * 0.02,
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(buildContext),
                      icon: const Icon(Icons.close))
                ],
              ),
              SizedBox(
                height: MediaQuery.of(buildContext).size.height * 0.02,
              ),
              const Text(
                'Добавить расходы',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: MediaQuery.of(buildContext).size.height * 0.02,
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Статья расходов',
                ),
              ),
              TextField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Сумма',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(
                height: MediaQuery.of(buildContext).size.height * 0.02,
              ),
              CustomElevatedButton(
                text: "Добавить/Обновить расходы",
                onTap: () async {
                  if (_validateFields()) {
                    await add(_nameController.text, _valueController.text);
                    _nameController.clear();
                    _valueController.clear();
                    if (buildContext.mounted) {
                      Navigator.pop(buildContext);
                    }
                  }
                },
                buttonStyle: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(buildContext).colorScheme.primary,
                    ),
                    foregroundColor: WidgetStateProperty.all(
                        Theme.of(buildContext).colorScheme.onPrimary)),
                height: model.screenWidth * 0.2,
                margin: EdgeInsets.fromLTRB(
                    model.screenWidth * 0.05,
                    model.screenHeight * 0.1,
                    model.screenWidth * 0.05,
                    model.screenHeight * 0.1),
              )
              // ElevatedButton(
              //   onPressed: () {
              //     if (_validateFields()) {
              //       Navigator.pop(context);
              //     }
              //   },
              //   child: const Text('Добавить'),
              // ),
            ],
          ),
        );
      },
    );
  }

  bool _validateFields() {
    String name = _nameController.text.trim();
    String valueStr = _valueController.text.trim();
    double? value = double.tryParse(valueStr);

    if (name.isEmpty) {
      _showErrorDialog('Пожалуйста, введите название расхода.');
      return false;
    }

    if (value == null || value <= 0) {
      _showErrorDialog('Пожалуйста, введите корректную сумму расхода.');
      return false;
    }

    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('ОК'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpenseManagerViewModel>();
    final name = model.productName;
    // final launchURL = model.launchURL;

    final productImage = model.productImage;
    return Row(
      children: [
        if (productImage != null)
          ReWildNetworkImage(
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.width * 0.1,
              image: productImage),
        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            child: Text(name,
                maxLines: 2,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05))),
        // IconButton(
        //   icon: const Icon(Icons.help_outline),
        //   onPressed: () {
        //     launchURL();
        //   },
        // ),
      ],
    );
  }
}

class _DataTable extends StatefulWidget {
  const _DataTable();

  @override
  State<_DataTable> createState() => _DataTableState();
}

class _DataTableState extends State<_DataTable> {
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _dialogTextFieldController =
      TextEditingController();
  @override
  void dispose() {
    _textFieldController.dispose();
    _dialogTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpenseManagerViewModel>();
    final expenses = model.expenses;
    final remove = model.remove;
    double totalCost = model.totalCost;
    final commission = model.commission;
    final realPrice = model.realProductPrice;
    final comRub = (commission * realPrice / 100).ceil();
    final avgLogisticsCost = model.averageLogistics;
    final returnsPercentage = model.returnsPercentage;
    final returnRub = (avgLogisticsCost + 50) * returnsPercentage / 100;
    final tax = model.tax;
    final taxRub = (tax * realPrice / 100).ceil();
    final save = model.add;
    totalCost = totalCost + avgLogisticsCost + comRub + returnRub + taxRub;
    final breakEvenPointPrice = model.calculateBreakEvenPoint();
    return DataTable(
      columnSpacing: MediaQuery.of(context).size.width * 0.01,
      horizontalMargin: MediaQuery.of(context).size.width * 0.01,
      dividerThickness: 0,
      headingRowHeight: MediaQuery.of(context).size.width * 0.1,
      columns: [
        DataColumn(
            label: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: const Text('Название'))),
        DataColumn(
            label: SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: const Text('Сумма'))),
        DataColumn(
            label: SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: const Text('Удалить'))),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(
            Text(
              'Комиссия WB, %',
              maxLines: 5,
            ),
          ),
          DataCell(
            Text(
              '$comRub₽ ($commission%)',
              maxLines: 2,
            ),
          ),
          DataCell(Container()),
        ]),
        DataRow(cells: [
          const DataCell(
            Text(
              'Стоимость логистики',
              maxLines: 5,
            ),
          ),
          DataCell(
            _buildValueField(
                value: '$avgLogisticsCost ₽',
                saveKey: TotalCostCalculator.logisticsKey,
                onSave: save,
                initialValue: '$avgLogisticsCost',
                title: 'Стоимость логистики'),
          ),
          DataCell(Container()),
        ]),
        DataRow(cells: [
          const DataCell(
            Text(
              'Процент возвратов',
              maxLines: 5,
            ),
          ),
          DataCell(
            _buildValueField(
                value: '$returnRub ₽ ($returnsPercentage%)',
                saveKey: TotalCostCalculator.returnsKey,
                initialValue: '$returnsPercentage',
                suffixText: '%',
                onSave: save,
                isError: returnRub == 0,
                title: 'Процент возвратов'),
          ),
          DataCell(Container()),
        ]),
        DataRow(cells: [
          const DataCell(
            Text(
              'Налог',
              maxLines: 5,
            ),
          ),
          DataCell(
            _buildValueField(
              title: 'Налог ',
              saveKey: TotalCostCalculator.taxKey,
              initialValue: '${tax == 0 ? "7" : tax}',
              suffixText: '%',
              onSave: save,
              isError: tax == 0,
              value: '$taxRub₽ ($tax%)',
            ),
          ),
          DataCell(Container()),
        ]),
        ...expenses.entries.where((element) => element.key != 't').map(
          (expense) {
            return DataRow(
              cells: [
                DataCell(SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(
                      expense.key,
                      maxLines: 2,
                    ))),
                DataCell(
                  _buildValueField(
                    title: 'Введите значение',
                    saveKey: expense.key,
                    onSave: save,
                    value: '${expense.value} ₽',
                  ),
                  // Text('${expense.value} ₽')
                ),
                DataCell(
                  IconButton(
                    icon: Icon(
                      Icons.delete_forever_outlined,
                      size: MediaQuery.of(context).size.width * 0.05,
                    ),
                    onPressed: () => remove(expense.key),
                  ),
                ),
              ],
            );
          },
        ),
        DataRow(
          cells: [
            const DataCell(
              Text(
                'Итого',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataCell(
              Text(
                '$totalCost ₽',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataCell(Container()), // Пустой виджет для ячейки "Действия"
          ],
        ),
        DataRow(
          cells: [
            const DataCell(
              Text(
                '* Цена безубыточности',
                style: TextStyle(
                    fontWeight: FontWeight.w100, fontStyle: FontStyle.italic),
              ),
            ),
            DataCell(
              Text(
                '$breakEvenPointPrice ₽',
                style: const TextStyle(
                    fontWeight: FontWeight.w100, fontStyle: FontStyle.italic),
              ),
            ),
            DataCell(Container()), // Пустой виджет для ячейки "Действия"
          ],
        ),
      ],
    );
  }

  Widget _buildValueField(
      {required String value,
      Function? onSave,
      String? saveKey,
      required String title,
      bool isError = false,
      String initialValue = "",
      String suffixText = "₽",
      Widget? dialog}) {
    void showEditDialog() {
      _dialogTextFieldController.text = initialValue;

      if (dialog != null) {
        showDialog(
          context: context,
          builder: (context) => dialog,
        );
        return;
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: _dialogTextFieldController,
              decoration: InputDecoration(
                hintText: "Новое значение",
                suffixText: suffixText,
              ),

              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true), // Если значение числовое
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  _dialogTextFieldController.clear();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Сохранить'),
                onPressed: () {
                  if (onSave == null) {
                    return;
                  }
                  onSave(
                    saveKey,
                    _dialogTextFieldController.text,
                  );
                  _dialogTextFieldController.clear();

                  Navigator.pop(context); // Закрыть диалог
                },
              ),
            ],
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        _textFieldController.text = value.replaceAll(' ₽', '');

        showEditDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isError
              ? Theme.of(context).colorScheme.errorContainer
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Text(
            value,
            maxLines: 2,
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
  });
  final String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

class _Custom extends StatefulWidget {
  const _Custom();

  @override
  State<_Custom> createState() => _CustomState();
}

class _CustomState extends State<_Custom> {
  final TextEditingController _dialogTextFieldController =
      TextEditingController();
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void dispose() {
    _dialogTextFieldController.dispose();
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpenseManagerViewModel>();
    final save = model.add;
    final price = model.realProductPrice;

    final wbDiscount = model.wbDiscount;

    return Column(
      children: [
        const _Header(title: "Цена продажи товара"),
        _buildValueField(
          label: 'Цена:',
          description: wbDiscount == 0 ? 'цена продажи до вычета СПП' : null,
          value: '$price ₽',
          isError: wbDiscount == 0,
          saveKey: TotalCostCalculator.priceKey,
          title: 'Введите цену',
          onSave: save,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Скидка WB, %', style: TextStyle(fontSize: 16)),
                  if (wbDiscount == 0)
                    Text('Вы не указали цену',
                        style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Text('${wbDiscount.toStringAsFixed(1)} %'),
              ),
            ],
          ),
        ),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildValueField(
      {required String label,
      String? description,
      required String value,
      Function? onSave,
      bool isError = false,
      String? saveKey,
      required String title,
      Widget? dialog}) {
    void showEditDialog() {
      if (dialog != null) {
        showDialog(
          context: context,
          builder: (context) => dialog,
        );
        return;
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: _dialogTextFieldController,
              decoration: const InputDecoration(hintText: "Новое значение"),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true), // Если значение числовое
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Сохранить'),
                onPressed: () {
                  if (onSave == null) {
                    return;
                  }
                  onSave(
                    saveKey,
                    _dialogTextFieldController.text,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              if (description != null)
                Text(description,
                    style: TextStyle(
                        fontSize: 10,
                        color: isError
                            ? Theme.of(context).colorScheme.onErrorContainer
                            : null)),
            ],
          ),
          GestureDetector(
            onTap: () {
              _textFieldController.text = value.replaceAll(' ₽', '');

              showEditDialog();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: isError
                    ? Theme.of(context).colorScheme.errorContainer
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarBottom extends StatelessWidget implements PreferredSizeWidget {
  const _AppBarBottom({
    required this.screenWidth,
  });

  final double screenWidth;

  @override
  Size get preferredSize => Size.fromHeight(screenWidth * 0.30);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExpenseManagerViewModel>();

    final totalCost = model.acpu;

    final price = model.realProductPrice;
    return PreferredSize(
      preferredSize: Size.fromHeight(screenWidth * 0.30),
      child: Padding(
          padding: EdgeInsets.fromLTRB(
              screenWidth * 0.05, 0, screenWidth * 0.05, screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Доход',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '$price ₽',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Затраты',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '${totalCost.ceil()} ₽',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Валовая прибыль',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '${(price - totalCost).floor()} ₽',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Валовая маржа',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    price > 0
                        ? '${(((price - totalCost) / price) * 100).toStringAsFixed(1)} %'
                        : '0 %',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
