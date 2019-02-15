import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DetailCell extends StatelessWidget {
  DetailCell({Key key, @required this.label, this.value, this.delivied: true})
      : super(key: key);

  final String label;
  final Object value;
  final bool delivied;

  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Column(
        children: <Widget>[
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                label,
                style: new TextStyle(
                  color: Colors.grey[500],
                  fontSize: 18.0,
                ),
              ),
              new SizedBox(width: 12.0),
              new Expanded(
                child: new Text(
                  '$value',
                  style: new TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),
          new SizedBox(height: 8.0),
          delivied
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
