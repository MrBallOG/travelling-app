import 'package:flutter/material.dart';

SnackBar snackBarSuccess(String text, {int duration = 3}) {
  return SnackBar(
    content: Text(text),
    duration: Duration(seconds: duration),
    backgroundColor: Colors.green,
  );
}

SnackBar snackBarFailure(String text, {int duration = 3}) {
  return SnackBar(
    content: Text(text),
    duration: Duration(seconds: duration),
    backgroundColor: Colors.red,
  );
}

SnackBar snackBarProgress(String text, {int duration = 3}) {
  return SnackBar(
    content: Text(text),
    duration: Duration(seconds: duration),
    backgroundColor: Colors.yellow.shade800,
  );
}
