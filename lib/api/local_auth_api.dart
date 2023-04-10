import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      Fluttertoast.showToast(
          msg: 'Finger Print is not available in this device',
          //toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
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
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (e) {
      Fluttertoast.showToast(
          msg: 'Finger Print is not supported by this device',
          //toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
      return false;
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
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
         Fluttertoast.showToast(
          msg:
              'No Support is found',
          //toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
      } else if (e.code == auth_error.lockedOut ) { 
            print(e.code);
            print(e.toString());
         Fluttertoast.showToast(
         
          msg:
              '5 attempts occur.Try after 30 seconds',
          //toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
      } else {                   //e.code == auth_error.permanentlyLockedOut
        Fluttertoast.showToast(
          msg: 'Biometric authentication is disabled until the user unlocks phone with strong authentication (PIN/Pattern/Password)',
          //toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
      }
      // if (e.toString() ==
      //     'PlatformException(PermanentlyLockedOut, The operation was canceled because ERROR_LOCKOUT occurred too many times. Biometric authentication is disabled until the user unlocks with strong authentication (PIN/Pattern/Password), null, null)') {
      //   Fluttertoast.showToast(
      //     //msg: response.statusCode.toString() + response.body,
      //     msg:
      //         'Biometric authentication is disabled until the user unlocks phone with strong authentication (PIN/Pattern/Password)',
      //     //toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 5,
      //     //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
      //     backgroundColor: Colors.black,
      //     textColor: Colors.white,
      //     fontSize: 16,
      //   );
      // } else {
      //   Fluttertoast.showToast(
      //     //msg: response.statusCode.toString() + response.body,
      //     msg: 'Too many attempts.Try after 30 seconds',
      //     //toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 5,
      //     //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
      //     backgroundColor: Colors.black,
      //     textColor: Colors.white,
      //     fontSize: 16,
      //   );
      //   //timer();
      // }

      print(e.toString());
      return false;
    }
  }
  // Widget timer(BuildContext context){
  //   return TweenAnimationBuilder(
  //                   tween: Tween(begin: 30.0, end: 0),
  //                   duration: const Duration(seconds: 30),
  //                   builder: (context, value, child) {
  //                     double val = value as double;
  //                     int time = val.toInt();
  //                     return Text(
  //                       "Retry in $time to continue",
  //                       style: const TextStyle(
  //                         fontSize: 16,
  //                       ),
  //                       textAlign: TextAlign.center,
  //                     );
  //                   },
  //                   onEnd: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => FingerprintPage(),
  //                       ),
  //                     );
  //                   },
  //                 );

  // }
}
