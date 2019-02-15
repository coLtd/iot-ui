import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FarmlandWidgetItem extends StatelessWidget {
  FarmlandWidgetItem({Key key, this.title, this.oid, @required this.onChanged})
      : super(key: key);

  final String title;
  final String oid;
  final ValueChanged<String> onChanged;

  void _handleTap() {
    onChanged(oid);
  }

  Widget build(BuildContext context) {

    return new GestureDetector(
      onTap: _handleTap,
      child: new Container(
        child: new Text(
          title,
        ),
      ),
    );
  }
}