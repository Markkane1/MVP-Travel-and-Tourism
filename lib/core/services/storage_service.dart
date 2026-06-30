import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A service to upload files to Firebase Storage, with built-in native image compression.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  StorageService();

  /// Compresses (if exceeds 1600px) and uploads an image to Firebase Storage, returning its URL.
  Future<String> uploadImage(File file, String path) async {
    File uploadFile = file;

    try {
      uploadFile = await _compressImage(file);
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image, uploading original instead: $e');
      }
    }

    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(uploadFile);

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// Compress and resize the image so that the longest edge does not exceed [maxEdge].
  Future<File> _compressImage(File file, {int maxEdge = 1600}) async {
    final bytes = await file.readAsBytes();

    // Instantiate a codec to check dimensions
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;

    final int width = image.width;
    final int height = image.height;

    // Skip resizing if original is already within boundaries
    if (width <= maxEdge && height <= maxEdge) {
      return file;
    }

    int newWidth = width;
    int newHeight = height;

    if (width > height) {
      newHeight = (height * maxEdge / width).round();
      newWidth = maxEdge;
    } else {
      newWidth = (width * maxEdge / height).round();
      newHeight = maxEdge;
    }

    // Re-decode with targetWidth and targetHeight for native scaling
    final resizedCodec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: newWidth,
      targetHeight: newHeight,
    );
    final resizedFrameInfo = await resizedCodec.getNextFrame();
    final resizedImage = resizedFrameInfo.image;

    final byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return file;
    }

    final compressedBytes = byteData.buffer.asUint8List();

    // Write back to a temp file
    final tempDir = Directory.systemTemp;
    final tempFile = File(
      '${tempDir.path}/img_compressed_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await tempFile.writeAsBytes(compressedBytes);

    return tempFile;
  }
}

/// Provider for the StorageService instance.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
