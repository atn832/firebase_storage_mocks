// Originally from https://github.com/firebase/flutterfire/blob/master/packages/firebase_storage/firebase_storage/lib/src/utils.dart

/// Returns a path from a given `gs://` URL.
///
/// If no path exists, the root path will be returned.
String pathFromGoogleStorageUrl(String url) {
  assert(url.startsWith('gs://'));
  final stopIndex = url.indexOf('/', 5);
  if (stopIndex == -1) return '/';
  return url.substring(stopIndex + 1, url.length);
}

const String _firebaseStorageHost = 'firebasestorage.googleapis.com';
const String _cloudStorageHost =
    '(?:storage.googleapis.com|storage.cloud.google.com)';
const String _bucketDomain = r'([A-Za-z0-9.\-_]+)';
const String _version = 'v[A-Za-z0-9_]+';
const String _firebaseStoragePath = r'(/([^?#]*).*)?$';
const String _cloudStoragePath = r'([^?#]*)*$';
const String _optionalPort = r'(?::\d+)?';

/// Returns a path from a given `http://` or `https://` URL.
///
/// If url fails to parse, null is returned
/// If no path exists, the root path will be returned.
Map<String, String?>? partsFromHttpUrl(String url) {
  assert(url.startsWith('http'));
  final decodedUrl = _decodeHttpUrl(url);
  if (decodedUrl == null) {
    return null;
  }

  // firebase storage url
  if (decodedUrl.contains(_firebaseStorageHost) ||
      decodedUrl.contains('localhost')) {
    String origin;
    if (decodedUrl.contains('localhost')) {
      final uri = Uri.parse(url);
      origin = '^http?://${uri.host}:${uri.port}';
    } else {
      origin = '^https?://$_firebaseStorageHost';
    }

    final firebaseStorageRegExp = RegExp(
      '$origin$_optionalPort/$_version/b/$_bucketDomain/o$_firebaseStoragePath',
      caseSensitive: false,
    );

    final match = firebaseStorageRegExp.firstMatch(decodedUrl);

    if (match == null) {
      return null;
    }

    return {
      'bucket': match.group(1),
      'path': match.group(3),
    };
    // google cloud storage url
  } else {
    final cloudStorageRegExp = RegExp(
      '^https?://$_cloudStorageHost$_optionalPort/$_bucketDomain/$_cloudStoragePath',
      caseSensitive: false,
    );

    final match = cloudStorageRegExp.firstMatch(decodedUrl);

    if (match == null) {
      return null;
    }

    return {
      'bucket': match.group(1),
      'path': match.group(2),
    };
  }
}

String? _decodeHttpUrl(String url) {
  try {
    return Uri.decodeFull(url);
  } catch (_) {
    return null;
  }
}
