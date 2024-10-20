import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/domain/entities/wh_coeffs.dart';
import 'package:rewild_bot_front/presentation/wh_coefficients_screen/wh_coefficients_view_model.dart';
import 'package:rewild_bot_front/widgets/date_range_picker_widget.dart';

class WarehouseCoeffsScreen extends StatefulWidget {
  const WarehouseCoeffsScreen({Key? key}) : super(key: key);

  @override
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
        builder: (context) =>
            BoxTypesScreen(warehouse: warehouse, model: model),
      ),
    );
  }
}

class BoxTypesScreen extends StatelessWidget {
  final WarehouseCoeffs warehouse;
  final WhCoefficientsViewModel model;

  BoxTypesScreen({Key? key, required this.warehouse, required this.model})
      : super(key: key);

  // Define the standard list of delivery types with correct boxTypeId values
  final List<BoxType> standardBoxTypes = [
    BoxType(boxTypeId: 2, boxTypeName: 'Короба', coefficient: 0.0, date: ''),
    BoxType(
        boxTypeId: 5, boxTypeName: 'Монопаллеты', coefficient: 0.0, date: ''),
    BoxType(boxTypeId: 6, boxTypeName: 'Суперсейф', coefficient: 0.0, date: ''),
    BoxType(
        boxTypeId: 4,
        boxTypeName: 'QR-поставка с коробами',
        coefficient: 0.0,
        date: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(warehouse.warehouseName),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: standardBoxTypes.length,
        itemBuilder: (context, index) {
          final boxType = standardBoxTypes[index];

          // Find available coefficients for this warehouse and box type
          final availableCoefficients = warehouse.boxTypes.where((bt) {
            // Ensure both boxTypeId and boxTypeName match
            return bt.boxTypeId == boxType.boxTypeId &&
                bt.boxTypeName == boxType.boxTypeName;
          }).toList();

          // Check if the user is subscribed to this boxType
          final isSubscribed = model.currentSubscriptions.any((sub) =>
              sub.warehouseId == warehouse.warehouseId &&
              sub.boxTypeId == boxType.boxTypeId);

          // Get the user's subscription if it exists
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
                        'Вы подписаны с коэффициентом: ${userSubscription.threshold}\nПериод: ${userSubscription.fromDate} - ${userSubscription.toDate}',
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
                        title: Text(
                          'Дата: ${_formatDate(DateTime.parse(coeff.date))}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          'Коэффициент приёмки: ${coeff.coefficient}',
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
    DateTime? fromDate;
    DateTime? toDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Подписка на "${boxType.boxTypeName}"'),
            content: SingleChildScrollView(
              child: Column(
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
                      // boxTypeName: boxType.boxTypeName,
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

    // final boxTypeName = subscription.boxTypeName;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Изменить подписку'),
            content: SingleChildScrollView(
              child: Column(
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
                      // boxTypeName: subscription.boxTypeName,
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
