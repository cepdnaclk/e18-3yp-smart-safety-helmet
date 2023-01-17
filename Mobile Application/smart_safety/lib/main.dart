import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_safety/screens/first_screen.dart';
// import 'package:smart_safety/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

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
      home: const Login(),
    );
  }
}

// Class to sign in using email and password
// class SignIn extends StatelessWidget {
//   // Constructor
//   const SignIn({super.key});

//   // Return the next screen after authentication
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: ((context, snapshot) {
//             if (snapshot.hasData) {
//               return const MainScreen(
//                 username: "Tharindu",
//               ); // Return to the main screen with logged user

//             }
//             if (snapshot.hasError) {
//               return const ErrorLogin();
//             } else {
//               return const Login(); // else remain in the login page
//             }
//           })),
//     );
//   }
// }

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
  // State to Keep the username
  String username = "user-name";
  // State to keep userId
  String userId = "";
  // Declarer controllers to get passwords and username
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State of location and bluetooth
  bool location = false;
  bool bluetoothStatus = false;

  // Password view variable
  bool _obsecure = true;

  // Initializescreen
  @override
  void initState() {
    super.initState();

    // request bluetooth and location access
    requestLocationAccess();
    requestBluetoothAccess();
  }

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
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image of the Login UI
              const Center(
                child: Image(
                    image: AssetImage('images/mobile_top.jpg'),
                    fit: BoxFit.fill),
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
                  obscureText: _obsecure,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obsecure = !_obsecure;
                            });
                          },
                          icon: Icon(_obsecure
                              ? Icons.visibility
                              : Icons.visibility_off)),
                      hintText: 'Password',
                      icon: const Icon(Icons.verified_user)),
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

              // Gap betwwen login button and status widgets
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to navigate to the nextscreen
  void navigationToMain() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConnectingScreen(
                  username: username,
                  userID: userId,
                )));
  }

  // Function to request Location persmission
  Future<void> requestLocationAccess() async {
    // Request for location services to be on
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // If permission is denied request for permission
      permission = await Geolocator.requestPermission();

      // After requesting permisssion cheeck whther permission is denieed or not
      // IF permission is denied set it in state
      if (permission == LocationPermission.denied) {
        setState(() {
          location = false;
        });
      }

      // if the permission is given
      else {
        setState(() {
          location = true;
        });
      }
    }

    // If permission are given as always or location services are while in use
    if ((permission == LocationPermission.whileInUse) ||
        (permission == LocationPermission.always)) {
      // Set the location to the state
      setState(() {
        location = true;
      });
    }
  }

  // Function to enable location
  Future<void> enableLocation() async {
    // Get the location is enabled or not
    bool? isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (isLocationEnabled) {
      setState(() {
        location = true;
      });
    }

    // if location is not turn on
    if (!isLocationEnabled) {
      // Request to enable location
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Enable Location"),
            content: const Text(
                "Location services are disabled. Please enable location services in settings."),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("Open Settings"),
                onPressed: () async {
                  final bool isLocationEnabled =
                      await Geolocator.isLocationServiceEnabled();
                  if (!isLocationEnabled) {
                    // redirect to location settings
                    final bool serviceStatus =
                        await Geolocator.isLocationServiceEnabled();
                    if (!serviceStatus) {
                      // ignore: use_build_context_synchronously
                      if (Theme.of(context).platform ==
                          TargetPlatform.android) {
                        await Geolocator.openAppSettings();
                        // ignore: use_build_context_synchronously
                      } else if (Theme.of(context).platform ==
                          TargetPlatform.iOS) {
                        await Geolocator.openLocationSettings();
                      }
                    }
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Function to request bluetooth permission
  Future<void> requestBluetoothAccess() async {
    // check whether bluetooth is enable or not
    bool? isBluetoothEnabled = await FlutterBluetoothSerial.instance.isEnabled;

    // requet access
    if ((isBluetoothEnabled != null) && (isBluetoothEnabled)) {
      setState(() {
        bluetoothStatus = true;
      });
    }
    if ((isBluetoothEnabled != null) && (!isBluetoothEnabled)) {
      // Request acess to enable bluetooth
      FlutterBluetoothSerial.instance.requestEnable();
      setState(() {
        bluetoothStatus = false;
      });
    }
  }

  // Authenticating user with firebase
  Future<void> signIn() async {
    try {
      final loggedUserResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text.trim().toLowerCase(),
              password: _passwordController.text.trim());

      // Get the logged user id
      var userID = loggedUserResult.user?.uid;

      // get the document related to the user ID
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();

      // get the data from the document
      var userName = doc.get('name');

      // await FirebaseFirestore.instance
      //     .collection('workers').doc()
      //     .where('User ID', isEqualTo: userID)
      //     .get()
      //     .then((value) {
      //   print(value.docs);
      // });

      // Update the State
      setState(() {
        username = userName;
        userId = userID!;
      });

      // Navigate to the main screen
      navigationToMain();
    }
    // if there is login error t will shown as dialog
    catch (ex) {
      // This dialog box show warning when login error occured
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Login Error',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            content: const Text('Invalid Credentials ! Try Again',
                style: TextStyle(fontSize: 20)),
            actions: <Widget>[
              TextButton(
                child: const Text("Close",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
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
