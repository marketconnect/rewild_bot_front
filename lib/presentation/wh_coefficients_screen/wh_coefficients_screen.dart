// В файле WarehouseCoeffsScreen.dart внесите следующие изменения:

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/domain/entities/wh_coeffs.dart';
import 'package:rewild_bot_front/presentation/wh_coefficients_screen/wh_coefficients_view_model.dart';

class WarehouseCoeffsScreen extends StatelessWidget {
  const WarehouseCoeffsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WhCoefficientsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Коэффициенты приёмки'),
      ),
      body: model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: model.warehouses.length,
              itemBuilder: (context, index) {
                final warehouse = model.warehouses[index];
                final isSubscribed = model.curentSubscriptions
                    .any((sub) => sub.whIdBoxTypeId == warehouse.whIdBoxTypeId);

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      warehouse.warehouseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Тип поставки: ${warehouse.boxTypeName}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            warehouse.coefficient == -1
                                ? 'Поставка недоступна'
                                : 'Коэффициент приёмки: ${warehouse.coefficient}',
                            style: TextStyle(
                              fontSize: 16,
                              color: warehouse.coefficient == -1
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: isSubscribed
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditCoefficientDialog(
                                      context, model, warehouse);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  model.unsubscribe(warehouse);
                                },
                              ),
                            ],
                          )
                        : IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _showSubscribeDialog(context, model, warehouse);
                            },
                          ),
                  ),
                );
              },
            ),
    );
  }

  void _showSubscribeDialog(BuildContext context, WhCoefficientsViewModel model,
      WarehouseCoeffs warehouse) {
    final TextEditingController _coefficientController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Добавить склад "${warehouse.warehouseName}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Установите коэффициент для отслеживания.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _coefficientController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Коэффициент',
                  hintText: 'Введите коэффициент',
                  border: OutlineInputBorder(),
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
                    _coefficientController.text.replaceAll(',', '.'));
                if (coefficient != null) {
                  final newWarehouse = WarehouseCoeffs(
                    warehouseId: warehouse.warehouseId,
                    boxTypeId: warehouse.boxTypeId,
                    boxTypeName: warehouse.boxTypeName,
                    warehouseName: warehouse.warehouseName,
                    coefficient: coefficient,
                  );
                  model.subscribe(warehouseCoeffs: newWarehouse);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Пожалуйста, введите корректный коэффициент.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditCoefficientDialog(BuildContext context,
      WhCoefficientsViewModel model, WarehouseCoeffs warehouse) {
    final TextEditingController _coefficientController =
        TextEditingController(text: warehouse.coefficient.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Изменить коэффициент для "${warehouse.warehouseName}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Текущий коэффициент: ${warehouse.coefficient}',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _coefficientController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Новый коэффициент',
                  hintText: 'Введите новый коэффициент',
                  border: OutlineInputBorder(),
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
                    _coefficientController.text.replaceAll(',', '.'));
                if (coefficient != null) {
                  final updatedWarehouse = WarehouseCoeffs(
                    warehouseId: warehouse.warehouseId,
                    boxTypeId: warehouse.boxTypeId,
                    boxTypeName: warehouse.boxTypeName,
                    warehouseName: warehouse.warehouseName,
                    coefficient: coefficient,
                  );
                  model.updateSubscription(updatedWarehouse);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Пожалуйста, введите корректный коэффициент.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
