import 'package:attendence_app_pwc/services/local_auth_api.dart';
import 'package:attendence_app_pwc/services/utils.dart';
import 'package:crypto/crypto.dart';
import 'globals.dart' as globals;
import 'dart:convert';
import 'dart:async';
import 'package:attendence_app_pwc/screens/user_dashboard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:dio/dio.dart';
//import 'package:enhanced_http/enhanced_http.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class Auth_Screen extends StatefulWidget {
  const Auth_Screen({super.key});

  @override
  State<Auth_Screen> createState() => _Auth_ScreenState();
}

class _Auth_ScreenState extends State<Auth_Screen> {
  utilsservices snackbar = utilsservices();
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  var emailf, passwordf;
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
  bool isfingerprintenable = false;
  bool isLoading = false;
  bool isLoadingf = false;
  var username;
  var chv;

  void checkflogin() async {
    SharedPreferences prefinger = await SharedPreferences.getInstance();
    String? val1 = prefinger.getString("email12");
    String? val2 = prefinger.getString("SHA12");
    String? val3 = prefinger.getString("sval12");
    String? val4 = prefinger.getString("username");
    if (val1 != null && val2 != null && val3 != null) {
      setState(() {
        emailf = val1;
        passwordf = val2;
        isfingerprintenable = true;
      });
    } else {
      setState(() {
        isfingerprintenable = false;
      });
    }
  }

  @override
  void initState() {
    _passwordVisible = false;
    // TODO: implement initState
    super.initState();
    // isKeyBoardvisible =
    //     KeyboardVisibilityProvider.isKeyboardVisible(context);
    //checkLogin();
    checkflogin();
    snackbar.notification();
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

  @override
  void dispose() {
    //print(config.toString());
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void login(String email, String password) async {
    final isValid1 = _formKey1.currentState!.validate();
    final isValid2 = _formKey2.currentState!.validate();

    if (isValid1 && isValid2) {
      _formKey1.currentState!.save();
      _formKey2.currentState!.save();
      setState(() {
        isLoading = true;
      });
      
      try {
        //print('here');
        var SHA1Password = utf8.encode(password);
        var sha1Result = sha1.convert(SHA1Password);
        Response response = await post(Uri.parse('${globals.apiurl}token'),
            headers: {
              "Accept": "application/json",
              "content-type": "application/json"
            },
            body: jsonEncode({
              'email': email, //eve.holt@reqres.in
              'password': sha1Result.toString() //pistol
            })).timeout(const Duration(seconds: 25));

        // print("respons: ${response.statusCode}");
        //print('here');
        // Response response = await Dio()
        //     .post(
        //       '${globals.apiurl}token',
        //       queryParameters: {
        //         'email': email,
        //         'password': sha1Result.toString(),
        //       },
        //       options: Options(
        //         headers: {
        //           "Accept": "application/json",
        //           "content-type": "application/json",
        //         },
        //       ),
        //     )
        //     .timeout(const Duration(seconds: 25));
        if (response.statusCode == 200) {
          setState(() {
            islogin = true;
          });
          var data = jsonDecode(response.body.toString());
          //var data = jsonDecode(response.data);
          //print("DATA: $data");
          pageRoute(data['password'], data['email'], data['displayName'],
              sha1Result.toString(), data['userId'].toString());
        } else {
          snackbar.showsnackbar(
              "Either Server Error Found or Enter Wrong Credentials");
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        snackbar.showsnackbar("Internet is not working");
      }
    }
  }

  void fingerprintlogin(String email, String SHA) async {
    setState(() {
      isLoadingf = true;
    });
    print(email);
    print(SHA);
    try {
      Response response = await post(Uri.parse('${globals.apiurl}token'),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonEncode({
            'email': email, //eve.holt@reqres.in
            'password': SHA //pistol
          })).timeout(const Duration(seconds: 25));
      // Response response = await Dio()
      //     .post(
      //       '${globals.apiurl}token',
      //       data: {
      //         'email': email,
      //         'password': SHA,
      //       },
      //       options: Options(
      //         headers: {
      //           "Accept": "application/json",
      //           "content-type": "application/json",
      //         },
      //       ),
      //     )
      //     .timeout(const Duration(seconds: 25));
      if (response.statusCode == 200) {
        setState(() {
          islogin = true;
        });
        var data = jsonDecode(response.body.toString());
        //var data = jsonDecode(response.data);
        pageRoute(data['password'], data['email'], data['displayName'], SHA,
            data['userId'].toString());
      } else {
        setState(() {
          isLoadingf = false;
        });
        snackbar.showsnackbar(
            "Either Server Error Found or Enter Wrong Credentials");
      }
    } catch (e) {
      setState(() {
        isLoadingf = false;
      });
      snackbar.showsnackbar("Internet is not working");
    }
  }

  void pageRoute(String token, String email1, String username2, String SHA1,
      String userid) async {
    setState(() {
      isLoading = false;
    });
    setState(() {
      isLoadingf = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UserDashboard(token, SHA1, email1, userid),
      ),
    );
    snackbar.showsnackbar("Welcome $username2 to TCRA Attendence Portal");
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
                      height: height / 3.3,
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
              isLoading
                  ? Center(
                      child: LinearProgressIndicator(
                      color: Colors.blue,
                    ))
                  : SizedBox.shrink(),
              isLoadingf
                  ? Center(
                      child: LinearProgressIndicator(
                      color: Colors.blue,
                    ))
                  : SizedBox.shrink(),
              Container(
                margin: EdgeInsets.only(
                    top:
                        (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                            ? 0
                            : height / 22,
                    bottom: height / 27),
                color: (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                    ? Colors.blue //const Color.fromRGBO(209, 57, 13, 1)
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
                              : Colors
                                  .blue, //const Color.fromRGBO(209, 57, 13, 1),
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
                          color: Colors
                              .blue, //const Color.fromRGBO(209, 57, 13, 1),
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
                          color: Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            utilsservices.openphone();
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
                margin: EdgeInsets.only(
                  left: width / 75,
                  //right: 40,
                ),
                child: SizedBox(
                  height: 75,
                  width: double.infinity,
                  child:
                      // Stack(
                      //   children: [
                      FloatingActionButton.large(
                    //<-- SEE HERE
                    backgroundColor:
                        Colors.blue, //const Color.fromRGBO(209, 57, 13, 1),
                    onPressed: () async {
                      dismissKeyboard();
                      login(
                        _emailController.text.toString(),
                        _passwordController.text.toString(),
                      );
                    },
                    child: Icon(
                      Icons.login,
                      size: 40,
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
                          color: Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: " Sign up",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
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
              const SizedBox(
                height: 15,
              ),
              Container(
                margin: EdgeInsets.only(left: width / 2.4),
                child: Row(
                  children: [
                    isfingerprintenable
                        ? IconButton(
                            onPressed: () async {
                              final isAuthenticated =
                                  await LocalAuthApi.authenticate();
                              if (isAuthenticated) {
                                fingerprintlogin(emailf, passwordf);
                              }
                            },
                            icon: const Icon(
                              Icons.fingerprint_outlined,
                            ),
                            iconSize: 40,
                            color: Colors.blue,
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
      //),
    );
  }
}
