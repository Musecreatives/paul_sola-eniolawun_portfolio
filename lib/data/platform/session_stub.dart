/// Session storage off the web (tests, desktop): in memory only.
String? _value;

String? readSession() => _value;
void writeSession(String v) => _value = v.isEmpty ? null : v;
