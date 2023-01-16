import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'bluetooth_device_list_entry.dart';

class DiscoveryPage extends StatefulWidget {
  /// If true, discovery starts on page start, otherwise user must press action button.
  final bool start;

  const DiscoveryPage({super.key, this.start = true});

  @override
  DiscoveryPageState createState() => DiscoveryPageState();
}

class DiscoveryPageState extends State<DiscoveryPage> {
  // Create a flutter blueetoooth instance
  // Declare a FlutterBluetoothSerial instance
  // FlutterBluetoothSerial flutterBluetoothSerial =
  //     FlutterBluetoothSerial.instance;
  // Get the list of available users with stream
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;

  // Get the vailable list of bluetooth devices
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);

  // Variable for determine whether the application is discovering new bluetooth devices
  bool isDiscovering = false;

  // Constructor
  DiscoveryPageState();

  // Save the address of connected bluetoooth device
  String connectedDevice = '';

  @override
  void initState() {
    super.initState();

    // Asking permission for enable bluetooth
    FlutterBluetoothSerial.instance.requestEnable();

    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  // Function to restart discovery
  void _restartDiscovery() {
    // Clear the bluetooth list
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  // Function to start discovery
  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0) {
          results[existingIndex] = r;
        } else {
          results.add(r);
        }
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  // @TODO . One day there should be `_pairDevice` on long tap on something... ;)

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isDiscovering
            ? const Text('Discovering devices')
            : const Text('Discovered devices'),
        backgroundColor: Colors.yellow,
        actions: <Widget>[
          isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: _restartDiscovery,
                )
        ],
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (BuildContext context, index) {
          BluetoothDiscoveryResult result = results[index];
          final device = result.device;
          final address = device.address;
          return BluetoothDeviceListEntry(
            device: device,
            rssi: result.rssi,
            onTap: () async {
              Navigator.of(context).pop(result.device);
            },
            onLongPress: () async {
              try {
                if (device.isConnected) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'Notification',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        content: const Text('Device is already connected',
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
                } else {
                  bool bonded = false;

                  // if device is bonded remove device with it's address
                  if (device.isBonded) {
                    await FlutterBluetoothSerial.instance
                        .removeDeviceBondWithAddress(address);
                  }
                  // Bonding with address
                  else {
                    bonded = (await FlutterBluetoothSerial.instance
                        .bondDeviceAtAddress(address))!;
                  }
                  // Connect to the bluetooth device
                  // await BluetoothConnection.toAddress(device.address);
                  setState(() {
                    connectedDevice = device.address;
                    results[results.indexOf(result)] = BluetoothDiscoveryResult(
                        device: BluetoothDevice(
                          name: device.name ?? '',
                          address: address,
                          type: device.type,
                          bondState: bonded
                              // ignore: dead_code
                              ? BluetoothBondState.bonded
                              : BluetoothBondState.none,
                        ),
                        rssi: result.rssi);
                  });
                  // ignore: use_build_context_synchronously
                  // Navigator.of(context).pop(connectedDevice);
                }
              } catch (ex) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: const Text(
                          "Error occured while connnecting to the device"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
