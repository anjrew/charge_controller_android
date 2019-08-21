
class BluetoothDeviceDetails{

  Map<String , dynamic> values = Map< String , dynamic>();

  BluetoothDeviceDetails(String nameDevice, String idDevice){
    name = nameDevice;
    id = idDevice;
    connected = false;
  }

  set name(String nameIn) => values['name'] = nameIn;
  String get name => values['name'];

  set id(String idIn) => values['id'] = idIn;
  String get id => values['id'];

  set connected(bool status) => values['connected'] = status;
  bool get connected => values['connected'];
}