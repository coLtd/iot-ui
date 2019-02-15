import 'package:flutter/material.dart';

class OverviewPage extends StatelessWidget {
  OverviewPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: new Text(
        '敬请期待',
        style: new TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }
}
