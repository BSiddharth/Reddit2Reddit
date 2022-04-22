import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showFlutterToast({required stringLabel}) {
  Fluttertoast.showToast(
    msg: stringLabel,
    backgroundColor: Colors.grey[400],
    textColor: Colors.black,
  );
}
