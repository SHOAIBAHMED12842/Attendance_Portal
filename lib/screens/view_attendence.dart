import 'dart:async';
import 'package:attendence_app_pwc/screens/user_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'globals.dart' as globals;
//import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
//import 'package:internet_connection_checker/internet_connection_checker.dart';

class ViewAttendence extends StatefulWidget {
  //const ViewAttendence({super.key});
  String token = "";
  String userid = "";
  String SHA1 = "";
  String email = "";
  String username = "";
  ViewAttendence(this.token, this.userid, this.SHA1, this.email, this.username,
      {super.key});

  @override
  State<ViewAttendence> createState() => _ViewAttendenceState();
}

class _ViewAttendenceState extends State<ViewAttendence> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String newtoken = "";
  String newuserid = "";
  String newSHA1 = "";
  String newemail = "";
  String newusername = "";
  int totalcheckin = 0;
  int totalcheckout = 0;
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    newtoken = widget.token;
    newuserid = widget.userid;
    newSHA1 = widget.SHA1;
    newemail = widget.email;
    newusername = widget.username;
    print(newusername);
    print("token: $newtoken   userid: $newuserid");
    //_getAttendenceData();
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
      _getAttendenceData();
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

  void totalstatus() {
    for (var element in _loadedattendence) {
      if ((element['attendanceType']) == "CHECK-IN" ||
          (element['attendanceType']) == "i") {
        setState(() {
          totalcheckin++;
        });
      } else if ((element['attendanceType']) == "CHECK-OUT" ||
          (element['attendanceType']) == "o") {
        setState(() {
          totalcheckout++;
        });
      }
    }
    print("TOTAL CHECK-IN : $totalcheckin");
    print("TOTAL CHECK-out : $totalcheckout");
  }

  // The list that contains information about attendence
  List _loadedattendence = [];
  List _lastattendence = [];
  var _isempty = false;
  // The function that fetches data from the API
  Future<void> _getAttendenceData() async {
    try {
      //List<String> client_categories = [];
      Response response = await get(
        Uri.parse('${globals.apiurl}attendance/$newuserid'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          'Authorization': 'Bearer $newtoken'
        },
      ).timeout(const Duration(seconds: 50));
      if (response.statusCode == 200) {
        // print("success");
        // print(response.body.toString());
        var data = jsonDecode(response.body.toString());
        setState(() {
          _loadedattendence = data;
        });
        //print(_loadedattendence[_loadedattendence.length-1]);
        totalstatus();
        //print(_loadedattendence);
        if (_loadedattendence.isNotEmpty) {
          setState(() {
            _isempty = false;
          });
          Fluttertoast.showToast(
            //msg: response.statusCode.toString() + response.body,
            msg: "Attendence Details is ready to show!",
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
            _isempty = true;
          });
          Fluttertoast.showToast(
            //msg: response.statusCode.toString() + response.body,
            msg: "No data found",
            //toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16,
          );
        }
      } else {
        try {
          print("token expired");
          Response response = await post(Uri.parse('${globals.apiurl}token'),
              headers: {
                "Accept": "application/json",
                "content-type": "application/json"
              },
              body: jsonEncode({
                'email': newemail, //eve.holt@reqres.in
                'password': newSHA1 //pistol
              })).timeout(const Duration(seconds: 25));

          if (response.statusCode == 200) {
            var data1 = jsonDecode(response.body.toString());
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ViewAttendence(data1['password'],
                    newuserid, newSHA1, newemail, newusername),
              ),
            );
          } else {
            //print("Soaub ${response.body}");
            Fluttertoast.showToast(
              //msg: response.statusCode.toString() + response.body,
              msg: "Server Error Found/Failed to Load Attendence data",
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
          // Fluttertoast.showToast(
          //   msg: "Internet is not working Kindly Connect it",
          //   //toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.BOTTOM,
          //   timeInSecForIosWeb: 5,
          //   //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
          //   backgroundColor: Colors.black,
          //   textColor: Colors.white,
          //   fontSize: 16,
          // );
        }
      }
    } catch (e) {
      print(e.toString());
      // Fluttertoast.showToast(
      //   msg: "Internet is not working Kindly Connect it",
      //   //toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      //   timeInSecForIosWeb: 5,
      //   //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
      //   backgroundColor: Colors.black,
      //   textColor: Colors.white,
      //   fontSize: 16,
      // );
      //print(e.toString());
    }
  }

  double height = 0;
  double width = 0;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //backgroundColor: const Color.fromRGBO(255, 230, 230, 1),
      body: SingleChildScrollView(
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(
              //   height: 30,
              // ),
              Container(
                height: height / 3.5,
                //width: width,
                margin: const EdgeInsets.only(
                    //top: 20,
                    //left: 130,
                    ),
                decoration: const BoxDecoration(
                  color: Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
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
                          newusername,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.view_list_sharp,
                      color: Colors.white,
                      size: width / 3,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: height / 100),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDashboard(widget.token,
                                widget.SHA1, widget.email, widget.userid),
                          ),
                        );
                        //Navigator.pushNamed(context, 'dashboard');
                      },
                      icon: const Icon(
                        Icons.arrow_back_sharp,
                      ),
                      iconSize: width / 12,
                      color:
                          Colors.blue, //const Color.fromRGBO(209, 57, 13, 1),
                    ),
                    SizedBox(
                      width: width / 7,
                    ),
                    Image.asset(
                      'assets/images/view4.png',
                      //width: 100,
                      height: width / 3.5,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(
                      width: width / 8,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAttendence(newtoken,
                                newuserid, newSHA1, newemail, newusername),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.refresh_outlined,
                      ),
                      iconSize: width / 12,
                      color:
                          Colors.blue, //const Color.fromRGBO(209, 57, 13, 1),
                    ),
                  ],
                ),
              ),
              // Text("token: $newtoken"),
              // Text("userid: $newuserid"),
              //  Text("SHA1: $newSHA1"),
              // Text("EMAIL: $newemail"),
              // Container(
              //   margin: const EdgeInsets.only(left: 90, right: 90),
              //   color: const Color.fromRGBO(216, 86, 4, 1),
              //   child: Center(
              //     child: Text(
              //       "Total Attendence Data  >>  ${_loadedattendence.length}",
              //       style: const TextStyle(color: Colors.white),
              //     ),
              //   ),
              // ),
              _loadedattendence.isEmpty
                  ? Column(
                      children: [
                        SizedBox(
                          height: height / 8,
                        ),
                        !_isempty
                            ? Center(
                                child:
                                    //Text("No Attendence data found")
                                    CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              )
                            : Center(
                                child:
                                    //Text("No Attendence data found")
                                    Text(
                                  "No Data Found",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 20),
                                ),
                              ),
                      ],
                    )
                  :
                  // Expanded(
                  //   //margin: const EdgeInsets.only(left: 25,right: 25 ),
                  //   child:
                  Column(
                      children: [
                        Center(
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            //color: const Color.fromRGBO(216, 86, 4, 1),
                            child: Container(
                              width: width / 3.0,
                              margin: const EdgeInsets.only(
                                  left: 3, right: 10, bottom: 5),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        ),
                                        const Text(
                                          "Check-In",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                        Text(
                                          "$totalcheckin",
                                          style: const TextStyle(
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Icons.check,
                                          color: Colors.red,
                                        ),
                                        const Text(
                                          "Check-Out",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        Text(
                                          "$totalcheckout",
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Icons.add_task_sharp,
                                          color: Colors.blue,
                                        ),
                                        const Text(
                                          "Total",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        Text(
                                          "${_loadedattendence.length}",
                                          style: const TextStyle(
                                              color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                    // const SizedBox(
                                    //   height: 5,
                                    // ),
                                  ]),
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          reverse: true,

                          //scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _loadedattendence.length,
                          itemBuilder: (context, index) {
                            String time24 = _loadedattendence[index]
                                    ["attendanceTime"]
                                .toString()
                                .substring(11, 16);
                            DateTime time =
                                DateTime.parse("2023-04-12 " + time24 + ":00");
                            String formattedTime = DateFormat.jm().format(time);
                            String date = _loadedattendence[index]
                                    ["attendanceTime"]
                                .toString()
                                .substring(0, 10);
                            DateTime dateTime = DateTime.parse(date);
                            String formattedDate =
                                DateFormat('dd-MMMM-yyyy').format(dateTime);
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8),
                              child: Container(
                                // decoration: BoxDecoration(
                                //   border: Border.all(
                                //     color: (_loadedattendence[index]
                                //                   ["attendanceType"] ==
                                //               "CHECK-OUT" ||
                                //           _loadedattendence[index]
                                //                   ["attendanceType"] ==
                                //               "o")
                                //       ? Colors.red
                                //       : (_loadedattendence[index]
                                //                       ["attendanceType"] ==
                                //                   "CHECK-IN" ||
                                //               _loadedattendence[index]
                                //                       ["attendanceType"] ==
                                //                   "i")
                                //           ? Colors.green
                                //           : Colors.black,
                                //   ),
                                // ),

                                // decoration: const ShapeDecoration(
                                //   shape: RoundedRectangleBorder(
                                //     side: BorderSide(
                                //       color: Colors.black,
                                //        //style: BorderStyle.solid
                                //        ),
                                //     borderRadius:
                                //         BorderRadius.all(Radius.circular(10.0)),
                                //   ),
                                // ),
                                margin:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: 10,
                                  shadowColor: (_loadedattendence[index]
                                                  ["attendanceType"] ==
                                              "CHECK-OUT" ||
                                          _loadedattendence[index]
                                                  ["attendanceType"] ==
                                              "o")
                                      ? Colors.red
                                      : (_loadedattendence[index]
                                                      ["attendanceType"] ==
                                                  "CHECK-IN" ||
                                              _loadedattendence[index]
                                                      ["attendanceType"] ==
                                                  "i")
                                          ? Colors.green
                                          : Colors.black,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: (_loadedattendence[index]
                                                      ["attendanceType"] ==
                                                  "CHECK-OUT" ||
                                              _loadedattendence[index]
                                                      ["attendanceType"] ==
                                                  "o")
                                          ? Color.fromRGBO(232, 141, 20, 1)
                                          : (_loadedattendence[index]
                                                          ["attendanceType"] ==
                                                      "CHECK-IN" ||
                                                  _loadedattendence[index]
                                                          ["attendanceType"] ==
                                                      "i")
                                              ? Colors.greenAccent
                                              : Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  color: (_loadedattendence[index]
                                                  ["attendanceType"] ==
                                              "CHECK-OUT" ||
                                          _loadedattendence[index]
                                                  ["attendanceType"] ==
                                              "o")
                                      ? Colors.redAccent
                                      : (_loadedattendence[index]
                                                      ["attendanceType"] ==
                                                  "CHECK-IN" ||
                                              _loadedattendence[index]
                                                      ["attendanceType"] ==
                                                  "i")
                                          ? Colors.green
                                          : Colors.black,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Center(
                                          child: Text(
                                            "${index + 1}",
                                            textAlign: TextAlign.justify,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        // Text(
                                        //   "ID  >>  ${_loadedattendence[index]["id"]}",
                                        //   textAlign: TextAlign.justify,
                                        //   style: const TextStyle(
                                        //       color: Colors.white),
                                        // ),
                                        Text(
                                          "Client  >>  ${_loadedattendence[index]["client"]["fldName"]}",
                                          textAlign: TextAlign.justify,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Status  >>  ${_loadedattendence[index]["attendanceType"]}",
                                              textAlign: TextAlign.justify,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            const Icon(
                                              Icons.check_box,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                        // const SizedBox(
                                        //   height: 3,
                                        // )
                                        Row(
                                          children: [
                                            Text(
                                              "Date  >>  $formattedDate",
                                              textAlign: TextAlign.justify,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "Time  >>  $formattedTime",
                                          textAlign: TextAlign.justify,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        // const SizedBox(
                                        //   height: 3,
                                        // ),
                                        Text(
                                          "Location  >>  ${_loadedattendence[index]["attendanceAddress"]}",
                                          textAlign: TextAlign.justify,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
              //),
            ],
          ),
        ),
      ),
    );
  }
}
