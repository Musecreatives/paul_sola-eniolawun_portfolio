import 'package:web/web.dart' as web;

/// The curator's session survives a reload. Only the PocketBase token and
/// record are kept; never the password.
const _key = 'pse_curator_session';

String? readSession() {
  try {
    return web.window.localStorage.getItem(_key);
  } catch (_) {
    return null;
  }
}

void writeSession(String v) {
  try {
    v.isEmpty ? web.window.localStorage.removeItem(_key) : web.window.localStorage.setItem(_key, v);
  } catch (_) {}
}
