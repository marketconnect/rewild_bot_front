import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rewild_bot_front/core/utils/text_filed_validator.dart';
import 'package:rewild_bot_front/presentation/products/cards/add_group_screen/add_group_screen_view_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/widgets/empty_widget.dart';
import 'package:rewild_bot_front/widgets/my_dialog_textfield_widget.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddGroupDialog(AddGroupScreenViewModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyDialogTextField(
          header: "Название группы",
          hint: "Введите название",
          addGroup: model.addGroup,
          validator: TextFieldValidator.isNotEmpty,
          btnText: "Добавить",
          description: "Группа объединит карточки товаров",
          keyboardType: TextInputType.name,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AddGroupScreenViewModel>();
    final save = model.save;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Добавить в группы',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                MainNavigationRouteNames.allCardsScreen,
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.done, color: Colors.green),
              onPressed: save,
              tooltip: 'Сохранить',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddGroupDialog(model),
          tooltip: 'Добавить новую группу',
          child: const Icon(Icons.add),
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AddGroupScreenViewModel>();
    final groups = model.groups;
    final selectedGroups = model.selectedGroupsNames;
    final selectGroup = model.selectGroup;

    if (groups.isEmpty) {
      return const EmptyWidget(
        text: 'Нет доступных групп. Пожалуйста, добавьте.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemCount: groups.length,
      itemBuilder: (BuildContext context, int index) {
        final group = groups[index];
        final isSelected = selectedGroups.contains(group.name);

        return GestureDetector(
          onTap: () {
            selectGroup(group.name);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              leading: CircleAvatar(
                backgroundColor: Color(group.bgColor),
                child: Text(
                  group.name[0].toUpperCase(),
                  style: TextStyle(color: Color(group.fontColor)),
                ),
              ),
              title: Text(
                group.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              trailing: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: isSelected
                    ? Icon(Icons.check_circle,
                        key: const ValueKey('selected'),
                        color: Theme.of(context).colorScheme.primary)
                    : Icon(Icons.radio_button_unchecked,
                        key: const ValueKey('unselected'),
                        color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ),
        );
      },
    );
  }
}
