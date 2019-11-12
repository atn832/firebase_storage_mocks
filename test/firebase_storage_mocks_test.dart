import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:test/test.dart';

final filename = 'someimage.png';

void main() {
  test('Puts File', () async {
    final storage = MockFirebaseStorage();
    final StorageReference storageRef = storage.ref().child(filename);
    final image = File(filename);
    final task = storageRef.putFile(image);
    await task.onComplete;
    expect(await getGsLink(storageRef), equals('gs://some-bucket//someimage.png'));
  });
}

Future<String> getGsLink(StorageReference storageRef) async {
  return 'gs://' + await storageRef.getBucket() + '/' + storageRef.path;
}
