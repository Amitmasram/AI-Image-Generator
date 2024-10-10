import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ImageDownloader {
  static Future<bool> saveImage(Uint8List imageBytes, BuildContext context) async {
    try {
      bool permissionGranted = await _requestPermissions(context);
      if (!permissionGranted) return false;

      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: "AI_Generated_Image_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to gallery successfully')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: ${result['error']}')),
        );
        return false;
      }
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while saving the image: $e')),
      );
      return false;
    }
  }

  static Future<bool> _requestPermissions(BuildContext context) async {
    if (Platform.isAndroid) {
      if (await _isAndroid10OrHigher()) {
        return await _requestAndroid10Permissions(context);
      } else {
        return await _requestLegacyAndroidPermissions(context);
      }
    } else if (Platform.isIOS) {
      return await _requestIOSPermissions(context);
    }
    return false;
  }

  static Future<bool> _isAndroid10OrHigher() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 29;
  }

  static Future<bool> _requestAndroid10Permissions(BuildContext context) async {
    final status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog(context);
      return false;
    } else {
      final result = await Permission.storage.request();
      return result.isGranted;
    }
  }

  static Future<bool> _requestLegacyAndroidPermissions(BuildContext context) async {
    final status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog(context);
      return false;
    } else {
      final result = await [
        Permission.storage,
      ].request();
      return result[Permission.storage]?.isGranted ?? false;
    }
  }

  static Future<bool> _requestIOSPermissions(BuildContext context) async {
    final status = await Permission.photos.status;
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog(context);
      return false;
    } else {
      final result = await Permission.photos.request();
      return result.isGranted;
    }
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text('To save images, this app needs permission to access your device storage. Please grant this permission in your device settings.'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Open Settings'),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
