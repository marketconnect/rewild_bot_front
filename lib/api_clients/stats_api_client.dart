import 'dart:convert';
import 'package:fpdart/fpdart.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subject_model.dart';
import 'package:rewild_bot_front/domain/services/stats_service.dart';
import 'package:rewild_bot_front/env.dart';

class StatsApiClient implements StatsServiceStatsApiClient {
  const StatsApiClient();

  @override
  Future<Either<RewildError, List<SubjectModel>>> getAllSubjects({
    required String token,
    required int take,
    required int skip,
    required List<int> subjectIds,
  }) async {
    final url = Uri.parse('${ServerConstants.apiUrl}/getSubjects');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
    };

    final body = {
      'take': take,
      'skip': skip,
      'subject_ids': subjectIds,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
        if (decodedResponse['subjects'] != null &&
            decodedResponse['subjects'] is List &&
            decodedResponse['subjects'].isNotEmpty) {
          final subjects = (decodedResponse['subjects'] as List)
              .map((subjectJson) => SubjectModel.fromJson(subjectJson))
              .toList();
          return right(subjects);
        } else {
          return right([]);
        }
      } else if (response.statusCode == 401) {
        return left(RewildError(
          sendToTg: true,
          "Пользователь не авторизован",
          source: "StatsApiClient",
          name: "getAllSubjects",
          args: [],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка сервера: ${response.statusCode}",
          source: "StatsApiClient",
          name: "getAllSubjects",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: ${e.toString()}",
        source: "StatsApiClient",
        name: "getAllSubjects",
        args: [],
      ));
    }
  }
}
