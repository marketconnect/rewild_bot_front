import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/advertising_constants.dart';
import 'package:rewild_bot_front/core/constants/geo_constants.dart';
import 'package:rewild_bot_front/core/utils/extensions/strings.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/advert_auto_model.dart';
import 'package:rewild_bot_front/domain/entities/advert_base.dart';

abstract class AllAdvertsWordsAdvertService {
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, List<Advert>>> getAll(
      {required String token, List<int>? types});
}

abstract class AllAdvertsWordsScreenCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

class AllAdvertsWordsViewModel extends ResourceChangeNotifier {
  final AllAdvertsWordsAdvertService advertService;
  final AllAdvertsWordsScreenCardOfProductService cardOfProductService;
  AllAdvertsWordsViewModel(
      {required super.context,
      required this.cardOfProductService,
      required this.advertService}) {
    _asyncInit();
  }

  // apiKey
  String? _apiKey;
  void setApiKey(String value) {
    _apiKey = value;
  }

  // adverts
  final List<Advert> _adverts = [];
  void setAdverts(List<Advert> value) {
    _adverts.clear();
    _adverts.addAll(value);
  }

  List<Advert> get adverts => _adverts;

  Map<int, List<String>> subjects = {};

  void addSubject(int id, String value) {
    if (subjects[id] == null) {
      subjects[id] = [];
    }
    subjects[id]!.add(value);
  }

  String gNum = geoDistanceKey('Москва');
  void setGNum(String value) {
    gNum = value;
    notify();
  }

  // images
  Map<int, String> _image = {};
  void setImage(Map<int, String> value) {
    _image = value;
  }

  void addImage(int advId, String value) {
    _image[advId] = value;
  }

  String image(int advId) {
    return _image[advId] ?? "";
  }

  void _asyncInit() async {
    final apiKey = await fetch(() => advertService.getApiKey());
    if (apiKey == null) {
      return;
    }
    setApiKey(apiKey);
    final adverts = await fetch(() => advertService
        .getAll(token: _apiKey!, types: [AdvertTypeConstants.auto]));
    if (adverts == null) {
      return;
    }

    List<int> campaignIds = [];
    setIsLoading(false);
    List<Advert> allAdverts = [];
    for (var advert in adverts) {
      campaignIds.add(advert.campaignId);
      List<int> nmIds = [];

      if (advert is AdvertAutoModel) {
        final params = advert.autoParams!;
        if (params.nms != null) {
          final nms = params.nms!;
          final n = nms.length > 3 ? 3 : nms.length;
          nmIds = nms.map((e) => e).toList().sublist(0, n);
        }

        if (params.subject != null) {
          final name = params.subject!.name ?? "";
          addSubject(advert.campaignId, name.capitalize());

          final newAdvert = advert.copyWith(subjectId: params.subject!.id);
          if (nmIds.isNotEmpty) {
            final image = await fetch(
              () => cardOfProductService.getImageForNmId(nmId: nmIds.first),
            );

            if (image == null) {
              continue;
            }

            addImage(newAdvert.campaignId, image);
          }
          allAdverts.add(newAdvert);
        }
      }

      allAdverts.sort((a, b) => b.status.compareTo(a.status));
      setAdverts(allAdverts);

      notify();
    }
  }

  bool _isLoading = true;
  void setIsLoading(bool variable) {
    _isLoading = variable;
    notify();
  }

  bool get isLoading => _isLoading;

  // loading text
  String _loadingText = 'Получаю кампании...';
  void setLoadingText(String loadingText) {
    _loadingText = loadingText;
    notify();
  }

  String get loadingText => _loadingText;
}
