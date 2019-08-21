import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:battery_saver/bloc.dart';
import 'package:battery_saver/bluetooth_devices_list.dart';
import 'package:battery_saver/bluetooth_device_details.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:scoped_model/scoped_model.dart';

class MyHomePage extends StatelessWidget {
    final String _title = 'Charge Controller';

    final EdgeInsetsGeometry _margin = EdgeInsets.all(20.0);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
                drawer: MainMenuDrawer(),
                appBar: AppBar(
                    title: Text(_title, style: Theme.of(context).textTheme.title),
                    actions: <Widget>[AppBarLogo()],
                ),
                body: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            StatusIcon(),
                            Padding(padding: _margin),
                            ConnectionStatusLabel(),
                            Padding(padding: _margin),
                            PercentageSlider()
                        ],
                    ),
                ),
                floatingActionButton: ConnectDisconnectButton());
    }
}

class PercentageSlider extends StatelessWidget {
    final EdgeInsetsGeometry _margin = EdgeInsets.all(10.0);

    @override
    Widget build(BuildContext context) => Container(
            width: double.infinity,
            padding: _margin,
            child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text(
                            'Battery charge setting',
                            style: Theme.of(context).textTheme.subhead,
                        ),
                        Padding(
                            padding: _margin,
                        ),
                        BatteryPercentageDisplay(),
                        BatterySettingSlider()
                    ]));
}

class BatteryPercentageDisplay extends StatelessWidget {
    @override
    Widget build(BuildContext context) => StreamBuilder<double>(
            stream: MainBloc.of(context).chargeSettingStream,
            initialData: 0.0,
            builder: (BuildContext context, AsyncSnapshot<double> snapshot) => Text(
                    '${snapshot.data.toInt()}%',
                    style: Theme.of(context).textTheme.display2));
}

class BatterySettingSlider extends StatelessWidget {
    @override
    Widget build(BuildContext context) => StreamBuilder<double>(
            stream: MainBloc.of(context).chargeSettingStream,
            initialData: 0.0,
            builder: (BuildContext context, AsyncSnapshot<double> snapshot) =>
                    CupertinoSlider(
                        value: snapshot.data,
                        onChanged: (value) {
                            MainBloc.of(context).setPercentage(value);
                        },
                        min: 0,
                        max: 100,
                        divisions: 10,
                        activeColor: Theme.of(context).sliderTheme.activeTrackColor,
                    ));
}

class ConnectDisconnectButton extends StatelessWidget {
    void _getSaverDevice(BuildContext context) {
        MainBloc bloc = MainBloc.of(context);

        /// Remove after testing TODO;
        bloc.battery.startCheckingBattery();

        showDialog(
                        context: context,
                        builder: (BuildContext context) => BluetoothDevicesDialog())
                .then((_) => bloc.bluetooth.stopScanning());
    }

    void disconnect(BuildContext context, String deviceName) {
        MainBloc.of(context).disconnectFromDevice();
        Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text("Disconnected from $deviceName")));
    }

    @override
    Widget build(BuildContext context) {
        MainBloc model = MainBloc.of(context);

        return StreamBuilder<BluetoothDeviceDetails>(
                stream: model.bluetooth.connectedDeviceStream,
                builder: (BuildContext context,
                        AsyncSnapshot<BluetoothDeviceDetails> snapshot) {
                    if (snapshot.hasData && snapshot.data.connected == true) {
                        return FloatingActionButton(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            onPressed: () => disconnect(context, snapshot.data.name),
                            tooltip: 'Disconnect',
                            child: Icon(Icons.bluetooth_disabled),
                        );
                    } else {
                        return FloatingActionButton(
                            onPressed: () => _getSaverDevice(context),
                            tooltip: 'Pair Device',
                            child: Icon(Icons.bluetooth_searching),
                        );
                    }
                });
    }
}

class ConnectionStatusLabel extends StatelessWidget {
    @override
    Widget build(BuildContext context) => StreamBuilder<BluetoothDeviceDetails>(
            stream: MainBloc.of(context).bluetooth.connectedDeviceStream,
            builder: (BuildContext context,
                    AsyncSnapshot<BluetoothDeviceDetails> snapshot) {
                Widget child;

                if (snapshot.hasData && snapshot.data.connected == true) {
                    child = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            Text(
                                'Connected to device',
                                style: Theme.of(context).textTheme.subhead,
                                textAlign: TextAlign.center,
                            ),
                            Text(
                                '${snapshot.data.name}',
                                style: Theme.of(context).textTheme.headline,
                                textAlign: TextAlign.center,
                            ),
                        ],
                    );
                } else {
                    child = Text(
                        'No device connected',
                        style: Theme.of(context).textTheme.headline,
                    );
                }

                assert(child != null, 'Child is null');

                return child;
            });
}

class StatusIcon extends StatelessWidget {
    @override
    Widget build(BuildContext context) => StreamBuilder<BluetoothDeviceDetails>(
            stream: MainBloc.of(context).bluetooth.connectedDeviceStream,
            builder: (BuildContext context,
                    AsyncSnapshot<BluetoothDeviceDetails> snapshot) {
                String animation;
                if (snapshot.hasData && snapshot.data.connected == true) {
                    animation = "spin";
                } else {
                    animation = "still";
                }

                assert(animation != null, 'animation is null');

                return Container(
                        width: 100,
                        height: 100,
                        child: FlareActor("assets/bluetooth_connected.flr",
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                animation: animation));
            });
}

class MainMenuDrawer extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Drawer(
            child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                    DrawerHeader(
                        child: Container(
                                alignment: Alignment(0, 0),
                                child: Text('Options',
                                        style: Theme.of(context).textTheme.display1)),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                        ),
                    ),
                    SettingSlider(Streams.tolerance),
                    Divider(),
                    SettingSlider(Streams.checkTime),
                    SetFactoryDefaultsButton(),
                ],
            ),
        );
    }
}

class SettingSlider extends StatelessWidget {
    final Streams _stream;
    SettingSlider(this._stream);

    @override
    Widget build(BuildContext context) {
        MainBloc model = MainBloc.of(context);
        return StreamBuilder<dynamic>(
                stream: model.getStream(_stream),
                builder: (BuildContext context, AsyncSnapshot<dynamic> stream) {
                    if (!stream.hasData) {
                        return Divider();
                    } else {
                        String title;
                        String trailing;
                        double min;
                        double max;
                        int divisions;

                        switch (_stream) {
                            case Streams.chargeSetting:
                                break;
                            case Streams.tolerance:
                                title = 'Tolerance %';
                                trailing = '${(stream.data as double).toInt()}%';
                                min = 0;
                                max = 50;
                                divisions = 25;
                                break;
                            case Streams.checkTime:
                                title = 'Check frequency';
                                trailing = '${stream.data} minutes';
                                min = 1;
                                max = 60;
                                divisions = 30;
                                break;
                        }

                        assert(title != null, 'title is null');
                        assert(trailing != null, 'trailing is null');
                        assert(stream.data != null, 'stream.data is null');

                        double value = stream.data is double
                                ? stream.data
                                : (stream.data as int).roundToDouble();

                        return ListTile(
                            title: Text(
                                title,
                                style: Theme.of(context).textTheme.subhead,
                            ),
                            subtitle: CupertinoSlider(
                                activeColor: Theme.of(context).accentColor,
                                value: value,
                                onChanged: (value) => model.setValue(_stream, value),
                                min: min,
                                max: max,
                                divisions: divisions,
                            ),
                            trailing: Text(trailing),
                        );
                    }
                });
    }
}

class SetFactoryDefaultsButton extends StatelessWidget {
    final EdgeInsetsGeometry _margin = EdgeInsets.all(10.0);

    @override
    Widget build(BuildContext context) => ScopedModelDescendant(
            builder: (BuildContext context, _, MainBloc model) => Container(
                    margin: _margin,
                    child: RaisedButton(
                        onPressed: model.setTofactoryDefaults,
                        child: Text('Reset to factory defaults'),
                    )));
}

class AppBarLogo extends StatelessWidget {
    final EdgeInsetsGeometry _padding = EdgeInsets.all(8.0);

    @override
    Widget build(BuildContext context) => Center(
                    child: Container(
                padding: _padding,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                ),
                child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: Image.asset('assets/battery_saver_logo.png')),
            ));
}
