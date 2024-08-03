import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> storeSession(String userId, String userEmail) async {
    await _secureStorage.write(key: 'userID', value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: 'userID');
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'userID');
  }
}
