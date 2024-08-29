import 'dart:convert';
import 'package:fpdart/fpdart.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:rewild_bot_front/core/utils/api_helpers/geo_search_api_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/geo_search_model.dart';
import 'package:rewild_bot_front/domain/entities/wb_search_log.dart';
import 'package:rewild_bot_front/domain/services/geo_search_service.dart';
import 'package:rewild_bot_front/domain/services/keywords_service.dart';
import 'package:rewild_bot_front/domain/services/tracking_service.dart';

class GeoSearchApiClient
    implements
        GeoSearchServiceGeoSearchApiClient,
        KeywordsServiceGeoSearchApiClient,
        TrackingServiceGeoSearchApiClient {
  const GeoSearchApiClient();
  static const String baseUrl =
      'https://search.wb.ru/exactmatch/ru/common/v5/search';
  static const Map<String, String> headers = {
    'accept': '*/*',
    'accept-language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,fr;q=0.6',
    'sec-ch-ua':
        '"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Linux"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'cross-site',
  };

  @override
  Future<Either<RewildError, (Map<int, GeoSearchModel>, List<WbSearchLog>)>>
      getProductsNmIdIndexMapWithGeoAndAdv(
          {required String gNum,
          required String query,
          required List<int> nmIds}) async {
    final encodedQuery = Uri.encodeComponent(query.trim());
    final uri = Uri.parse(
        '$baseUrl?ab_testing=false&appType=64&curr=rub&dest=$gNum&query=$encodedQuery&resultset=catalog&sort=popular&spp=30&suppressSpellcheck=false');

    final Map<String, String> customHeaders = {
      ...headers,
      'x-queryid': 'qid${DateTime.now().millisecondsSinceEpoch}',
      'referer':
          'https://www.wildberries.ru/catalog/0/search.aspx?search=$encodedQuery',
    };

    try {
      // var response = await GeoSearchApiHelper.search.get(null, params);
      // var uri = Uri.https(_host, _path, params);
      var response = await http.get(uri, headers: customHeaders);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> products = data['data']['products'];
        if (products.isEmpty) {
          return left(RewildError(
            sendToTg: false,
            'По вашему запросу ничего не найдено',
            source: 'GeoApiClient',
            name: 'getProductsNmIdIndexMapWithGeoAndAdv',
            args: [],
          ));
        }

        Map<int, GeoSearchModel> idToIndexMap = {};
        List<WbSearchLog> nmIdToPositionMap = [];
        for (var i = 0; i < products.length; i++) {
          int productId = products[i]['id'];

          final log = products[i]['log'];
          // Adverts positions and CPM
          if (log != null) {
            nmIdToPositionMap.add(WbSearchLog.fromJson(log, gNum));
          }

          if (nmIds.contains(productId)) {
            int? advPosition;
            int? advCpm;
            if (log != null) {
              advPosition = log['position'];
              advCpm = log['cpm'];
            }
            final geoSearch = GeoSearchModel(
                nmId: productId,
                position: i,
                advCpm: advCpm,
                advPosition: advPosition);
            idToIndexMap[productId] = geoSearch;
          }
        }
        return right((idToIndexMap, nmIdToPositionMap));
      } else {
        return left(RewildError(
          sendToTg: false,
          GeoSearchApiHelper.search
              .errResponse(statusCode: response.statusCode),
          source: 'GeoApiClient',
          name: 'getProductsNmIdIndexMapWithGeoAndAdv',
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: false,
        "Неизвестная ошибка: $e",
        source: 'GeoApiClient',
        name: 'getProductsNmIdIndexMapWithGeoAndAdv',
        args: [],
      ));
    }
  }

  Future<Either<RewildError, Map<int, WbSearchLog>>> getProductsNmIdAdv(
      {required String gNum,
      required String query,
      bool secondPage = false}) async {
    final encodedQuery = Uri.encodeComponent(query.trim());

    final Map<String, String> customHeaders = {
      ...headers,
      'x-queryid': 'qid${DateTime.now().millisecondsSinceEpoch}',
      'referer':
          'https://www.wildberries.ru/catalog/0/search.aspx?search=$encodedQuery',
    };
    Uri uri = Uri.parse(
        '$baseUrl?ab_testing=false&appType=64&curr=rub&dest=$gNum&query=$encodedQuery&resultset=catalog&sort=popular&spp=30&suppressSpellcheck=false');
    if (secondPage) {
      uri = Uri.parse(
          '$baseUrl?page=2&ab_testing=false&appType=64&curr=rub&dest=$gNum&query=$encodedQuery&resultset=catalog&sort=popular&spp=30&suppressSpellcheck=false');
    }
    try {
      // var response = await GeoSearchApiHelper.search.get(null, params);
      // var uri = Uri.https(_host, _path, params);
      var response = await http.get(uri, headers: customHeaders);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> products = data['data']['products'];

        if (products.isEmpty) {
          return left(RewildError(
            sendToTg: false,
            'По вашему запросу ничего не найдено',
            source: 'GeoApiClient',
            name: 'getProductsNmIdIndexMapWithGeoAndAdv',
            args: [],
          ));
        }

        // Map<int, GeoSearchModel> idToIndexMap = {};
        Map<int, WbSearchLog> nmIdToPositionMap = {};
        for (var i = 0; i < products.length; i++) {
          int productId = products[i]['id'];

          final log = products[i]['log'];

          // Adverts positions and CPM
          if (log != null && log['cpm'] != null) {
            nmIdToPositionMap[productId] = WbSearchLog.fromJson(log, gNum);
          }
        }
        return right(nmIdToPositionMap);
      } else {
        return left(RewildError(
          sendToTg: false,
          GeoSearchApiHelper.search
              .errResponse(statusCode: response.statusCode),
          source: 'GeoApiClient',
          name: 'getProductsNmIdIndexMapWithGeoAndAdv',
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: false,
        "Неизвестная ошибка: $e",
        source: 'GeoApiClient',
        name: 'getProductsNmIdIndexMapWithGeoAndAdv',
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, Map<int, GeoSearchModel>>>
      getProductsNmIdIndexMapWithGeo(
          {required String gNum,
          required String query,
          required List<int> nmIds,
          bool secondPage = false}) async {
    final encodedQuery = Uri.encodeComponent(query.trim());

    final Map<String, String> customHeaders = {
      ...headers,
      'x-queryid': 'qid${DateTime.now().millisecondsSinceEpoch}',
      'referer':
          'https://www.wildberries.ru/catalog/0/search.aspx?search=$encodedQuery',
    };
    Uri uri = Uri.parse(
        '$baseUrl?ab_testing=false&appType=64&curr=rub&dest=$gNum&query=$encodedQuery&resultset=catalog&sort=popular&spp=30&suppressSpellcheck=false');
    if (secondPage) {
      uri = Uri.parse(
          '$baseUrl?page=2&ab_testing=false&appType=64&curr=rub&dest=$gNum&query=$encodedQuery&resultset=catalog&sort=popular&spp=30&suppressSpellcheck=false');
    }
    try {
      // var response = await GeoSearchApiHelper.search.get(null, params);
      // var uri = Uri.https(_host, _path, params);
      var response = await http.get(uri, headers: customHeaders);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> products = data['data']['products'];
        if (products.isEmpty || products.length == 1) {
          return left(RewildError(
            sendToTg: false,
            'По вашему запросу ничего не найдено $secondPage',
            source: 'GeoApiClient',
            name: 'getProductsNmIdIndexMapWithGeo',
            args: [],
          ));
        }

        Map<int, GeoSearchModel> idToIndexMap = {};
        for (var i = 0; i < products.length; i++) {
          int productId = products[i]['id'];
          if (nmIds.contains(productId)) {
            final log = products[i]['log'];
            int? advPosition;
            int? advCpm;
            if (log != null) {
              advPosition = log['position'];
              advCpm = log['cpm'];
            }
            final geoSearch = GeoSearchModel(
                nmId: productId,
                position: secondPage ? i + 100 : i,
                advCpm: advCpm,
                advPosition: advPosition);
            idToIndexMap[productId] = geoSearch;
          }
        }
        return right(idToIndexMap);
      } else {
        return left(RewildError(
          sendToTg: false,
          GeoSearchApiHelper.search
              .errResponse(statusCode: response.statusCode),
          source: 'GeoApiClient',
          name: 'getProductsNmIdIndexMapWithGeo',
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: false,
        "Неизвестная ошибка: $e",
        source: 'GeoApiClient',
        name: 'getProductsNmIdIndexMapWithGeo',
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, Map<int, GeoSearchModel>>>
      getProductsNmIdIndexMapIn(
          {required String query,
          required List<int> nmIds,
          bool secondPage = false}) async {
    final encodedQuery = Uri.encodeComponent(query.trim());

    final Map<String, String> customHeaders = {
      ...headers,
      'x-queryid': 'qid${DateTime.now().millisecondsSinceEpoch}',
      'referer':
          'https://www.wildberries.ru/catalog/0/search.aspx?search=$encodedQuery',
    };
    Uri uri = Uri.parse(
        '$baseUrl?ab_testing=false&appType=64&curr=rub&dest=-1257786&query=$encodedQuery&resultset=catalog&sort=popular&spp=30&suppressSpellcheck=false');
    if (secondPage) {
      uri = Uri.parse(
          '$baseUrl?page=2&ab_testing=false&appType=64&curr=rub&dest=-1257786&query=$encodedQuery&resultset=catalog&sort=popular&spp=30&suppressSpellcheck=false');
    }
    try {
      // var uri = Uri.https(_host, _path, params);

      var response = await http.get(
        uri,
        headers: customHeaders,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> products = data['data']['products'];
        if (products.isEmpty || products.length == 1) {
          return left(RewildError(
            sendToTg: false,
            'По вашему запросу ничего не найдено $secondPage',
            source: 'GeoApiClient',
            name: 'getProductsNmIdIndexMapIn',
            args: [],
          ));
        }
        Map<int, GeoSearchModel> idToIndexMap = {};
        for (var i = 0; i < products.length; i++) {
          int productId = products[i]['id'];
          if (nmIds.contains(productId)) {
            final log = products[i]['log'];
            int? advPosition;
            int? advCpm;
            if (log != null) {
              advPosition = log['position'];
              advCpm = log['cpm'];
            }

            final geoSearch = GeoSearchModel(
                nmId: productId,
                position: secondPage ? i + 100 : i,
                advCpm: advCpm,
                advPosition: advPosition);
            idToIndexMap[productId] = geoSearch;
          }
        }
        return right(idToIndexMap);
      } else {
        return left(RewildError(
          sendToTg: false,
          GeoSearchApiHelper.search
              .errResponse(statusCode: response.statusCode),
          source: 'GeoApiClient',
          name: 'getProductsNmIdIndexMapIn',
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: false,
        "Неизвестная ошибка: $e",
        source: 'GeoApiClient',
        name: 'getProductsNmIdIndexMapIn',
        args: [],
      ));
    }
  }

  static Future<Either<RewildError, Map<int, int>>>
      getProductsNmIdIndexMapWithGeoInBg(
          {required String gNum,
          required String query,
          required List<int> nmIds,
          bool secondPage = false}) async {
    final encodedQuery = Uri.encodeComponent(query.trim());

    final Map<String, String> customHeaders = {
      ...headers,
      'x-queryid': 'qid${DateTime.now().millisecondsSinceEpoch}',
      'referer':
          'https://www.wildberries.ru/catalog/0/search.aspx?search=$encodedQuery',
    };
    Uri uri = Uri.parse(
        '$baseUrl?ab_testing=false&appType=64&curr=rub&dest=$gNum&query=$encodedQuery&resultset=catalog&sort=popular&spp=30&suppressSpellcheck=false');
    if (secondPage) {
      uri = Uri.parse(
          '$baseUrl?page=2&ab_testing=false&appType=64&curr=rub&dest=$gNum&query=$encodedQuery&resultset=catalog&sort=popular&spp=30&suppressSpellcheck=false');
    }
    try {
      var response = await http.get(uri, headers: customHeaders);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> products = data['data']['products'];
        if (products.isEmpty || products.length == 1) {
          return left(RewildError(
            sendToTg: false,
            'По вашему запросу ничего не найдено $secondPage',
            source: 'GeoApiClient',
            name: 'getProductsNmIdIndexMapWithGeoInBg',
            args: [],
          ));
        }

        Map<int, int> idToIndexMap = {};
        for (var i = 0; i < products.length; i++) {
          int productId = products[i]['id'];
          if (nmIds.contains(productId)) {
            idToIndexMap[productId] = secondPage ? i + 100 : i;
          }
        }
        return right(idToIndexMap);
      } else {
        return left(RewildError(
          sendToTg: false,
          GeoSearchApiHelper.search
              .errResponse(statusCode: response.statusCode),
          source: 'GeoApiClient',
          name: 'getProductsNmIdIndexMapWithGeoInBg',
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: false,
        "Неизвестная ошибка: $e",
        source: 'GeoApiClient',
        name: 'getProductsNmIdIndexMapWithGeoInBg',
        args: [],
      ));
    }
  }

  static Future<Either<RewildError, Map<int, int>>> getProductsNmIdIndexMapInBg(
      {required String query,
      required List<int> nmIds,
      bool secondPage = false}) async {
    final encodedQuery = Uri.encodeComponent(query.trim());

    final Map<String, String> customHeaders = {
      ...headers,
      'x-queryid': 'qid${DateTime.now().millisecondsSinceEpoch}',
      'referer':
          'https://www.wildberries.ru/catalog/0/search.aspx?search=$encodedQuery',
    };
    Uri uri = Uri.parse(
        '$baseUrl?ab_testing=false&appType=64&curr=rub&dest=-1257786&query=$encodedQuery&resultset=catalog&sort=popular&spp=30&suppressSpellcheck=false');
    if (secondPage) {
      uri = Uri.parse(
          '$baseUrl?page=2&ab_testing=false&appType=64&curr=rub&dest=-1257786&query=$encodedQuery&resultset=catalog&sort=popular&spp=30&suppressSpellcheck=false');
    }

    try {
      var response = await http.get(uri, headers: customHeaders);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> products = data['data']['products'];
        if (products.isEmpty || products.length == 1) {
          return left(RewildError(
            sendToTg: false,
            'По вашему запросу ничего не найдено $secondPage',
            source: 'GeoApiClient',
            name: 'getProductsNmIdIndexMapWithGeoInBg',
            args: [],
          ));
        }
        Map<int, int> idToIndexMap = {};
        for (var i = 0; i < products.length; i++) {
          int productId = products[i]['id'];
          if (nmIds.contains(productId)) {
            idToIndexMap[productId] = secondPage ? i + 100 : i;
          }
        }
        return right(idToIndexMap);
      } else {
        return left(RewildError(
          sendToTg: false,
          GeoSearchApiHelper.search
              .errResponse(statusCode: response.statusCode),
          source: 'GeoApiClient',
          name: 'getProductsNmIdIndexMapWithGeoInBg',
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: false,
        "Неизвестная ошибка: $e",
        source: 'GeoApiClient',
        name: 'getProducts',
        args: [],
      ));
    }
  }
}
