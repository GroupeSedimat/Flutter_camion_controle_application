import 'package:flutter/material.dart';

class DialogService {
  static final DialogService _instance = DialogService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory DialogService() => _instance;

  DialogService._internal();

  // Function to show a generic dialog
  Future<T?> showDialog<T>({
    required String title,
    required String message,
    List<DialogAction> actions = const [],
  }) async {
    return showGeneralDialog<T>(
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
                Navigator.of(navigatorKey.currentState!.context).pop(action.result);
              },
              child: Text(action.label),
            );
          }).toList(),
        );
      },
    );
  }
}

class DialogAction<T> {
  final String label;
  final T result;

  DialogAction({required this.label, required this.result});
}