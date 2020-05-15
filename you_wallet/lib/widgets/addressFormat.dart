import 'package:flutter/material.dart';
import 'package:youwallet/global.dart';

class AddressFormat extends StatelessWidget {
  final address;
  AddressFormat(this.address, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      Global.maskAddress(this.address) ,
      style: TextStyle(
        fontSize: 16,
        letterSpacing: 1,
        color: Colors.white,
      ),
    );
  }
}