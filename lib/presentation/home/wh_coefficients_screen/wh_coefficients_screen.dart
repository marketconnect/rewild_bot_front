import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';

import 'package:rewild_bot_front/domain/entities/wh_coeffs.dart';
import 'package:rewild_bot_front/presentation/home/wh_coefficients_screen/wh_coefficients_view_model.dart';
import 'package:rewild_bot_front/widgets/date_range_picker_widget.dart';

class WarehouseCoeffsScreen extends StatefulWidget {
  const WarehouseCoeffsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WarehouseCoeffsScreenState createState() => _WarehouseCoeffsScreenState();
}

class _WarehouseCoeffsScreenState extends State<WarehouseCoeffsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildAppBarTitle() {
    return const Text('Выбор склада');
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Поиск по названию склада...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 16.0),
      onChanged: (value) {
        setState(() {
          _searchText = value;
        });
      },
    );
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      _isSearching = false;
      _searchText = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WhCoefficientsViewModel>();

    List<WarehouseCoeffs> filteredWarehouses = model.warehouses;

    if (_searchText.isNotEmpty) {
      filteredWarehouses = filteredWarehouses
          .where((warehouse) => warehouse.warehouseName
              .toLowerCase()
              .contains(_searchText.toLowerCase()))
          .toList();
    }

    // Сортировка складов по алфавиту
    filteredWarehouses
        .sort((a, b) => a.warehouseName.compareTo(b.warehouseName));

    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : _buildAppBarTitle(),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              if (_isSearching) {
                _handleSearchEnd();
              } else {
                _handleSearchStart();
              }
            },
          ),
        ],
      ),
      body: model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredWarehouses.isEmpty
              ? const Center(child: Text('Склады не найдены.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredWarehouses.length,
                  itemBuilder: (context, index) {
                    final warehouse = filteredWarehouses[index];

                    // Проверяем, есть ли подписка на этот склад
                    final isSubscribedToWarehouse =
                        model.currentSubscriptions.any(
                      (sub) => sub.warehouseId == warehouse.warehouseId,
                    );

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: isSubscribedToWarehouse
                            ? const Icon(Icons.notifications_active,
                                color: Colors.blue)
                            : null,
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          warehouse.warehouseName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _navigateToBoxTypes(context, warehouse, model);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _navigateToBoxTypes(BuildContext context, WarehouseCoeffs warehouse,
      WhCoefficientsViewModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: model,
          child: BoxTypesScreen(warehouse: warehouse),
        ),
      ),
    );
  }
}

class BoxTypesScreen extends StatelessWidget {
  final WarehouseCoeffs warehouse;

  BoxTypesScreen({
    super.key,
    required this.warehouse,
  });

  final List<BoxType> standardBoxTypes = [
    BoxType(boxTypeId: 2, boxTypeName: 'Короба', coefficient: 0.0, date: ''),
    BoxType(
        boxTypeId: 5, boxTypeName: 'Монопаллеты', coefficient: 0.0, date: ''),
    BoxType(boxTypeId: 6, boxTypeName: 'Суперсейф', coefficient: 0.0, date: ''),
    BoxType(
        boxTypeId: 0,
        boxTypeName: 'QR-поставка с коробами',
        coefficient: 0.0,
        date: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WhCoefficientsViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(warehouse.warehouseName),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: standardBoxTypes.length,
        itemBuilder: (context, index) {
          final boxType = standardBoxTypes[index];

          final availableCoefficients = warehouse.boxTypes.where((bt) {
            return bt.boxTypeId == boxType.boxTypeId &&
                bt.boxTypeName == boxType.boxTypeName;
          }).toList();

          availableCoefficients.sort((a, b) =>
              DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

          final isSubscribed = model.currentSubscriptions.any((sub) =>
              sub.warehouseId == warehouse.warehouseId &&
              sub.boxTypeId == boxType.boxTypeId);

          UserSubscription? userSubscription;
          if (isSubscribed) {
            userSubscription = model.currentSubscriptions.firstWhere((sub) =>
                sub.warehouseId == warehouse.warehouseId &&
                sub.boxTypeId == boxType.boxTypeId);
          }

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(
                boxType.boxTypeName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: isSubscribed && userSubscription != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Вы подписаны с коэффициентом: ${userSubscription.threshold}\nПериод: c ${formatDate(userSubscription.fromDate)} по ${formatDate(userSubscription.toDate)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  : null,
              children: [
                if (availableCoefficients.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: availableCoefficients.map((coeff) {
                      return ListTile(
                        tileColor:
                            coeff.coefficient == 0.0 ? Colors.green[100] : null,
                        title: Text(
                          'Дата: ${_formatDate(DateTime.parse(coeff.date))}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          coeff.coefficient == 0.0
                              ? 'Бесплатно'
                              : 'Коэффициент приёмки: ${coeff.coefficient}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Нет доступных коэффициентов для этого типа поставки.',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    isSubscribed
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditSubscriptionDialog(
                                      context, model, userSubscription!);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  model.unsubscribe(userSubscription!);
                                },
                              ),
                            ],
                          )
                        : IconButton(
                            icon: const Icon(Icons.notifications),
                            onPressed: () {
                              _showSubscribeDialog(
                                  context, model, warehouse, boxType);
                            },
                          ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSubscribeDialog(BuildContext context, WhCoefficientsViewModel model,
      WarehouseCoeffs warehouse, BoxType boxType) {
    final TextEditingController coefficientController = TextEditingController();

    DateTime now = DateTime.now();
    DateTime sixMonthsFromNow = now.add(const Duration(days: 182));

    DateTimeRange selectedDateRange =
        DateTimeRange(start: now, end: sixMonthsFromNow);

    DateTime? fromDate = selectedDateRange.start;
    DateTime? toDate = selectedDateRange.end;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: Text('Подписка на "${boxType.boxTypeName}"'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Установите коэффициент и период для отслеживания.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: coefficientController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Коэффициент',
                    hintText: 'Введите коэффициент',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DateRangePickerWidget(
                  btnText: 'Выбрать период',
                  initDateTimeRange: selectedDateRange,
                  onDateRangeSelected: (start, end) {
                    setState(() {
                      fromDate = start;
                      toDate = end;
                    });
                  },
                ),
                if (fromDate != null && toDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Период: ${_formatDate(fromDate!)} - ${_formatDate(toDate!)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('Добавить'),
                onPressed: () {
                  final coefficient = double.tryParse(
                      coefficientController.text.replaceAll(',', '.'));
                  if (coefficient != null &&
                      fromDate != null &&
                      toDate != null) {
                    final newSubscription = UserSubscription(
                      warehouseId: warehouse.warehouseId,
                      boxTypeId: boxType.boxTypeId,
                      threshold: coefficient,
                      warehouseName: warehouse.warehouseName,
                      fromDate: _formatDate(fromDate!),
                      toDate: _formatDate(toDate!),
                    );
                    model.subscribe(sub: newSubscription);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Пожалуйста, заполните все поля и введите корректный коэффициент.'),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showEditSubscriptionDialog(BuildContext context,
      WhCoefficientsViewModel model, UserSubscription subscription) {
    final TextEditingController coefficientController =
        TextEditingController(text: subscription.threshold.toString());
    DateTime? fromDate =
        DateTime.tryParse(subscription.fromDate) ?? DateTime.now();
    DateTime? toDate = DateTime.tryParse(subscription.toDate) ??
        DateTime.now().add(const Duration(days: 1));

    DateTimeRange selectedDateRange =
        DateTimeRange(start: fromDate, end: toDate);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Изменить подписку'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Текущий коэффициент: ${subscription.threshold}',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: coefficientController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Новый коэффициент',
                    hintText: 'Введите новый коэффициент',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DateRangePickerWidget(
                  btnText: 'Изменить период',
                  initDateTimeRange: selectedDateRange,
                  onDateRangeSelected: (start, end) {
                    setState(() {
                      fromDate = start;
                      toDate = end;
                    });
                  },
                ),
                if (fromDate != null && toDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Период: ${_formatDate(fromDate!)} - ${_formatDate(toDate!)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('Сохранить'),
                onPressed: () {
                  final coefficient = double.tryParse(
                      coefficientController.text.replaceAll(',', '.'));
                  if (coefficient != null &&
                      fromDate != null &&
                      toDate != null) {
                    final updatedSubscription = UserSubscription(
                      warehouseId: subscription.warehouseId,
                      boxTypeId: subscription.boxTypeId,
                      threshold: coefficient,
                      warehouseName: subscription.warehouseName,
                      fromDate: _formatDate(fromDate!),
                      toDate: _formatDate(toDate!),
                    );
                    model.updateSubscription(updatedSubscription);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Пожалуйста, заполните все поля и введите корректный коэффициент.'),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}
