import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class PsdAsset {
  File file;
  String name;
  int sizeBytes;
  DateTime modified;

  PsdAsset({
    required this.file,
    required this.name,
    required this.sizeBytes,
    required this.modified,
  });
}

class FileScannerService {
  static Future<List<PsdAsset>> scanPsdFiles() async {
    List<PsdAsset> psdList = [];
    final rootDir = Directory('/storage/emulated/0');

    if (await rootDir.exists()) {
      await for (var entity in rootDir.list(recursive: true, followLinks: false)) {
        try {
          if (entity is File && entity.path.toLowerCase().endsWith('.psd')) {
            final stat = await entity.stat();
            psdList.add(PsdAsset(
              file: entity,
              name: p.basename(entity.path),
              sizeBytes: stat.size,
              modified: stat.modified,
            ));
          }
        } catch (_) {}
      }
    }
    return psdList;
  }

  static Future<List<File>> scanFontFiles() async {
    List<File> fontList = [];
    final rootDir = Directory('/storage/emulated/0');
    const validExtensions = ['.ttf', '.otf', '.zip'];

    if (await rootDir.exists()) {
      await for (var entity in rootDir.list(recursive: true, followLinks: false)) {
        try {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (validExtensions.contains(ext)) {
              fontList.add(entity);
            }
          }
        } catch (_) {}
      }
    }
    return fontList;
  }

  static Future<File?> renameFile(File file, String newName) async {
    try {
      final dir = p.dirname(file.path);
      final ext = p.extension(file.path);
      final sanitizedName = newName.endsWith(ext) ? newName : "$newName$ext";
      final newPath = p.join(dir, sanitizedName);
      return await file.rename(newPath);
    } catch (e) {
      return null;
    }
  }

  static Future?> inspectPsd(File psdFile) async {
    try {
      final Uint8List bytes = await psdFile.readAsBytes();
      final img.Image? decoded = img.decodePsd(bytes);
      if (decoded == null) return null;

      List<Color> palette = [];
      final stepX = (decoded.width / 5).clamp(1, decoded.width).toInt();
      final stepY = (decoded.height / 5).clamp(1, decoded.height).toInt();

      for (int x = 0; x < decoded.width && palette.length < 5; x += stepX) {
        final pixel = decoded.getPixel(x, stepY);
        palette.add(Color.fromARGB(255, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()));
      }

      return {
        'image': decoded,
        'pngBytes': Uint8List.fromList(img.encodePng(decoded)),
        'width': decoded.width,
        'height': decoded.height,
        'channels': decoded.numChannels,
        'palette': palette,
      };
    } catch (e) {
      return null;
    }
  }

  static Future<File?> exportAsset(img.Image decodedImage, String outputPath, {bool asPng = true}) async {
    try {
      final bytes = asPng ? img.encodePng(decodedImage) : img.encodeJpg(decodedImage, quality: 95);
      final outFile = File(outputPath);
      return await outFile.writeAsBytes(bytes);
    } catch (e) {
      return null;
    }
  }
}
