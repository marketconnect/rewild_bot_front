// class OzonTransactionResponse {
//   final List<OzonTransactionOperation> operations;
//   final int pageCount;
//   final int rowCount;

//   OzonTransactionResponse({
//     required this.operations,
//     required this.pageCount,
//     required this.rowCount,
//   });

//   factory OzonTransactionResponse.fromJson(Map<String, dynamic> json) {
//     return OzonTransactionResponse(
//       operations: (json['operations'] as List)
//           .map((op) => OzonTransactionOperation.fromJson(op))
//           .toList(),
//       pageCount: json['page_count'],
//       rowCount: json['row_count'],
//     );
//   }
// }

// class OzonTransactionOperation {
//   final int operationId;
//   final String operationType;
//   final String operationDate;
//   final String operationTypeName;
//   final double deliveryCharge;
//   final double returnDeliveryCharge;
//   final double accrualsForSale;
//   final double saleCommission;
//   final double amount;
//   final String type;
//   final OzonPosting posting;
//   final List<OzonItem> items;
//   final List<OzonService> services;

//   OzonTransactionOperation({
//     required this.operationId,
//     required this.operationType,
//     required this.operationDate,
//     required this.operationTypeName,
//     required this.deliveryCharge,
//     required this.returnDeliveryCharge,
//     required this.accrualsForSale,
//     required this.saleCommission,
//     required this.amount,
//     required this.type,
//     required this.posting,
//     required this.items,
//     required this.services,
//   });

//   factory OzonTransactionOperation.fromJson(Map<String, dynamic> json) {
//     return OzonTransactionOperation(
//       operationId: json['operation_id'],
//       operationType: json['operation_type'],
//       operationDate: json['operation_date'],
//       operationTypeName: json['operation_type_name'],
//       deliveryCharge: json['delivery_charge'] ?? 0.0,
//       returnDeliveryCharge: json['return_delivery_charge'] ?? 0.0,
//       accrualsForSale: json['accruals_for_sale'] ?? 0.0,
//       saleCommission: json['sale_commission'] ?? 0.0,
//       amount: json['amount'] ?? 0.0,
//       type: json['type'] ?? '',
//       posting: OzonPosting.fromJson(json['posting']),
//       items: (json['items'] as List)
//           .map((item) => OzonItem.fromJson(item))
//           .toList(), // Правильное парсинг для items
//       services: (json['services'] as List)
//           .map((service) => OzonService.fromJson(service))
//           .toList(), // Правильное парсинг для services
//     );
//   }
// }

// class OzonItem {
//   final String name;
//   final int sku;
//   final double price;

//   OzonItem({
//     required this.name,
//     required this.sku,
//     required this.price,
//   });

//   factory OzonItem.fromJson(Map<String, dynamic> json) {
//     return OzonItem(
//       name: json['name'],
//       sku: json['sku'],
//       price: json['price'] ?? 0.0,
//     );
//   }
// }

// class OzonService {
//   final String name;

//   OzonService({
//     required this.name,
//   });

//   factory OzonService.fromJson(Map<String, dynamic> json) {
//     return OzonService(
//       name: json['name'],
//     );
//   }
// }

// class OzonPosting {
//   final String deliverySchema;
//   final String orderDate;
//   final String postingNumber;
//   final int warehouseId;

//   OzonPosting({
//     required this.deliverySchema,
//     required this.orderDate,
//     required this.postingNumber,
//     required this.warehouseId,
//   });

//   factory OzonPosting.fromJson(Map<String, dynamic> json) {
//     return OzonPosting(
//       deliverySchema: json['delivery_schema'] ?? '',
//       orderDate: json['order_date'] ?? '',
//       postingNumber: json['posting_number'] ?? '',
//       warehouseId: json['warehouse_id'] ?? 0,
//     );
//   }
// }

// class OzonTransactionFilter {
//   final DateTime fromDate;
//   final DateTime toDate;
//   final String transactionType;
//   final String? postingNumber;

//   OzonTransactionFilter({
//     required this.fromDate,
//     required this.toDate,
//     required this.transactionType,
//     this.postingNumber,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       "date": {
//         "from": fromDate.toUtc().toIso8601String(), // Добавлено toUtc()
//         "to": toDate.toUtc().toIso8601String(), // Добавлено toUtc()
//       },
//       "transaction_type": transactionType,
//       "posting_number": postingNumber ?? "",
//     };
//   }
// }
