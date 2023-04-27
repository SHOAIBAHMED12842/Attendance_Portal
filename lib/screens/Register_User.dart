import 'dart:io';
import 'package:attendence_app_pwc/screens/auth_screen.dart';
import 'package:attendence_app_pwc/services/utils.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

//import 'package:convert/convert.dart';
import 'dart:convert';
import 'package:http/http.dart';
//import 'package:dio/dio.dart';
//import 'package:axios/axios.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  utilsservices snackbar = utilsservices();
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  File? imageFile;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  final _formKey5 = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _passControllerc = TextEditingController();
  final _userFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordcFocusNode = FocusNode();
  var _passwordVisible;
  var _passwordVisible1;
  var username, email, password, passwordc;
  var _validpassword = false;
  String placeValue = '';
  List _loadedemail = [];
  List _loadedusername = [];
  var usernameget;
  var emailget;
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  @override
  void initState() {
    _passwordVisible = false;
    _passwordVisible1 = false;
    // TODO: implement initState
    super.initState();
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
      get_username();
      get_email();
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

  void get_username() async {
    try {
      //List<String> client_categories = [];
      Response response = await get(
        Uri.parse('${globals.apiurl}user'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
        },
      ).timeout(const Duration(seconds: 50));
//       Response response = await Dio().get(
//   '${globals.apiurl}user',
//   options: Options(headers: {
//     "Accept": "application/json",
//     "content-type": "application/json",
//   }),
// ).timeout(Duration(seconds: 50));

      if (response.statusCode == 200) {
        // print("success");
        // print(response.body.toString());
        var data = jsonDecode(response.body.toString());
        //var data = jsonDecode(response.data);
        // print("DATA: $data");
        for (var element in data) {
          _loadedusername.add(element['displayName']);
        }
      } else {
        snackbar.showsnackbar("Server Error Found");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void get_email() async {
    try {
      //List<String> client_categories = [];
      Response response = await get(
        Uri.parse('${globals.apiurl}user'),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
        },
      ).timeout(const Duration(seconds: 50));
//       Response response = await Dio().get(
//   '${globals.apiurl}user',
//   options: Options(headers: {
//     "Accept": "application/json",
//     "content-type": "application/json",
//   }),
// ).timeout(Duration(seconds: 50));

      if (response.statusCode == 200) {
        // print("success");
        // print(response.body.toString());
        var data = jsonDecode(response.body.toString());
        // var data = jsonDecode(response.data);
        // print("DATA: $data");
        for (var element in data) {
          _loadedemail.add(element['email']);
        }
      } else {
        snackbar.showsnackbar("Server Error Found");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void dismissKeyboard() {
    _passwordcFocusNode.unfocus();
  }

  @override
  void dispose() {
    //print(config.toString());
    _userFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordcFocusNode.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void _getFrontCamera() async {
    XFile? pickedFile = (await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 190,
      maxWidth: 190,
      //imageQuality: 200
    ));
    setState(() {
      imageFile = File(pickedFile!.path);
    });
  }

  void register(
      String username1, String type, String email1, String password1) async {
    _loadedusername.forEach((item) {
      if (item.contains(username1)) {
        print("found");
        setState(() {
          usernameget = item;
        });
        //print(item);
      }
    });
    _loadedemail.forEach((item) {
      if (item.contains(email1)) {
        setState(() {
          emailget = item;
        });
      }
    });
    final isValid1 = _formKey1.currentState!.validate();
    final isValid2 = _formKey2.currentState!.validate();
    final isValid3 = _formKey3.currentState!.validate();
    final isValid4 = _formKey4.currentState!.validate();
    final isValid5 = _formKey5.currentState!.validate();

    if (isValid1 && isValid2 && isValid3 && isValid4 && isValid5) {
      _formKey1.currentState!.save();
      _formKey2.currentState!.save();
      _formKey3.currentState!.save();
      _formKey4.currentState!.save();
      _formKey5.currentState!.save();
      if (imageFile != null) {
        try {
          var SHA1Password = utf8.encode(password1);
          Digest sha1Result = sha256.convert(SHA1Password);
          print('SHA1: $sha1Result');
          Response response = await post(
              Uri.parse('${globals.apiurl}user'),
              headers: {
                "Accept": "application/json",
                "content-type": "application/json"
              },
              body: jsonEncode({
                'displayName': username1,
                'userName': type,
                'email': email1,
                'password': sha1Result.toString(),
                // imageBytes: adeel.toString(),
                'createdDate': null
              })).timeout(const Duration(seconds: 25));
          // Response response = await Dio().post(
          //   '${globals.apiurl}user',
          //   options: Options(headers: {
          //     "Accept": "application/json",
          //     "content-type": "application/json"
          //   }),
          //   data: jsonEncode({
          //     'displayName': username1,
          //     'userName': type,
          //     'email': email1,
          //     'password': sha1Result.toString(),
          //     'createdDate': null
          //   }),
          // );

          if (response.statusCode == 200) {
            var data = jsonDecode(response.body.toString());
            //  var data = jsonDecode(response.data);
            //  print("DATA: $data");
            Navigator.pushNamedAndRemoveUntil(
                context, 'auth', (route) => false);
            snackbar.showsnackbar("$username1 Register Successfully");
          } else {
            snackbar.showsnackbar("Server Error Found");
          }
        } catch (e) {
          snackbar.showsnackbar("Internet is not working");
        }
      } else {
        snackbar.showsnackbar("Kindly Capture Your Image");
      }
    }
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

      body: SingleChildScrollView(
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              // const SizedBox(
              //   height: 25,
              // ),
              (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                  ? SizedBox(
                      height: height / 5000,
                    )
                  : Container(
                      height: height / 3.5,
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
                          'assets/images/Registeration1.png',
                          //width: 100,
                          height: width / 3,
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
                            : height / 30,
                    bottom: height / 37),
                color: (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                    ? Colors.blue
                    : Colors
                        .transparent, //const Color.fromRGBO(209, 57, 13, 1): Colors.transparent,
                child: Column(
                  children: [
                    (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                        ? const SizedBox(
                            height: 25,
                          )
                        : const SizedBox(),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Auth_Screen(),
                              ),
                            );
                            //Navigator.pushNamed(context, 'auth');
                          },
                          icon: const Icon(
                            Icons.arrow_back_sharp,
                          ),
                          iconSize: width / 12,
                          color: (WidgetsBinding
                                      .instance.window.viewInsets.bottom >
                                  0.0)
                              ? Colors.white
                              : Colors
                                  .blue, //const Color.fromRGBO(209, 57, 13, 1),
                        ),
                        SizedBox(
                          width: width / 7,
                        ),
                        Text(
                          "REGISTRATION",
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
                            fontSize: width / 17,
                            fontWeight: FontWeight.w900,
                            //letterSpacing: 1,
                          ),
                        ),
                        SizedBox(
                          width: width / 8,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterUser(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.refresh_outlined,
                          ),
                          iconSize: width / 12,
                          color: (WidgetsBinding
                                      .instance.window.viewInsets.bottom >
                                  0.0)
                              ? Colors.white
                              : Colors
                                  .blue, //const Color.fromRGBO(209, 57, 13, 1),
                        ),
                      ],
                    ),
                    (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
                        ? const SizedBox(
                            height: 10,
                          )
                        : const SizedBox(),
                  ],
                ),
              ),

              Form(
                key: _formKey1,
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 10,
                  ),
                  //child: Flexible(
                  child: TextFormField(
                    key: const ValueKey('Username'),
                    //enabled: false,
                    focusNode: _userFocusNode,
                    controller: _userController,
                    //maxLength: 12,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                    onSaved: (value) {
                      username = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Username can\'t be empty';
                      }
                      if (value == usernameget) {
                        //print("username already exist!");
                        return 'Username already exist!';
                      }
                      //_isusernameexist=false;
                      return null;
                    },
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(105, 240, 174, 1),
                          width: 1.0,
                        ),
                      ),
                      counterText: "",
                      hintText: 'Username',
                      // hintStyle:
                      //     TextStyle(color: Colors.black38, fontSize: 14),
                      prefixIcon: Icon(
                        Icons.person_outline,
                      ),
                    ),
                  ),
                  // ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: 10,
                ),
                child: Form(
                  key: _formKey2,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: DropdownSearch<String>(
                    popupProps: const PopupProps.modalBottomSheet(
                      showSelectedItems: true,
                      modalBottomSheetProps: ModalBottomSheetProps(
                        isScrollControlled: true,
                        constraints: BoxConstraints(maxHeight: 175),
                        enableDrag: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    items: const ["Admin", "User"],
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration:
                          // InputDecoration(
                          //   hintText: "Select type",
                          //   hintStyle: TextStyle(fontWeight: FontWeight.bold,color:Colors.black),
                          //   //border: InputBorder.none,
                          // ),
                          InputDecoration(
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
                          Icons.type_specimen_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value.toString() == 'Select a Type') {
                        return 'Please select type';
                      }
                      return null;
                    },
                    // => value == 'SELECT'
                    //           ? 'Please select place'
                    //           : 'SELECT',
                    onChanged: (newValue) {
                      setState(() {
                        placeValue = newValue!;
                      });
                      //print(placeValue);
                    },
                    selectedItem: "Select a Type",
                  ),
                ),
                //),
              ),
              const SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey3,
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 10,
                  ),
                  //child: Flexible(
                  child: TextFormField(
                    key: const ValueKey('Email'),
                    //enabled: false,
                    controller: _emailController,
                    //maxLength: 12,
                    focusNode: _emailFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                    onSaved: (value) {
                      //_enteredconsumer = value!;
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
                        print("Too short");
                        return 'Too short';
                      }
                      if (value == emailget) {
                        //print("Email already exist!");
                        return 'Email already exist!';
                      }
                      // if(_isemailexist){
                      //   print("Email already exist!");
                      //   return 'Email already exist!';
                      // }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(105, 240, 174, 1),
                          width: 1.0,
                        ),
                      ),
                      counterText: "",
                      hintText: 'Email',
                      // hintStyle:
                      //     TextStyle(color: Colors.black38, fontSize: 14),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                      ),
                    ),
                  ),
                  //),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey4,
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 10,
                  ),
                  // child: Flexible(
                  child: TextFormField(
                    key: const ValueKey('Password:'),
                    //enabled: false,
                    obscuringCharacter: '*',
                    obscureText: !_passwordVisible,
                    controller: _passController,
                    maxLength: 20,
                    focusNode: _passwordFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordcFocusNode);
                    },
                    onSaved: (value) {
                      //_enteredconsumer = value!;
                      password = value;
                    },
                    validator: (value) {
                      RegExp regex = RegExp(
                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                      if (value!.isEmpty) {
                        return 'Please enter password';
                      } else {
                        if (!regex.hasMatch(value)) {
                          setState(() {
                            _validpassword = true;
                          });
                          return 'Enter valid password';
                        } else {
                          setState(() {
                            _validpassword = false;
                          });
                          return null;
                        }
                      }
                      // return null;
                    },
                    keyboardType: TextInputType.visiblePassword,
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
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(105, 240, 174, 1),
                          width: 1.0,
                        ),
                      ),
                      counterText: "",
                      hintText: 'Password',
                      // hintStyle:
                      //     TextStyle(color: Colors.black38, fontSize: 14),
                    ),
                  ),
                  //),
                ),
              ),

              _validpassword
                  ? Container(
                      margin: const EdgeInsets.only(left: 265),
                      child: IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Center(
                                      child: Text("Password Info"),
                                    ),
                                    scrollable: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          30.0,
                                        ),
                                      ),
                                    ),
                                    content:
                                        // SizedBox(
                                        //   child:
                                        Column(
                                      children: const [
                                        Text(
                                          "1-Should contain at least one upper case.",
                                          textAlign: TextAlign.justify,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "2-Should contain at least one lower case.",
                                          textAlign: TextAlign.justify,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "3-Should contain at least one digit number.",
                                          textAlign: TextAlign.justify,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "4-Should contain at least one Special character.",
                                          textAlign: TextAlign.justify,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "5-Must be at least 8 characters in length.",
                                          textAlign: TextAlign.justify,
                                        ),
                                      ],
                                    ),
                                    //)
                                    // SizedBox(
                                    //   //color: Colors.blue.shade800,
                                    //   height: 71,
                                    //   child: Center(
                                    //     child: Text(
                                    //       'Password Info',
                                    //       style: TextStyle(
                                    //         fontSize: 35,
                                    //         color: Colors.white,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  );
                                });
                          },
                          icon: const Icon(Icons.info_outlined)),
                    )
                  : const SizedBox(),
              !_validpassword
                  ? const SizedBox(
                      height: 10,
                    )
                  : const SizedBox(),
              Form(
                key: _formKey5,
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 10,
                  ),
                  //child: Flexible(
                  child: TextFormField(
                    key: const ValueKey('Confirm Password:'),
                    //enabled: false,
                    obscuringCharacter: '*',
                    obscureText: !_passwordVisible1,
                    controller: _passControllerc,
                    focusNode: _passwordcFocusNode,
                    maxLength: 20,
                    onFieldSubmitted: (_) {
                      dismissKeyboard();
                    },
                    onSaved: (value) {
                      //_enteredconsumer = value!;
                      passwordc = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Confirm Password can\'t be empty';
                      }
                      if (value != _passController.text) {
                        return 'Confirm Password not match with password';
                      }

                      return null;
                    },
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordVisible1
                              ? Icons.visibility
                              : Icons.visibility_off,
                          semanticLabel: _passwordVisible1
                              ? 'show password'
                              : 'hide password',
                          color: Colors
                              .blue, //const Color.fromRGBO(209, 57, 13, 1),
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordVisible1 = !_passwordVisible1;
                          });
                        },
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(105, 240, 174, 1),
                          width: 1.0,
                        ),
                      ),
                      counterText: "",
                      hintText: 'Confirm Password',
                      //hintText: 'Enter 12 digit Consumer No',
                      // hintStyle:
                      //     TextStyle(color: Colors.black38, fontSize: 14),
                    ),
                  ),
                  //),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              imageFile != null
                  ? Container(
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: Image.file(imageFile!))
                  : Container(
                      height: 200,
                      width: 150,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: const Center(child: Text("IMAGE AREA")),
                    ),
              const SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                //<-- SEE HERE
                backgroundColor:
                    Colors.blue, //const Color.fromRGBO(209, 57, 13, 1),
                onPressed: () async {
                  _getFrontCamera();
                },
                child: const Icon(
                  Icons.camera,
                  size: 45,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: height / 10,
                margin: EdgeInsets.only(
                  left: 50,
                  right: 50,
                  top: height / 55,
                ),
                decoration: const BoxDecoration(
                  color: Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
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
                        register(
                            _userController.text.toString(),
                            placeValue,
                            _emailController.text.toString(),
                            _passController.text.toString());
                      },
                      child: const Icon(
                        Icons.person_add_alt_1_sharp,
                        size: 25,
                        color: Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: "btn2",
                      backgroundColor: Colors.white,
                      onPressed: () {
                        Navigator.pushNamed(context, 'auth');
                      },
                      child: const Icon(
                        Icons.arrow_back_sharp,
                        size: 25,
                        color: Colors.blue, //Color.fromRGBO(209, 57, 13, 1),
                      ),
                    ),
                  ],
                ),
              ),
              //),
              const SizedBox(
                height: 55,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
