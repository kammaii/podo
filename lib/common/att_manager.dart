import 'package:flutter/material.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:permission_handler/permission_handler.dart';

class ATTManager {
  static Future<void> requestTrackingPermission(BuildContext context) async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;

    if (status == TrackingStatus.notDetermined) {
      // 처음 요청하는 경우만 팝업 표시
      final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
      print('ATT status: $newStatus');
    } else if (status == TrackingStatus.denied) {
      // 이미 거절된 경우 → 팝업 표시 대신 안내
      _showDeniedDialog(context);
    } else {
      print('ATT status: $status'); // authorized, restricted 등
    }
  }

  static void _showDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'To provide personalized ads, please enable tracking permission in Settings > Podo Korean > Allow Tracking.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
