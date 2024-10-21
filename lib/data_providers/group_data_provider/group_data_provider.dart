import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/group_model.dart';
import 'package:rewild_bot_front/domain/services/group_service.dart';

class GroupDataProvider implements GroupServiceGroupDataProvider {
  const GroupDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, int>> insert({required GroupModel group}) async {
    try {
      final db = await _db;
      final txn = db.transaction('groups', idbModeReadWrite);
      final store = txn.objectStore('groups');

      for (final nmId in group.cardsNmIds) {
        await store.put({
          'name': group.name,
          'bgColor': group.bgColor,
          'fontColor': group.fontColor,
          'nmId': nmId,
          "nmId_name": '${nmId}_${group.name}'
        });
      }

      await txn.completed;
      return right(group.cardsNmIds.length);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "GroupDataProvider",
        name: "insert",
        args: [group],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> renameGroup({
    required String groupName,
    required String newGroupName,
  }) async {
    try {
      final db = await _db;

      // Открываем транзакцию для чтения и записи
      final txn = db.transaction('groups', idbModeReadWrite);
      final store = txn.objectStore('groups');
      final index = store.index('name');

      // Получаем все записи и ключи с именем groupName
      final records = await index.getAll(groupName);
      final keys = await index.getAllKeys(groupName);

      // Удаляем старые записи и вставляем новые
      for (int i = 0; i < records.length; i++) {
        final value = records[i] as Map<String, dynamic>;
        final oldKey = keys[i];

        // Удаляем старую запись
        await store.delete(oldKey);

        // Обновляем данные
        value['name'] = newGroupName;
        value['nmId_name'] = '${value['nmId']}_$newGroupName';

        // Вставляем новую запись
        await store.put(value);
      }

      await txn.completed;

      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: 'GroupDataProvider',
        name: 'renameGroup',
        args: [groupName, newGroupName],
      ));
    }
  }

  @override
  @override
  Future<Either<RewildError, void>> delete({
    required String name,
    int? nmId,
  }) async {
    try {
      final db = await _db;

      if (nmId != null) {
        // Если указан nmId, удаляем конкретную запись
        final txn = db.transaction('groups', idbModeReadWrite);
        final store = txn.objectStore('groups');
        final key = '${nmId}_$name';
        await store.delete(key);
        await txn.completed;
      } else {
        // Если nmId не указан, удаляем все записи с заданным именем группы

        // Сначала собираем все ключи для удаления, используя транзакцию только для чтения
        final readTxn = db.transaction('groups', idbModeReadOnly);
        final store = readTxn.objectStore('groups');
        final index = store.index('name');

        final keys = await index.getAllKeys(name);
        await readTxn.completed;

        if (keys.isNotEmpty) {
          // Открываем транзакцию для записи и удаляем записи по ключам
          final writeTxn = db.transaction('groups', idbModeReadWrite);
          final writeStore = writeTxn.objectStore('groups');

          for (final key in keys) {
            await writeStore.delete(key);
          }

          await writeTxn.completed;
        }
      }

      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: 'GroupDataProvider',
        name: 'delete',
        args: [name, nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, GroupModel?>> get({required String name}) async {
    try {
      final db = await _db;
      final txn = db.transaction('groups', idbModeReadOnly);
      final store = txn.objectStore('groups');
      final index = store.index('name');
      final cursorStream = index.openCursor(range: KeyRange.only(name));

      int? bgColor;
      int? fontColor;
      List<int> nmIds = [];

      await for (final cursor in cursorStream) {
        final value = cursor.value as Map<String, dynamic>;
        if (bgColor == null) {
          bgColor = value['bgColor'] as int;
          fontColor = value['fontColor'] as int;
        }
        nmIds.add(value['nmId'] as int);
      }

      await txn.completed;

      if (nmIds.isEmpty) {
        return right(null);
      }

      return right(GroupModel(
        name: name,
        bgColor: bgColor!,
        fontColor: fontColor!,
        cardsNmIds: nmIds,
      ));
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "GroupDataProvider",
        name: "get",
        args: [name],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<GroupModel>?>> getAll(
      [List<int>? nmIds]) async {
    try {
      final db = await _db;
      final txn = db.transaction('groups', idbModeReadOnly);
      final store = txn.objectStore('groups');
      List<GroupModel> resultGroups = [];

      List<Map<String, dynamic>> groups = [];

      if (nmIds != null) {
        for (final nmId in nmIds) {
          final index = store.index('nmId');
          final cursorStream = index.openCursor(range: KeyRange.only(nmId));

          await for (final cursor in cursorStream) {
            final value = cursor.value as Map<String, dynamic>;
            groups.add(value);
          }
        }
      } else {
        final result = await store.getAll();
        groups = result.map((e) => e as Map<String, dynamic>).toList();
      }

      if (groups.isEmpty) {
        return right(null);
      }

      final groupsNames =
          groups.map((group) => group['name'] as String).toSet().toList();

      for (final groupName in groupsNames) {
        final groupMapsList =
            groups.where((e) => e['name'] == groupName).toList();

        String? name;
        int? bgColor;
        int? fontColor;
        List<int> nmIds = [];
        for (final group in groupMapsList) {
          if (name == null) {
            name = group['name'] as String;
            bgColor = group['bgColor'] as int;
            fontColor = group['fontColor'] as int;
          }
          nmIds.add(group['nmId'] as int);
        }

        resultGroups.add(GroupModel(
          name: name!,
          bgColor: bgColor!,
          fontColor: fontColor!,
          cardsNmIds: nmIds,
        ));
      }

      await txn.completed;
      return right(resultGroups);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "GroupDataProvider",
        name: "getAll",
        args: [nmIds],
      ));
    }
  }
}
