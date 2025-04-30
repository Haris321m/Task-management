import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/folder.dart';
import '../models/task.dart';

class HiveService {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _encryptionKeyStorageKey = 'encryptionKey';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(FolderAdapter());
    Hive.registerAdapter(TaskAdapter());

    // Retrieve or generate encryption key
    String? storedKey = await _secureStorage.read(
      key: _encryptionKeyStorageKey,
    );

    // Generate new key if none exists
    if (storedKey == null) {
      final encryptionKey = Hive.generateSecureKey();
      storedKey =
          encryptionKey.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
      await _secureStorage.write(
        key: _encryptionKeyStorageKey,
        value: storedKey,
      );
    }

    // Now safely cast to non-nullable string
    final String encryptionKeyString = storedKey!;

    // Validate key format
    if (encryptionKeyString.length % 2 != 0 ||
        !RegExp(r'^[0-9a-fA-F]+$').hasMatch(encryptionKeyString)) {
      throw FormatException(
        "Invalid encryption key format. Must be even-length hex string.",
      );
    }

    // Convert to bytes
    final encryptionKeyBytes = List<int>.generate(
      encryptionKeyString.length ~/ 2,
      (i) =>
          int.parse(encryptionKeyString.substring(i * 2, i * 2 + 2), radix: 16),
    );

    // Validate key length
    if (![16, 24, 32].contains(encryptionKeyBytes.length)) {
      throw FormatException(
        "Encryption key must be 16, 24, or 32 bytes (got ${encryptionKeyBytes.length})",
      );
    }

    // Initialize encrypted boxes
    await Hive.openBox<Folder>(
      'folders',
      encryptionCipher: HiveAesCipher(encryptionKeyBytes),
    );
    await Hive.openBox<Task>(
      'tasks',
      encryptionCipher: HiveAesCipher(encryptionKeyBytes),
    );
  }
}
