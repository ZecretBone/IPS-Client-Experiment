import 'package:flutter/material.dart';

typedef CallbackPressed = void Function();

class CustomButton0 extends StatelessWidget {
  final CallbackPressed onPressed;

  const CustomButton0({
    super.key,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xff64b483),
            Color(0xff1D9375),
          ]
        )
      ),
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text('Scan & Send',style: TextStyle(fontSize: 20)),
      ),
    );
  }
}