// @dart=3.2

/// Colored console output for scripts.
void printStatus(String msg) => print('[\x1b[34mINFO\x1b[0m] $msg');
void printSuccess(String msg) => print('[\x1b[32mSUCCESS\x1b[0m] $msg');
void printWarning(String msg) => print('[\x1b[33mWARNING\x1b[0m] $msg');
void printError(String msg) => print('[\x1b[31mERROR\x1b[0m] $msg');
