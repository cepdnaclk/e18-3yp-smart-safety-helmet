// Login Screen
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_safety/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_safety/screens/discover_page.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';

class MainScreen extends StatefulWidget {
  // Variable to store username
  final String username;

  // Get the bluetooth device to communicate
  final BluetoothDevice server;

  // Constructor
  const MainScreen({super.key, required this.username, required this.server});

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
  // Variables for Noise and Vibration indicators to show the saftey levels

  String temperature = "27";
  String vibrationStatus = "Safe";
  String noiseStatus = "Safe";
  String gasStatus = "Safe";

  // State for locations
  var longitude = '';
  var altitude = '';

  // Variable for storing geolocation
  String geolocation = '';

  // Create blueetooth instance
  // Declare a FlutterBluetoothSerial instance
  FlutterBluetoothSerial flutterBluetoothSerial =
      FlutterBluetoothSerial.instance;

  // test purposes
  String btState = '';

  // Adddress of the connected device
  String deviceAddress = '';

  // ==================================== Bluetoooth Variables ========================================================

  // Bluetooth connection
  BluetoothConnection? connection;

  // Bool is connnecting
  bool isConnecting = false;

  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  // Message buffer
  String _messageBuffer = '';

  // Sensor data variable
  String sensorData = '';

  // List to store data
  List<String> dataList = List<String>.empty(growable: true);

  // ==================================================================================================================

  // Function of initializing state
  @override
  void initState() {
    // Constructor
    super.initState();

    // Start the timer and update working time
    startStopWatch();
    updateWorkingTime();

    // Check whether bluetooth device is connected
    if (widget.server.isConnected) {
      setState(() {
        bluetoothStatus = true;
      });
    } else {
      setState(() {
        bluetoothStatus = false;
      });
    }

    // Check connection
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.

        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      if (kDebugMode) {
        print('Cannot connect, exception occured');
        print(error);
      }
    });

    // // Request access to geo ocator when initializing
    requestLocationAccess();
  }

  // Function t dispose
  @override
  void dispose() {
    // flag to set is connected
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    // Dispose the context
    super.dispose();
  }

  // Bluetooth data reciving
  // Method for getting data from HC 05 module
  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }

    // get data to the buffer
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    // length of the buffer is get as index
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(10);
    if (~index != 0) {
      setState(() {
        // Set message to the sensor data
        // Clear previous data before add new data for space

        // Adding sensor data to the variable
        sensorData = dataString.trim();

        // Adding sensor data to the list
        dataList.add(backspacesCounter > 0
            ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString.substring(0, index));

        // Get the message
        _messageBuffer = dataString.substring(index);
      });
    }

    // Else
    else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  // Bluetooth data sending
  void _sendMessage(String text) async {
    text = text.trim();

    if (text.isNotEmpty) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
        await connection!.output.allSent;

        setState(() {});
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  // Function to check and set bluetooth state
  void setBluetoothState() {
    // if device is connected
    if (widget.server.isConnected) {
      setState(() {
        bluetoothStatus = true;
      });
    }

    // if device is not connected
    else {
      setState(() {
        bluetoothStatus = false;
      });
    }
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
    return WillPopScope(
      onWillPop: () async {
        // When pressing back button it will ask to logout or otherwise it will remai in the same screen
        logoutPopUp();

        return false;
      },
      child: Scaffold(
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
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      // Welcome text of the app
                      Text(
                        widget.username,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),

                      const Text(
                        " !",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),

                  // Bluetooth button
                  // IconButton(
                  //   icon: const Icon(Icons.bluetooth),
                  //   tooltip: 'Connect with Helmet',
                  //   iconSize: 40,
                  //   onPressed: () {
                  //     // have to implement function to the connect with bluetooth
                  //     // Pairing screen with blueetoth
                  //     navigateBluetooth(context);
                  //     setState(() {
                  //       bluetoothStatus =
                  //           FlutterBluetoothSerial.instance.state as bool;
                  //     });
                  //     // Updating status
                  //     // startStopWatch(); // Starting stopwatch
                  //     // updateWorkingTime(); // Updating working time
                  //     // updateState();
                  //   },
                  // ),
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

              // Test purpose only
              Text("test $sensorData"),

              // Timer to get work time
              SizedBox(
                // Sizes of the widgets

                height: 110,
                width: 350,
                child: Card(
                  // Deactivate the backgroun
                  elevation: 0,
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
                        const SizedBox(height: 10),
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

              //  Space between gas and temparature indicators
              const SizedBox(
                height: 30,
              ),

              // Gas status inidcating widget
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
                      const Text("  Gas Status",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      Text("$gasStatus  ",
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
                  onPressed: logoutPopUp, // Call logout function
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

              // Space below the screen
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  // ===================================================== Bluetooth Communication ========================================

  // Function to the navigate to the Bluutoth pairing screen
  // Implementing navigateto the bluetooth
  // Future<void> navigateBluetooth(BuildContext context) async {
  //   // Do the navigation
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const DiscoveryPage()),
  //   );

  //   // Check themounted property
  //   if (!mounted) return;

  //   // Set State
  //   setState(() {
  //     deviceAddress = result;
  //   });

  //   // Create a device with that address
  //   BluetoothDevice device = BluetoothDevice(address: result, name: "Device");

  //   // Setting state of connection state
  //   // if connectedd
  //   if (device.isConnected) {
  //     setState(() {
  //       bluetoothStatus = true;
  //     });
  //   }

  //   // if disconnected
  //   if (!device.isConnected) {
  //     setState(() {
  //       bluetoothStatus = true;
  //     });
  //   }
  // }

  //=======================================================================================================================

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

  // Method to pop up about logout
  Future<void> logoutPopUp() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Log-Out',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  'Do you want to logout ? ',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                logout();
              },
            )
          ],
        );
      },
    );
  }

  // Function to perform Logout
  void logout() {
    // Navigation to the next screen
    // Calling firebase signout method
    FirebaseAuth.instance.signOut();

    // Replace the page with Login page
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login()));

    // Disconnect Bluetooth device
    flutterBluetoothSerial.requestDisable();
    flutterBluetoothSerial.setPairingRequestHandler(null);
    dispose();
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
    // Random random = Random();

    // Set states (After analysing data recieved from bluetooth module)
    setState(() {
      bluetoothStatus = !bluetoothStatus;
      temperature = sensorData.split("/").elementAt(0);
      noiseStatus = sensorData.split("/").elementAt(1);
      gasStatus = sensorData.split('/').elementAt(2);
      vibrationStatus = sensorData.split("/").elementAt(3);
    });

    // Data which is send to the Colud firestore
    // String conState = 'disconnected';
    String btState = 'disconnected';

    // If bluetoooth is enabled set BT state to connected
    if (bluetoothStatus) {
      btState = "connected";
    }
    // update bluetooth State
    setBluetoothState();

    // Update location
    updatePosition();

    // get notification
    getNotifications();

    // Create data with sensor details to send to the firebase
    // createData(
    //     username: widget.username,
    //     bluetoothStatus: btState,
    //     noiseStatus: noiseStatus,
    //     vibrationStatus: vibrationStatus,
    //     workingTime: workingTime,
    //     temparature: temperature.toString());

    //Update State if bluetooth connection is available
    // if (bluetoothStatus) {
    //   updateState();
    // }
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

  // Function to show message which shows that emergency was sent
  Future<void> emergency() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Emergency',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  'Emergency message was sent successfully !',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 15,
                ),
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 50,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // Sending message to arduino
                _sendMessage("1");
                setState(() {
                  emergencyPressed = false; // Set State to emergency pressed
                });
                // sendNotification(
                // name: widget.username); // Send noptification with username
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                  'Emergency is detetced around you !',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 15,
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
                  fontSize: 20,
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
        bluetoothStatus: bluetoothStatus,
        noiseStatus: noiseStatus,
        vibrationStatus: vibrationStatus,
        temparature: temparature,
        workingTime: workingTime,
        position: geolocation);

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
  final String bluetoothStatus;
  final String noiseStatus;
  final String vibrationStatus;
  final String temparature;
  final String workingTime;
  final DateTime date = DateTime.now();
  final String position;

  // Constructor to the model
  UserData(
      {required this.id,
      required this.username,
      required this.bluetoothStatus,
      required this.noiseStatus,
      required this.vibrationStatus,
      required this.temparature,
      required this.workingTime,
      required this.position});

  // Method to create JSON object
  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': username,
        'bluetoothStatus': bluetoothStatus,
        'noiseStatus': noiseStatus,
        'vibrationStatus': vibrationStatus,
        'temparature': temparature,
        'working-time': workingTime,
        'date': date,
        'location': position
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
