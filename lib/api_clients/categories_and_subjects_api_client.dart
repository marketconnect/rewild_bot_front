import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subject_commission_model.dart';
import 'package:rewild_bot_front/domain/services/categories_and_subjects_sevice.dart';

import 'package:rewild_bot_front/env.dart';

class CategoriesAndSubjectsApiClient
    implements CategoriesAndSubjectsServiceApiClient {
  const CategoriesAndSubjectsApiClient();

  @override
  Future<Either<RewildError, List<String>>> getAllCategories({
    required String token,
  }) async {
    final url = Uri.parse('${ServerConstants.apiUrl}/getCategories');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({}), // Empty body if required
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));

        final List<String> categories =
            List<String>.from(decodedResponse['catNames']);
        return right(categories);
      } else if (response.statusCode == 401) {
        return left(RewildError(
          sendToTg: true,
          "Пользователь не авторизован",
          source: "CategoriesAndSubjectsApiClient",
          name: "getAllCategories",
          args: [],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка сервера: ${response.statusCode}",
          source: "CategoriesAndSubjectsApiClient",
          name: "getAllCategories",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: ${e.toString()}",
        source: "CategoriesAndSubjectsApiClient",
        name: "getAllCategories",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubjectCommissionModel>>> getSubjects({
    required String token,
    required List<String> catNames,
  }) async {
    if (catNames.isEmpty) {
      return right([]);
    }

    final url = Uri.parse('${ServerConstants.apiUrl}/getSubjectsForCategories');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
    };

    final body = {
      'categoriesNames': catNames,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
        // Assuming the response has a 'subject' array
        if (decodedResponse['subject'] == null) {
          return right([]);
        }
        final subjectsJson = decodedResponse['subject'] as List<dynamic>;
        final subjects = subjectsJson
            .map((e) =>
                SubjectCommissionModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return right(subjects);
      } else if (response.statusCode == 401) {
        return left(RewildError(
          sendToTg: true,
          "Пользователь не авторизован",
          source: "CategoriesAndSubjectsApiClient",
          name: "getSubjects",
          args: [],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка сервера: ${response.statusCode}",
          source: "CategoriesAndSubjectsApiClient",
          name: "getSubjects",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: ${e.toString()}",
        source: "CategoriesAndSubjectsApiClient",
        name: "getSubjects",
        args: [],
      ));
    }
  }
}
