import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DetailTitleCell extends StatelessWidget {
  DetailTitleCell({Key key, @required this.label, this.icon})
      : super(key: key);

  final String label;
  final String icon;

  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Row(
        children: <Widget>[
          new Image.asset(
            icon,
            height: 18.0,
          ),
          new SizedBox(width: 8.0),
          new Text(
            label,
            style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: const Color(0xFF2196f3),
            ),
          ),
        ],
      ),
    );
  }
}
