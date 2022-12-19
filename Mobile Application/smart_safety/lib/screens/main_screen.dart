// Login Screen
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  // Constructor
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScrren();
}

class _MainScrren extends State<MainScreen> {
  // Create a stopwatch for time measurements
  var stopwatch = Stopwatch();

  // Variables to maintain the screen
  String username = 'John';

  // Variables for maintain the bluetooth and connection status
  bool connectionStatus = true;
  bool bluetoothStatus = false;

  //Variable for time measuring
  String workingTime = '00:00:00';

  // Buttons status of the main screen
  bool emergencyPressed = false;
  bool logoutPressed = false;

  // Variable for stiring temperarture
  String temperarture = "27";
  // Variables for Noise and Vibration indicators to show the saftey levels
  String vibrationStatus = "Safe";
  String noiseStatus = "Safe";

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
                // Welcome text of the app
                const Text(
                  "  Welcome, John!",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),

                // Bluetooth button
                IconButton(
                  icon: const Icon(Icons.bluetooth),
                  tooltip: 'Connect with Helmet',
                  iconSize: 40,
                  onPressed: () {
                    // have to implement function to the connect with bluetooth
                    setState(() {
                      bluetoothStatus = true;
                      startStopWatch(); // Starting stopwatch
                      updateWorkingTime(); // Updating working time
                      updateState();
                    });
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
              if (connectionStatus == true) {
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
                    Text(" Disonnected",
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
                    Text("$temperarture C ",
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
    if (stopwatch.isRunning) {
      updateWorkingTime(); // Callback the updaing function
    }

    setState(() {
      // Setting working time in state
      workingTime =
          '${stopwatch.elapsed.inHours.toString().padLeft(2, "0")}:${(stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, "0")}:${(stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, "0")}';
    });
  }

  // Function to perform Logout
  void logout() {
    // Navigation to the next screen
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => const Login()));
    // Calling firebase signout method
    FirebaseAuth.instance.signOut();
  }

  // Callback function to update state in every 5 second
  // initialize duration
  final updateDuration = const Duration(seconds: 5);
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
      connectionStatus = !connectionStatus;
      temperarture = random.nextInt(50).toString();
      vibrationStatus = vibrationStatus;
      noiseStatus = noiseStatus;
    });

    //Update State
    if (bluetoothStatus) {
      updateState();
    }
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
