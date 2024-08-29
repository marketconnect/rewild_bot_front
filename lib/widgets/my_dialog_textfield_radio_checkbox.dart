import 'package:flutter/material.dart';
import 'package:rewild_bot_front/core/constants/numeric_constance.dart';
import 'package:rewild_bot_front/core/utils/extensions/strings.dart';

class MyDialogTextFieldRadioCheckBox extends StatefulWidget {
  const MyDialogTextFieldRadioCheckBox(
      {super.key,
      required this.addGroup,
      required this.header,
      required this.description,
      this.keyboardType,
      required this.btnText,
      required this.radioOptions,
      required this.textInputOptions,
      required this.checkBoxOptions,
      required this.validator});

  final Future<void> Function(
      {required String value,
      required int option,
      required int option1}) addGroup;
  final bool Function(String name, int value) validator;
  final String header;
  final String description;
  // final String hint;
  final String btnText;
  final TextInputType? keyboardType;
  final Map<int, String> radioOptions;
  final Map<int, String> checkBoxOptions;
  final Map<int, String> textInputOptions;

  @override
  State<MyDialogTextFieldRadioCheckBox> createState() =>
      _MyDialogTextFieldRadioCheckBoxState();
}

class _MyDialogTextFieldRadioCheckBoxState
    extends State<MyDialogTextFieldRadioCheckBox> {
  String newGroupName = "";
  late int selectedOption;
  late int selectedInstrument;
  bool checkBoxValue = false;
  bool isValid = true;
  @override
  void initState() {
    super.initState();
    // Set the initially selected option to the first one in the map
    selectedOption = widget.radioOptions.keys.first;
    selectedInstrument = widget.checkBoxOptions.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      buttonPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.all(0),
      contentPadding: EdgeInsets.zero,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: Icon(
                    Icons.close,
                    size: MediaQuery.of(context).size.width * 0.07,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.header,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.065),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.5),
                      fontSize: MediaQuery.of(context).size.width * 0.05),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
                child: TextField(
                  keyboardType: widget.keyboardType,
                  decoration: InputDecoration(
                    hintText:
                        widget.textInputOptions[selectedOption].toString(),
                    hintStyle: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.3)),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.02,
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                          color: isValid
                              ? Colors.grey
                              : Theme.of(context).colorScheme.error,
                          width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                          color: isValid
                              ? Colors.grey
                              : Theme.of(context).colorScheme.error,
                          width: 0.0),
                    ),
                  ),
                  cursorColor: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.3),
                  onChanged: (value) {
                    setState(() {
                      newGroupName = value;
                    });
                  },
                ),
              ),
              // Radio buttons for selecting options
              Column(
                children: widget.radioOptions.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.value),
                    leading: Radio(
                      value: entry.key,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.05,
                  ),
                  Text(
                    'Название предметной группы',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              Column(
                children: widget.checkBoxOptions.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.value.capitalize()),
                    leading: Radio(
                      value: entry.key,
                      groupValue: selectedInstrument,
                      onChanged: (int? value) {
                        setState(() {
                          selectedInstrument = value!;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isValid = widget.validator(
                        newGroupName, NumericConstants.minCpmValue);
                  });

                  if (isValid) {
                    widget.addGroup(
                        value: newGroupName,
                        option: selectedOption,
                        option1: selectedInstrument);
                    FocusScope.of(context).requestFocus(FocusNode());
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.08,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5))),
                  child: Text(widget.btnText,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
