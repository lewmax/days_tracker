// ignore_for_file: avoid_print
// @dart=3.2

import 'dart:io';

/// Creates .dev.env, .uat.env, and .prod.env from a template with empty values.
/// Run from project root: fvm dart run scripts/create_env_files.dart
void main() {
  const template = '''
DEV_WEBSITE_CRED_LOGIN=
DEV_WEBSITE_CRED_PASSWORD=
API_KEY=
SALT_KEY=
INITIAL_WEBSITE_URL=
ALLOWED_PHONE_CODES=
SIMULATE_USERS=
REGISTER_REDIRECT_URL=
BANK_ID_URL=
BANK_ID_CLIENT_ID=
PRIVAT_BANK_URL=
PRIVAT_BANK_CLIENT_ID=
APPSTORE_ID=
PLAY_MARKET_ID=
FINGERPRINT_API_KEY=
''';

  final projectRoot = Directory.current.path;
  final files = ['.dev.env', '.uat.env', '.prod.env'];

  for (final name in files) {
    final path = '$projectRoot/$name';
    final file = File(path);
    if (file.existsSync()) {
      print('Skipped (already exists): $name');
    } else {
      file.writeAsStringSync('${template.trim()}\n');
      print('Created: $name');
    }
  }

  print('');
  print('Done. Fill in values for each environment.');
}
