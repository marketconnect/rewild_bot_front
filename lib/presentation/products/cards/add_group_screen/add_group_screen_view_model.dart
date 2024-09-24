import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/core/color.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/group_model.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:fpdart/fpdart.dart';

import 'package:flutter/material.dart';

abstract class AddGroupScreenGroupsService {
  Future<Either<RewildError, List<GroupModel>?>> getAll([List<int>? nmIds]);
  Future<Either<RewildError, void>> add(
      {required List<GroupModel> groups,
      required List<int> productsCardsNmIds});
}

class AddGroupScreenViewModel extends ResourceChangeNotifier {
  final AddGroupScreenGroupsService groupsProvider;

  final List<int> productsCardsIds;
  AddGroupScreenViewModel({
    required super.context,
    required this.groupsProvider,
    required this.productsCardsIds,
  }) {
    asyncInit();
  }

  Future<void> asyncInit() async {
    final groupsResource = await fetch(() => groupsProvider.getAll());
    if (groupsResource == null) {
      return;
    }

    _groups = groupsResource;
    notify();
  }

  List<GroupModel> _groups = [];
  List<GroupModel> get groups => _groups;

  void addGroup(String newGroupName) async {
    if (newGroupName == "") {
      return;
    }
    debugPrint(newGroupName);
    newGroupName = newGroupName.trim();
    final generatedColors = ColorsConstants.getColorsPair(groups.length);
    GroupModel newGroup = GroupModel(
        name: newGroupName,
        bgColor: generatedColors.backgroundColor.value,
        cardsNmIds: [],
        fontColor: generatedColors.fontColor.value);
    if (groups.where((element) => element.name == newGroup.name).isNotEmpty) {
      return;
    }
    groups.add(newGroup);
    _selectedGroupsNames.add(newGroupName);
    // await groupsProvider.addGroup(newGroup);

    notify();
  }

  final List<String> _selectedGroupsNames = [];
  List<String> get selectedGroupsNames => _selectedGroupsNames;

  void selectGroup(String name) {
    _selectedGroupsNames.contains(name)
        ? _selectedGroupsNames.remove(name)
        : _selectedGroupsNames.add(name);
    notify();
  }

  void save() async {
    if (selectedGroupsNames.isNotEmpty) {
      final groupsToAdd = _groups.where((element) {
        return selectedGroupsNames.contains(element.name);
      }).toList();
      await groupsProvider.add(
          groups: groupsToAdd, productsCardsNmIds: productsCardsIds);
    }

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(
        MainNavigationRouteNames.allCardsScreen,
      );
    }
  }
}
