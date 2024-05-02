import 'package:flutter/material.dart';

typedef CallbackToggle2Mode = void Function(int modeIndex);

class CustomToggle2Button extends StatefulWidget {
  const CustomToggle2Button({
    Key? key,
    required this.onToggle,
  }) : super(key: key);

  final CallbackToggle2Mode onToggle;

  @override
  State<CustomToggle2Button> createState() => _CustomToggle2ButtonState();
}

class _CustomToggle2ButtonState extends State<CustomToggle2Button> {
  int selectedMode = 0; // 0: Default, 1: Timer, 2: Custom

  void toggle2Mode(int modeIndex) {
    setState(() {
      selectedMode = modeIndex;
    });
    widget.onToggle(modeIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xff64b483),
            Color(0xff1D9375),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ToggleButtons(
          constraints: const BoxConstraints.expand(width: 150),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          isSelected: List.generate(3, (index) => index == selectedMode),
          selectedColor: Colors.black,
          fillColor: Colors.white,
          borderColor: Colors.transparent,
          onPressed: (int currentIndex) {
            toggle2Mode(currentIndex);
          },
          children: const [
            Text('Default',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Timer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Custom',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class DefaultModeWidget extends StatelessWidget {
  const DefaultModeWidget({
    Key? key,
    required this.onScanSend,
  }) : super(key: key);

  final VoidCallback onScanSend;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onScanSend,
      child: const Text('Scan & Send'),
    );
  }
}

class TimerModeWidget extends StatelessWidget {
  const TimerModeWidget({
    Key? key,
    required this.onTimeSelect,
    required this.onStartTimer,
  }) : super(key: key);

  final VoidCallback onTimeSelect;
  final VoidCallback onStartTimer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTimeSelect,
          child: const Text('Time Select'),
        ),
        ElevatedButton(
          onPressed: onStartTimer,
          child: const Text('Start Timer'),
        ),
      ],
    );
  }
}

class CustomModeWidget extends StatelessWidget {
  const CustomModeWidget({
    Key? key,
    required this.onStart,
    required this.onStop,
  }) : super(key: key);

  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onStart,
      child: const Text('Start'),
    );
  }
}
