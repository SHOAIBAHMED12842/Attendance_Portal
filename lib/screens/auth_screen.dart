import 'package:crypto/crypto.dart';
//import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'globals.dart' as globals;
//import 'package:convert/convert.dart';
import 'dart:convert';
import 'dart:async';
//import 'package:google_fonts/google_fonts.dart';
import 'package:attendence_app_pwc/screens/user_dashboard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
//import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class Auth_Screen extends StatefulWidget {
  const Auth_Screen({super.key});

  @override
  State<Auth_Screen> createState() => _Auth_ScreenState();
}

class _Auth_ScreenState extends State<Auth_Screen> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  GetStorage box = GetStorage();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var isValid = false;
  var email, password;
  var _passwordVisible;
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool islogin = false;

  @override
  void initState() {
    _passwordVisible = false;
    // TODO: implement initState
    super.initState();
    // isKeyBoardvisible =
    //     KeyboardVisibilityProvider.isKeyboardVisible(context);
    checkLogin();
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

  void dismissKeyboard() {
    _passwordFocusNode.unfocus();
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = AlertDialog(content: Text(text), actions: <Widget>[
      TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void checkLogin() async {
    //Here we check if user already login or credential already avalable or not
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? val = pref.getString("login");
    if (val != null) {
      //Navigator.push(context, MaterialPageRoute(builder: (context)=> const UserDashboard()));
      Navigator.pushNamedAndRemoveUntil(context, 'dashboard', (route) => false);
    }
  }

  @override
  void dispose() {
    //print(config.toString());
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  static Future<void> openphone() async {
    Uri phoneno = Uri.parse('tel: +923322045416'); //'tel:+923041112482'
    if (await launchUrl(phoneno)) {
      //dialer opened
    } else {
      //dailer is not opened
    }
  }

  void login(String email, String password) async {
    final isValid1 = _formKey1.currentState!.validate();
    final isValid2 = _formKey2.currentState!.validate();

    if (isValid1 && isValid2) {
      _formKey1.currentState!.save();
      _formKey2.currentState!.save();
      try {
        var SHA1Password = utf8.encode(password);
        var sha1Result = sha1.convert(SHA1Password);
        //  print(email);
        //  print(password);
        //  print(SHA1Password);
        //  print('SHA1: $sha1Result');
        // Response response = await post(
        //   Uri.parse('https://reqres.in/api/login'),
        //   body: {
        //     'email' : email,//eve.holt@reqres.in
        //     'password' : password,//pistol
        //   }
        // );
        Response response = await post(Uri.parse('${globals.apiurl}token'),
            headers: {
              "Accept": "application/json",
              "content-type": "application/json"
            },
            body: jsonEncode({
              'email': email, //eve.holt@reqres.in
              'password': sha1Result.toString() //pistol
            })).timeout(const Duration(seconds: 25));

        if (response.statusCode == 200) {
          // box.write('email',email);
          // print(box.read('email').toString());
          // box.remove('email');
          setState(() {
            islogin = true;
          });
          var data = jsonDecode(response.body.toString());
          //print(data);
          // print("token");
          // print(data['token']);
          //print('Login successfully');
          pageRoute(data['password'], data['email'], data['displayName'],
              sha1Result.toString(), data['userId'].toString());
        } else {
          //print("Soaub ${response.body}");
          Fluttertoast.showToast(
            //msg: response.statusCode.toString() + response.body,
            msg: "Either Server Error Found or Enter Wrong Credentials",
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
        Fluttertoast.showToast(
          msg: "Internet is not working",
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
    }
  }

  void pageRoute(String token, String email1, String username2, String SHA1,
      String userid) async {
    //stored token in shared prefrences
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('login', token);
    await pref.setString('username', username2);
    await pref.setString('SHA1', SHA1);
    await pref.setString('email', email1);
    await pref.setString('id', userid);
    // print("SHA1: $SHA1");
    // print("email: $email1");
    //Navigator.push(context, MaterialPageRoute(builder: (context)=> const UserDashboard()));
    //Navigator.pushNamedAndRemoveUntil(context, 'dashboard', (route) => false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const UserDashboard(),
      ),
    );
    Fluttertoast.showToast(
      msg: "Welcome $username2 to TCRA Attendence Portal",
      //toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      //backgroundColor: const Color.fromRGBO(232, 141, 20, 1),
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  double height = 0;
  double width = 0;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      //backgroundColor: const Color.fromRGBO(255, 230, 230, 1),
      resizeToAvoidBottomInset: false,
      //backgroundColor: Color.fromRGBO(243,190,38, 1),
      body:
          // SizedBox(
          //   height: deviceSize.height,
          //   width: deviceSize.width,
          //   child:
          SingleChildScrollView(
        child: SizedBox(
          //height: height,
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                  ? SizedBox(
                      height: height / 5000,
                    )
                  : Container(
                      height: height / 2.5,
                      margin: const EdgeInsets.only(
                          //top: 20,
                          //left: 130,
                          ),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(209, 57, 13, 1),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(70),
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/login.png',
                          //width: 100,
                          height: width / 2.5,
                          color: Colors.white,
                          //fit: BoxFit.fill,
                        ),
                      ),
                    ),
              Container(
                margin: EdgeInsets.only(
                    top:
                        (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                            ? 0
                            : height / 22,
                    bottom: height / 27),
                color: (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                    ? const Color.fromRGBO(209, 57, 13, 1)
                    : Colors.transparent,
                child: Column(
                  children: [
                    (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                        ? const SizedBox(
                            height: 30,
                          )
                        : const SizedBox(),
                    Center(
                      child: Text(
                        "LOGIN",
                        style:
                            // GoogleFonts.openSans(color: const Color.fromRGBO(232, 141, 20, 1),fontSize: 25,),
                            TextStyle(
                          color: (WidgetsBinding
                                      .instance.window.viewInsets.bottom >
                                  0.0)
                              ? Colors.white
                              : const Color.fromRGBO(209, 57, 13, 1),
                          //color: const Color.fromRGBO(232, 141, 20, 1),
                          fontSize: width / 12,
                          fontWeight: FontWeight.w900,
                          //letterSpacing: 1,
                        ),
                      ),
                    ),
                    (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                        ? const SizedBox(
                            height: 10,
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              // SizedBox(
              //   width: double.infinity,
              //   child: Container(
              //     margin: const EdgeInsets.only(left: 50, right: 50),
              //     child: Image.asset(
              //       'assets/images/login.png',
              //       //width: 100,
              //       height: 150,
              //       //fit: BoxFit.fill,
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
              Form(
                key: _formKey1,
                //autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          key: const ValueKey('email'),
                          //focusNode: focusNode,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          focusNode: _emailFocusNode,
                          //maxLength: 11,
                          onChanged: (value) {
                            //phone = value;
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          },
                          onSaved: (value) {
                            email = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty ||
                                !value.contains('@') ||
                                !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            if (value.length < 4) {
                              return 'Too short';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(100.0),
                              ),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 10.0,
                              ),
                            ),
                            //border: InputBorder.none,
                            counterText: "",
                            hintText: 'Email',
                            // errorText: _validate
                            //     ? 'Phone number Can\'t Be Empty'
                            //     : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              // Expanded(
              //   child:
              Form(
                key: _formKey2,
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 10),
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    key: const ValueKey('password'),
                    controller: _passwordController,
                    obscuringCharacter: '*',
                    obscureText:
                        !_passwordVisible, //This will obscure text dynamically
                    focusNode: _passwordFocusNode,
                    keyboardType: TextInputType.visiblePassword,
                    //maxLength: 11,
                    onChanged: (value) {
                      //phone = value;
                    },
                    onSaved: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password is Required';
                      }
                      if (value.length < 8) {
                        return 'Must be 8 character long';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          semanticLabel: _passwordVisible
                              ? 'show password'
                              : 'hide password',
                          color: const Color.fromRGBO(209, 57, 13, 1),
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(100.0),
                        ),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      //border: InputBorder.none,
                      counterText: "",
                      hintText: 'Password',
                      // errorText: _validate
                      //     ? 'Phone number Can\'t Be Empty'
                      //     : null,
                    ),
                  ),
                ),
              ),
              //),

              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Forgot Password?",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color.fromRGBO(209, 57, 13, 1),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            openphone();
                          },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 40,
                  right: 40,
                ),
                child: SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: FloatingActionButton.large(
                    //<-- SEE HERE
                    backgroundColor: const Color.fromRGBO(209, 57, 13, 1),
                    onPressed: () async {
                      dismissKeyboard();
                      login(
                        _emailController.text.toString(),
                        _passwordController.text.toString(),
                      );
                    },
                    child: Icon(
                      Icons.login,
                      size: 55,
                      color: !islogin ? Colors.white : Colors.amber,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                margin: const EdgeInsets.only(right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: "Don't have an account?",
                        style: TextStyle(
                          color: Color.fromRGBO(209, 57, 13, 1),
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: " Sign up",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color.fromRGBO(209, 57, 13, 1),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, 'RegU', (route) => false);
                          },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30,)
              // SizedBox(
              //   width: double.infinity,
              //   child: Container(
              //     margin: const EdgeInsets.only(top: 50, left: 50, right: 50),
              //     child: Image.asset(
              //       'assets/images/PricewaterhouseCoopers_Logo.svg.png',
              //       //width: 100,
              //       height: 100,
              //       //fit: BoxFit.fill,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      //),
    );
  }
}
