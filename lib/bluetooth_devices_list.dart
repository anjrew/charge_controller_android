import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:battery_saver/bloc.dart';
import 'package:battery_saver/bluetooth_device_details.dart';

class BluetoothDevicesDialog extends StatelessWidget {

  void selectDevice(int key, BuildContext context){

    MainBloc bloc = MainBloc.of(context);

    bloc.bluetooth.connectToDevice(bloc.bluetooth.devices[key], key );

    Navigator.pop(context);
    print('Selected $key');

  }

  @override
  Widget build(BuildContext context) => 
  
      SimpleDialog(
        title: Container(width: double.infinity,child: Text('Choose a device to pair with', style: Theme.of(context).textTheme.display1,)),
        children: <Widget>[
          
          /// Profiles list
          Container(
              decoration: BoxDecoration( shape: BoxShape.circle ),
              height: 400.0,
              width: 300.0,
              child: 

              StreamBuilder<List<BluetoothDeviceDetails>>(
              stream: MainBloc.of(context).bluetooth.getDevicesStream,
              builder: (BuildContext context, AsyncSnapshot<List<BluetoothDeviceDetails>> devices) {
              
              if(!devices.hasData){ return Center(child:CircularProgressIndicator());}
              else{
              return

                ListView.separated(
                  separatorBuilder: (BuildContext context, int index) => Divider(),
                  itemCount: devices.data.length,
                  itemBuilder: (BuildContext context, int index) =>
                
                ListTile(
                  trailing: Icon(Icons.bluetooth_searching),
                  key: Key(index.toString()),
                  title: Text(devices.data[index].name),
                  onTap: () => selectDevice(index, context),)
                );}         
              }
              )
              ),
        ],
      );
}
