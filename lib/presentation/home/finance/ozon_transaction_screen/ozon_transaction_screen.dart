// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:rewild_bot_front/domain/entities/ozon_transaction_response.dart';
// import 'ozon_transaction_view_model.dart';
// import 'package:intl/intl.dart';

// class OzonTransactionScreen extends StatelessWidget {
//   const OzonTransactionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ozon Transactions'),
//       ),
//       body: Consumer<OzonTransactionViewModel>(
//         builder: (context, viewModel, child) {
//           if (viewModel.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return Column(
//             children: [
//               _buildDatePicker(context, viewModel),
//               _buildTransactionList(viewModel),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDatePicker(
//       BuildContext context, OzonTransactionViewModel viewModel) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             children: [
//               const Text('From Date'),
//               TextButton(
//                 onPressed: () =>
//                     _selectDate(context, viewModel, isFromDate: true),
//                 child:
//                     Text(DateFormat.yMd().format(viewModel.selectedFromDate)),
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               const Text('To Date'),
//               TextButton(
//                 onPressed: () =>
//                     _selectDate(context, viewModel, isFromDate: false),
//                 child: Text(DateFormat.yMd().format(viewModel.selectedToDate)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectDate(
//       BuildContext context, OzonTransactionViewModel viewModel,
//       {required bool isFromDate}) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate:
//           isFromDate ? viewModel.selectedFromDate : viewModel.selectedToDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );

//     if (picked != null) {
//       if (isFromDate) {
//         viewModel.selectPeriod(picked, viewModel.selectedToDate);
//       } else {
//         viewModel.selectPeriod(viewModel.selectedFromDate, picked);
//       }
//     }
//   }

//   Widget _buildTransactionList(OzonTransactionViewModel viewModel) {
//     final transactions = viewModel.transactionResponse?.operations ?? [];

//     if (transactions.isEmpty) {
//       return const Center(
//           child: Text('No transactions found for the selected period.'));
//     }

//     return Expanded(
//       child: ListView.builder(
//         itemCount: transactions.length,
//         itemBuilder: (context, index) {
//           final transaction = transactions[index];
//           return ExpansionTile(
//             title: Text('Operation: ${transaction.operationTypeName}'),
//             subtitle: Text('Amount: ${transaction.amount.toString()}'),
//             trailing: Text(DateFormat.yMd()
//                 .format(DateTime.parse(transaction.operationDate))),
//             children: [
//               _buildItemsList(transaction),
//               _buildServicesList(transaction),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildItemsList(OzonTransactionOperation transaction) {
//     if (transaction.items.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(8.0),
//         child: Text('No items available'),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: transaction.items.map((item) {
//         return ListTile(
//           title: Text('Item: ${item.name}'),
//           subtitle: Text('SKU: ${item.sku}, Price: ${item.price}'),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildServicesList(OzonTransactionOperation transaction) {
//     if (transaction.services.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(8.0),
//         child: Text('No services available'),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: transaction.services.map((service) {
//         return ListTile(
//           title: Text('Service: ${service.name}'),
//         );
//       }).toList(),
//     );
//   }
// }
