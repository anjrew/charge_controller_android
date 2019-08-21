import 'dart:async';
import 'package:battery_saver/bluetooth_device_details.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

class BluetoothInstance {

	final MethodChannel _platform = MethodChannel("batterysaver.flutter.dev/bluetooth");
   	Stream _scanSubscription;
    BluetoothDevice device;
    List<BluetoothDeviceDetails> _devices;
    List<BluetoothDevice> _btDevices;

    List<BluetoothDevice> get devices => _btDevices;
    BluetoothDeviceDetails _currentDevice;


    BehaviorSubject<List<BluetoothDeviceDetails>>
            _avaliableDevicesStreamController;
    BehaviorSubject<BluetoothDeviceDetails> _connectionStreamContoller =
            new BehaviorSubject<BluetoothDeviceDetails>();

    Stream<BluetoothDeviceDetails> get connectedDeviceStream =>
            _connectionStreamContoller.stream;

    /// init
    BluetoothInstance() {
        _avaliableDevicesStreamController =
                new BehaviorSubject<List<BluetoothDeviceDetails>>();
        _devices = new List<BluetoothDeviceDetails>();
    }

    void startCharging() {
        _turnSwitchOn();
        print('Start charging');
    }

    void stopCharging() {
        _turnSwitchOff();
        print('Stop charging');
    }

    Stream<List<BluetoothDeviceDetails>> get getDevicesStream {
        scan();
        return _avaliableDevicesStreamController.stream;
    }

    void scan()async{
        _scanSubscription = await _platform.invokeMethod('scan');
        filterDevices();
    }

    void stopScanning() {
        _platform.invokeMethod('stopscan');
    }

    void filterDevices(ScanResult scanResult) {
        String deviceName = scanResult.device.name;

        if (deviceName != null && 
				deviceName != '' && 
					(deviceName.contains("BATTERYSAVER") || deviceName.contains("CHARGECONTROLLER"))) {
						
            bool hasDeviceAlready = false;

            _btDevices.forEach((device) {
                if (device.id.id == scanResult.device.id.id) {
                    hasDeviceAlready = true;
                }
            });

            if (!hasDeviceAlready) {
                _addDevice(scanResult);
            }
        }
    }

    void _addDevice( scanResult) {
        BluetoothDeviceDetails newDevice;
        String name = scanResult.device.name;
        String deviceName = name == '' || name == null ? 'Unknown' : name;
        String id = scanResult.device.id.id;
        newDevice = BluetoothDeviceDetails(deviceName, id);

        if (newDevice != null) {
            _devices.add(newDevice);
            _btDevices.add(scanResult.device);
            _avaliableDevicesStreamController.add(_devices);
        }
    }

    /// Create a connection to the device
    void connectToDevice(int key) {
       	_platform.invokeMethod('connectToDevice',[<String,dynamic>{'deviceIndex': key}] );
    }

    /// Disconnect from device
    void disconnectFromDevice() {
		_platform.invokeMethod('disconnectFromDevice');
    }

    Future<void> _turnSwitchOn() async {
		_platform.invokeMethod('turnOn');
    }

    Future<void> _turnSwitchOff() async {
		_platform.invokeMethod('turnOff');
    }

    void dispose() {
        _connectionStreamContoller.close();
		
    }
}
