import 'package:flutter/material.dart';

/// Affiche un dialogue dont les [SnackBar] apparaissent **devant** le modal.
///
/// Enveloppe le contenu dans un [ScaffoldMessenger] + [Scaffold] transparent
/// (les SnackBars du Scaffold parent passent sinon derrière le dialogue).
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  bool useRootNavigator = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) {
      return ScaffoldMessenger(
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  if (barrierDismissible)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  Center(child: builder(context)),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

/// Affiche un SnackBar visible au-dessus d'un dialogue ouvert.
///
/// Utilise le [ScaffoldMessenger] le plus proche (celui du dialogue s'il a
/// été ouvert via [showAppDialog]).
void showAppSnackBar(
  BuildContext context, {
  required String message,
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 4),
  SnackBarAction? action,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
