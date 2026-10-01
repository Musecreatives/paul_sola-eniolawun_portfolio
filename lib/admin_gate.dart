import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'admin/admin.dart' deferred as admin;
import 'theme/tokens.dart';

/// Loads the Curator's office on demand. The admin code ships as a separate
/// deferred chunk that only `/admin` visitors download.
class AdminGate extends StatelessWidget {
  const AdminGate(this.state, {super.key});
  final GoRouterState state;

  static bool _loaded = false;

  @override
  Widget build(BuildContext context) => _loaded
      ? admin.adminScreen(state)
      : FutureBuilder(
          future: admin.loadLibrary().then((_) => _loaded = true),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.done && !snap.hasError) return admin.adminScreen(state);
            return ColoredBox(
              color: Palette.admBg,
              child: Center(
                child: snap.hasError
                    ? Text(
                        "The curator's office couldn't load. Refresh to try again.",
                        style: T.body(15, color: Palette.placardInk),
                        textDirection: TextDirection.ltr,
                      )
                    : const CircularProgressIndicator(color: Palette.royalAction),
              ),
            );
          },
        );
}
