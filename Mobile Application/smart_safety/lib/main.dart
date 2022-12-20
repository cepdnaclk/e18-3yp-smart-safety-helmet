import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_safety/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Safety',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const SignIn(),
    );
  }
}

// Class to sign in using email and password
class SignIn extends StatelessWidget {
  // Constructor
  const SignIn({super.key});

  // Return the next screen after authentication
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return const MainScreen(); // Return to the main screen with logged user
            }
            if (snapshot.hasError) {
              return const ErrorLogin();
            } else {
              return const Login(); // else remain in the login page
            }
          })),
    );
  }
}

// Login Screen of the system
class Login extends StatefulWidget {
  //Constructor
  const Login({super.key});

  // Build the UI
  @override
  State<Login> createState() => _Login();
}

// Stateful login Ui
class _Login extends State<Login> {
  // Declarer controllers to get passwords and username
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Dispose the controllers when widget is disposed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return the UI of the login Screen
    return Scaffold(
      // Body of the login screen
      body: Column(
        children: [
          // Image of the Login UI
          const Center(
            child: Image(
                image: AssetImage('images/mobile_top.jpg'), fit: BoxFit.fill),
          ),

          // title
          const Center(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                  text: "Smart ",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 50)),
              TextSpan(
                  text: 'Safety',
                  style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 50))
            ])),
          ),

          // Space between Title and Inputs
          const SizedBox(height: 45),

          // User Name input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                  hintText: 'Email', icon: Icon(Icons.person)),
            ),
          ),

          // Gap between buttons
          const SizedBox(height: 25),

          // Password Input

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  hintText: 'Password', icon: Icon(Icons.verified_user)),
            ),
          ),

          // Gap Betweeen button and input
          const SizedBox(
            height: 40,
          ),

          // Add the Login Button
          SizedBox(
            width: 300.0,
            height: 50,
            child: ElevatedButton(
              onPressed: signIn,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Authenticating user with firebase
  Future<void> signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
  }
}

// Registered user model
class RegisteredUser {
  // Properties of the registered user
  String id;
  final String name;
  final String password;

  // Constructor for creating registered user object
  RegisteredUser({this.id = '', required this.name, required this.password});

  // Method for gettting user data from cloud firestore
  static RegisteredUser fromJSON(Map<String, dynamic> json) {
    return RegisteredUser(name: json['name'], password: json['password']);
  }
}

// Widget for show Login error
class ErrorLogin extends StatelessWidget {
  //constructor
  const ErrorLogin({super.key});

  // Return the npotification that shows errror
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Login Error',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: const <Widget>[
            Text(
              'Check your e-mail and password and try again !',
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(
              height: 25,
            ),
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 100,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'OK',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
