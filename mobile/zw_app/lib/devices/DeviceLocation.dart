import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zw_app/devices/DeviceInfo.dart';
import 'package:zw_app/devices/DeviceNewInfo.dart';
import 'package:zw_app/devices/GISLocate.dart';
import 'package:zw_app/Utils.dart';
import 'package:zw_app/component/InputCell.dart';
import 'package:my_location/my_location.dart';

class DeviceLocation extends StatefulWidget {
  DeviceLocation({Key key, this.devInfo}) : super(key: key);

  final DeviceInfo devInfo;
  @override
  _DeviceLocationState createState() => new _DeviceLocationState(devInfo);
}

class _DeviceLocationState extends State<DeviceLocation> {
  DeviceInfo devInfo;

  bool isLocating = false;
  String error;

  TextEditingController _lngController;
  TextEditingController _latController;

  _DeviceLocationState(this.devInfo);

  @override
  void initState() {
    super.initState();

    _lngController = new TextEditingController(
        text: (devInfo.lng == 0.0) ? '' : devInfo.lng.toStringAsFixed(6));
    _latController = new TextEditingController(
        text: (devInfo.lat == 0.0) ? '' : devInfo.lat.toStringAsFixed(6));
  }

  @override
  void dispose() {
    _lngController.dispose();
    _latController.dispose();
    super.dispose();
  }

  _prevStep() {
    Navigator.of(context).pop();
  }

  _nextStep() {
    if (_lngController.text.isEmpty || _latController.text.isEmpty) {
      _showMessage('经纬度不能为空');
      return;
    }

    if (Utils.isNotNumber(_lngController.text) ||
        Utils.isNotNumber(_latController.text)) {
      _showMessage('经纬度数据存在非数字字符');
      return;
    }

    if (num.parse(_lngController.text) < -180.0 ||
        num.parse(_lngController.text) > 180.0 ||
        num.parse(_latController.text) < -90.0 ||
        num.parse(_latController.text) > 90.0) {
      _showMessage('经纬度数据超范围\n'
          '经度：-180.0~180.0\n'
          '纬度：-90.0~90.0');
      return;
    }

    devInfo.setLngLat(
        lng: num.parse(_lngController.text),
        lat: num.parse(_latController.text));

    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) =>
            new DeviceNewInfo(devInfo: devInfo)));
  }

  void _showMessage(String msg) {
    showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(content: new Text(msg), actions: <Widget>[]);
        });
  }

  Function _paste(BuildContext ctx) {
    return () async {
      try {
        ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
        var obj = json.decode(data.text);
        setState(() {
          _lngController.text = obj['lng'].toStringAsFixed(6);
          _latController.text = obj['lat'].toStringAsFixed(6);
        });
      } catch (e) {
        print('caught: "${e.toString()}"');
      }
    };
  }

  _locate() async {
    setState(() {
      isLocating = true;
    });

    Map<dynamic, dynamic> location;

    try {
      location = await MyLocation.location;
      print('location: $location');
      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
        'Permission denied - please ask the user to enable it from the app settings';
      }

      location = null;
    }
    if (!mounted) return;

    setState(() {
      isLocating = false;
      if (location != null) {
        _lngController.text = location['longitude'].toStringAsFixed(6);
        _latController.text = location['latitude'].toStringAsFixed(6);
      }
    });
  }

  _locateByGIS() {
    Navigator
        .of(context)
        .push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
      return new GISLocation();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
//      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('设备定位'),
        leading: null,
        automaticallyImplyLeading: true,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.public),
              tooltip: 'GIS定位',
              onPressed: _locateByGIS),
        ],
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new Container(
              padding: const EdgeInsets.all(12.0),
              child: new ListView(
//                mountedΩainAxisAlignment: MainAxisAlignment.start,
//                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    isLocating == false ? '' : '正在获取定位...',
                    style: new TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  new InputCell(
                      label: '经度',
                      inputController: _lngController,
                      keyboardType: TextInputType.number),
                  new InputCell(
                      label: '纬度',
                      inputController: _latController,
                      keyboardType: TextInputType.number),
                  new SizedBox(height: 32.0),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new FlatButton(
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 6),
                        color: const Color(0xFF30aaff),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.all(
                                new Radius.circular(20.0))),
                        onPressed: _paste(context),
                        child: new Text(
                          '粘贴',
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      new FlatButton(
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 6),
                        color: const Color(0xFF2bd0fe),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.all(
                                new Radius.circular(20.0))),
                        onPressed: _locate,
                        child: new Text(
                          '定位',
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          new Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: new Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 15,
              color: Color(0xFF30aaff),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new FlatButton(
                      onPressed: _prevStep,
                      child: new Text(
                        '上一步',
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  new Container(
                    height: MediaQuery.of(context).size.height / 24,
                    decoration: new BoxDecoration(
                      border: new Border.all(
                        color: Colors.white,
                        width: 0.3,
                      ),
                    ),
                  ),
                  new Expanded(
                    child: new FlatButton(
                      onPressed: _nextStep,
                      child: new Text(
                        '下一步',
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
