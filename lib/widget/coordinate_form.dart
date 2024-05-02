// import 'package:flutter/material.dart';

// typedef CallbackSetCoordinates = void Function(double x, double y, double z);
// typedef CallbackChangeCoordinate = void Function(String axis, String value);

// class CoordinateForm extends StatefulWidget {
//   const CoordinateForm({
//     Key? key,
//     required this.onCoordinatesChanged,
//     required this.changeCoordinate,
//     required this.xController,
//     required this.yController,
//     required this.zController,
//   }) : super(key: key);

//   final CallbackSetCoordinates onCoordinatesChanged;
//   final CallbackChangeCoordinate changeCoordinate;
//   final TextEditingController xController;
//   final TextEditingController yController;
//   final TextEditingController zController;

//   @override
//   _CoordinateFormState createState() => _CoordinateFormState();
// }

// class _CoordinateFormState extends State<CoordinateForm> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _xController = TextEditingController();
//   final TextEditingController _yController = TextEditingController();
//   final TextEditingController _zController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           customCoordinateForm(),
//         ],
//       ),
//     );
//   }

//   Widget customCoordinateForm() => Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             const SizedBox(width: 10),
//             const Icon(Icons.location_on),
//             const SizedBox(width: 10),
//             Flexible(
//               child: TextFormField(
//                 controller: _xController,
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//                 decoration: const InputDecoration(
//                   border: InputBorder.none,
//                   hintText: 'X',
//                 ),
//                 validator: (String? value) {
//                   return (value!.isEmpty) ? 'X Coor' : null;
//                 },
//               ),
//             ),
//             Flexible(
//               child: TextFormField(
//                 controller: _yController,
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//                 decoration: const InputDecoration(
//                   border: InputBorder.none,
//                   hintText: 'Y',
//                 ),
//                 validator: (String? value) {
//                   return (value!.isEmpty) ? 'Y Coor' : null;
//                 },
//               ),
//             ),
//             Flexible(
//               child: TextFormField(
//                 controller: _zController,
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//                 decoration: const InputDecoration(
//                   border: InputBorder.none,
//                   hintText: 'Z',
//                 ),
//                 validator: (String? value) {
//                   return (value!.isEmpty) ? 'Z Coor' : null;
//                 },
//               ),
//             ),
//           ],
//         ),
//       );

//   @override
//   void dispose() {
//     _xController.dispose();
//     _yController.dispose();
//     _zController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _xController.addListener(_onTextChanged);
//     _yController.addListener(_onTextChanged);
//     _zController.addListener(_onTextChanged);
//   }

//   void _onTextChanged() {
//     widget.onCoordinatesChanged(
//       double.tryParse(_xController.text) ?? 0.0,
//       double.tryParse(_yController.text) ?? 0.0,
//       double.tryParse(_zController.text) ?? 0.0,
//     );
//   }
// }

import 'package:flutter/material.dart';

typedef CallbackSetCoordinates = void Function(double x, double y, double z);
typedef CallbackChangeCoordinate = void Function(String axis, String value);

class CoordinateForm extends StatefulWidget {
  const CoordinateForm({
    Key? key,
    required this.onCoordinatesChanged,
    required this.changeCoordinate,
    required this.xController,
    required this.yController,
    required this.zController,
  }) : super(key: key);

  final CallbackSetCoordinates onCoordinatesChanged;
  final CallbackChangeCoordinate changeCoordinate;
  final TextEditingController xController;
  final TextEditingController yController;
  final TextEditingController zController;

  @override
  _CoordinateFormState createState() => _CoordinateFormState();
}

class _CoordinateFormState extends State<CoordinateForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          customCoordinateForm(),
        ],
      ),
    );
  }

  Widget customCoordinateForm() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.location_on),
            const SizedBox(width: 10),
            Flexible(
              child: TextFormField(
                controller: widget.xController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'X',
                ),
                validator: (String? value) {
                  return (value!.isEmpty) ? 'X Coor' : null;
                },
                onChanged: (value) {
                  widget.onCoordinatesChanged(
                    double.tryParse(value) ?? 0.0,
                    double.tryParse(widget.yController.text) ?? 0.0,
                    double.tryParse(widget.zController.text) ?? 0.0,
                  );
                },
              ),
            ),
            Flexible(
              child: TextFormField(
                controller: widget.yController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Y',
                ),
                validator: (String? value) {
                  return (value!.isEmpty) ? 'Y Coor' : null;
                },
                onChanged: (value) {
                  widget.onCoordinatesChanged(
                    double.tryParse(widget.xController.text) ?? 0.0,
                    double.tryParse(value) ?? 0.0,
                    double.tryParse(widget.zController.text) ?? 0.0,
                  );
                },
              ),
            ),
            Flexible(
              child: TextFormField(
                controller: widget.zController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Z',
                ),
                validator: (String? value) {
                  return (value!.isEmpty) ? 'Z Coor' : null;
                },
                onChanged: (value) {
                  widget.onCoordinatesChanged(
                    double.tryParse(widget.xController.text) ?? 0.0,
                    double.tryParse(widget.yController.text) ?? 0.0,
                    double.tryParse(value) ?? 0.0,
                  );
                },
              ),
            ),
          ],
        ),
      );
}
