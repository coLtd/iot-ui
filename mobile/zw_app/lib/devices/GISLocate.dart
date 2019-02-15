import 'package:flutter/material.dart';

class GISLocation extends StatefulWidget {
  GISLocation({Key key}) : super(key: key);

  @override
  _GISLocationState createState() => new _GISLocationState();
}

class _GISLocationState extends State<GISLocation> {

  double lng = 110.0;
  double lat = 99.0;

  _back() {
    Navigator.of(context).pop();
  }

  _ok() {

  }

  _clear() {

  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('GIS定位'),
        leading: null,
        automaticallyImplyLeading: true,
      ),
      body: new Center(
        child: new Text('GIS定位页面'),
      ),
    );
  }

}

