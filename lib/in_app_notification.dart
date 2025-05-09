import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void showNotification(BuildContext context, String message) {
  return showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.error(
      message: message,
      textStyle: TextStyle(color: Colors.white, fontSize: 16),
    ),
  );
}
