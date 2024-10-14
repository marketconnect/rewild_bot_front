// import 'package:fpdart/fpdart.dart';
// import 'package:rewild_bot_front/core/utils/rewild_error.dart';
// import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
// import 'package:rewild_bot_front/domain/entities/ozon_transaction_response.dart';
// import 'package:rewild_bot_front/presentation/home/finance/ozon_transaction_screen/ozon_transaction_view_model.dart';

// abstract class OzonTransactionServiceApiClient {
//   Future<Either<RewildError, OzonTransactionResponse>> getTransactionList({
//     required String clientId,
//     required String apiKey,
//     required OzonTransactionFilter filter,
//     required int page,
//     required int pageSize,
//   });
// }

// // Api key
// abstract class OzonTransactionServiceApiKeyDataProvider {
//   Future<Either<RewildError, ApiKeyModel?>> getOzonKey();
// }

// class OzonTransactionService
//     implements OzonTransactionScreenOzonTransactionService {
//   final OzonTransactionServiceApiClient apiClient;
//   final OzonTransactionServiceApiKeyDataProvider apiKeysDataProvider;

//   const OzonTransactionService(
//       {required this.apiClient, required this.apiKeysDataProvider});
//   @override
//   Future<Either<RewildError, bool>> apiKeyExists() async {
//     // Get active seller

//     // Get Api key
//     final either = await apiKeysDataProvider.getOzonKey();
//     return either.fold((l) => left(l), (r) {
//       if (r == null) {
//         return right(false);
//       }
//       return right(true);
//     });
//   }

//   @override
//   Future<Either<RewildError, OzonTransactionResponse>> getTransactionList({
//     // required String clientId,
//     // required String apiKey,
//     required OzonTransactionFilter filter,
//     required int page,
//     required int pageSize,
//   }) async {
//     // Get Api key
//     final either = await apiKeysDataProvider.getOzonKey();
//     if (either.isLeft()) {
//       return left(either.fold((l) => l, (r) => throw UnimplementedError()));
//     }
//     final apiKey = either.fold((l) => throw UnimplementedError(), (r) => r);
//     if (apiKey == null) {
//       return left(
//         RewildError(
//           sendToTg: true,
//           'Api key not found',
//           source: 'OzonTransactionService',
//           name: 'getTransactionList',
//           args: [],
//         ),
//       );
//     }
//     return apiClient.getTransactionList(
//       clientId: apiKey.sellerId,
//       apiKey: apiKey.token,
//       filter: filter,
//       page: page,
//       pageSize: pageSize,
//     );
//   }
// }
