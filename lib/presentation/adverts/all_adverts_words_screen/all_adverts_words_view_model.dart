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
  late List<Advert> _adverts = [];
  void setAdverts(List<Advert> value) {
    _adverts = value;
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
    final adverts = await fetch(() => advertService.getAll(
        token: _apiKey!,
        // types: [AdvertTypeConstants.inSearch, AdvertTypeConstants.auto]));
        types: [AdvertTypeConstants.auto]));
    if (adverts == null) {
      return;
    }

    List<int> campaignIds = [];
    setIsLoading(false);
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
          advert = advert.copyWith(subjectId: params.subject!.id);
        }
      }
      // else if (advert is AdvertSearchModel) {
      //   final params = advert.params!;
      //   for (final param in params) {
      //     if (param.nms != null) {
      //       final nms = param.nms!;
      //       final n = nms.length > 3 ? 3 : nms.length;
      //       nmIds = nms.map((e) => e.nm).toList().sublist(0, n);
      //     }
      //     if (param.subjectName != null) {
      //       final name = param.subjectName ?? "";
      //       addSubject(
      //         advert.campaignId,
      //         name.capitalize(),
      //       );
      //     }
      //   }
      //   // cpm = params.first.price!.toString();
      // }
      if (nmIds.isNotEmpty) {
        final image = await fetch(
          () => cardOfProductService.getImageForNmId(nmId: nmIds.first),
        );

        if (image == null) {
          continue;
        }

        addImage(advert.campaignId, image);
      }

      adverts.sort((a, b) => b.status.compareTo(a.status));
      setAdverts(adverts);

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
