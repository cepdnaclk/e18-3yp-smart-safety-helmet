import 'dart:async';

import 'package:flutter/material.dart';
import 'SelectBondedDevicePage.dart';
import 'discover_page.dart';
import 'main_screen.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ConnectingScreen extends StatefulWidget {
  // Variable for storing username
  final String username;

  // constructor
  const ConnectingScreen({super.key, required this.username});

  @override
  State<StatefulWidget> createState() => _ConnectionScreen();
}

class _ConnectionScreen extends State<ConnectingScreen> {
  // Variables for bluetooth connectivity
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  //properties of discovering bluetooth devices
  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  // Initialize state
  @override
  void initState() {
    // Conctructor
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    // get th name
    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Properties of discoverable timeout
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  // Dispose function
  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  // Render the widget
  @override
  Widget build(BuildContext context) {
    // Render the widget
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          // Gap above
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
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  // Welcome text of the app
                  Text(
                    widget.username,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),

                  const Text(
                    " !",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ],
          ),

          // Gap between buton and title
          const SizedBox(
            height: 10,
          ),

          // Add the logo image
          const Center(
            child:
                Image(image: AssetImage('images/logo.png'), fit: BoxFit.fill),
          ),

          // Button to redirect to the main screen
          // IconButton(
          //     icon: const Icon(Icons.bluetooth_outlined),
          //     tooltip: 'Connect with Helmet',
          //     iconSize: 40,
          //     onPressed: () async {
          //       final BluetoothDevice? selectedDevice =
          //           await Navigator.of(context).push(
          //         MaterialPageRoute(
          //           builder: (context) {
          //             return const DiscoveryPage();
          //           },
          //         ),
          //       );
          //     }),

          // Gap between button and bluetooth button
          const SizedBox(
            height: 10,
          ),

          // Elevated button to pair if device is not connected

          SizedBox(
            width: 300,
            height: 50,
            child: ElevatedButton(
              // Function to start discovery page
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const DiscoveryPage();
                    },
                  ),
                );
              },

              // Style
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text(
                'Pair with New Helmet !',
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Gap between two buttons
          const SizedBox(
            height: 50,
          ),

          // Button to start working
          SizedBox(
            width: 300,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                          checkAvailability: false);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return MainScreen(
                            username: widget.username, server: selectedDevice);
                      },
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text(
                'Select your Smart Helmet !',
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Gap between instruction and select helmet widget
          const SizedBox(
            height: 50,
          ),

          // Instruction for pairing
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: 300,
                height: 80,
                // child text
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Pairing a new Helmet",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "To pair a new device long press the device you waant to pair",
                      style: TextStyle(fontSize: 22),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      )),
    );
  }
}
