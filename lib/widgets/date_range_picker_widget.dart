import 'package:flutter/material.dart';

class DateRangePickerWidget extends StatefulWidget {
  final Function(DateTime? start, DateTime? end) onDateRangeSelected;
  final DateTimeRange? initDateTimeRange;
  final bool centerBtn;
  final String btnText;

  final DateTime? firstAllowable;
  final DateTime? lastAllowable;

  const DateRangePickerWidget({
    super.key,
    required this.onDateRangeSelected,
    required this.btnText,
    this.centerBtn = false,
    this.initDateTimeRange,
    this.firstAllowable,
    this.lastAllowable,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DateRangePickerWidgetState createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.centerBtn)
          SizedBox(height: MediaQuery.of(context).size.height * 0.35),
        Center(
          child: TextButton(
            onPressed: () => _pickDateRange(context),
            child: Text(
              widget.btnText,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: widget.firstAllowable ?? DateTime(DateTime.now().year - 5),
      lastDate:
          widget.lastAllowable ?? DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked.start != picked.end) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      widget.onDateRangeSelected(_startDate, _endDate);
    }
  }
}
