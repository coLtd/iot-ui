import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zw_app/devices/DeviceInfo.dart';
import 'package:zw_app/devices/DeviceLocation.dart';
import 'package:zw_app/devices/FarmlandList.dart';
import 'package:zw_app/component/app_bar.dart';

class CreateDevice extends StatefulWidget {
  CreateDevice({Key key, this.devInfo}) : super(key: key);

  final DeviceInfo devInfo;

  @override
  _CreateDeviceState createState() => new _CreateDeviceState(devInfo);
}

class _CreateDeviceState extends State<CreateDevice> {
  DeviceInfo devInfo;
  String farmlandOid;
  String farmlandName;

  _CreateDeviceState([DeviceInfo devInfo]) {
    this.devInfo = devInfo;
  }

  @override
  initState() {
    super.initState();
    if (devInfo == null) devInfo = new DeviceInfo();
    this.devInfo.editable = true;
    farmlandName = devInfo.farmlandName;
    farmlandOid = devInfo.farmlandOid;
  }

  void _clear() {
    setState(() {
      farmlandName = null;
    });
  }

  Function _selectFarmland(BuildContext context) {
    return () async {
      final result = await Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new FarmlandList()),
      );
      if (result == null) return;

      var obj = json.decode(result);
      if (obj != null && obj.length > 0) {
        setState(() {
          farmlandName = obj['name'];
          farmlandOid = obj['oid'];
        });
      }
    };
  }

  _nextStep() {
    if (farmlandOid == null) {
      showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('请先选择地块'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('确认'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (farmlandOid == null || devInfo.farmlandOid != this.farmlandOid)
      devInfo.farmlandOid = this.farmlandOid;

    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) =>
            new DeviceLocation(devInfo: devInfo)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('选择地块'),
        leading: null,
        automaticallyImplyLeading: true,
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.only(top: 20.0),
              child: new Column(
                children: <Widget>[
                  new Container(
                    foregroundDecoration: new BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: new Border.all(
                        color: Colors.grey[350],
                        width: 1.0,
                      ),
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(20.0)),
                    ),
                    padding: const EdgeInsets.only(left: 8.0),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: farmlandName == null || farmlandName.isEmpty
                              ? new Text(
                                  '请选择地块',
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      color: Theme.of(context).hintColor),
                                )
                              : new Text(
                                  "$farmlandName",
                                  style: new TextStyle(
                                    fontSize: 20.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        new IconButton(
                          icon: new Icon(Icons.clear),
                          onPressed: _clear,
                        ),
                      ],
                    ),
                  ),
                  new SizedBox(height: 24.0),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      new FlatButton(
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 10),
                        color: const Color(0xFF2bd0fe),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.all(
                                new Radius.circular(20.0))),
                        onPressed: _selectFarmland(context),
                        child: new Text(
                          '选择地块',
                          style: new TextStyle(
                            color: Colors.white,
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
            width: size.width,
            height: size.height / 15,
            color: Color(0xFF30aaff),
            child: new FlatButton(
              onPressed: _nextStep,
              child: new Text(
                '下一步',
                style: new TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
