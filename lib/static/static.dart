import 'package:flutter/material.dart';

// Image logoSmall =
//     Image.asset('assets/images/logo.jpg', width: 100, height: 100);
// Image logoBig = Image.asset('assets/images/logo.jpg', width: 200, height: 200);

String logo = 'logo.jpg';
String background = 'background_image.jpg';
Color popuptitleColor = Color(0xFF3E84BE);
String font = 'Roboto';

const textFieldDecoration = InputDecoration(
  border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
    Radius.circular(10.0),
  )),
  labelText: 'Label',
  labelStyle: TextStyle(
    //fontWeight: FontWeight.bold,
    fontSize: 15,
    color: Color.fromARGB(255, 65, 65, 65),
  ),
  hintText: '',
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color.fromARGB(255, 143, 204, 255),
      width: 2.0,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color.fromARGB(255, 208, 208, 208),
      width: 1.0,
    ),
  ),
);

var buttonStyle1 = ButtonStyle(
  backgroundColor:
      MaterialStateProperty.all<Color>(Color.fromARGB(255, 143, 204, 255)),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),
);
