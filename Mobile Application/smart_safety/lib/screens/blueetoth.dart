import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// Bluetooth Class for pairing bluetooth Devices

class Bluetooth extends StatefulWidget {
  // Constructor
  const Bluetooth({super.key});

  // Create a State
  @override
  BluetoothScreen createState() => BluetoothScreen();
}

// State Class for Blueetooth pairing

class BluetoothScreen extends State<Bluetooth> with WidgetsBindingObserver {
  // Declare a FlutterBluetoothSerial instance
  FlutterBluetoothSerial flutterBluetoothSerial =
      FlutterBluetoothSerial.instance;

  // Declare a list of BluetoothDevice objects
  List<BluetoothDevice> devicesList = [];

  // Get the list of available users with stream
  StreamSubscription<BluetoothDiscoveryResult>? streamSubscription;

  // Get the vailable list of bluetooth devices
  List<BluetoothDiscoveryResult> availableDevices =
      List<BluetoothDiscoveryResult>.empty(growable: true);

  // Declare a flag to determine if the device is connected
  bool isConnected = false;

  // Variable for determine whether the application is discovering new bluetooth devices
  // Initially set to discovering mode
  // App is searchng for available devices
  bool isDiscovering = true;

  // Initalizing State
  // In here Searching for bluetooth devices for pairing and Show them on a list
  @override
  void initState() {
    // Constructor
    super.initState();

    // Add widget binding observer
    WidgetsBinding.instance.addObserver(this);

    // Start dicovering when initialzing the screen
    if (isDiscovering) {
      startDiscover();
    }
  }

  // Dispose function to avoid memory leaks
  @override
  void dispose() {
    // Disposing the binder
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Function to start Dsicovering bluetoooth devices
  // Function to start discovery
  void startDiscover() {
    // Listen to the device stream
    streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      // Setting state by looking at the available devices are cnnected or not
      setState(() {
        final existingIndex = availableDevices.indexWhere(
            (element) => element.device.address == result.device.address);

        // if current device is in paired device update it with new details
        if (existingIndex >= 0) {
          availableDevices[existingIndex] = result;
        }
        // Else add device to the available device list
        else {
          availableDevices.add(result);
        }
      });
    });

    // After finishing discovery set isDiecovering variable to flase
    streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  // Function to restart discovery
  void restartDiscovery() {
    // Clear the aviable devices
    setState(() {
      availableDevices.clear();
      isDiscovering = true;
    });

    // Restart the discovering devices again
    startDiscover();
  }

  // Render the widget to the secreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Connect with Smart Helmet',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.yellow,
        toolbarHeight: 75,

        // Add a action to restart bluetooth scanning
        actions: [
          IconButton(
            onPressed: restartDiscovery,
            icon: const Icon(Icons.replay_circle_filled_outlined),
            iconSize: 40,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Display a list of available Bluetooth devices
            Expanded(
              child: ListView.builder(
                itemCount: availableDevices.length,
                itemBuilder: (context, index) {
                  // Get the BluetoothDevice for the current item
                  BluetoothDevice device = devicesList[index];

                  // Return a tile with details of bluetooth device name and address
                  return Card(
                    child: ListTile(
                      leading: device.bondState.isBonded
                          ? const Icon(Icons.done)
                          : const Icon(Icons.cancel),
                      title: Text(device.name!),
                      subtitle: Text(device.address),
                      onTap: () async {
                        // Connect to the device
                        // await flutterBluetoothSerial.connect(device);
                        var pairingStatus = await flutterBluetoothSerial
                            .bondDeviceAtAddress(device.address);

                        isConnected = pairingStatus!;

                        // if (pairingStatus) {
                        //   Navigator.of(context).pop();
                        // }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
