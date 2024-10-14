// import 'dart:convert';
// // ignore: depend_on_referenced_packages
// import 'package:http/http.dart' as http;
// import 'package:fpdart/fpdart.dart';
// import 'package:rewild_bot_front/core/utils/rewild_error.dart';
// import 'package:rewild_bot_front/domain/entities/ozon_transaction_response.dart';
// import 'package:rewild_bot_front/domain/services/ozon_transaction_service.dart';

// class OzonTransactionApiClient implements OzonTransactionServiceApiClient {
//   const OzonTransactionApiClient();

//   // https://docs.ozon.ru/api/seller/#operation/FinanceAPI_FinanceTransactionListV3
//   @override
//   Future<Either<RewildError, OzonTransactionResponse>> getTransactionList({
//     required String clientId,
//     required String apiKey,
//     required OzonTransactionFilter filter,
//     required int page,
//     required int pageSize,
//   }) async {
//     const url = "https://api-seller.ozon.ru/v3/finance/transaction/list";
//     final headers = {
//       'Content-Type': 'application/json',
//       'Client-Id': clientId,
//       'Api-Key': apiKey,
//     };

//     final body = jsonEncode({
//       "filter": filter.toJson(),
//       "page": page,
//       "page_size": pageSize,
//     });

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(utf8.decode(response.bodyBytes));
//         final transactionResponse =
//             OzonTransactionResponse.fromJson(data['result']);
//         return Right(transactionResponse);
//       } else {
//         return Left(RewildError(
//           "Ошибка сервера: ${response.statusCode} ${response.body}",
//           source: "TransactionApiClient",
//           name: "getTransactionList",
//           args: [clientId, page, pageSize],
//           sendToTg: true,
//         ));
//       }
//     } catch (e) {
//       return Left(RewildError(
//         e.toString(),
//         source: "TransactionApiClient",
//         name: "getTransactionList",
//         args: [clientId, page, pageSize],
//         sendToTg: true,
//       ));
//     }
//   }
// }
