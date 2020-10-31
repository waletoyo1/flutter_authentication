import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authentication/dashboard.dart';
import 'package:flutter_authentication/user_manager.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Login Home '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FlutterLogin(
          title: 'Welcome!',
          emailValidator: (value) {
            if (value.isEmpty) {
              return 'E-Mail cannot be empty';
            }
            return null;
          },
          passwordValidator: (value) {
            if (value.length < 6) {
              return 'Password Must be at least 6 characters';
            }
            return null;
          },
          logo: 'assets/image.png',
          theme: LoginTheme(
            primaryColor: Colors.green,
            accentColor: Colors.lightGreenAccent,
          ),
          onLogin: (LoginData data) => FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: data.name, password: data.password)
              .then((user) async {
            //save the user details for continuous loggin
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('email', data.name);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => DashBoard()));
          }).catchError((e) {
            setState(() {
              _errorMessage = e.message;
            });

            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text('Error'),
                      content: Text('$_errorMessage'),
                      actions: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                            // Navigator.of(context).pop();
                          },
                          child: Text('ok'),
                          color: Colors.amberAccent,
                        )
                      ],
                    ));

            print(e);
          }),
          onSignup: (LoginData data) => FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: data.name, password: data.password)
              .then((signedInUser) async {
            //next page
            UserManager()
                .addUserDetails(signedInUser.user.email, signedInUser.user.uid);
            //stores email in shared preference for persistent login
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('email', data.name);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => DashBoard()));

            print(' ${signedInUser.user.email}');
          }).catchError((e) {
            setState(() {
              _errorMessage = e.message;
            });

            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text('Error'),
                      content: Text('$_errorMessage'),
                      actions: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                            // Navigator.of(context).pop();
                          },
                          child: Text('ok'),
                          color: Colors.amberAccent,
                        )
                      ],
                    ));
          }),
          onSubmitAnimationCompleted: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ));
          },
          onRecoverPassword: (String email) => FirebaseAuth.instance
              .sendPasswordResetEmail(email: email)
              .then((value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return MyHomePage();
            }));
          }).catchError((e) {
            print(e);
            setState(() {
              _errorMessage = e.message;
            });
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text('Error'),
                      content: Text('$_errorMessage'),
                      actions: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                            // Navigator.of(context).pop();
                          },
                          child: Text('ok'),
                          color: Colors.amberAccent,
                        )
                      ],
                    ));
          }),
        ));
  }
}
