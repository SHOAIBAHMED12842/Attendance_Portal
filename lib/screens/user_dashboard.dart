// ignore_for_file: unnecessary_null_comparison
import 'dart:async';
import 'dart:convert';
import 'package:attendence_app_pwc/api/local_auth_api.dart';
import 'package:attendence_app_pwc/notification_service.dart';

import 'globals.dart' as globals;
//import 'dart:typed_data';
import 'package:attendence_app_pwc/screens/auth_screen.dart';
import 'package:attendence_app_pwc/screens/view_attendence.dart';
import 'package:flutter/services.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart';
//import 'package:analog_clock/analog_clock.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
//import 'package:internet_connection_checker/internet_connection_checker.dart';
//import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'dart:io';

class UserDashboard extends StatefulWidget {
  String token1 = "";
  String userid1 = "";
  String SHA11 = "";
  String email1 = "";
  UserDashboard(this.token1, this.SHA11, this.email1, this.userid1,
      {super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  //  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
  //     systemNavigationBarColor: Color.fromRGBO(209, 57, 13, 1),
  //     systemNavigationBarIconBrightness: Brightness.light,
  //     systemNavigationBarDividerColor: Colors.blue,
  //   );
  NotificationServices notificationServices = NotificationServices();
  bool isSwitched = false;
  var switchf = '0';
  //var textValue = 'Switch is OFF';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  File? imageFile;
  final _formKey1 = GlobalKey<FormState>();
  GetStorage box = GetStorage();
  // final StopWatchTimer _stopWatchTimer = StopWatchTimer(); // Create instance.
  //String time = DateFormat("hh:mm:ss a").format(DateTime.now());
  String time = '';
  String time1 = '';
  String time3 = '';
  //String systime = DateFormat("hh:mm a").format(DateTime.now());
  String day = DateFormat("EEEEE").format(DateTime.now());
  String date = DateFormat("MMMM dd, yyyy").format(DateTime.now());
  String token = "";
  String username = "";
  String SHA1 = "";
  String email = "";
  String userid = "";
  late Position position;
  String? _currentAddress;
  Position? _currentPosition;
  late bool _isAddress;
  String? selecteditem;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  bool _isclient = false;
  bool _ischeckin = false;
  bool _ischeckout = false;
  bool _isusercheckin = false;
  bool _istimebox = false;
  String? marking; //no radio button will be selected
  var format1 = DateFormat("HH:mm");
  String base64string = '';
  // List<String> client_categories = [];
  List client_categories = [];
  List<String> client_Search_categories = [];
  // List<String> countries = ["Brazil", "Italia (Disabled)", "Tunisia", 'Canada'];
  var dropdownvalue;
  String? clientid;
  var time2 = Time(hours3: 0, minutes3: 0, seconds3: 0);
  late Timer _timer;
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  var lastcheckintime;
  String? time24, time12;
  DateTime? parsedTime;
  var attendencedate;
  var _isnegative = false;

  void getusername() async {
    try {
      Response response = await post(Uri.parse('${globals.apiurl}token'),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonEncode({
            'email': email, //eve.holt@reqres.in
            'password': SHA1 //pistol
          })).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        var data1 = jsonDecode(response.body.toString());
        setState(() {
          username = data1['displayName'];
        });
        SharedPreferences prefinger = await SharedPreferences.getInstance();
        await prefinger.setString('username', username);
        _getAttendenceData();
      } else {
        Fluttertoast.showToast(
          //msg: response.statusCode.toString() + response.body,
          msg: "Server Error Found/Failed to Show Categories",
          //toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
      }
    } catch (e) {}
  }

  List _loadedattendence = [];
  var _lastattendence;
  var _isattendenceloading = false;

  // The function that fetches data from the API
  Future<void> _getAttendenceData() async {
    Fluttertoast.showToast(
      msg: "Looking for previous attendence Kindly wait!",
      //toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16,
    );
    try {
      //List<String> client_categories = [];
      Response response = await get(
        Uri.parse('${globals.apiurl}attendance/${userid}'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          'Authorization': 'Bearer ${token}'
        },
      ).timeout(const Duration(seconds: 50));
      print('view');
      print(response.statusCode);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        _loadedattendence = data;
        print(_loadedattendence);
        if (_loadedattendence.isNotEmpty) {
          print(_loadedattendence);
          setState(() {
            _lastattendence = _loadedattendence[_loadedattendence.length - 1];
          });
          if ((_lastattendence["attendanceType"] == "CHECK-IN" ||
              _lastattendence["attendanceType"] == "i")) {
            print('user check in');
            print(_lastattendence["client"]["fldID"]);
            print(_lastattendence["attendanceType"]);
            time24 =
                _lastattendence["attendanceTime"].toString().substring(11, 16);
            parsedTime = DateFormat('HH:mm').parse(time24!);
            String date =
                _lastattendence["attendanceTime"].toString().substring(0, 10);
            DateTime dateTime = DateTime.parse(date);
            setState(() {
              value = '1';
              _ischeckin = true;
              _isattendenceloading = false;
              clientid = _lastattendence["client"]["fldID"].toString();
              time12 = DateFormat('h:mm a').format(parsedTime!);
              time3 = _lastattendence["attendanceTime"]
                  .toString()
                  .substring(11, 19);
              attendencedate = DateFormat('dd-MMMM-yyyy').format(dateTime);
            });
            // print(time3);
            // print(clientid);
            SharedPreferences prefinger = await SharedPreferences.getInstance();
            await prefinger.setString('CI', '1');
            notificationServices.cancelnotification();
            notificationServices.schedulecheckoutinnotification(
                "Check-out Alert!",
                "Respected $username kindly mark the check-out.");
            Fluttertoast.showToast(
              msg: "Last Check-in at ${_lastattendence["client"]["fldName"]}",
              //toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 5,
              //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16,
            );
            check_two_times_is_before();
            _timerstart();
            // Fluttertoast.showToast(
            //   //msg: response.statusCode.toString() + response.body,
            //   msg: "Clients is ready to show!",
            //   //toastLength: Toast.LENGTH_SHORT,
            //   gravity: ToastGravity.BOTTOM,
            //   timeInSecForIosWeb: 5,
            //   //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
            //   backgroundColor: Colors.black,
            //   textColor: Colors.white,
            //   fontSize: 16,
            // );
          } else {
            print('user checkout');
            print(_lastattendence["client"]["fldID"]);
            print(_lastattendence["attendanceType"]);
            setState(() {
              value = '0';
              _ischeckin = false;
              _isattendenceloading = true;
              clientid = "";
              //lastcheckintime="";
              time12 = "";
              attendencedate = "";
            });
            SharedPreferences prefinger = await SharedPreferences.getInstance();
            await prefinger.setString('CI', '2');
            notificationServices.cancelnotification();
            notificationServices.schedulecheckinnotification("Check-in Alert!",
                "Respected $username kindly mark the check-in.");
            Fluttertoast.showToast(
              msg:
                  "Last Check-out at ${_lastattendence["client"]["fldName"]} now you can select client",
              //toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 5,
              //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16,
            );
            // Fluttertoast.showToast(
            //   //msg: response.statusCode.toString() + response.body,
            //   msg: "Clients is ready to show!",
            //   //toastLength: Toast.LENGTH_SHORT,
            //   gravity: ToastGravity.BOTTOM,
            //   timeInSecForIosWeb: 5,
            //   //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
            //   backgroundColor: Colors.black,
            //   textColor: Colors.white,
            //   fontSize: 16,
            // );
          }
        } else {
          setState(() {
            value = '0';
            _ischeckin = false;
            _isattendenceloading = true;
            clientid = "";
            //lastcheckintime="";
            time12 = "";
            attendencedate = "";
          });
          Fluttertoast.showToast(
            msg: "$username is a new user",
            //toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16,
          );
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void checkflogin() async {
    SharedPreferences prefinger = await SharedPreferences.getInstance();
    String? val1 = prefinger.getString("email12");
    String? val2 = prefinger.getString("SHA12");
    String? val3 = prefinger.getString("sval12");
    if (val3 != null && val1 != null) {
      if (val1 != email) {
        setState(() {
          isSwitched = false;
        });
        SharedPreferences prefinger = await SharedPreferences.getInstance();
        await prefinger.remove("email12");
        await prefinger.remove("SHA12");
        await prefinger.remove("sval12");
      } else {
        //print('fingerprint enable');
        setState(() {
          isSwitched = true;
        });
      }
    } else {
      setState(() {
        isSwitched = false;
      });
    }
  }

  void toggleSwitch(bool value) async {
    final isAvailable = await LocalAuthApi.hasBiometrics();
    final isDeviceSupported = await LocalAuthApi.isDeviceSupported();
    if (isSwitched == false) {
      if (isAvailable && isDeviceSupported) {
        setState(() {
          isSwitched = true;
          switchf = '1';
        });
        SharedPreferences prefinger = await SharedPreferences.getInstance();
        await prefinger.setString('email12', email);
        await prefinger.setString('SHA12', SHA1);
        await prefinger.setString('sval12', switchf);
      } else {
        setState(() {
          isSwitched = false;
          switchf = '0';
        });
      }

      Fluttertoast.showToast(
        msg: "Finger Print Login Enable Successfully",
        //toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16,
      );
      print('Switch Button is ON');
    } else {
      setState(() {
        isSwitched = false;
        switchf = '0';
      });
      SharedPreferences prefinger = await SharedPreferences.getInstance();
      String? val1 = prefinger.getString("email12");
      String? val2 = prefinger.getString("SHA12");
      String? val3 = prefinger.getString("sval12");
      await prefinger.remove("email12");
      await prefinger.remove("SHA12");
      await prefinger.remove("sval12");

      Fluttertoast.showToast(
        msg: "Finger Print Login Disable Successfully",
        //toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16,
      );
      print('Switch Button is OFF');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    token = widget.token1;
    email = widget.email1;
    userid = widget.userid1;
    SHA1 = widget.SHA11;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {});
    notificationServices.initializenotification();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_UpdateConnectionState);
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print("Error Occurred: ${e.toString()} ");
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _UpdateConnectionState(result);
  }

  Future<void> _UpdateConnectionState(ConnectivityResult result) async {
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      //getCred();
      //getstatus();
      getusername();
      getAllCategory();
      checkflogin();
      _getCurrentPosition();
      final snackBar = SnackBar(
          content: Row(
            children: const [
              Icon(
                Icons.wifi,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text("Internet is Connected"),
            ],
          ), //${result.toString()
          backgroundColor: Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //showStatus(result, true);
    } else {
      final snackBar = SnackBar(
          content: Row(
            children: const [
              Icon(
                Icons.wifi,
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Text("Internet is not Connected"),
            ],
          ), //${result.toString()
          backgroundColor: Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //showStatus(result, false);
    }
  }

  void _timerstart() {
    _timer.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // use timer when you are offline and cancel it when you are back online
      setState(() {
        if (time2.seconds3 < 59) {
          time2.seconds3++;
        } else {
          if (time2.minutes3 < 59) {
            time2.minutes3++;
          } else {
            time2.minutes3 = 0;
            time2.hours3++;
          }
          time2.seconds3 = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
      super.dispose();
    } else {
      super.dispose();
    }

    //await _stopWatchTimer.dispose(); // Need to call dispose function.
  }

  void getindex(String items) {}
  void check_two_times_is_before() {
    print("success time");
    String systime = DateFormat("HH:mm:ss").format(DateTime.now());
    var format = DateFormat("HH:mm:ss");
    var start = format.parse(time3);
    var end = format.parse(systime);

    Duration diff = end.difference(start);
    if (diff.isNegative) {
      diff = start.difference(end);
      final hours1 = diff.inHours;
      final minutes1 = diff.inMinutes % 60;
      final seconds1 = diff.inSeconds % 60;
      setState(() {
        hours = hours1;
        minutes = minutes1;
        seconds = seconds1;
        time2 = Time(hours3: hours, minutes3: minutes, seconds3: seconds);
      });
      // }
      print('$hours hours $minutes minutes $seconds seconds');
      print('$hours1 hours1 $minutes1 minutes1');
      setState(() {
        _isnegative = true;
      });
      Fluttertoast.showToast(
        msg:
            "Your Check-in is 1 or more days earlier.Kindly tap to check-out immediately!",
        //toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16,
      );
    } else {
      setState(() {
        _isnegative = false;
      });
      final hours1 = diff.inHours;
      final minutes1 = diff.inMinutes % 60;
      final seconds1 = diff.inSeconds % 60;
      //else if (hours > 0 && minutes > 0) {
      setState(() {
        hours = hours1;
        minutes = minutes1;
        seconds = seconds1;
        time2 = Time(hours3: hours, minutes3: minutes, seconds3: seconds);
      });
      // }
      print('$hours hours $minutes minutes $seconds seconds');
      print('$hours1 hours1 $minutes1 minutes1');
      //}
    }
  }

  void _getFrontCamera() async {
    if (value == "1") {
      try {
        XFile? pickedFile = (await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxHeight: 190,
          maxWidth: 190,
          //imageQuality: 200
        ));
        setState(() {
          //imageFile=File(pickedFile!.path);
          imageFile = File(pickedFile!.path);
        });
        print("$imageFile: imageFile");
        Uint8List imagebytes =
            await imageFile!.readAsBytes(); //convert to bytes
        //time = DateFormat("hh:mm a").format(DateTime.now());
        print("time before:$time");

        setState(() {
          base64string =
              base64.encode(imagebytes); //convert bytes to base64 string
        });
        setState(() {
          _ischeckin = false;
        });
        try {
          Response response =
              await post(Uri.parse('${globals.apiurl}attendance'),
                  headers: {
                    "Accept": "application/json",
                    "content-type": "application/json",
                    'Authorization': 'Bearer ${token}'
                  },
                  body: jsonEncode({
                    'userID': userid,
                    'attendanceTime': time,
                    'latitude': _currentPosition!.latitude.toString(),
                    'longitude': _currentPosition!.longitude.toString(),
                    'attendanceType': "CHECK-IN",
                    'imageBytes': base64string.toString(),
                    'attendanceAddress': _currentAddress.toString(),
                    'userInfo': null,
                    'clientID': clientid
                  })).timeout(const Duration(seconds: 25));
          if (response.statusCode == 200) {
            setState(() {
              time = DateFormat("hh:mm a").format(DateTime.now());
              time3 = DateFormat("HH:mm:ss").format(DateTime.now());
              time1 = '';
              _ischeckin = true;
            });

            var data = jsonDecode(response.body.toString());
            // print(data);
            // print('success');

            Fluttertoast.showToast(
              msg: "$username Check-in at $time",
              //toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16,
            );
            setState(() {
              _ischeckin = true;
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserDashboard(token, SHA1, email, userid),
              ),
            );
          } else {
            Fluttertoast.showToast(
              msg: "Server Error Found/Select a client",
              //toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 5,
              //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16,
            );
            //print('failed');
          }
        } catch (e) {
          print(e.toString());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserDashboard(token, SHA1, email, userid),
            ),
          );
          Fluttertoast.showToast(
            msg:
                "Internet is not working/Please enable the Location services then TAP Live Location",
            //toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16,
          );
          //print(e.toString());
        }
      } catch (e) {
        print("error messege${e.toString()}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboard(token, SHA1, email, userid),
          ),
        );
      }
    } else if (value == "2") {
      try {
        XFile? pickedFile = (await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxHeight: 190,
          maxWidth: 190,
          //imageQuality: 200
        ));
        setState(() {
          //imageFile=File(pickedFile!.path);
          imageFile = File(pickedFile!.path);
        });
        print(imageFile);
        Uint8List imagebytes =
            await imageFile!.readAsBytes(); //convert to bytes

        //print("time before:$time1");
        setState(() {
          base64string =
              base64.encode(imagebytes); //convert bytes to base64 string
        });
        try {
          Response response =
              await post(Uri.parse('${globals.apiurl}attendance'),
                  headers: {
                    "Accept": "application/json",
                    "content-type": "application/json",
                    'Authorization': 'Bearer ${token}'
                  },
                  body: jsonEncode({
                    'userID': userid,
                    'attendanceTime': time1,
                    'latitude': _currentPosition!.latitude.toString(),
                    'longitude': _currentPosition!.longitude.toString(),
                    'attendanceType': "CHECK-OUT",
                    'imageBytes': base64string.toString(),
                    'attendanceAddress': _currentAddress.toString(),
                    'userInfo': null,
                    'clientID': clientid
                  })).timeout(const Duration(seconds: 25));
          if (response.statusCode == 200) {
            setState(() {
              time1 = DateFormat("hh:mm a").format(DateTime.now());
            });
            var data = jsonDecode(response.body.toString());

            Fluttertoast.showToast(
              msg: "$username Check-out at $time1",
              //toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserDashboard(token, SHA1, email, userid),
              ),
            );
          } else {
            //print("Soaub ${response.body}");
            Fluttertoast.showToast(
              msg: "Server Error Found",
              //toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 5,
              //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16,
            );
            //print('failed');
          }
        } catch (e) {
          print(e.toString());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserDashboard(token, SHA1, email, userid),
            ),
          );
          Fluttertoast.showToast(
            msg:
                "Internet is not working/Please enable the Location services then TAP Live Location",
            //toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16,
          );
          //print(e.toString());
        }
      } catch (e) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboard(token, SHA1, email, userid),
          ),
        );
      }
    }
  }

  Future<void> getAllCategory() async {
    try {
      //List<String> client_categories = [];
      Response response = await get(
        Uri.parse('${globals.apiurl}attendance/clients'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          'Authorization': 'Bearer ${token}'
        },
      ).timeout(const Duration(seconds: 50));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (var element in data) {
          client_Search_categories.add(element['fldName']);
        }
        setState(() {
          client_categories = data;
        });
      } else {
        try {
          print("token expired");
          Response response = await post(Uri.parse('${globals.apiurl}token'),
              headers: {
                "Accept": "application/json",
                "content-type": "application/json"
              },
              body: jsonEncode({
                'email': email, //eve.holt@reqres.in
                'password': SHA1 //pistol
              })).timeout(const Duration(seconds: 25));

          if (response.statusCode == 200) {
            var data1 = jsonDecode(response.body.toString());
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UserDashboard(data1['password'], SHA1, email, userid),
              ),
            );
          } else {
            Fluttertoast.showToast(
              //msg: response.statusCode.toString() + response.body,
              msg: "Server Error Found/Failed to Show Categories",
              //toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 5,
              //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16,
            );
            //print('failed');
          }
        } catch (e) {
          print(e.toString());
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void getstatus() async {
    SharedPreferences pref2 = await SharedPreferences.getInstance();
    String? newstatus = await pref2.getString('status');
    String? newcid = await pref2.getString('CID');
    String? newtime = await pref2.getString('time');
    String? newtime2 = await pref2.getString('time2');
    if (newstatus == null && newtime == null && newcid == null) {
      value = "0";
      clientid = "";
      time = "";
      print("newstatus : $newstatus , newcid : $newcid , newtime : $newtime");
    } else {
      print("newstatus : $newstatus , newcid : $newcid , newtime : $newtime");
      setState(() {
        _ischeckin = true;
        _isclient = true;
        value = newstatus!;
        clientid = newcid;
        time = newtime!;
        time3 = newtime2!;
      });
      check_two_times_is_before();
      _timerstart();
      //startTimer();
    }
    print("newstatus : $newstatus , newcid : $newcid , newtime : $newtime");
  }

  //we get our credentials from shared pref and client categories
  void getCred() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    SharedPreferences pref1 = await SharedPreferences.getInstance();
    String? pretoken = pref.getString("login");
    String? newtoken = pref1.getString("login");
    if (pretoken == newtoken || newtoken == '') {
      setState(() {
        token = pref.getString("login")!;
        username = pref.getString("username")!;
        SHA1 = pref.getString("SHA1")!;
        email = pref.getString("email")!;
        userid = pref.getString("id")!;
      });
      print(email);
      print('pre token: $token');
      print("id: $userid");
    } else {
      setState(() {
        token = pref1.getString("login")!;
        username = pref.getString("username")!;
        SHA1 = pref.getString("SHA1")!;
        email = pref.getString("email")!;
        userid = pref.getString("id")!;
      });
      await pref.setString('login', token);
      getAllCategory();
      print('new token: $token');
      print("id: $userid");
      // print('SHA1: $SHA1');
      // print('email: $email');
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text('Location services are disabled. Please enable the services')));
      Fluttertoast.showToast(
        msg: "Location services are disabled. Please enable the services",
        //toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16,
      );
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
          msg: "Location permissions are denied",
          //toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
        msg:
            "Location permissions are permanently denied, we cannot request permissions.",
        //toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16,
      );
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        //_currentAddress
      });
      getAddressFromLatLng(
          _currentPosition!.latitude, _currentPosition!.longitude);
      //setState(() => _currentPosition = position);
      print(_currentPosition!);
      // print(_currentAddress);
    }).catchError((e) {
      //debugPrint(e);
    });
    // print('LAT: ${_currentPosition?.latitude}');
    // print('LNG: ${_currentPosition?.longitude}');
  }

  Future<void> getAddressFromLatLng(double lat, double lng) async {
    String _host = 'https://maps.google.com/maps/api/geocode/json';
    String mapApiKey = "AIzaSyAch-yWx3Q83D6WXdFFiHCbTOYvENkWon0";
    final url = '$_host?key=$mapApiKey&language=en&latlng=$lat,$lng';
    if (lat != null && lng != null) {
      try {
        var response = await get(Uri.parse(url));
        if (response.statusCode == 200) {
          Map data = jsonDecode(response.body.toString());
          setState(() {
            _currentAddress = data["results"][0]["formatted_address"];
            //_currentAddress='';
          });
          //print("response ==== $_currentAddress");
          //return _formattedAddress;
        } else {
          Fluttertoast.showToast(
            msg: "Server Error Found",
            //toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 15,
            //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16,
          );
          //_currentAddress='';
        }
      } catch (e) {}
    } else {
      Fluttertoast.showToast(
        msg: "Successfully Getting Location Address",
        //toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 15,
        //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16,
      );
    }
  }

  void markattendence() {
    _getFrontCamera();
  }

  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Check-Out Alert!',
              style: TextStyle(
                color: (value == "1" && _ischeckin)
                    ? Colors.green
                    : Colors.blue, // const Color.fromRGBO(209, 57, 13, 1),
              ),
            ),
          ),
          content: const Text(
            "Kindly mark check-out before logout.",
            //textAlign: TextAlign.left,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                15.0,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void logout() async {
    Fluttertoast.showToast(
      msg: "$username Logout Attendance Portal",
      //toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Auth_Screen(),
      ),
    );
  }

  double height = 0;
  double width = 0;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

// Height (without SafeArea)
    var padding = MediaQuery.of(context).viewPadding;
    double height1 = height - padding.top - padding.bottom;

// Height (without status bar)
    double height2 = height - padding.top;

// Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;
    return Scaffold(
      //backgroundColor: const Color.fromRGBO(255, 230, 230, 1),
      resizeToAvoidBottomInset: false,
      //backgroundColor: (_isclient && value == "1")?const Color.fromRGBO(243, 188, 135, 1):Colors.lightGreen,
      body: SingleChildScrollView(
        child: SizedBox(
          width: width,
          //height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(
              //   width: double.infinity,
              //   child:
              Container(
                height: height / 3.5,
                decoration: BoxDecoration(
                  color:
                      (value == "1" && _ischeckin) ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(70),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: height / 25,
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: width / 50,
                        ),
                        Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(
                          width: width / 40,
                        ),
                        Text(
                          username,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                    Center(
                      child: Image.asset(
                        'assets/images/attendence6.png',
                        //width: 100,
                        height: height / 6,
                        color: Colors.white,
                        //fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.date_range, color: Colors.blueGrey),
                    Center(
                      child: Text(
                        date,
                        style: TextStyle(
                          fontSize: width / 21,
                          color: (value == '1')
                              ? Colors.green
                              : Colors
                                  .blue, //const Color.fromRGBO(209, 57, 13, 1),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width / 9,
                    ),
                    const Icon(Icons.fingerprint_rounded,
                        color: Colors.blueGrey),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Finger Print',
                      style: TextStyle(
                        fontSize: width / 21,
                        color: (value == '1')
                            ? Colors.green
                            : Colors
                                .blue, //const Color.fromRGBO(209, 57, 13, 1),
                      ),
                    ),
                    Transform.scale(
                        scale: 1.2,
                        child: Switch(
                          onChanged: toggleSwitch,
                          value: isSwitched,
                          activeColor: (value == "1" && _ischeckin)
                              ? Colors.green
                              : Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
                          activeTrackColor: (value == "1" && _ischeckin)
                              ? Color.fromARGB(255, 198, 240, 200)
                              : Color.fromRGBO(185, 224, 241, 1),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor:
                              Color.fromARGB(255, 190, 186, 186),
                        )),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: height / 75, bottom: height / 75),
                child: Center(
                  child: Text(
                    "ATTENDENCE PORTAL",
                    style:
                        // GoogleFonts.openSans(color: const Color.fromRGBO(232, 141, 20, 1),fontSize: 25,),
                        TextStyle(
                      color: (value == "1" && _ischeckin)
                          ? Colors.green
                          : Colors.blue, //const Color.fromRGBO(209, 57, 13, 1),
                      //color: const Color.fromRGBO(232, 141, 20, 1),
                      fontSize: width / 16,
                      fontWeight: FontWeight.w900,
                      //letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: height / 75,
              ),
              Container(
                margin: EdgeInsets.only(left: width / 3.5),
                width: double.infinity,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/attendence5.png',
                      height: width / 10,
                      color: Colors.redAccent,
                      //fit: BoxFit.fill,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: () {
                        _getCurrentPosition();
                      },
                      child: Text(
                        "Live Location ",
                        style: TextStyle(
                          fontSize: width / 21,
                          color: (value == "1" && _ischeckin)
                              ? Colors.green
                              : Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height / 75,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: width / 15,
                  right: width / 15,
                  top: height / 60,
                ),
                child: Text(
                  _currentAddress ??
                      "Connect the Internet then refresh the page/Please enable the Location services then TAP Live Location",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: width / 24,
                    //color: (_currentAddress!.isNotEmpty)? const Color.fromRGBO(194, 35, 3, 1):const Color.fromRGBO(230, 105, 162, 1),
                    color: const Color.fromRGBO(209, 57, 13, 1),
                  ),
                ),
              ),
              (_ischeckin)
                  ? Container(
                      child: Column(
                        children: [
                          (!_isattendenceloading)
                              ? Container(
                                  margin: EdgeInsets.only(
                                    left: width / 15,
                                    right: width / 15,
                                    top: height / 75,
                                  ),

                                  // child: Form(
                                  //   key: _formKey1,
                                  //   autovalidateMode: AutovalidateMode.onUserInteraction,
                                  child: DropdownButtonFormField(
                                    isExpanded: true,

                                    //underline: const SizedBox(),//for dropdown button
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        // borderSide: BorderSide(
                                        //   color: Color.fromRGBO(105, 240, 174, 1),
                                        //   width: 1.0,
                                        // ),
                                      ),
                                      counterText: "",
                                      prefixIcon: Icon(
                                        Icons.person_add_alt_outlined,
                                      ),
                                    ),
                                    //const InputDecoration.collapsed(hintText: ''),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                    alignment: AlignmentDirectional.center,
                                    dropdownColor: Colors.white,

                                    value: (_ischeckin) ? clientid : null,
                                    validator: (value) => value == null
                                        ? 'Please select client'
                                        : null,
                                    icon: const Icon(
                                      Icons.arrow_drop_down_outlined,
                                      //Icons.keyboard_arrow_down_sharp,
                                      //color: Colors.grey.shade600,
                                    ),
                                    hint: const Text(
                                      'Select a Client',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    items: client_categories.map((item) {
                                      return DropdownMenuItem(
                                        value: item['fldID'].toString(),
                                        child: Text(item['fldName'].toString()),
                                      );
                                    }).toList(),

                                    onChanged: (_ischeckin || _isusercheckin)
                                        ? null
                                        : (area) {
                                            setState(() {
                                              _isclient = true;
                                              clientid = area.toString();
                                            });
                                            print(clientid);
                                          },
                                  ),
                                  //dropdownfieldform
                                  //),
                                  //),
                                )
                              : SizedBox(),
                          SizedBox(
                            height: height / 75,
                          ),
                          Column(
                            children: [
                              ((!_ischeckin) || (value == "1"))
                                  ? SizedBox(
                                      height: height / 75,
                                    )
                                  : const SizedBox(),
                              (value == "1" && _ischeckin)
                                  ? Container(
                                      margin:
                                          //EdgeInsets.only(left: !_ischeckin ? 100 : 95),
                                          EdgeInsets.only(left: width / 50),
                                      child: CustomRadioButton(
                                          "TAP TO CHECK-OUT", "2"),
                                    )
                                  : Container(),
                              (value == "1" && _ischeckin)
                                  ? SizedBox(
                                      height: height / 60,
                                    )
                                  : const SizedBox(
                                      height: 0,
                                    ),
                              (value == "1" && _ischeckin)
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(left: width / 4.5),
                                      child: Row(
                                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            buildTimeCard(
                                                time: time2.hours3,
                                                header: 'HRS'),
                                            SizedBox(
                                              width: width / 8,
                                            ),
                                            buildTimeCard(
                                                time: time2.minutes3,
                                                header: 'MIN'),
                                            SizedBox(
                                              width: width / 8,
                                            ),
                                            buildTimeCard(
                                                time: time2.seconds3,
                                                header: 'SEC'),
                                          ]),
                                    )
                                  : const SizedBox(),
                              (value == "1" && _ischeckin)
                                  ? SizedBox(
                                      height: height / 75,
                                    )
                                  : const SizedBox(
                                      height: 0,
                                    ),
                              (value == "1" && _ischeckin)
                                  ? Container(
                                      margin: EdgeInsets.only(
                                          left: (value == "1")
                                              ? width / 10
                                              : width / 10,
                                          right: width / 10),
                                      decoration: BoxDecoration(
                                        color: (value == "1")
                                            ? Colors.green
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.black26,
                                        ),
                                      ),
                                      child: SizedBox(
                                        height: height / 20,
                                        width: (value == "1")
                                            ? width / 1.4
                                            : width / 1,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              //width: width / 25,
                                              width: width / 30,
                                            ),
                                            (value == "1")
                                                ? const Icon(
                                                    Icons.timer,
                                                    color: Colors.white,
                                                  )
                                                : Container(),
                                            SizedBox(
                                              //width: width / 18,
                                              width: width / 30,
                                            ),
                                            (value == "1")
                                                ? Text(
                                                    //'CHECK-IN TIME  $time',
                                                    'CHECK-IN TIME  $time12',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  )
                                                : const Text(""),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              (_isnegative)
                                  ? SizedBox(
                                      height: height / 75,
                                    )
                                  : const SizedBox(
                                      height: 0,
                                    ),
                              (_isnegative)
                                  ? Container(
                                      margin: EdgeInsets.only(
                                          left: (_isnegative)
                                              ? width / 15
                                              : width / 10,
                                          right: width / 10),
                                      decoration: BoxDecoration(
                                        color: (_isnegative)
                                            ? Colors.green
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.black26,
                                        ),
                                      ),
                                      child: SizedBox(
                                        height: height / 20,
                                        width: (value == "1")
                                            ? width / 0.1
                                            : width / 1,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              //width: width / 25,
                                              width: width / 30,
                                            ),
                                            (_isnegative)
                                                ? const Icon(
                                                    Icons.date_range_sharp,
                                                    color: Colors.white,
                                                  )
                                                : Container(),
                                            SizedBox(
                                              //width: width / 18,
                                              width: width / 30,
                                            ),
                                            (_isnegative)
                                                ? Text(
                                                    //'CHECK-IN TIME  $time',
                                                    'CHECK-IN DATE  $attendencedate',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.8),
                                                  )
                                                : const Text(""),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          )
                          //),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: height / 75,
                        ),
                        (!_isattendenceloading)
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              )
                            : Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: width / 15,
                                      right: width / 15,
                                      top: height / 75,
                                    ),
                                    child: DropdownSearch<String>(
                                      enabled:
                                          !_isattendenceloading ? false : true,
                                      popupProps: const PopupProps.dialog(
                                        showSelectedItems: true,
                                        showSearchBox: true,
                                        dialogProps: DialogProps(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      items: client_Search_categories,
                                      //items: client_categories,
                                      dropdownDecoratorProps:
                                          const DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          counterText: "",
                                          prefixIcon: Icon(
                                            Icons.person_add_alt_outlined,
                                          ),
                                        ),
                                      ),

                                      validator: (value) {
                                        if (value.toString() ==
                                            'Select a Client') {
                                          return 'Please Select a Client';
                                        }
                                        return null;
                                      },
                                      onChanged: (selectclient) {
                                        var fldID =
                                            client_Search_categories.indexOf(
                                                    selectclient.toString()) +
                                                1;
                                        print(
                                            'index of $selectclient :  $fldID');
                                        setState(() {
                                          //placeValue = newValue!;
                                          _isclient = true;
                                          clientid = fldID.toString();
                                          //selecteditem=selectclient;
                                        });
                                        //print(selecteditem);
                                        print(clientid);
                                        print(selectclient);
                                      },
                                      selectedItem: "Select a Client",
                                    ),
                                  ),
                                  (_isclient)
                                      ? SizedBox(
                                          height: height / 75,
                                        )
                                      : const SizedBox(),
                                  (_isclient)
                                      ? Container(
                                          margin:
                                              //EdgeInsets.only(left: !_ischeckin ? 100 : 95),
                                              EdgeInsets.only(left: width / 50),
                                          child: CustomRadioButton(
                                              "TAP TO CHECK-IN", "1"),
                                        )
                                      : Container(),
                                ],
                              ),
                      ],
                    ),
              Container(
                height: height / 10,
                margin: EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: height / 55,
                ),
                decoration: BoxDecoration(
                  color: (value == "1" && _ischeckin)
                      ? Colors.green
                      : Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: "btn1",
                      backgroundColor: Colors.white,
                      onPressed: () {
                        // Navigator.pushNamedAndRemoveUntil(
                        //     context, 'dashboard', (route) => false);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDashboard(token, SHA1, email, userid),
                          ),
                        );
                        //Navigator.pushNamed(context, 'dashboard');
                      },
                      child: Icon(
                        Icons.refresh_outlined,
                        size: 25,
                        color: (value == "1" && _ischeckin)
                            ? Colors.green
                            : Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: "btn2",
                      backgroundColor: Colors.white,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAttendence(
                                token, userid, SHA1, email, username),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.remove_red_eye_sharp,
                        size: 25,
                        color: (value == "1" && _ischeckin)
                            ? Colors.green
                            : Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: "btn3",
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        logout();
                      },
                      child: Icon(
                        Icons.logout_outlined,
                        size: 25,
                        color: (value == "1" && _ischeckin)
                            ? Colors.green
                            : Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  var value = "0";
  Widget CustomRadioButton(String text, String index) {
    return
        // OutlinedButton(
        //   onPressed: () {
        //     setState(() {
        //       value = index;
        //     });
        //     markattendence();
        //   },
        //   style: OutlinedButton.styleFrom(
        //       shape:
        //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //       //side: const BorderSide(color: Colors.black),

        //       backgroundColor: //const Color.fromRGBO(238, 156, 52, 1)
        //           (value == index || !_ischeckin)
        //               ? Colors.green
        //               :
        //               //(value == index && _ischeckin)
        //               //?
        //               // const Color.fromRGBO(194, 35, 3, 1)
        //               Colors.red
        //       //: Colors.white,
        //       ),
        //   child: Text(
        //     text,
        //     style: const TextStyle(color: Colors.white
        //         //(value == index) ? Colors.white : Colors.black,
        //         ),
        //   ),
        // );
        Column(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: (value == '1') ? Colors.red : Colors.green,
          ),
        ),
        SizedBox(
          height: height / 75,
        ),
        FloatingActionButton.large(
          onPressed: () {
            setState(() {
              value = index;
            });
            markattendence();
          },
          backgroundColor:
              (value == index || !_ischeckin) ? Colors.green : Colors.red,
          foregroundColor: Colors.white,
          highlightElevation: 0,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(50),
          // ),

          child: (value == index || !_ischeckin)
              ? Icon(Icons.check)
              : Icon(Icons.done_all),
          //         Text(
          //       text,
          //       style: TextStyle(color: Colors.white, fontSize: 25),
          // ),
        ),
      ],
    );
  }
}

class Time {
  int hours3;
  int minutes3;
  int seconds3;
  Time({
    this.hours3 = 0,
    this.minutes3 = 0,
    this.seconds3 = 0,
  });
}

Widget buildTimeCard({required int time, required String header}) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(216, 86, 4, 1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black26,
            ),
          ),
          child: (time < 10)
              ? Text(
                  "0${time.toString()}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                )
              : Text(
                  time.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(header,
            style: const TextStyle(
              color: Color.fromRGBO(209, 57, 13, 1),
            )),
      ],
    );
