import 'package:flutter/material.dart';

typedef CallbackSetEeid = void Function(String eeid);

class UserFormForSavingID extends StatefulWidget {
  const UserFormForSavingID({super.key, required this.onSaved});

  final CallbackSetEeid onSaved;

  @override
  State<UserFormForSavingID> createState() => _UserFormForSavingIDState();
}

class _UserFormForSavingIDState extends State<UserFormForSavingID> {
  final _formKey = GlobalKey<FormState>();

  Widget customEeidForm() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.person),
            const SizedBox(width: 10),
            Flexible(
              child: TextFormField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Device Nickname (Any)',
                ),
                validator: (String? value) {
                  return (value!.isEmpty) ? 'Please fill your ID' : null;
                },
                onSaved: (String? value) => widget.onSaved(value!),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xff64b483),
                        Color(0xff1D9375),
                      ])),
              child: IconButton(
                onPressed: () => _formKey.currentState?.save(),
                icon: const Icon(Icons.add),
                color: Colors.white,
                iconSize: 30,
              ),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          customEeidForm(),
        ],
      ),
    );
  }
}
