import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LaunchScreen extends StatelessWidget {
  final Widget child;

  LaunchScreen({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
    Container(alignment: Alignment(0, 0),
    child: Image.asset('assets/battery_saver_logo.png'),
    decoration: BoxDecoration(color: Color.fromRGBO(133, 92, 128, 1)),
);
}