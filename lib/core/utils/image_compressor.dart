import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {
  /// Compresses the given [file] to reduce its size in KBs without noticeable quality loss.
  static Future<File?> compressImage(File file, {int quality = 70}) async {
    final parentPath = file.parent.path;
    final targetPath = '$parentPath/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
    
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, 
      targetPath,
      quality: quality,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      return File(result.path);
    }
    return null;
  }
}
