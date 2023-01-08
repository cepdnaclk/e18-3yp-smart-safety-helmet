// Login Screen
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_safety/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_safety/screens/blueetoth.dart';
import 'package:smart_safety/screens/discover_page.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';

class MainScreen extends StatefulWidget {
  // Variable to store username
  final String username;

  // Constructor
  const MainScreen({super.key, required this.username});

  @override
  State<StatefulWidget> createState() => _MainScrren();
}

class _MainScrren extends State<MainScreen> {
  // Create a stopwatch for time measurements
  var stopwatch = Stopwatch();

  // Variables to maintain the nocation
  bool getNotified = false;

  // Variables for maintain the bluetooth and connection status
  // bool connectionStatus = true;
  bool bluetoothStatus = false;

  //Variable for time measuring
  String workingTime = '00:00:00';

  // Buttons status of the main screen
  bool emergencyPressed = false;
  bool logoutPressed = false;

  // Variable for stiring temperature
  String temperature = "27";
  // Variables for Noise and Vibration indicators to show the saftey levels
  String vibrationStatus = "Safe";
  String noiseStatus = "Safe";

  // State for locations
  var longitude = '';
  var altitude = '';

  // Variable for storing geolocation
  String geolocation = '';

  // Function of initializing state
  @override
  void initState() {
    // Constructor
    super.initState();

    // Request access to geo ocator when initializing
    requestLocationAccess();
  }

  // Function t dispose
  @override
  void dispose() {
    super.dispose();
  }

  // Function to request access to geo locator and set location state
  Future requestLocationAccess() async {
    // Request for location services to be on
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // If permission is denied request for permission
      permission = await Geolocator.requestPermission();

      // Get the location
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      // Set the location to the state
      setState(() {
        geolocation = "$position";
      });

      //After requesting permisssion cheeck whther permission is denieed or not
      // IF permission is denied set it in state
      if (permission == LocationPermission.denied) {
        setState(() {
          geolocation = "Permission Denied";
        });
      }
    }

    // If permission are given as always or location services are while in use
    if ((permission == LocationPermission.whileInUse) ||
        (permission == LocationPermission.always)) {
      // Get the location
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      // Set the location to the state
      setState(() {
        geolocation = "$position";
      });
    }
  }

  // Buliding the UI of the main Screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add a gap with head of the scrren
            const SizedBox(
              height: 60,
            ),

            // welcome text and bluetooth button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "  Hi, ",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    // Welcome text of the app
                    Text(
                      widget.username,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),

                    const Text(
                      " !",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    )
                  ],
                ),

                // Bluetooth button
                IconButton(
                  icon: const Icon(Icons.bluetooth),
                  tooltip: 'Connect with Helmet',
                  iconSize: 40,
                  onPressed: () {
                    // have to implement function to the connect with bluetooth
                    // Pairing screen with blueetoth
                    navigateBluetooth();
                    setState(() {
                      bluetoothStatus =
                          FlutterBluetoothSerial.instance.state as bool;
                    });
                    // Updating status
                    // startStopWatch(); // Starting stopwatch
                    // updateWorkingTime(); // Updating working time
                    // updateState();
                  },
                ),
              ],
            ),

            // Gap between welocme text and connection status text
            const SizedBox(
              height: 30,
            ),

            // Connection status text
            const Text(
              "Connection Status",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            // Return the connection status
            LayoutBuilder(builder: (context, constratints) {
              if (bluetoothStatus == true) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.brightness_1,
                      color: Colors.green,
                    ),
                    Text(" Connected",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.green))
                  ],
                );
              }
              // Rendering disconnected status
              else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.brightness_1,
                      color: Colors.red,
                    ),
                    Text(" Disconnected",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.red))
                  ],
                );
              }
            }),

            // Gap between timer widget and connection status
            const SizedBox(height: 30),

            Text("test $geolocation"),

            // Timer to get work time
            SizedBox(
              // Sizes of the widgets
              height: 100,
              width: 350,
              child: Card(
                // Gradient of the widget
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(colors: [
                        Color.fromARGB(255, 255, 230, 0),
                        Color.fromARGB(255, 234, 247, 115)
                      ])),

                  // Stopwatch and working time widget
                  child: Column(
                    children: [
                      // Gap for clarity
                      const SizedBox(height: 5),
                      const Text("Working Time",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),

                      // Space between timer and it's title
                      const SizedBox(
                        height: 10,
                      ),

                      // Show time of the Stopwatch in the widget
                      Text(
                        workingTime,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Add a space between tempareture and working time
            const SizedBox(
              height: 30,
            ),

            // Temperature indicationg widget
            SizedBox(
              height: 60,
              width: 350,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(colors: [
                      Color.fromARGB(255, 255, 230, 0),
                      Color.fromARGB(255, 234, 247, 115)
                    ])),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("  Temperature",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    Text("$temperature C ",
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),

            //  Space between noise and temparature indicators
            const SizedBox(
              height: 30,
            ),

            // Noise warning widget
            SizedBox(
              height: 60,
              width: 350,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(colors: [
                      Color.fromARGB(255, 255, 230, 0),
                      Color.fromARGB(255, 234, 247, 115)
                    ])),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("  Noise",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    Text("$noiseStatus  ",
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),

            // Space between noise and vibration level indicator
            const SizedBox(
              height: 30,
            ),

            // Vibration warning wodget
            SizedBox(
              height: 60,
              width: 350,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(colors: [
                      Color.fromARGB(255, 255, 230, 0),
                      Color.fromARGB(255, 234, 247, 115)
                    ])),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("  Vibration",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    Text("$vibrationStatus  ",
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),

            // Space between indicators and buttons
            const SizedBox(
              height: 30,
            ),

            // Buttons for logout and send emergency status to the server
            // Button for sending emergency to the sever
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: (() => setState(() {
                      emergencyPressed =
                          true; // Set state of the button to the pressed
                      emergency();
                    })),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text(
                  'Emergency',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),

            // Space between two buttons for clarity
            const SizedBox(
              height: 20,
            ),

            // logout button for log out the system
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: logout, // Call logout function
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to start Stop watch
  void startStopWatch() {
    stopwatch.start();
  }

  // Add a callback function to update state after 1 seonde of delay
  // Duration variable for get a one second
  final duration = const Duration(seconds: 1);

  // Function for updating stopwatch
  void updateWorkingTime() {
    // Add a Timer function to update state regulary after every second after starting working timer
    Timer(duration, calculateTime);
  }

  // Function to update state of the stopwatch
  void calculateTime() {
    setState(() {
      // Setting working time in state
      workingTime =
          '${stopwatch.elapsed.inHours.toString().padLeft(2, "0")}:${(stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, "0")}:${(stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, "0")}';
    });

    if (stopwatch.isRunning) {
      updateWorkingTime(); // Callback the updaing function
    }
  }

  // Function to perform Logout
  void logout() {
    // Navigation to the next screen
    // Calling firebase signout method
    FirebaseAuth.instance.signOut();
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => const Login()));

    // Replace the page with Login page
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login()));
    // dispose();
  }

  // Callback function to update state in every 5 second
  // initialize duration
  final updateDuration = const Duration(seconds: 5);

  // Function to update State
  void updateState() {
    // Call back check state
    Timer(updateDuration, checkState);
  }

  // Check state function
  // Blueetoth data should be proceed here
  // then after 1 second state will be updated
  void checkState() {
    Random random = Random();

    // Set states (After analysing data recieved from bluetooth module)
    setState(() {
      bluetoothStatus = !bluetoothStatus;
      temperature = random.nextInt(50).toString();
      vibrationStatus = vibrationStatus;
      noiseStatus = noiseStatus;
    });

    // Data which is send to the Colud firestore
    // String conState = 'disconnected';
    String btState = 'disconnected';

    // If bluetoooth is enabled set BT state to connected
    if (bluetoothStatus) {
      btState = "connected";
    }

    // Update location
    updatePosition();

    // Create data with sensor details to send to the firebase
    createData(
        username: widget.username,
        // connectionStatus: conState,
        bluetoothStatus: btState,
        noiseStatus: noiseStatus,
        vibrationStatus: vibrationStatus,
        workingTime: workingTime,
        temparature: temperature.toString());

    //Update State if bluetooth connection is available
    if (bluetoothStatus) {
      updateState();
    }

    // get notification
    getNotifications();
  }

  // Function to update position
  Future updatePosition() async {
    // Get the position
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    // Set state as position
    String locationData = "$position";

    // Set state
    setState(() {
      geolocation = locationData;
    });
  }

  // Function to the navigate to the Bluutoth pairing screen
  void navigateBluetooth() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Bluetooth()));
  }

  // Function to show message which shows that emergency was sent
  Future<void> emergency() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Emergency',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  'Emergency message was sent successfully !',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(
                  height: 25,
                ),
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
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
                setState(() {
                  emergencyPressed = false; // Set State to emergency pressed
                });
                sendNotification(
                    name: widget.username); // Send noptification with username
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Funcion to popup notification
  Future<void> notifications() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Notification',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  'Emergency is detetced around you !',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(
                  height: 25,
                ),
                Icon(
                  Icons.notification_add_rounded,
                  color: Colors.yellow,
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
                setState(() {
                  getNotified = false; // Set State to emergency pressed
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to create notification
  Future sendNotification({required String name}) async {
    // Reference to the notification database
    final userDoc =
        FirebaseFirestore.instance.collection('safety-notification').doc();

    // Create notification object
    final notification = Notification(name: widget.username);

    // Convert into the JSOn format
    final json = notification.toJSON();

    // Send to the cloud firestore
    await userDoc.set(json);
  }

  // Function to send data to the database
  Future createData(
      {required String username,
      // required String connectionStatus,
      required String bluetoothStatus,
      required String noiseStatus,
      required String vibrationStatus,
      required String temparature,
      required String workingTime}) async {
    // Referenec to the collection (AppData)
    final userDoc = FirebaseFirestore.instance.collection('appdata').doc();

    // Create data object
    final data = UserData(
        id: userDoc.id,
        username: username,
        // connectionStatus: connectionStatus,
        bluetoothStatus: bluetoothStatus,
        noiseStatus: noiseStatus,
        vibrationStatus: vibrationStatus,
        temparature: temparature,
        workingTime: workingTime,
        position: geolocation);
    // location: geolocation);
    // longitude: longitude,
    // altitude: altitude);

    // Create JSON object
    final jsondata = data.toJSON();

    // Send data to the Cloud Firestore
    await userDoc.set(jsondata);
  }

  // Firebase get realtime notification
  Future getNotifications() async {
    // Use firebase instance
    DatabaseReference database = FirebaseDatabase.instance.ref();

    // Set the state of notification
    final snapshot = await database.child('notified').get();
    if (snapshot.exists) {
      // ignore: avoid_print
      print(snapshot.toString());
    } else {
      // ignore: avoid_print
      print('No data available.');
    }

    // Call popup notification
    if (getNotified) {
      notifications();
    }
  }
}

// Model for Sending user Data to server
class UserData {
  final String id;
  final String username;
  // final String connectionStatus;
  final String bluetoothStatus;
  final String noiseStatus;
  final String vibrationStatus;
  final String temparature;
  final String workingTime;
  // final String longitude;
  // final String altitude;
  // final String location;
  final DateTime date = DateTime.now();
  final String position;

  // Constructor to the model
  UserData(
      {required this.id,
      required this.username,
      // required this.connectionStatus,
      required this.bluetoothStatus,
      required this.noiseStatus,
      required this.vibrationStatus,
      required this.temparature,
      required this.workingTime,
      required this.position});
  // required this.location});
  // required this.longitude,
  // required this.altitude});

  // Method to create JSON object
  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': username,
        // 'connectionStatus': connectionStatus,
        'bluetoothStatus': bluetoothStatus,
        'noiseStatus': noiseStatus,
        'vibrationStatus': vibrationStatus,
        'temparature': temparature,
        'working-time': workingTime,
        'date': date,
        'location': position
        // 'longitude': longitude,
        // 'altitude': altitude
      };

  // Method for Creating data to the JSON format
}

// Notifications Model
class Notification {
  // Variables of the user
  final String name;
  final DateTime date = DateTime.now();

  // Constructor of this model
  Notification({required this.name});

  // Convert object into the JSON format
  Map<String, dynamic> toJSON() => {'name': name, 'date': date};
}
