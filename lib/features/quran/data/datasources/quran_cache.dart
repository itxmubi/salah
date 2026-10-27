import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class QuranCache {
  Future<Map<String, dynamic>?> read(String key);
  Future<void> write(String key, Map<String, dynamic> value);
}

/// Application support storage survives cache eviction and app restarts.
class FileQuranCache implements QuranCache {
  FileQuranCache({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;
  final Future<Directory> Function() _directory;
  Future<void> _queue = Future.value();

  Future<File> _file(String key) async {
    final root = Directory('${(await _directory()).path}/quran-v1');
    await root.create(recursive: true);
    final name = base64Url.encode(utf8.encode(key));
    return File('${root.path}/$name.json');
  }

  @override
  Future<Map<String, dynamic>?> read(String key) async {
    try {
      final file = await _file(key);
      if (!await file.exists()) return null;
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, Map<String, dynamic> value) {
    final operation = _queue.catchError((Object _) {}).then((_) async {
      final file = await _file(key);
      final temporary = File('${file.path}.tmp');
      await temporary.writeAsString(jsonEncode(value), flush: true);
      await temporary.rename(file.path);
    });
    _queue = operation;
    return operation;
  }
}
