import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
void successToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
void errorToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
String getDateString(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
String extractDateFromDateTime(String dateTimeString) {
  if (dateTimeString.contains(' ')) {
    return dateTimeString.split(' ')[0];
  }
  return dateTimeString;
}

Future<bool> parseAudioFile(String filePath) async {
  try {
    final ByteData data = await rootBundle.load(filePath);
    if (data.lengthInBytes == 0) {
      return false;
    }

    if (!isValidAudioFormat(data)) {
      return false;
    }

    return true;

  } catch (e) {
    return false;
  }
}

bool isValidAudioFormat(ByteData data) {
  List<int> header = data.buffer.asUint8List(0, 4);

  if (header[0] == 0x49 && header[1] == 0x44 && header[2] == 0x33) {
    return true;
  }

  if (header[0] == 0xFF && (header[1] & 0xE0) == 0xE0) {
    return true;
  }

  if (header[0] == 0x52 && header[1] == 0x49 &&
      header[2] == 0x46 && header[3] == 0x46) {
    return true;
  }

  return false;
}