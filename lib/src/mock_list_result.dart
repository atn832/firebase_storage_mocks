import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:firebase_storage_mocks/src/mock_storage_reference.dart';

class MockListResult implements ListResult {
  @override
  MockFirebaseStorage storage;

  @override
  List<MockReference> items;

  @override
  List<MockReference> prefixes;

  @override
  String? nextPageToken;

  MockListResult({
    required this.storage,
    required this.items,
    required this.prefixes,
    this.nextPageToken,
  });
}
