import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/advert_base.dart';
import 'package:rewild_bot_front/domain/entities/stream_advert_event.dart';

abstract class RootAdvertsAdvertService {
  Future<Either<RewildError, List<Advert>>> getAllAdverts(
      {required String token});
  Future<Either<RewildError, int?>> getBallance({required String token});
  Future<Either<RewildError, int>> getBudget(
      {required String token, required int campaignId});
  Future<Either<RewildError, String?>> getApiKey();
}

class RootAdvertsScreenViewModel extends ResourceChangeNotifier {
  final RootAdvertsAdvertService advertService;
  final Stream<StreamAdvertEvent> updatedAdvertStream;
  final Stream<Map<ApiKeyType, String>> apiKeyExistsStream;
  RootAdvertsScreenViewModel(
      {required super.context,
      required this.advertService,
      required this.apiKeyExistsStream,
      required this.updatedAdvertStream}) {
    _asyncInit();
  }

  // Adverts
  List<Advert> _adverts = [];
  void setAdverts(List<Advert> value) {
    _adverts = value;
    notify();
  }

  void updateAdvert(Advert advert) {
    _adverts.removeWhere((element) => element.campaignId == advert.campaignId);
    _adverts.insert(0, advert);
    notify();
  }

  List<Advert> get adverts => _adverts;

  // budget
  Map<int, int> _budget = {};
  void setBudget(Map<int, int> value) {
    _budget = value;
  }

  void addBudget(int advId, int value) {
    _budget[advId] = value;
  }

  Map<int, int> get budget => _budget;

  bool _isLoading = false;
  void setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  bool get isLoading => _isLoading;

  // ApiKeysExists
  String? _advertApiKey;
  void setAdvertApiKey(String? value) {
    _advertApiKey = value;
  }

  bool get advertApiKeyExists => _advertApiKey != null;

  // balance
  int? _balance;
  void setBalance(int? value) {
    _balance = value;
  }

  int? get balance => _balance;

  void _asyncInit() async {
    // Update in MainNavigationAdvertScreen status of _AllAdvertsWidget
    apiKeyExistsStream.listen((event) {
      if (event[ApiKeyType.promo] != null) {
        setAdvertApiKey(
            event[ApiKeyType.promo] == "" ? null : event[ApiKeyType.promo]);
      }
      notify();
    });
    updatedAdvertStream.listen((event) async {
      if (event.status != null) {
        final oldAdverts =
            _adverts.where((a) => a.campaignId == event.campaignId);
        if (oldAdverts.isEmpty) {
          return;
        }
        final newAdvert = oldAdverts.first.copyWith(status: event.status);
        updateAdvert(newAdvert);
      }

      notify();
    });

    final advertApiKey = await fetch(() => advertService.getApiKey());
    if (advertApiKey == null) {
      return;
    }
    setAdvertApiKey(advertApiKey);

    final newAdverts =
        await fetch(() => advertService.getAllAdverts(token: _advertApiKey!));
    if (newAdverts == null) {
      return;
    }

    setAdverts(newAdverts);
    notify();
  }

  Future<void> updateAdverts() async {
    setIsLoading(true);
    if (_advertApiKey == null) {
      return;
    }
    final balance =
        await fetch(() => advertService.getBallance(token: _advertApiKey!));
    if (balance == null) {
      return;
    }
    setBalance(balance);
    notify();

    final newAdverts =
        await fetch(() => advertService.getAllAdverts(token: _advertApiKey!));
    if (newAdverts == null) {
      return;
    }

    setAdverts(newAdverts);

    for (final advert in _adverts) {
      final budget = await fetch(() => advertService.getBudget(
          token: _advertApiKey!, campaignId: advert.campaignId));
      if (budget != null) {
        addBudget(advert.campaignId, budget);
        notify();
      }
    }
    setIsLoading(false);
  }
}
