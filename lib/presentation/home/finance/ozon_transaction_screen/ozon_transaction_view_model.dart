// import 'package:fpdart/fpdart.dart';
// import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
// import 'package:rewild_bot_front/core/utils/rewild_error.dart';
// import 'package:rewild_bot_front/domain/entities/ozon_transaction_response.dart';

// abstract class OzonTransactionScreenOzonTransactionService {
//   Future<Either<RewildError, OzonTransactionResponse>> getTransactionList({
//     required OzonTransactionFilter filter,
//     required int page,
//     required int pageSize,
//   });
//   Future<Either<RewildError, bool>> apiKeyExists();
// }

// class OzonTransactionViewModel extends ResourceChangeNotifier {
//   final OzonTransactionScreenOzonTransactionService ozonTransactionService;

//   OzonTransactionViewModel(
//       {required super.context, required this.ozonTransactionService}) {
//     _asyncInit();
//   }

//   OzonTransactionResponse? _transactionResponse;
//   DateTime _selectedFromDate = DateTime.now();
//   DateTime _selectedToDate = DateTime.now();

//   OzonTransactionResponse? get transactionResponse => _transactionResponse;
//   DateTime get selectedFromDate => _selectedFromDate;
//   DateTime get selectedToDate => _selectedToDate;

// // loading
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//   void setIsLoading(bool loading) {
//     _isLoading = loading;
//     notify();
//   }

//   // api key exists
//   bool _apiKeyExists = false;
//   bool get apiKeyExists => _apiKeyExists;
//   void setApiKeyExists(bool exists) {
//     _apiKeyExists = exists;
//   }

//   // Methods

//   Future<void> _asyncInit() async {
//     setIsLoading(true);
//     final apiKeyExistOrNull =
//         await fetch(() => ozonTransactionService.apiKeyExists());
//     if (apiKeyExistOrNull == null) {
//       setApiKeyExists(false);
//       setIsLoading(false);
//       return;
//     }
//     setApiKeyExists(apiKeyExistOrNull);
//     setIsLoading(false);

//     await _loadTodayTransactions();
//   }

//   Future<void> _loadTodayTransactions() async {
//     await _fetchTransactions(fromDate: DateTime.now(), toDate: DateTime.now());
//   }

//   Future<void> _fetchTransactions({
//     required DateTime fromDate,
//     required DateTime toDate,
//   }) async {
//     _isLoading = true;
//     notify();

//     final result = await ozonTransactionService.getTransactionList(
//       filter: OzonTransactionFilter(
//         fromDate: fromDate,
//         toDate: toDate,
//         transactionType: "all",
//       ),
//       page: 1,
//       pageSize: 100,
//     );

//     result.fold(
//       (error) {
//         _transactionResponse = null;
//       },
//       (response) {
//         _transactionResponse = response;
//       },
//     );

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> selectPeriod(DateTime fromDate, DateTime toDate) async {
//     _selectedFromDate = fromDate;
//     _selectedToDate = toDate;
//     await _fetchTransactions(fromDate: fromDate, toDate: toDate);
//   }
// }
