import 'dart:async';
import 'package:attendence_app_pwc/services/utils.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    utilsservices snackbar = utilsservices();
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      snackbar.showsnackbar('Finger Print is not available in this device');
      return false;
    }
  }

  static Future<List<BiometricType>> getBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      return <BiometricType>[];
    }
  }

  static Future<bool> isDeviceSupported() async {
    utilsservices snackbar = utilsservices();
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (e) {
      snackbar.showsnackbar('Finger Print is not supported by this device');
      return false;
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    utilsservices snackbar = utilsservices();
    if (!isAvailable) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'Scan Fingerprint to Authenticate',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Fingerprint authentication required!',
            cancelButton: 'No thanks',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
          ),
        ],
        //useErrorDialogs: true,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          sensitiveTransaction: false,
          biometricOnly: true,
        ),
        //stickyAuth: true,
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        snackbar.showsnackbar('No Support is found');
      } else if (e.code == auth_error.lockedOut) {
        snackbar.showsnackbar('5 attempts occur.Try after 30 seconds');
      } else {
        snackbar.showsnackbar(
            'Biometric authentication is disabled until the user unlocks phone with strong authentication (PIN/Pattern/Password)');
      }
      return false;
    }
  }
}
