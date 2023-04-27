import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  void initializenotification() async {
    InitializationSettings _initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(_initializationSettings);
  }

  void checkIn() async {
    final now = DateTime.now();
    // Store the current check-in time in shared preferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('checkInTime', now.toString());
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val1 = prefs.getString("checkOutTime");

    if (val1 != null) {
      print('check-out:${val1.toString()}');
      await prefs.remove("checkOutTime");
    }
    print('check-in:${now.toString()}');
  }

  void checkOut() async {
    final now = DateTime.now();
    // Store the current check-out time in shared preferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('checkOutTime', now.toString());
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val1 = prefs.getString("checkInTime");

    if (val1 != null) {
      print('check-in:${val1.toString()}');
      await prefs.remove("checkInTime");
    }
    print('check-out:${now.toString()}');
  }

  Future<void> sendNotification(String title, String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('attendance_app', 'Attendance App',
            //"notification",
            //'Reminder to check in or out',
            importance: Importance.high,
            priority: Priority.high);

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    //cancelnotification();
    await _flutterLocalNotificationsPlugin
        .show(7, title, message, platformChannelSpecifics, payload: 'payload');
    cancelbyidnotification(7);
  }

  void checkAttendance() {
    final now = DateTime.now();
    final elevenAm = DateTime(now.year, now.month, now.day, 11);
    final elevenPm = DateTime(now.year, now.month, now.day, 23);

    SharedPreferences.getInstance().then((prefs) {
      final checkInTime = prefs.getString('checkInTime');
      final checkOutTime = prefs.getString('checkOutTime');

      if (checkInTime == null && now.isAfter(elevenAm)) {
        // User missed check-in before 11 AM
        print("checkInTime :${checkInTime.toString()}");
        sendNotification("Missed check-in", "Please check in before 11 AM");
      }

      if (checkOutTime == null && now.isAfter(elevenPm)) {
        // User missed check-out before 11 PM
        print("checkoutTime :${checkOutTime.toString()}");
        sendNotification("Missed check-out", "Please check out before 11 PM");
      }
    });
  }

  void sendnotification(String title, String body) async {
    AndroidNotificationDetails _androidNotificationDetails =
        const AndroidNotificationDetails(
      "2",
      "channelName",
      //"notification",
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: _androidNotificationDetails,
    );
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  void schedulenotification(String title, String body) async {
    AndroidNotificationDetails _androidNotificationDetails =
        const AndroidNotificationDetails(
      "channelId",
      "channelName",
      //"notification",
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: _androidNotificationDetails,
    );
    await _flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      title,
      body,
      RepeatInterval.everyMinute,
      notificationDetails,
    );
  }
void schedulecheckinnotification1(String title, String body, String clientname){
  var now = DateTime.now();
     if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
    // Cancel all scheduled notifications
    cancelnotification();
  } else {
  schedulecheckinnotification(title,body,clientname);
  }
}
  void schedulecheckinnotification(
      String title, String body, String clientname) async {
    print('inside check-in function');
    //await _flutterLocalNotificationsPlugin.cancel(1);
    AndroidNotificationDetails _androidNotificationDetails =
        const AndroidNotificationDetails(
      "channelId",
      "channelName",
      //"notification",
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: _androidNotificationDetails,
    );

    // Set the time for 11 AM
    var time = const Time(11, 0, 0);

    // Check if the time has already passed for today
    var now = DateTime.now();
    var scheduledTime = DateTime(
        now.year, now.month, now.day, time.hour, time.minute, time.second);
    if (scheduledTime.isBefore(now) || scheduledTime.weekday == DateTime.saturday ||
        scheduledTime.weekday == DateTime.sunday) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Schedule the notification to show at 11 AM every day
    // ignore: deprecated_member_use
    await _flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      title,
      body,
      time,
      notificationDetails,
    );
    sendNotification(
        'Last Check-out $clientname', "Kindly mark check-in before 11AM");
  }
void schedulecheckoutinnotification1(String title, String body, String clientname, String time12){
  var now = DateTime.now();
     if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
    // Cancel all scheduled notifications
    cancelnotification();
  } else {
  schedulecheckoutinnotification(title,body,clientname,time12);
  }
}
  void schedulecheckoutinnotification(
      String title, String body, String clientname, String time12) async {
    print('inside check-out function');
    // await _flutterLocalNotificationsPlugin.cancel(0);
    AndroidNotificationDetails _androidNotificationDetails =
        const AndroidNotificationDetails(
      "channelId",
      "channelName",
      //"notification",
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: _androidNotificationDetails,
    );

    // Set the time for 11 PM
    var time = const Time(23, 0, 0);

    // Check if the time has already passed for today
    var now = DateTime.now();
    var scheduledTime = DateTime(
        now.year, now.month, now.day, time.hour, time.minute, time.second);
    if (scheduledTime.isBefore(now) || scheduledTime.weekday == DateTime.saturday ||
        scheduledTime.weekday == DateTime.sunday) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Schedule the notification to show at 11 AM every day
    // ignore: deprecated_member_use
    await _flutterLocalNotificationsPlugin.showDailyAtTime(
      1,
      title,
      body,
      time,
      notificationDetails,
    );
    sendNotification('Last Check-in $clientname at $time12',
        "Kindly mark check-out before 11PM");
  }

  void cancelnotification() async {
    print('cancel notification');
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  void cancelbyidnotification(int id) async {
    print('cancel by id notification');
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

// void Notification()async{
//    schedulecheckinnotification("Check-in Alert!", "Kindly mark check-in (ignore if done)");
//   schedulecheckoutinnotification("Check-out Alert!", "Kindly mark check-out (ignore if done)");
// }
  void bothNotification() {
    var now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      // Cancel all scheduled notifications
      cancelnotification();
    } else {
      scheduleboth1notification('Check-in/Check-out Alert!',
          'Kindly mark either check-in or check-out.');
      scheduleboth2notification('Check-in/Check-out Alert!',
          'Kindly mark either check-in or check-out.');
    }
  }

  void scheduleboth1notification(String title, String body) async {
    print('inside both1 function');
    //await _flutterLocalNotificationsPlugin.cancel(1);
    AndroidNotificationDetails _androidNotificationDetails =
        const AndroidNotificationDetails(
      "channelId",
      "channelName",
      //"notification",
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: _androidNotificationDetails,
    );

    // Set the time for 12 AM
    var time = const Time(0, 0, 0);

    // Check if the time has already passed for today
    var now = DateTime.now();

    var scheduledTime = DateTime(
        now.year, now.month, now.day, time.hour, time.minute, time.second);
    if (scheduledTime.isBefore(now) || scheduledTime.weekday == DateTime.saturday ||
        scheduledTime.weekday == DateTime.sunday) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    // Schedule the notification to show at 11 AM every day
    // ignore: deprecated_member_use
    await _flutterLocalNotificationsPlugin.showDailyAtTime(
      2,
      title,
      body,
      time,
      notificationDetails,
    );
  }

  void scheduleboth2notification(String title, String body) async {
    print('inside both2 function');
    //await _flutterLocalNotificationsPlugin.cancel(1);
    AndroidNotificationDetails _androidNotificationDetails =
        const AndroidNotificationDetails(
      "channelId",
      "channelName",
      //"notification",
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: _androidNotificationDetails,
    );

    // Set the time for 12 PM
    var time = const Time(12, 0, 0);

    // Check if the time has already passed for today
    var now = DateTime.now();
    var scheduledTime = DateTime(
        now.year, now.month, now.day, time.hour, time.minute, time.second);
    if (scheduledTime.isBefore(now) || scheduledTime.weekday == DateTime.saturday ||
        scheduledTime.weekday == DateTime.sunday) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Schedule the notification to show at 11 AM every day
    // ignore: deprecated_member_use
    await _flutterLocalNotificationsPlugin.showDailyAtTime(
      3,
      title,
      body,
      time,
      notificationDetails,
    );
  }

  void newusernotification(String username) {
    var now = DateTime.now();
     if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
    // Cancel all scheduled notifications
    cancelnotification();
  } else {
    cancelnotification();
    sendNotification('Newuser Check-in required!',
        'Kindly mark check-in for the first time.');
    schedulenewuser1notification(
        'Newuser Check-in Alert!', 'Kindly mark check-in for the first time.');
    schedulenewuser2notification(
        '$username Check-inAlert!', 'Kindly mark check-in for the first time.');
  }
  }

  void schedulenewuser1notification(String title, String body) async {
    print('inside both1 function');
    //await _flutterLocalNotificationsPlugin.cancel(1);
    AndroidNotificationDetails _androidNotificationDetails =
        const AndroidNotificationDetails(
      "channelId",
      "channelName",
      //"notification",
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: _androidNotificationDetails,
    );

    // Set the time for 11 AM
    var time = const Time(11, 0, 0);

    // Check if the time has already passed for today
    var now = DateTime.now();
    var scheduledTime = DateTime(
        now.year, now.month, now.day, time.hour, time.minute, time.second);
    if (scheduledTime.isBefore(now) || scheduledTime.weekday == DateTime.saturday ||
        scheduledTime.weekday == DateTime.sunday) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Schedule the notification to show at 11 AM every day
    // ignore: deprecated_member_use
    await _flutterLocalNotificationsPlugin.showDailyAtTime(
      4,
      title,
      body,
      time,
      notificationDetails,
    );
  }

  void schedulenewuser2notification(String title, String body) async {
    print('inside both1 function');
    //await _flutterLocalNotificationsPlugin.cancel(1);
    AndroidNotificationDetails _androidNotificationDetails =
        const AndroidNotificationDetails(
      "channelId",
      "channelName",
      //"notification",
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: _androidNotificationDetails,
    );

    // Set the time for 11 PM
    var time = const Time(23, 0, 0);

    // Check if the time has already passed for today
    var now = DateTime.now();
    var scheduledTime = DateTime(
        now.year, now.month, now.day, time.hour, time.minute, time.second);
    if (scheduledTime.isBefore(now) || scheduledTime.weekday == DateTime.saturday ||
        scheduledTime.weekday == DateTime.sunday) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Schedule the notification to show at 11 AM every day
    // ignore: deprecated_member_use
    await _flutterLocalNotificationsPlugin.showDailyAtTime(
      5,
      title,
      body,
      time,
      notificationDetails,
    );
  }

  void stopnotification() async {
    await _flutterLocalNotificationsPlugin.cancel(0);
  }

  void soundnotification(String title, String body) async {
    AndroidNotificationDetails _androidNotificationDetails =
        const AndroidNotificationDetails(
      "2",
      "channelName",
      //"notification",
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: _androidNotificationDetails,
    );
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}
