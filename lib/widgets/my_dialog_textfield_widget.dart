import 'package:rewild_bot_front/core/constants/numeric_constance.dart';
import 'package:flutter/material.dart';

class MyDialogTextField extends StatefulWidget {
  const MyDialogTextField(
      {super.key,
      required this.addGroup,
      required this.header,
      required this.description,
      this.keyboardType,
      required this.hint,
      required this.btnText,
      required this.validator});

  final void Function(String value) addGroup;
  final bool Function(String name, int value) validator;
  final String header;
  final String description;
  final String hint;
  final String btnText;
  final TextInputType? keyboardType;

  @override
  State<MyDialogTextField> createState() => _MyDialogTextFieldState();
}

class _MyDialogTextFieldState extends State<MyDialogTextField> {
  bool isValid = true;
  @override
  Widget build(BuildContext context) {
    String newGroupName = "";
    return AlertDialog(
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
        height: MediaQuery.of(context).size.height * 0.15,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.07,
              child: TextField(
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                  hintText: widget.hint,
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
                  newGroupName = value;
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isValid = widget.validator(
                      newGroupName, NumericConstants.minCpmValue);
                });

                if (isValid) {
                  widget.addGroup(newGroupName);
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
            )
          ],
        ),
      ),
    );
  }
}
