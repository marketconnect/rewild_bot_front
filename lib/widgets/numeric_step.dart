import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rewild_bot_front/core/utils/nums.dart';

class NumericStepButton extends StatefulWidget {
  final num currentValue;
  final ValueChanged<num> onChanged;
  final num? minValue;
  final num? maxValue;
  final bool asDouble;

  const NumericStepButton({
    super.key,
    this.minValue,
    this.maxValue,
    this.asDouble = false,
    required this.onChanged,
    required this.currentValue,
  });

  @override
  State<NumericStepButton> createState() => _NumericStepButtonState();
}

class _NumericStepButtonState extends State<NumericStepButton> {
  late num counter;
  bool longPressEnd = false;
  late bool asDouble;
  @override
  void initState() {
    super.initState();
    counter = widget.currentValue;
    asDouble = widget.asDouble;
  }

  void _showNumberInputDialogue() {
    final TextEditingController numberInputController =
        TextEditingController(text: counter.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Введите число'),
          content: TextField(
            controller: numberInputController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Введите значение'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                final String enteredText = numberInputController.text;
                num? enteredNumber;
                final t = checkNumberType(enteredText);

                if (t == 0) {
                  enteredNumber = int.tryParse(enteredText);
                } else if (t == 1) {
                  enteredNumber = double.tryParse(enteredText);
                } else {
                  return;
                }

                if (enteredNumber != null &&
                    (widget.minValue == null ||
                        enteredNumber >= widget.minValue!) &&
                    (widget.maxValue == null ||
                        enteredNumber <= widget.maxValue!)) {
                  setState(() {
                    counter = enteredNumber!;
                    widget.onChanged(counter);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _changeCounter(num delta) {
    if (longPressEnd) {
      return;
    }

    setState(() {
      counter += delta;
      if (widget.maxValue != null && counter >= widget.maxValue!) {
        counter = widget.maxValue!;
      } else if (widget.minValue != null && counter <= widget.minValue!) {
        counter = widget.minValue!;
      }

      widget.onChanged(counter);
    });
  }

  void _increase() {
    final num delta = asDouble ? 0.1 : 1;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (longPressEnd ||
          !mounted ||
          counter >= (widget.maxValue ?? double.infinity)) {
        timer.cancel();
        return;
      }
      _changeCounter(delta);
    });
  }

  void _decrease() {
    final num delta = asDouble ? -0.1 : -1;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (longPressEnd ||
          !mounted ||
          counter <= (widget.minValue ?? double.negativeInfinity)) {
        timer.cancel();
        return;
      }
      _changeCounter(delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              // minus ==================================
              onTap: () {
                longPressEnd = false;
                setState(() {
                  if (widget.minValue != null && counter <= widget.minValue!) {
                    counter = widget.minValue!;
                    return;
                  }
                  if (counter <= 0) {
                    counter = 0;
                    return;
                  }
                  if (asDouble) {
                    counter -= 0.1;
                  } else {
                    counter--;
                  }
                  widget.onChanged(counter);
                });
              },
              onLongPress: () {
                _decrease();
              },
              onLongPressEnd: (details) {
                longPressEnd = true;
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                  color: Colors.transparent,
                )),
                child: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  child: Container(
                    width: screenWidth * 0.07,
                    height: screenWidth * 0.07,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      Icons.remove,
                      size: screenWidth * 0.05,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _showNumberInputDialogue,
              child: Text(
                counter is int
                    ? counter.toString()
                    : counter.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onLongPress: () {
                longPressEnd = false;
                _increase();
              },
              onLongPressEnd: (details) {
                longPressEnd = true;
              },
              onTap: () {
                setState(() {
                  if (asDouble) {
                    counter += 0.1;
                  } else {
                    counter++;
                  }
                  widget.onChanged(counter);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                  color: Colors.transparent,
                )),
                child: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  child: Container(
                    width: screenWidth * 0.07,
                    height: screenWidth * 0.07,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      Icons.add,
                      size: screenWidth * 0.05,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
