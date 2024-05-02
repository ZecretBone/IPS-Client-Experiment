import 'package:flutter/material.dart';

typedef CallbackSetTimer = void Function(int x, int y);

class TimerForm extends StatefulWidget {
  const TimerForm({
    Key? key,
    required this.onTimerChanged,
  }) : super(key: key);

  final CallbackSetTimer onTimerChanged;

  @override
  _TimerFormState createState() => _TimerFormState();
}

class _TimerFormState extends State<TimerForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _timerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          customTimerForm(),
        ],
      ),
    );
  }

  // Widget customTimerForm() => Container(
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Row(
  //         children: [
  //           const SizedBox(width: 10),
  //           const Icon(Icons.access_time),
  //           const SizedBox(width: 10),
  //           Flexible(
  //             child: TextFormField(
  //               controller: _intervalController,
  //               keyboardType: TextInputType.numberWithOptions(decimal: false),
  //               decoration: const InputDecoration(
  //                 border: InputBorder.none,
  //                 hintText: 'Polling Interval/Timeout (Sec)',
  //               ),
  //               validator: (String? value) {
  //                 return (value!.isEmpty) ? 'X Coor' : null;
  //               },
  //             ),
  //           ),
  //           Flexible(
  //             child: TextFormField(
  //               controller: _timerController,
  //               keyboardType: TextInputType.numberWithOptions(decimal: false),
  //               decoration: const InputDecoration(
  //                 border: InputBorder.none,
  //                 hintText: 'Record Limit',
  //               ),
  //               validator: (String? value) {
  //                 return (value!.isEmpty) ? 'Y Coor' : null;
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     );

  Widget customTimerForm() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 10),
                const Icon(Icons.access_time),
                const SizedBox(width: 10),
                Flexible(
                  child: TextFormField(
                    controller: _intervalController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: false),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Polling Interval (Sec/Rec)',
                    ),
                    validator: (String? value) {
                      return (value!.isEmpty) ? '3' : null;
                    },
                  ),
                ),
              ],
            ),
            Divider(), // Adding a separating line
            Row(
              children: [
                const SizedBox(width: 10),
                // Changing the icon for the record limit
                const Icon(Icons.fact_check),
                const SizedBox(width: 10),
                Flexible(
                  child: TextFormField(
                    controller: _timerController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: false),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Record Limit',
                    ),
                    validator: (String? value) {
                      return (value!.isEmpty) ? '1' : null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  @override
  void dispose() {
    _intervalController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _intervalController.addListener(_onTextChanged);
    _timerController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onTimerChanged(int.tryParse(_intervalController.text) ?? 1,
        int.tryParse(_timerController.text) ?? 15);
  }
}
