import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SelectButton extends StatefulWidget {
  SelectButton(
      {Key key, this.title, this.isPress: false, @required this.onChanged})
      : super(key: key);

  final String title;
  final bool isPress;
  final ValueChanged<bool> onChanged;

  @override
  _SelectButtonState createState() => new _SelectButtonState(isPress);
}

class _SelectButtonState extends State<SelectButton> {
  bool isPress;

  _SelectButtonState(this.isPress);

  void _handleTap() {
    setState(() {
      isPress = !isPress;
    });

    widget.onChanged(isPress);
  }

  Widget build(BuildContext context) {
    return new InkWell(
      onTap: _handleTap,
      child: new Container(
        child: new Center(
          child: new Text(
            widget.title,
            style: isPress
                ? new TextStyle(color: Colors.red)
                : new TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
