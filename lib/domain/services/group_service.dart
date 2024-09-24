import 'package:rewild_bot_front/presentation/products/cards/add_group_screen/add_group_screen_view_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/group_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/all_cards_screen_view_model.dart';

abstract class GroupServiceGroupDataProvider {
  Future<Either<RewildError, GroupModel?>> get({required String name});
  Future<Either<RewildError, int>> insert({required GroupModel group});
  Future<Either<RewildError, List<GroupModel>?>> getAll([List<int>? nmIds]);
  Future<Either<RewildError, void>> delete({required String name, int? nmId});
  Future<Either<RewildError, void>> renameGroup(
      {required String groupName, required String newGroupName});
}

class GroupService
    implements AllCardsScreenGroupsService, AddGroupScreenGroupsService {
  final GroupServiceGroupDataProvider groupDataProvider;

  int _groupsCount = 0;
  void _setGroupsCount(int count) {
    _groupsCount = count;
  }

  int groupsCount() => _groupsCount;

  GroupService({required this.groupDataProvider});
  Future<Either<RewildError, void>> add(
      {required List<GroupModel> groups,
      required List<int> productsCardsNmIds}) async {
    for (final group in groups) {
      final responseEither = await groupDataProvider.insert(
          group: GroupModel(
              name: group.name,
              bgColor: group.bgColor,
              fontColor: group.fontColor,
              cardsNmIds: productsCardsNmIds));
      if (responseEither.isLeft()) {
        return responseEither.fold((l) => left(l), (r) => right(null));
      }
    }

    return right(null);
  }

  @override
  Future<Either<RewildError, List<GroupModel>?>> getAll(
      [List<int>? nmIds]) async {
    final resource = await groupDataProvider.getAll(nmIds);
    if (resource.isLeft()) {
      return resource.fold((l) => left(l), (r) => right(r));
    }

    final groups =
        resource.fold((l) => throw UnimplementedError(), (r) => r ?? []);
    _setGroupsCount(groups.length);
    return right(groups);
  }

  Future<Either<RewildError, GroupModel?>> loadGroup(
      {required String name}) async {
    return await groupDataProvider.get(name: name);
  }

  Future<Either<RewildError, void>> delete(
      {required String groupName, required int nmId}) {
    return groupDataProvider.delete(name: groupName, nmId: nmId);
  }

  Future<Either<RewildError, void>> deleteGroup({required String groupName}) {
    return groupDataProvider.delete(name: groupName);
  }

  Future<Either<RewildError, void>> renameGroup(
      {required String groupName, required String newGroupName}) {
    return groupDataProvider.renameGroup(
        groupName: groupName, newGroupName: newGroupName);
  }
}
