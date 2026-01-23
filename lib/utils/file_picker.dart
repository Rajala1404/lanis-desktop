import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class PickedFile {
  String name;

  /// The size in bytes (is 0 if something went wrong)
  num? size;

  String? path;

  String get extension => name.split('.').last;

  /// May be null if no mimeType was found
  String? get mimeType => lookupMimeType(path!);

  MediaType? get mediaType => MediaType.parse(mimeType!);

  PickedFile({required this.name, this.size, this.path});
}

extension Actions on PickedFile {
  Future<MultipartFile> intoMultipart() async {
    return await MultipartFile.fromFile(
      path!,
      filename: name,
      contentType: mediaType,
    );
  }
}

/// Allows the user to pick multiple files
Future<List<PickedFile>> pickMultipleFiles(
  BuildContext context,
  List<String>? allowedExtensions,
) async {
  return pickFileUsingDocumentsUI(allowedExtensions);
}

Future<List<PickedFile>> pickFileUsingDocumentsUI(
  List<String>? allowedExtensions,
) async {
  if (allowedExtensions == null || allowedExtensions.isEmpty) {
    allowedExtensions = List.from(["*"]);
  }
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
    allowMultiple: true,
  );
  List<PickedFile> returnResult = [];

  if (result != null) {
    for (final file in result.files) {
      returnResult.add(
        PickedFile(name: file.name, path: file.path, size: file.size),
      );
    }
  }

  return returnResult;
}