import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zw_app/Constant.dart';
import 'package:zw_app/component/FarmlandWidgetItem.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zw_app/component/SearchCell.dart';
import 'package:zw_app/User/Account.dart';

class FarmlandList extends StatefulWidget {
  FarmlandList({Key key}) : super(key: key);

  @override
  _FarmlandListState createState() => new _FarmlandListState();
}

class _FarmlandListState extends State<FarmlandList> {
  String farmlandOid;
  String farmlandName;

  bool _expanded = false;
  List<FarmlandEntry> list = new List<FarmlandEntry>();

  final TextEditingController _searchController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _readFarmlandData().then((String contents) {
      List<FarmlandEntry> newList = convertData(contents);
      setState(() {
        list = newList;
      });
    });
  }

  Future<File> _getFarmlandFile() async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/FarmlandContants.txt');
  }

  Future<String> _readFarmlandData() async {
    try {
      File file = await _getFarmlandFile();
      //if (file.lastModifiedSync())
      String contents = await file.readAsString();
      return contents;
    } on FileSystemException {
      return null;
    }
  }

  void _queryByNameOrID() {
    String name = _searchController.text;
    if (name.isEmpty) {
//      getDeviceData(null);
      return;
    }
  }

  _localQueryAndUpdate(String value) {
    String newValue = value.trim();
    if (newValue == null || newValue.length == 0) {
      _readFarmlandData().then((String contents) {
        List<FarmlandEntry> newList = convertData(contents);
        setState(() {
          _expanded = false;
          list = newList;
        });
      });
    } else {
      _readFarmlandData().then((String contents) {
        List<FarmlandEntry> newList = convertData(contents, newValue);
        setState(() {
          _expanded = true;
          list = newList;
        });
      });
    }
  }

  List<FarmlandEntry> convertData(String contents, [String match]) {
    List<FarmlandEntry> newList = new List<FarmlandEntry>();
    if (contents == null || contents.isEmpty) return newList;

//    print('contents.length: ${contents.length}');
    var deviceItems = json.decode(contents);
    for (var item in deviceItems) {
      String oid = item['_id']['\$oid'];

      var tenantDesc = item['tenant'];
      if (tenantDesc.length == 0) continue;

      if (match != null && match.length > 0) {
        if (item['name'] == null) continue;
        if (item['code'] == null) continue;
        if (!item['name'].toUpperCase().contains(match.toUpperCase()) &&
            !item['code'].toUpperCase().contains(match.toUpperCase())) continue;
      }

      var orignItem = tenantDesc[0];
      //print(
      //    'farm.company: ${item["name"]}====farm.name: ${enterprizeItem['name']}');

      int add = 0;
      for (FarmlandEntry orign in newList) {
        if (orign.oid == orignItem['_id']['\$oid'].toString()) {
          List<FarmlandEntry> children = orign.children;
          if (children == null) {
            children = <FarmlandEntry>[];
            orign.children = children;
          }
          children.add(new FarmlandEntry(
              oid, item['name'], item['code'], <FarmlandEntry>[]));
          continue;
        }
        add++;
      }
      if (add >= newList.length) {
        FarmlandEntry newOrign = new FarmlandEntry(orignItem['_id']['\$oid'],
            orignItem['name'], null, <FarmlandEntry>[]);
        List<FarmlandEntry> children = newOrign.children;
        children.add(new FarmlandEntry(
            oid, item['name'], item['code'], <FarmlandEntry>[]));
        newList.add(newOrign);
      }
    }

    return newList;
  }

  final Widget promptDialog = new Builder(builder: (BuildContext context) {
      return new Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            new Container(
              alignment: AlignmentDirectional.center,
              width: MediaQuery.of(context).size.width / 2 * 1.4,
              height: MediaQuery.of(context).size.width / 2,
//              margin: EdgeInsets.all(8.0),
//              padding: EdgeInsets.all(10.0),
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: const Color(0xFF30aaff),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: new Offset(0.0, 10.0),
                  ),
                ],
                borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
              ),
              child: new Text(
                "导入成功",
                style: new TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ),
            new Container(
              padding: EdgeInsets.all(5.0),
              child: new IconButton(
                icon: new Icon(
                  Icons.cancel,
                  color: Colors.white,
                ),
                onPressed: null,
              ),
            ),
          ],
        );

    });

  _successPrompt() {
    showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
//          return promptDialog;
          return new Dialog(
            child: promptDialog,
          );
        });
  }

  void _showMessage(String msg) {
    showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(content: new Text(msg), actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: new Text('确定'))
          ]);
        });

  }

  Future<Null> _getFarmlandData() async {
    list.clear();
    List<FarmlandEntry> newList = List<FarmlandEntry>();

    var url = '$Server_ISS_URL/tenant.farmland/aggregate';
    var projection = [
      {
        "\$lookup": {
          "from": 'sys.tenant',
          "localField": 'tenant',
          "foreignField": '_id',
          "as": 'tenant'
        }
      },
      {
        "\$project": {
          "name": 1,
          "code": 1,
          "tenant": {"_id": 1, "name": 1}
        }
      }
    ];
    var farmlands = await Account.getOwnerFarmland();
    if (farmlands != null && farmlands.isNotEmpty) {
      var match = {
        "\$match": {
          "_id": {"\$in": farmlands},
          "_removed": {"\$exists": false},
        }
      };
      projection.insert(0, match);
    }
    print("projection: " + json.encode(projection));

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
        print("json.length: ${jsonStr.length}");

        newList = convertData(jsonStr);
        print("newlist.length: ${newList.length}");
        if (newList.length > 0) {
          await (await _getFarmlandFile()).writeAsString('$jsonStr');
        }
        _showMessage('导入成功');
      } else {
        result = '导入失败。请稍后重试！';
      }
    } catch (exception) {
      result = '导入失败。请稍后重试！';
    }

    if (!mounted) return;

    if (newList.length > 0) {
      setState(() {
        list = newList;
      });
    }

    if (result != null)
      _showMessage('$result');
  }

  @override
  Widget build(BuildContext context) {
    Widget _searchSection = new SearchCell(
      hintText: '输入编号或名称',
      inputController: _searchController,
      onButtonClicked: _queryByNameOrID,
      onChanged: _localQueryAndUpdate,
    );

    final Widget _emptyContent = new Center(
      child: new Center(
        child: new Text(
          '无匹配地块',
          style: new TextStyle(
            fontSize: 20.0,
            color: Colors.grey[500],
          ),
        ),
      ),
    );

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('地块列表'),
        leading: null,
        automaticallyImplyLeading: true,
      ),
      body: new Column(
        children: <Widget>[
          _searchSection,
          new Expanded(
            child: (list.length == 0)
                ? _emptyContent
                : new ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return new ExpansionTile(
                        key: new PageStorageKey<FarmlandEntry>(list[index]),
                        title: new Text(list[index].title),
                        initiallyExpanded: _expanded,
                        children:
                            list[index].children.map((FarmlandEntry entry) {
                          if (list[index].children.isNotEmpty)
                            return new ListTile(
                              title: new Text(entry.title),
                              subtitle: new Text(entry.code),
                              onTap: () {
                                var obj = {
                                  "oid": entry.oid,
                                  "name": entry.title
                                };
                                String jsonString = json.encode(obj);
                                Navigator.pop(context, '$jsonString');
                              },
                            );
                        }).toList(),
                      );
                    }, //=> new EntryCell(list[index]),
                    itemCount: list.length,
                  ),
          ),
          new Container(
            margin: const EdgeInsets.all(8.0),
            child: new FlatButton(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 4),
              color: const Color(0xFF30aaff),
              shape: new RoundedRectangleBorder(
                  borderRadius:
                      new BorderRadius.all(new Radius.circular(40.0))),
              child: new Text(
                '导入地块',
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              onPressed: _getFarmlandData,
            ),
          ),
        ],
      ),
    );
  }
}

class FarmlandEntry {
  FarmlandEntry(this.oid, this.title, this.code, this.children);
  final String oid;
  final String title;
  final String code;
  List<FarmlandEntry> children;
}
