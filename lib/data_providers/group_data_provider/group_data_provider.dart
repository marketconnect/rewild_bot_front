import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/group_model.dart';
import 'package:rewild_bot_front/domain/services/group_service.dart';

class GroupDataProvider implements GroupServiceGroupDataProvider {
  const GroupDataProvider();

  Box<GroupModel> get _box => Hive.box<GroupModel>(HiveBoxes.groups);

  @override
  Future<Either<RewildError, int>> insert({required GroupModel group}) async {
    try {
      await _box.put(group.id, group);
      return right(group.id);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось вставить группу: $e',
        source: runtimeType.toString(),
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
      final group = _box.values.firstWhere((g) => g.name == groupName);
      final updatedGroup = group.copyWith(name: newGroupName);
      await _box.put(updatedGroup.id, updatedGroup);
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось переименовать группу: $e',
        source: runtimeType.toString(),
        name: "renameGroup",
        args: [groupName, newGroupName],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> delete({
    required String name,
    int? nmId,
  }) async {
    try {
      final group = _box.values.firstWhere((g) => g.name == name);
      if (nmId != null) {
        group.cardsNmIds.remove(nmId);
        await group.save();
      } else {
        await _box.delete(group.id);
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось удалить группу: $e',
        source: runtimeType.toString(),
        name: "delete",
        args: [name, nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, GroupModel?>> get({required String name}) async {
    try {
      final group = _box.values.firstWhere((g) => g.name == name);
      return right(group);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось получить группу: $e',
        source: runtimeType.toString(),
        name: "get",
        args: [name],
      ));
    }
  }

  Future<Either<RewildError, int>> update(GroupModel group) async {
    try {
      await _box.put(group.id, group);
      return right(group.id);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось обновить группу: $e',
        source: runtimeType.toString(),
        name: "update",
        args: [group],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<GroupModel>?>> getAll(
      [List<int>? nmIds]) async {
    try {
      final groups = nmIds != null
          ? _box.values.where((g) => g.cardsNmIds.any(nmIds.contains)).toList()
          : _box.values.toList();

      return right(groups.isEmpty ? null : groups);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось получить все группы: $e',
        source: runtimeType.toString(),
        name: "getAll",
        args: [nmIds],
      ));
    }
  }
}
