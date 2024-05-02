import 'package:flutter/material.dart';

typedef CallbackToggleMode = void Function(List<bool> mode);

class CustomToggleButton0 extends StatefulWidget {
  const CustomToggleButton0({super.key, required this.onToggle});

  final CallbackToggleMode onToggle;

  @override
  State<CustomToggleButton0> createState() => _CustomToggleButton0State();
}

class _CustomToggleButton0State extends State<CustomToggleButton0> {
  List<bool> scanMode = [true, false, false];

  void toggleMode(int currentIndex) {
    setState(() {
      for (int i = 0; i < scanMode.length; i++) {
        if (i == currentIndex) {
          scanMode[i] = true;
        } else {
          scanMode[i] = false;
        }
      }
    });
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
              ])),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
            builder: (context, constraints) => ToggleButtons(
                    constraints: BoxConstraints.expand(
                        width: (constraints.maxWidth / 3) - 3),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    isSelected: scanMode,
                    selectedColor: Colors.black,
                    fillColor: Colors.white,
                    borderColor: Colors.transparent,
                    onPressed: (int currentIndex) {
                      toggleMode(currentIndex);
                      widget.onToggle(scanMode);
                    },
                    children: const [
                      Text('Single',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Continuous',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Custom',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))
                    ])),
      ),
    );
  }
}
