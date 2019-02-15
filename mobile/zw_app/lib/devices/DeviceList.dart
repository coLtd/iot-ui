import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zw_app/devices/CreateDevice.dart';
import 'package:zw_app/devices/Device.dart';
import 'package:zw_app/devices/DeviceDetail.dart';
import 'package:zw_app/component/DeviceCell.dart';
import 'package:zw_app/component/CustomButtonBar.dart';
import 'package:zw_app/Constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zw_app/component/SearchCell.dart';
import 'package:zw_app/User/Account.dart';
import 'package:zw_app/User/UserCenter.dart';

class DeviceList extends StatefulWidget {
  DeviceList({Key key}) : super(key: key);

  @override
  _DeviceListState createState() => new _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  Map<String, List> typeIDs;

  List<Item> items;
  Item _selectedValue;
  int add = 0;

  String queryString;
  Stream<List<Device>> myStream;
  final TextEditingController _searchController = new TextEditingController();

  _DeviceListState();

  void _createDevice() {
    setState(() {
      Navigator
          .of(context)
          .push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new CreateDevice();
      }));
    });
  }

  void _userCenter() {
//    setState(() {
    Navigator
        .of(context)
        .push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
      return new UserCenter();
    }));
//    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_checkInputValue);

//    device = new List<Device>();
    typeIDs = {
      "0": new List<String>(),
      "1": new List<String>(),
      "2": new List<String>(),
      "3": new List<String>(),
      "4": new List<String>()
    };

    items = <Item>[
      new Item('气象站', '0'),
      new Item('视频', '3'),
      new Item('土壤环境', '1'),
      new Item('水体环境', '2'),
      new Item('控制设备', '4'),
    ];

    getDeviceTypes();
    myStream = getDeviceData()?.asStream();

    // TODO
//    _readDeviceData().then((String contents) {
//      List<Device> newList = convertData(contents);
//      setState(() {
//        device = newList;
//      });
//    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_checkInputValue);
    _searchController.dispose();
    super.dispose();
  }

  _checkInputValue() {
    if (_searchController.text.length > 128) {
      String tmp = _searchController.text;
      tmp = tmp.substring(0, 128);
      _searchController.text = tmp;
      _searchController.selection =
          new TextSelection.collapsed(offset: tmp.length);
    }
  }

  Future<File> _getDeviceFile() async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/RemoteDeviceData.txt');
  }

  Future<String> _readDeviceData() async {
    try {
      File file = await _getDeviceFile();
      await file.lastModified().then((DateTime dt) {
        if (dt.add(new Duration(minutes: 10)).isBefore(DateTime.now())) {
          getDeviceData();
          return null;
        }
      });

      String contents = await file.readAsString();
      return contents;
    } on FileSystemException {
      getDeviceData();
      return null;
    }
  }

  List<Device> convertData(String contents, [String match]) {
    List<Device> newList = new List<Device>();
    if (contents == null || contents.isEmpty) return newList;

    var data = json.decode(contents);
    var deviceItems = data['items'];
    for (var item in deviceItems) {
      var tmpOid = item['_id'];
      String oid = tmpOid['\$oid'];
      var update = item['updatedOn'];
      if (item['name'] == null ||
          item['code'] == null ||
          item['name'].isEmpty ||
          item['code'].isEmpty) continue;
      int updatedOn = int.parse(update['\$numberLong']);
      String name = (item['name'].length > 16)
          ? item['name'].substring(0, 16) + '...'
          : item['name'];
      String code = (item['code'].length > 16)
          ? item['code'].substring(0, 16) + '...'
          : item['code'];
      Device d = new Device(oid, code, name, updatedOn);
      newList.add(d);
    }

    return newList;
  }

  /// 获取设备类型数据，提取统计标签与类型ID的对应关系；
  Future<Null> getDeviceTypes() async {
    var url = '$Server_IOT_URL/base.device.type';
    var projection = {"_id": 1, "tag": 1};
    String encodeProjection = Uri.encodeQueryComponent(json.encode(projection));
    url = url + '?projection=$encodeProjection';
    var httpClient = new HttpClient();

    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        String jsonString = await response.transform(utf8.decoder).join();
        var data = json.decode(jsonString);
        var deviceItems = data['items'];
        for (var item in deviceItems) {
          int tag = item['tag'];
          if (tag >= 1 && tag <= 5) {
            String oid = item['_id']['\$oid'];
            List<String> obj = typeIDs['${tag-1}'];
            obj.add(oid);
          }
        }
        result = jsonString;
      } else {
        result =
            'Error getting IP address:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed getting IP address';
      print(exception);
    }
  }

  /// 获取设备列表数据
  /// param filter: 查找条件, 设备名称，设备ID，统计标签
  Future<List<Device>> getDeviceData([String filter]) async {
    List<Device> newList = new List<Device>();

    var url = '$Server_IOT_URL/tenant.device';
    var projection = {"_id": 1, "name": 1, "code": 1, "updatedOn": 1};
    String encodeProjection = Uri.encodeQueryComponent(json.encode(projection));
    url = url + '?projection=$encodeProjection';

    var filterMap = {};
    //提取有权限地块
    List<Map<Object, Object>> farmlandsIn = await Account.getOwnerFarmland();
    if (farmlandsIn != null && farmlandsIn.isNotEmpty) {
      filterMap["farmland"] = {"\$in": farmlandsIn};
    }
    if (filter != null && filter.isNotEmpty) {
      var tmpFilter = json.decode(filter);
      filterMap.addAll(tmpFilter);
    }
    if (filterMap.length > 0) {
      String encodeFilter = Uri.encodeQueryComponent(json.encode(filterMap));
      url = url + '&filter=$encodeFilter';
    }
    url += '&sort={"updatedOn":-1}';

    var httpClient = new HttpClient();

    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        String jsonStr = await response.transform(utf8.decoder).join();

        newList = convertData(jsonStr);

        result = jsonStr;
//        if (newlist.length > 0) {
//          await (await _getDeviceFile()).writeAsString('$jsonStr');
//        }
      } else {
        result =
            'Error getting IP address:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed getting IP address';
      print(exception);
    }

    if (newList.length == 0) return null;
    return newList;
  }

  /// 根据设备名称或者设备ID进行查找
  void _queryByNameOrID() {
    String name = _searchController.text.trim();

    var filter = {
      "\$or": [
        {
          "name": {"\$regex": "$name", "\$options": "si"}
        },
        {
          "code": {"\$regex": "$name", "\$options": "si"}
        }
      ]
    }; //&skip=0&limit=10&sort={"updatedOn":-1}
    queryString = json.encode(filter);
    myStream = getDeviceData(queryString)?.asStream();
    setState((){});
  }

  /// 根据统计标签进行查找
  void _queryByTag(int value) {
    var filter = {};
    if (value < 0) {
      queryString = null;
      myStream = getDeviceData(queryString)?.asStream();
      return;
    }

    List<String> ids = typeIDs['$value'];

    if (ids.isEmpty) return;

    //提取统计标签
    var typesIn = [];
    for (int i = 0; i < ids.length; i++) {
      var tmp = {"\$oid": "${ids[i]}"};
      typesIn.add(tmp);
    }
    if (typesIn.length > 0) {
      filter["type"] = {
        "\$in": typesIn
      }; //&skip=0&limit=10&sort={"updatedOn":-1}
    }

    queryString = json.encode(filter);
    myStream = getDeviceData(queryString)?.asStream();
  }

  Future<Null> onItemClicked(String oid) async {
    String result = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (_) => new DeviceDetail(oid: oid),
      ),
    );
    if (result == null) return;
    var obj = json.decode(result);
    if (obj != null && obj.length > 0) {
      setState(() {
        if (obj['oid'] != null)
          ; //deleteItem(obj['oid']);
        else {
          String errmsg = obj['err'];
          showDialog<Null>(
              context: context,
              builder: (BuildContext context) {
                return new SimpleDialog(
                  title: Text('$errmsg'),
                  children: <Widget>[],
                );
              });
        }
      });
    }
  }

//  deleteItem(String oid) {
//    List<Device> newlist = new List<Device>();
//    for (Device dev in device) {
//      if (dev.oid != oid) newlist.add(dev);
//    }
//    setState(() {
//      device = newlist;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    final Widget _emptyContent = new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Image.asset('images/wuxinxi.png'),
          new Container(
            alignment: Alignment.center,
            width: 160.0,
            child: new Text(
              '无设备信息',
              style: new TextStyle(
                fontSize: 20.0,
                color: Colors.grey[500],
              ),
            ),
          ),
          new Container(
            margin: const EdgeInsets.only(top: 64.0),
            width: MediaQuery.of(context).size.width * 3 / 4,
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: new BorderRadius.all(new Radius.circular(28.0)),
              gradient: new LinearGradient(
                  colors: [const Color(0xFF30aaff), const Color(0xFF2bd0fe)],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.5, 0.0),
                  stops: [0.0, 0.5],
                  tileMode: TileMode.clamp),
            ),
            child: new FlatButton(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              onPressed: _createDevice,
              child: new Text(
                '添加设备',
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final Widget _searchSection = new Row(
      children: <Widget>[
        new Expanded(
          child: new SearchCell(
            hintText: '设备名称或ID',
            inputController: _searchController,
            onButtonClicked: _queryByNameOrID,
            onChanged: null,
          ),
        ),
        new Container(
          padding: new EdgeInsets.all(10.0),
          color: Theme.of(context).primaryColor,
          child: new Container(
            //padding: new EdgeInsets.only(left: 8.0),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: new BorderRadius.all(new Radius.circular(40.0)),
            ),
            child: new Ink(
              height: 48.0,
              child: new InkWell(
                onTap: _queryByNameOrID,
                child: new Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(4.0)),
                  ),
                  child: new Text(
                    '搜索',
                    style: new TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final List<Widget> children = <Widget>[];
    items.forEach((Item item) {
//      if (items.first != item)
//        children.add(new Container(
//          height: 48 / 3,
//          decoration: new BoxDecoration(
//            border: new Border.all(
//              color: Colors.white,
//              width: 0.3,
//            ),
//          ),
//        ));

      children.add(new InkWell(
        onTap: () {
          setState(() {
            if (_selectedValue != null && _selectedValue == item)
              _selectedValue = null;
            else
              _selectedValue = item;
          });
          if (_selectedValue == null)
            _queryByTag(-1);
          else
            _queryByTag(num.parse(item.value));
        },
        child: new Container(
          padding: EdgeInsets.all(6.0),
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
            color: item != null && item == _selectedValue
                ? Colors.white30
                : Colors.transparent,
          ),
          child: new Text(
            item.title,
            style: new TextStyle(color: Colors.white),
          ),
        ),
      ));
    });
    final Widget _selectSection = new Ink(
      color: Theme.of(context).primaryColor,
      height: 48.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );

//    Widget _dataContent = new Container(
//      padding: new EdgeInsets.all(8.0),
//      child: new Column(
//        children: <Widget>[
//          _searchSection,
//          _selectSection,
//          new Expanded(
//              child: new ListView(
//            padding: new EdgeInsets.symmetric(vertical: 8.0),
//            children: listTitles.toList(),
//          )),
//        ],
//      ),
//    );

    return new Container(
      child: new StreamBuilder<List<Device>>(
        stream: myStream,
        builder: (BuildContext context, AsyncSnapshot<List<Device>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text('Press button to start');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return new Center(
                child: new CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else {
                if (snapshot.hasData) {
                  Iterable<Widget> listTitles =
                      snapshot.data.map((Device device) {
                    return new DeviceCell(
                        device: device, onItemClicked: onItemClicked);
                  });

                  listTitles = ListTile.divideTiles(
                      context: context,
                      tiles: listTitles,
                      color: Colors.grey[600]);

                  return new Column(
                    children: <Widget>[
                      _searchSection,
                      _selectSection,
                      new Expanded(
                          child: new ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return listTitles.elementAt(index);
                        },
                      )),
                    ],
                  );
                } else {
                  //无设备数据
                  if (queryString == null)
                    return _emptyContent;
                  //搜索无数据
                  else
                    return new Column(
                      children: <Widget>[
                        _searchSection,
                        _selectSection,
                        new Expanded(
                          child: new Center(
                            child: new Text(
                              '无匹配设备',
                              style: new TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                }
              }
          }
        },
      ),
    );
  }
}
