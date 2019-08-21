import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

class Preferances{

  SharedPreferences _prefs;

  BehaviorSubject<double> _toleranceStream = new BehaviorSubject<double>();
  BehaviorSubject<double> _chargeSettingStream = new BehaviorSubject<double>();
  BehaviorSubject<int> _checkTimeStream = new BehaviorSubject<int>();

  Preferances(){
    _init();
  }

  void _init() async { 
    _prefs = await SharedPreferences.getInstance();
    if(!_hasBeenSetup){ setTofactoryDefaults();}
    else{
      _toleranceStream.add(_toleranceValue);
      _chargeSettingStream.add(_chargeSettingValue);
      _checkTimeStream.add(_checkTimeValue);
    }
  }

  void setTofactoryDefaults(){
    tolerance = 5.0;
    chargeSetting = 20.0;
    checkTime = 5;
    _prefs.setBool( _hasBeenSetupId, true);
  }

  String _hasBeenSetupId = 'hasBeenSetupId';
  bool get _hasBeenSetup {

    var itHas;
    if( _prefs.get(_hasBeenSetupId) != null )
    {
     itHas = _prefs.get(_hasBeenSetupId);
     
    if (itHas != null){ itHas = true; }
    }
    
    else{ itHas = false; }

    assert( itHas != null, 'itHas is null');
    return itHas;
  }

  String _toleranceId = 'tolerance';

  set tolerance( double newTolerance ) {
   double currantTolerance =  _prefs.getDouble(_toleranceId );
    if(currantTolerance != newTolerance){
      _prefs.setDouble( _toleranceId, newTolerance );
      _toleranceStream.add( newTolerance ); 
    }
  }
  Stream<double> get toleranceStream => _toleranceStream.stream;
  double get _toleranceValue => _prefs.getDouble(_toleranceId);

  String _chargeSettingId = 'chargeSetting';

  set chargeSetting( double number ) {
    if(_prefs.getDouble(_chargeSettingId ) != number){
      _prefs.setDouble( _chargeSettingId, number );
      _chargeSettingStream.add( number );
    }
  }

  Stream<double> get chargeSettingStream => _chargeSettingStream.stream;
  double get _chargeSettingValue => _prefs.getDouble(_chargeSettingId);

  String _checkTimeId = 'checkTime';
  set checkTime( int number ) {
    if(_prefs.getInt(_checkTimeId ) != number){
      _prefs.setInt( _checkTimeId, number );
      _checkTimeStream.add( number );
    }
  }
  Stream<int> get checkTimeStream => _checkTimeStream.stream;  
  int get _checkTimeValue => _prefs.getInt(_checkTimeId);

  void dispose(){
    _toleranceStream.close();
    _chargeSettingStream.close();
    _checkTimeStream.close();
  }
}

enum Preferance{ tolerance , chargeSetting , checkTime }