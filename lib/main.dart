import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:battery_saver/bloc.dart';
import 'package:battery_saver/main_page.dart';
import 'package:battery_saver/theme.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
]);
  runApp(MyApp());}

class MyApp extends StatelessWidget {

  final MainBloc mainBloc = new MainBloc();

  @override
  Widget build(BuildContext context) =>

   ScopedModel<MainBloc>(
      model: mainBloc,
      child:

      MaterialApp(
      title: 'Charge Controller',
      theme: buildThemeData(),
      home: MyHomePage(),
    ));
}

