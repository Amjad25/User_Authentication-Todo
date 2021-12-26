import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_learning/screens/homescreen.dart';
import 'package:flutter/material.dart';

import 'package:firebase_learning/main.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

final emailcontoroller = TextEditingController();
final passwordcontoroller = TextEditingController();
final GlobalKey<FormState> _key = GlobalKey<FormState>();
String errormessage = '';
String useremail = '';

class _LoginState extends State<Login> {
  register() async {
    if (_key.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailcontoroller.text,
                password: passwordcontoroller.text);
        errormessage = '';
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          errormessage = e.message!;
          print('The password provided is too weak.\n');
        } else if (e.code == 'email-already-in-use') {
          errormessage = e.message!;
          print('The account already exists for that email.\n');
        }
        setState(() {});
      } catch (e) {
        print(e);
      }
    }
  }

  Signin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailcontoroller.text, password: passwordcontoroller.text);
      errormessage = '';
      setState(() {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
        useremail = emailcontoroller.text;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errormessage = e.message!;
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        errormessage = e.message!;
        print('Wrong password provided for that user.');
      }
      setState(() {});
    }
  }

  logout() async {}

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade400,
        title: Text('Auth User (Logged ' + (user == null ? 'out' : 'in') + ')'),
        leading: const Icon(Icons.fireplace),
      ),
      body: Center(
        child: Container(
          height: 500,
          width: 300,
          child: Center(
            child: Form(
              key: _key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  TextFormField(
                    controller: emailcontoroller,
                    validator: emailvalidator,
                    obscureText: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      labelText: 'email',
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: passwordcontoroller,
                    validator: passwordvalidator,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      labelText: 'Password',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            register();
                            setState(() {
                              // register();
                              emailcontoroller.clear();
                              passwordcontoroller.clear();
                            });
                          },
                          child: const Text("SignUP")),
                      ElevatedButton(
                          onPressed: () async {
                            Signin();
                            setState(() {
                              emailcontoroller.clear();
                              passwordcontoroller.clear();
                            });
                          },
                          child: const Text("SignIN")),
                      ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            setState(() {
                              emailcontoroller.clear();
                              passwordcontoroller.clear();
                            });
                          },
                          child: const Text("SignOUT")),
                    ],
                  ),
                  Center(
                    child: Text(
                      errormessage,
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? emailvalidator(String? value) {
    if (value == null || value.isEmpty) {
      return "email address is required";
    }
    String pattern = r'\w+@\w+\.\w+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return "invalied e-mail addrss format";
    }
    return null;
  }

  String? passwordvalidator(String? value) {
    if (value == null || value.isEmpty) {
      return "password is required";
    }
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    // RegExp regex = new RegExp(pattern);
    // if (!regex.hasMatch(value)) {
    // return '''
    //   Password must be at least 8 characters,
    //   include an uppercase letter, number and symbol.
    //   ''';
    // }
    return null;
  }
}
