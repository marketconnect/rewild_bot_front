import 'package:rewild_bot_front/widgets/empty_widget.dart';
import 'package:rewild_bot_front/core/utils/text_filed_validator.dart';
import 'package:rewild_bot_front/widgets/my_dialog_textfield_widget.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/presentation/products/cards/add_group_screen/add_group_screen_view_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AddGroupScreenViewModel>();
    final addGroup = model.addGroup;
    final save = model.save;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Добавить в группы',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1f1f1f),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.done, color: Colors.green),
              onPressed: save,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  MainNavigationRouteNames.allCardsScreen,
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return MyDialogTextField(
                header: "Название группы",
                hint: "Введите название",
                addGroup: addGroup,
                validator: TextFieldValidator.isNotEmpty,
                btnText: "Добавить",
                description: "Группа объединит карточки товаров",
                keyboardType: TextInputType.name,
              );
            },
          ),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, size: 28),
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

    return groups.isEmpty
        ? const EmptyWidget(text: 'Нет доступных групп. Пожалуйста, добавьте.')
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(
                        groups[index].name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: selectedGroups.contains(groups[index].name)
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                      ),
                      trailing: Checkbox(
                        value: selectedGroups.contains(groups[index].name),
                        onChanged: (_) {
                          selectGroup(groups[index].name);
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
