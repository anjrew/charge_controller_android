import 'package:scoped_model/scoped_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver/bluetooth_functions.dart';
import 'package:battery_saver/preferances.dart';
import 'package:battery_saver/battery_instance.dart';

class MainBloc extends Model{

  Map<Streams, BehaviorSubject<dynamic>> _streams = new Map<Streams, BehaviorSubject<dynamic>>();

  Stream<dynamic> getStream(Streams type) => _streams[type].stream;

  void setValue(Streams stream, double value){
    switch(stream){
      case Streams.checkTime: timeStream = value.toInt(); break;
      case Streams.tolerance: _setToleranceSetting(value);break;
      case Streams.chargeSetting: break;
    }
  }
  
  /// Init
  MainBloc(){
    _preferances = new Preferances();
    setupStreams();
    battery = new BatteryInstance(this);
    _preferances.toleranceStream.listen(_setToleranceSetting);
    _preferances.chargeSettingStream.listen(setPercentage);
    bluetooth = new BluetoothInstance();
  }

  void setupStreams(){
    _streams[Streams.chargeSetting] = new BehaviorSubject<double>();
    _streams[Streams.checkTime] = new BehaviorSubject<int>();
    _streams[Streams.tolerance] = new BehaviorSubject<double>();
    _streams[Streams.tolerance].addStream(_preferances.toleranceStream);
    _streams[Streams.checkTime].addStream(_preferances.checkTimeStream);
  }

  void disconnectFromDevice(){
    bluetooth.disconnectFromDevice();
    battery.stopCheckingBattery(); 
  }
  
  /// PREFERANCES
  Preferances _preferances;

  void setTofactoryDefaults (){
    _preferances.setTofactoryDefaults();
  }
  void _setToleranceSetting (double value){ 
    _tolerancePercentage = value;
    _preferances.tolerance = value; }

  

  double _tolerancePercentage;

  Stream<int> get checkTimeStream => _streams[Streams.checkTime].stream as Stream<int>;
  set timeStream(int timeIns) => _preferances.checkTime = timeIns;

  /// BATTERY
  BatteryInstance battery;
  double _batterySetting;
  BehaviorSubject<double> get _chargeSettingStreamController => _streams[Streams.chargeSetting].stream;

  double get _lowerTolerance => (_batterySetting - _tolerancePercentage);
  double get _upperTolerance => (_batterySetting + _tolerancePercentage);

  void batterySettingChanged(double setting){ 
    _batterySetting = setting;
    _preferances.chargeSetting = setting; }
  
  void batteryChargeChanged(int chargePercentage){
    print('Charge percentage is $chargePercentage');
    if( chargePercentage <= _lowerTolerance )
    {  bluetooth.startCharging(); }
    if( chargePercentage >= _upperTolerance )
    {  bluetooth.stopCharging(); }
  }

  Stream<double> get chargeSettingStream => _chargeSettingStreamController.stream;

  void setPercentage(double percentage) {
     _chargeSettingStreamController.add(percentage); 
     _batterySetting = percentage;
     _preferances.chargeSetting = percentage;}


  /// BLUETOOTH
  BluetoothInstance bluetooth;

  static MainBloc of(BuildContext context) =>
      ScopedModel.of<MainBloc>(context);

  void dispose() { 
    _chargeSettingStreamController.close();
  }
}

enum Streams{ chargeSetting, checkTime, tolerance}
