// @dart=3.2

import 'dart:io';

/// Returns absolute project root path (parent of scripts/).
String getProjectRoot(String scriptDir) => File('$scriptDir/..').absolute.path;
