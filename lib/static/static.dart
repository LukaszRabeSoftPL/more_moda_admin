import 'package:flutter/material.dart';

// Image logoSmall =
//     Image.asset('assets/images/logo.jpg', width: 100, height: 100);
// Image logoBig = Image.asset('assets/images/logo.jpg', width: 200, height: 200);

String logo = 'logo_more_moda.jpg';
String background = 'background_more_moda.png';
Color popuptitleColor = Color(0xFF273630);
String font = 'Roboto';

Color cardColor = Color(0xFFeef1f7);
Color unactiveColor = Color(0xFFBABFC3);
Color buttonColor = Color(0xFF273630);
Color buttonColor2 = Color(0xFF273630);

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
      color: Color(0xFF273630),
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
  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF273630)),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),
);
