import 'dart:io';

String user() {
  return Platform.environment["USER"] ?? "unknown";
}
