import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomCell extends StatelessWidget {
  CustomCell(
      {Key key,
      @required this.label,
      this.hintText,
      this.child,
      this.delivied: true})
      : super(key: key);

  final String label;
  final String hintText;
  final Widget child;
  final bool delivied;

  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Text(
                this.label,
                style: new TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16.0,
                ),
              ),
              new SizedBox(width: 10.0),
              new Expanded(
                child: this.child,
              ),
            ],
          ),
          new SizedBox(height: 4.0),
          this.delivied
              ? new Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: new BoxDecoration(
                    border: new Border.all(
                      color: Colors.grey[400],
                      width: 0.3,
                    ),
                  ),
                )
              : new Container(),
        ],
      ),
    );
  }
}
