import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  /// Read string value
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Write string value
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read JSON and decode
  Future<Map<String, dynamic>?> readJson(String key) async {
    final value = await read(key);
    if (value == null) return null;
    try {
      return json.decode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Write JSON (encode and store)
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    final encoded = json.encode(value);
    await write(key, encoded);
  }

  /// Read JSON list
  Future<List<dynamic>?> readJsonList(String key) async {
    final value = await read(key);
    if (value == null) return null;
    try {
      return json.decode(value) as List<dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Write JSON list
  Future<void> writeJsonList(String key, List<dynamic> value) async {
    final encoded = json.encode(value);
    await write(key, encoded);
  }

  /// Delete key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Delete all keys
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    final value = await read(key);
    return value != null;
  }
}
