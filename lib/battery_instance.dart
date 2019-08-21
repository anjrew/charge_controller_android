import 'package:battery/battery.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:battery_saver/bloc.dart';


class BatteryInstance{

  final MainBloc _bloc;
  final Battery _battery = new Battery();
  final BehaviorSubject<int> _batteryLevelContoller = new BehaviorSubject<int>();
  Timer _checkTimer;
  int _checkDurationMinutes;

  /// init
  BatteryInstance(this._bloc){
    _bloc.checkTimeStream.listen((value) => _checkDurationMinutes = value);
    _batteryLevelContoller.listen(_bloc.batteryChargeChanged);
  }

  void startCheckingBattery (){
     _checkTimer = new Timer.periodic(Duration(minutes: _checkDurationMinutes), _checkBattery);
  }

  void stopCheckingBattery (){
     _checkTimer.cancel();
  }

  void _checkBattery(Timer t)async{
     _batteryLevelContoller.add( await _batteryLevel);
  }

  void dispose() { 
    _batteryLevelContoller.close();
  }

  Future<int>  get _batteryLevel => _battery.batteryLevel;
  
}
