import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zw_app/Constant.dart';
import 'package:zw_app/devices/CreateDevice.dart';
import 'package:zw_app/devices/DeviceInfo.dart';
import 'package:zw_app/devices/ParamTypeItem.dart';
import 'package:zw_app/component/DetailTitleCell.dart';
import 'package:zw_app/component/DetailCell.dart';

class DeviceDetail extends StatefulWidget {
  DeviceDetail({Key key, this.oid}) : super(key: key);
  final String oid;

  @override
  _DeviceDetailState createState() => new _DeviceDetailState(oid);
}

class _DeviceDetailState extends State<DeviceDetail> {
  final String oid;
  DeviceInfo devInfo;
  String company;
  String _staffName;

  bool dataReady;
  bool isParamsVisible;
  bool _isStaffVisible;
  bool isDeleting = false;

  List<ParamTypeItem> paramList;

  _DeviceDetailState(this.oid);

  @override
  void initState() {
    super.initState();
    dataReady = false;
    isParamsVisible = false;
    _isStaffVisible = false;
    paramList = new List<ParamTypeItem>();

    devInfo = new DeviceInfo.from(oid, null);

    getDeviceInfo(oid);
  }

  void _showMessage(String name) {
    showDialog<Null>(
        context: context,
        child: new AlertDialog(content: new Text(name), actions: <Widget>[
          new FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: new Text('确定'))
        ]));
  }

  Future<Null> getFarmland(String farmOid) async {
    var url = '$Server_ISS_URL/tenant.farmland/aggregate';
    var projection = [
      {
        "\$match": {
          "_id": {"\$oid": "$farmOid"}
        }
      },
      {
        "\$lookup": {
          "from": 'sys.tenant',
          "localField": 'tenant',
          "foreignField": '_id',
          "as": 'tenant'
        }
      }
    ];
    print("getFarmland.projection: " + json.encode(projection));

    var httpClient = new HttpClient();
    String result;
    try {
      var request = await httpClient.postUrl(Uri.parse(url));
      request.headers.contentType =
          new ContentType("application", "json", charset: "utf-8");
      request.write(json.encode(projection));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        String jsonStr = await response.transform(utf8.decoder).join();

        var deviceItems = json.decode(jsonStr);
        for (var item in deviceItems) {
          // only one
          String oid = item['_id']['\$oid'];
          if (oid != farmOid) return;
          setState(() {
            devInfo.farmlandName = item['name'];
            var typeDesc = item['tenant'];
            var typeItem = typeDesc[0];
            this.company = typeItem['name'];
          });
        }
        result = jsonStr;
      } else {
        result = 'getDeviceInfo failed:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'getDeviceInfo Exception:';
      print(exception);
    }

    // If the widget was removed from the tree while the message was in flight,
    // we want to discard the reply rather than calling setState to update our
    // non-existent appearance.
    if (!mounted) return;

    setState(() {
//      print("_responsedata: "+result);
    });
  }

  Future<Null> getParamsData(var params) async {
    bool isVisible = false;
    var url = '$Server_IOT_URL/base.device.param_type';
    if (params != null && params.length > 0) {
      var filter = {
        "_id": {"\$in": params}
      };
      String queryString = Uri.encodeQueryComponent(json.encode(filter));
      print('getParamsData.filter: ' + json.encode(filter));
      url = url + '?filter=$queryString';

      var projection = {"name": 1, "type": 1, "required": 1, "value": 1};
      String projectionString =
          Uri.encodeQueryComponent(json.encode(projection));
      print('getParamsData.projection: ' + json.encode(projection));
      url = url + '&projection=$projectionString';
    }
    print(url);

    var httpClient = new HttpClient();
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));

      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        String jsonString = await response.transform(utf8.decoder).join();
        print('getParamsData.response: $jsonString');
        var responseData = json.decode(jsonString);

        var responseItems = responseData['items'];
        for (var item in responseItems) {
          ParamTypeItem paramItem = new ParamTypeItem.from(item);
          paramList.add(paramItem);

          String id = paramItem.oid;
          var oldValue = devInfo.params[id];
          if (oldValue == null) oldValue = item['value'];
          paramItem.currentValue = oldValue;

          isVisible = true;
        }

        result = jsonString;
      } else {
        result = 'getSensorData failed:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'getSensorData Exception: $exception';
      print(result);
    }

    // If the widget was removed from the tree while the message was in flight,
    // we want to discard the reply rather than calling setState to update our
    // non-existent appearance.
    if (!mounted) return;

    setState(() {
      isParamsVisible = isVisible;
    });
  }

  Future<Null> getStaffData(String staffOid) async {
    bool isVisible = false;
    if (staffOid == null || staffOid.isEmpty) return;

    var url = '$Server_ISS_URL/tenant.staff';
    var filter = {
      "_id": {"\$oid": staffOid}
    };
    String queryString = Uri.encodeQueryComponent(json.encode(filter));
    print('getStaffData.filter: ' + json.encode(filter));
    url = url + '?filter=$queryString';

    var projection = {"name": 1};
    String projectionString = Uri.encodeQueryComponent(json.encode(projection));
    print('getStaffData.projection: ' + json.encode(projection));
    url = url + '&projection=$projectionString';
    print(url);

    var httpClient = new HttpClient();
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));

      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        String jsonString = await response.transform(utf8.decoder).join();
        print('getParamsData.response: $jsonString');
        var responseData = json.decode(jsonString);

        var responseItems = responseData['items'];
        for (var item in responseItems) {
          _staffName = item['name'];
          isVisible = true;
        }

        result = jsonString;
      } else {
        result = 'getSensorData failed:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'getSensorData Exception: $exception';
      print(result);
    }

    // If the widget was removed from the tree while the message was in flight,
    // we want to discard the reply rather than calling setState to update our
    // non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isStaffVisible = isVisible;
    });
  }

  Future<Null> getDeviceInfo(String oid) async {
    devInfo.clear();

    var url = '$Server_IOT_URL/tenant.device/aggregate';
    var projection = [
      {
        "\$match": {
          "_id": {"\$oid": "$oid"}
        }
      },
      {
        "\$lookup": {
          "from": 'base.device.type',
          "localField": 'type',
          "foreignField": '_id',
          "as": 'type'
        }
      }
    ];
    print("getDeviceInfo.projection: " + json.encode(projection));

    var httpClient = new HttpClient();

    String result;
    try {
      var request = await httpClient.postUrl(Uri.parse(url));
      request.headers.contentType =
          new ContentType("application", "json", charset: "utf-8");
      request.write(json.encode(projection));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        String jsonStr = await response.transform(utf8.decoder).join();
        var deviceItems = json.decode(jsonStr);
        for (var item in deviceItems) {
          // only one
          String oid = item['_id']['\$oid'];
          if (oid != this.oid) return;
          devInfo.oid = oid;
          devInfo.code = item['code'];
          devInfo.name = item['name'];
          devInfo.setLngLat(lng: item['lng'], lat: item['lat']);
          if (item['alti'] != null) devInfo.alti = item['alti'];
          devInfo.location = item['location'];
          devInfo.remark = item['remark'];
          devInfo.status = item['status'] == 1 ? true : false;

          var typeDesc = item['type'];
          var typeItem = typeDesc[0];
          devInfo.typeOid = typeItem['_id']['\$oid'];
          devInfo.typeName = typeItem['name'];

          var timestamp = item['updatedOn'];
          var datetime = new DateTime.fromMillisecondsSinceEpoch(
              int.parse(timestamp['\$numberLong']));
          devInfo.updatedOn =
              datetime.toString() != null && datetime.toString().length >= 16
                  ? datetime.toString().substring(0, 16)
                  : datetime.toString();

          if (item['farmland'] != null) {
            devInfo.farmlandOid = item['farmland']['\$oid'];
            getFarmland(devInfo.farmlandOid);
          }

          if (item['staff'] != null) {
            devInfo.staffOid = item['staff']['\$oid'];
            getStaffData(devInfo.staffOid);
          }

          var typeOids = typeItem['paramTypes'];
          if (typeOids != null && typeOids.length > 0) {
            getParamsData(typeOids);
            var params = item['params'];
            print('params: $params');
            if (params != null && params.length > 0) {
              for (var key in typeOids) {
                print(key);
                var oid = key['\$oid'];
                if (params[oid] != null) devInfo.params[oid] = params[oid];
              }
            }
          }
        }
        result = jsonStr;
      } else {
        result = 'getDeviceInfo failed:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'getDeviceInfo Exception:';
      print(exception);
    }

    if (!mounted) return;

    setState(() {
      print("DeviceInfo: \n" + result);
      if (devInfo.name != null && devInfo.name.isNotEmpty) dataReady = true;
    });
  }

  _edit() {
    setState(() {
      Navigator
          .of(context)
          .push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new CreateDevice(devInfo: this.devInfo);
      }));
    });
  }

  _showPromptDialog() {
    showDialog<Null>(
        context: context,
        child: new AlertDialog(content: new Text('确认删除设备？'), actions: <Widget>[
          new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDevice();
              },
              child: new Text('是')),
          new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: new Text('否'))
        ]));
  }

  _deleteDevice() async {
    setState(() {
      isDeleting = true;
    });
    String url = '$Server_IOT_URL/tenant.device';
    var httpClient = new HttpClient();

    String errmsg;
    var requestBody = {
      "filter": {
        "_id": {"\$oid": "$oid"}
      }
    };
    try {
      var request = await httpClient.deleteUrl(Uri.parse(url));
      request.headers.contentType =
          new ContentType("application", "json", charset: "utf-8");
      request.write(json.encode(requestBody));
      var response = await request.close();
      print("response.statusCode: ${response.statusCode}");
      if (response.statusCode == HttpStatus.OK) {} else {
        errmsg = '网络错误(${response.statusCode}),请稍后重试！';
      }
    } catch (exception) {
      errmsg = '异常: $exception';
    }

    if (!mounted) return;
    if (errmsg == null) {
      print(oid);
      var obj = {"oid": oid};
      String jsonString = json.encode(obj);
      setState(() {
        Navigator.pop(context, '$jsonString');
      });
    } else {
      setState(() {
        Navigator.pop(context, '{"err":$errmsg}');
      });
    }
  }

  void _changeStatus(bool value) {
    devInfo.editable = true;
    setState(() {
      devInfo.status = value;
    });
    devInfo.commit().then((String responseString) {
      var responseData = json.decode(responseString);
      if (responseData['updatedOn'] != null)
        _showMessage(devInfo.status ? '设备已启用' : '设备已禁用');
      else {
        setState(() {
          devInfo.status = !value;
        });
        _showMessage('更新失败，请稍后重试');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingDialog = new Center(child: new CircularProgressIndicator());

    final List<Widget> devInfos = <Widget>[];

    ///标头
    devInfos.add(new DetailTitleCell(icon: 'images/shebei.png', label: '设备信息'));

    ///设备ID
    devInfos.add(new DetailCell(
        label: '设备ID', value: dataReady == false ? '--' : '${devInfo.code}'));

    ///设备名称
    devInfos.add(new DetailCell(
        label: '设备名称', value: dataReady == false ? '--' : '${devInfo.name}'));

    ///设备类型
    devInfos.add(new DetailCell(
        label: '设备类型',
        value: dataReady == false ? '--' : '${devInfo.typeName}'));

    ///参数
    if (isParamsVisible) {
      paramList.forEach((ParamTypeItem item) {
        devInfos.add(new DetailCell(
            label: '${item.name}',
            value: '${(item.currentValue==null)?'':item.currentValue}'));
      });
    }

    ///海拔
    devInfos.add(new DetailCell(
        label: '海拔(米)', value: dataReady == false ? '--' : '${devInfo.alti}'));

    ///安装位置
    devInfos.add(new DetailCell(
        label: '安装位置',
        value: dataReady == false
            ? '--'
            : (devInfo.location != null && devInfo.location.isNotEmpty
                ? '${devInfo.location}'
                : '无')));

    ///描述
    devInfos.add(new Align(
      alignment: Alignment.centerLeft,
      child: new Text(
        '描述',
        style: new TextStyle(
          color: Colors.grey[500],
          fontSize: 18.0,
        ),
      ),
    ));
    devInfos.add(new Row(
      children: <Widget>[
        new Expanded(
          child: new Text(
            dataReady == false
                ? '--'
                : (devInfo.remark != null && devInfo.remark.isNotEmpty
                    ? '${devInfo.remark}'
                    : '无'),
            style: new TextStyle(
              color: Colors.grey[600],
              fontSize: 18.0,
            ),
          ),
        ),
      ],
    ));

    Widget dataContents = new ListView(
      children: <Widget>[
        ///标头
        new Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          color: const Color(0xFF30aaff),
          child: new Column(
            children: <Widget>[
              new Text(
                this.company == null || this.company.isEmpty
                    ? "--"
                    : '${this.company}',
                style: new TextStyle(
                  fontSize: 26.0,
                  color: Colors.white,
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Image.asset('images/jidi.png', height: 14.0),
                  new SizedBox(
                    width: 8.0,
                  ),
                  new Text(
                    devInfo.farmlandName == null || devInfo.farmlandName.isEmpty
                        ? "--"
                        : '${devInfo.farmlandName}',
                    style: new TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //分隔
        new Container(
          alignment: Alignment.center,
          color: Colors.grey[200],
          child: new SizedBox(
            height: 12.0,
          ),
        ),

        ///经纬度
        new Container(
          padding: const EdgeInsets.all(12.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new DetailTitleCell(icon: 'images/jingweidu.png', label: '经纬度'),
              new DetailCell(
                  label: '经度',
                  value: dataReady == false ? "--" : '${devInfo.lng}'),
              new DetailCell(
                  label: '纬度',
                  value: dataReady == false ? "--" : '${devInfo.lat}'),
              new SizedBox(height: 12.0),
              new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Builder(
                    builder: (BuildContext context) {
                      return new FlatButton(
                        shape: new RoundedRectangleBorder(
                            side: new BorderSide(
                              color: const Color(0xFF30aaff),
                              width: 1.0,
                            ),
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(8.0))),
                        child: new Text(
                          '复制',
                          style: new TextStyle(
                            color: const Color(0xFF30aaff),
                          ),
                        ),
                        onPressed: () {
                          var jsonObj = {
                            'lng': devInfo.lng,
                            'lat': devInfo.lat
                          };
                          String jsonString = json.encode(jsonObj);
                          Clipboard
                              .setData(new ClipboardData(text: jsonString));
                          Scaffold.of(context).showSnackBar(new SnackBar(
                                content: new Text("已复制到剪切板！"),
                              ));
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        //分隔
        new Container(
          alignment: Alignment.center,
          color: Colors.grey[200],
          child: new SizedBox(
            height: 12.0,
          ),
        ),

        ///设备信息
        new Container(
          padding: const EdgeInsets.all(12.0),
          child: new Column(
            children: devInfos,
          ),
        ),

        //分隔
        new Container(
          alignment: Alignment.center,
          color: Colors.grey[200],
          child: new SizedBox(
            height: 12.0,
          ),
        ),

        ///当前状态
        new Container(
          padding: const EdgeInsets.all(12.0),
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: new DetailTitleCell(
                    icon: 'images/dangqianzhuangtai.png', label: '当前状态'),
              ),
              new Switch(
                value: devInfo.status ? true : false,
                onChanged: _changeStatus,
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),

        ///操作人，时间
        new Container(
          padding: const EdgeInsets.all(12.0),
          color: Colors.grey[200],
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new DetailCell(
                  delivied: false,
                  label: '操作人',
                  value: _isStaffVisible ? '$_staffName' : '--'),
              new DetailCell(
                  delivied: false,
                  label: '时  间',
                  value: devInfo.updatedOn == null || devInfo.updatedOn.isEmpty
                      ? "--"
                      : '${devInfo.updatedOn}'),
            ],
          ),
        ),
      ],
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("设备信息"),
        centerTitle: true,
//        backgroundColor: const Color(0xFF2196f3),
        actions: <Widget>[
          new PopupMenuButton<String>(
            onSelected: (String value) {
              if ("edit".compareTo(value) == 0)
                _edit();
              else if ("delete".compareTo(value) == 0) _showPromptDialog();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  new PopupMenuItem<String>(
                      value: 'edit',
                      child: const ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('编辑'))),
                  const PopupMenuDivider(),
                  new PopupMenuItem<String>(
                      value: 'delete',
                      child: const ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('删除')))
                ],
          ),
        ],
      ),
      body: isDeleting ? loadingDialog : dataContents,
    );
  }
}
