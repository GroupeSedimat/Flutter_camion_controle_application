import 'package:flutter/material.dart';

class DialogService {
  static final DialogService _instance = DialogService._internal();

  // GlobalKey to manage the Navigator state without context
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory DialogService() => _instance;

  DialogService._internal();

  // Function to show a generic dialog
  Future<void> showDialog({
    required String title,
    required String message,
    List<DialogAction> actions = const [],
  }) async {
    await showGeneralDialog(
      context: navigatorKey.currentState!.overlay!.context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (_, __, ___) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: actions.map((action) {
            return TextButton(
              onPressed: () {
                action.onPressed();
                Navigator.of(navigatorKey.currentState!.context).pop();
              },
              child: Text(action.label),
            );
          }).toList(),
        );
      },
    );
  }
}

class DialogAction {
  final String label;
  final VoidCallback onPressed;

  DialogAction({required this.label, required this.onPressed});
}