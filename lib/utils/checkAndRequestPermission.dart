import 'package:permission_handler/permission_handler.dart';
import 'package:personalized_speech_interpreter/dialog/showPermissionRequestDialog.dart';

Future<bool> checkAndRequestPermission(context) async {
  bool micDenied = await Permission.microphone.isDenied;
  bool storageDenied = await Permission.storage.isDenied;

  if (micDenied && storageDenied) {
    showPermissionRequestDialog(context, 2);
    return false;
  } else if (micDenied) {
    showPermissionRequestDialog(context, 0);
    return false;
  } else if (storageDenied) {
    showPermissionRequestDialog(context, 1);
    return false;
  } else {
    return true;
  }
}