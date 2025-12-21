import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ProfileServiceWeb {
  static const String baseUrl = 'http://localhost:8000';

  static Future<Map<String, dynamic>> uploadProfilePicture(
  CookieRequest request,
  Object file,
) {
  final htmlFile = file as html.File; 

  final completer = Completer<Map<String, dynamic>>();

  final formData = html.FormData();
  formData.appendBlob('profile_picture', htmlFile, htmlFile.name);

  final xhr = html.HttpRequest();
  xhr.open('POST', '$baseUrl/accounts/profile/upload-picture/');
  xhr.withCredentials = true;

  xhr.onLoad.listen((_) {
    completer.complete(jsonDecode(xhr.responseText!));
  });

  xhr.onError.listen((_) {
    completer.completeError('Upload failed');
  });

  xhr.send(formData);

  return completer.future;
}

  static Future<html.File?> pickImage() async {
    final input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    await input.onChange.first;
    return input.files?.first;
  }

  static String previewUrl(Object file) {
    return html.Url.createObjectUrl(file as html.File);
  }
}
