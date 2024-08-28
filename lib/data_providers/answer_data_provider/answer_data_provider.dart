import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/services/answer_service.dart';

class AnswerDataProvider implements AnswerServiceAnswerDataProvider {
  const AnswerDataProvider();
  Future<Database> get _db async => await DatabaseHelper().database;
  @override
  Future<Either<RewildError, bool>> delete(
      {required String id, required String type}) async {
    try {
      final db = await _db;
      final transaction = db.transaction('answers', idbModeReadWrite);
      final objectStore = transaction.objectStore('answers');

      await objectStore.delete(id);

      await transaction.completed;
      return right(true);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          e.toString(),
          source: runtimeType.toString(),
          name: "delete",
          args: [id, type]));
    }
  }

  @override
  Future<Either<RewildError, bool>> insert(
      {required String id,
      required String answer,
      required String type}) async {
    try {
      final db = await _db;
      final transaction = db.transaction("answers", idbModeReadWrite);
      final objectStore = transaction.objectStore('answers');

      await objectStore.add({'id': id, 'answer': answer, 'type': type});

      await transaction.completed;
      return right(true);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          e.toString(),
          source: runtimeType.toString(),
          name: "insert",
          args: [id, answer, type]));
    }
  }

  @override
  Future<Either<RewildError, List<String>>> getAllIds({
    required String type,
  }) async {
    try {
      final db = await _db;
      final transaction = db.transaction('answers', idbModeReadOnly);
      final objectStore = transaction.objectStore('answers');

      final result = await objectStore.getAll(type);

      if (result.isEmpty) {
        return right([]);
      }

      // Explicitly cast items to Map<String, dynamic>
      final items = result.cast<Map<String, dynamic>>();

      // Convert the result to a List<String>
      final ids = items.map((item) => item['id'] as String).toList();

      return right(ids);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getAllIds",
        args: [type],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<String>>> getAll(
      {required String type}) async {
    try {
      final db = await _db;
      final transaction = db.transaction('answers', idbModeReadOnly);
      final objectStore = transaction.objectStore('answers');

      final result = await objectStore.getAll(type);

      if (result.isEmpty) {
        return right([]);
      }

      if (result is List<Map<String, dynamic>>) {
        return right(result.map((e) => e['answer'] as String).toList());
      }

      return right([]);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          e.toString(),
          source: runtimeType.toString(),
          name: "getAll",
          args: [type]));
    }
  }
}
