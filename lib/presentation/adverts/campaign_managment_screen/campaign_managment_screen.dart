import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/presentation/adverts/campaign_managment_screen/campaign_managment_view_model.dart';

class Interval {
  DateTime begin;
  DateTime end;

  Interval(this.begin, this.end);
}

class CampaignManagementScreen extends StatefulWidget {
  const CampaignManagementScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CampaignManagementScreenState createState() =>
      _CampaignManagementScreenState();
}

class _CampaignManagementScreenState extends State<CampaignManagementScreen> {
  TextEditingController textFieldController = TextEditingController();
  TextEditingController dialogTextFieldController = TextEditingController();
  @override
  void dispose() {
    textFieldController.dispose();
    dialogTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CampaignManagementViewModel>();
    final searchCpm = model.saerchCpm;
    final catalogCpm = model.cpmCatalog;
    final title = model.title;
    final dialogWidget = model.changeCpmDialog;
    final isLoading = model.isLoading;

    final wasCpmOrBudgetChanged = model.wasStatusOrBudgetChanged;
    // final saveNotification = model.saveNotification;
    final budget = model.budget;
    final setBudget = model.setBudget;

    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              // await saveNotification();

              if (context.mounted) {
                Navigator.of(context).pop(wasCpmOrBudgetChanged);
              }
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          title: Text(title),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusSwitch(),
              const SizedBox(height: 20),
              if (catalogCpm != null)
                _buildValueField(
                    label: 'Текущая ставка в каталоге: ',
                    value: '${catalogCpm.toInt()} ₽',
                    title: 'Введите ставку',
                    dialog: dialogWidget),
              _buildValueField(
                  label: 'Текущая ставка в поиске: ',
                  value: '${searchCpm == null ? 0 : searchCpm.toInt()} ₽',
                  title: 'Введите ставку',
                  dialog: dialogWidget),
              const SizedBox(height: 20),
              _buildValueField(
                  label: 'Бюджет кампании: ',
                  value: '${budget == null ? 0 : budget.toInt()} ₽',
                  onSave: (String value) {
                    setBudget(value);
                  },
                  title: 'Пополнить на сумму'),
              const SizedBox(height: 20),
              // _buildNotifyAboutMinimumBudgetCheckbox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSwitch() {
    final model = context.watch<CampaignManagementViewModel>();
    final isActive = model.isActive;
    final changeAdvertStatus = model.changeAdvertStatus;
    // final setStatus = model.;
    if (isActive == null) {
      return const SizedBox();
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('Статус: ${isActive ? "Активна" : "На паузе"}'),
      trailing: Switch(
        value: isActive,
        onChanged: (value) async {
          await changeAdvertStatus();
          // setStatus(value ? CampaignStatus.active : CampaignStatus.paused);
        },
      ),
    );
  }

  Widget _buildValueField(
      {required String label,
      required String value,
      Function? onSave,
      required String title,
      Widget? dialog}) {
    void showEditDialog() {
      if (dialog != null) {
        showDialog(
          context: context,
          builder: (context) => dialog,
        );
        return;
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: dialogTextFieldController,
              decoration: const InputDecoration(hintText: "Новое значение"),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true), // Если значение числовое
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Сохранить'),
                onPressed: () {
                  if (onSave == null) {
                    return;
                  }
                  onSave(dialogTextFieldController.text);
                  Navigator.pop(context); // Закрыть диалог
                },
              ),
            ],
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          GestureDetector(
            onTap: () {
              textFieldController.text = value.replaceAll(' ₽', '');

              showEditDialog();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildNotifyAboutMinimumBudgetCheckbox() {
  //   final model = context.watch<CampaignManagementViewModel>();
  //   final notifyAboutMinimumBudget = model.notifyAboutMinimumBudget;
  //   final setNotifyAboutMinimumBudget = model.setNotifyAboutMinimumBudget;
  //   final minBudgetLimit = model.minBudgetLimit;
  //   return CheckboxListTile(
  //     title: Text(
  //         "Уведомить, если бюджет менее${minBudgetLimit != null ? ' $minBudgetLimit ₽' : '?'} ",
  //         style: TextStyle(
  //           fontSize: MediaQuery.of(context).size.height * 0.02,
  //         )),
  //     value: notifyAboutMinimumBudget,
  //     onChanged: (bool? value) {
  //       setNotifyAboutMinimumBudget(value!);

  //       if (value) {
  //         _showMinimumBudgetEditDialog();
  //       }
  //     },
  //     controlAffinity: ListTileControlAffinity.leading,
  //   );
  // }

  // void _showMinimumBudgetEditDialog() {
  //   final model = context.read<CampaignManagementViewModel>();
  //   final setMinBudgetLimit = model.setMinBudgetLimit;
  //   final setNotifyAboutMinimumBudget = model.setNotifyAboutMinimumBudget;
  //   TextEditingController textFieldController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Введите минимальный бюджет'),
  //         content: TextField(
  //           controller: textFieldController,
  //           decoration: const InputDecoration(hintText: "Минимальный бюджет"),
  //           keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Отмена'),
  //             onPressed: () {
  //               setNotifyAboutMinimumBudget(false);
  //               Navigator.pop(context);
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Сохранить'),
  //             onPressed: () {
  //               setMinBudgetLimit(int.parse(textFieldController.text));
  //               Navigator.pop(context);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
