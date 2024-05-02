import 'package:flutter/material.dart';

typedef CallbackRemoveEeid = void Function();

class UserBarWithDeleteButton extends StatefulWidget {
  final String eeid;
  final CallbackRemoveEeid onPressedToRemove;

  const UserBarWithDeleteButton({
    super.key,
    required this.eeid,
    required this.onPressedToRemove
  });

  @override
  State<UserBarWithDeleteButton> createState() => _UserBarWithDeleteButtonState();
}

class _UserBarWithDeleteButtonState extends State<UserBarWithDeleteButton> {

  Widget customUserIcon() => Padding(
    padding: const EdgeInsets.all(5.0),
    child: Container(
      width: 40,
      height: 40,
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
      child: const Icon(
        Icons.person,
        size: 30,
        color: Colors.white,
      ),
    ),
  );

  Widget customEeid(String eeid) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
    child: Text(
      widget.eeid,
      style: const TextStyle(fontSize: 16),
    )
  );

  Widget customRemoveEeidButton() => Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: IconButton(
      onPressed: () => widget.onPressedToRemove(),
      icon: const Icon(
        Icons.cancel_rounded,
        color: Color.fromARGB(255, 187, 81, 81),
        size: 30,
      )
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              customUserIcon(),
              customEeid(widget.eeid),
            ],
          ),
          customRemoveEeidButton()
        ],
      ),
    );
  }
}