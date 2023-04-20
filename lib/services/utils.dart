import 'package:attendence_app_pwc/services/notification_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class utilsservices{
  NotificationServices notificationServices = NotificationServices();
  void showsnackbar(String message){
    Fluttertoast.showToast(
            //msg: response.statusCode.toString() + response.body,
            msg: message,
            //toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16,
          );
  }
  void notification() async {
    notificationServices.initializenotification();
    SharedPreferences prefinger = await SharedPreferences.getInstance();
   var username = prefinger.getString("username")!;
    var chv = prefinger.getString("CI");
    print(chv);
    if (username != null) {
      if (chv == null) {
        notificationServices.cancelnotification();
        notificationServices.bothNotification();
      } else if (chv == '1') {
        notificationServices.cancelnotification();
        notificationServices.schedulecheckoutinnotification(
            "Check-out Alert!", "Respected $username kindly mark check-out.");
      } else if (chv == '2') {
        notificationServices.cancelnotification();
        notificationServices.schedulecheckinnotification(
            "Check-in Alert!", "Respected $username kindly mark check-in.");
      } else if (chv == '3') {
        notificationServices.newusernotification();
      }
    } else {
      notificationServices.cancelnotification();
      notificationServices.bothNotification();
    }
  }
  void removeharepreferenes()async{
    SharedPreferences prefinger = await SharedPreferences.getInstance();
        await prefinger.remove("email12");
        await prefinger.remove("SHA12");
        await prefinger.remove("sval12");
  }
   static Future<void> openphone() async {
    Uri phoneno = Uri.parse('tel: +923322045416'); //'tel:+923041112482'
    if (await launchUrl(phoneno)) {
      //dialer opened
    } else {
      //dailer is not opened
    }
  }
}