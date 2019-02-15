import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zw_app/Constant.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:zw_app/devices/CreateDevice.dart';
import 'package:zw_app/devices/DeviceInfo.dart';
import 'package:zw_app/devices/DeviceTypeItem.dart';
import 'package:zw_app/devices/ParamTypeItem.dart';
import 'package:zw_app/devices/DeviceDetail.dart';
import 'package:zw_app/Utils.dart';
import 'package:zw_app/home.dart';
import 'package:zw_app/component/app_bar.dart';
import 'package:zw_app/component/CustomCell.dart';
import 'package:zw_app/component/InputCell.dart';
import 'package:zw_app/component/EnsureVisibleWhenFocused.dart';

class DeviceNewInfo extends StatefulWidget {
  DeviceNewInfo({Key key, this.devInfo}) : super(key: key);

  DeviceInfo devInfo;

  @override
  _DeviceNewInfoState createState() => new _DeviceNewInfoState(devInfo);
}

class _DeviceNewInfoState extends State<DeviceNewInfo> {
  FocusNode _focusNodeRemark = new FocusNode();
  DeviceInfo devInfo;

  bool isParamsVisible = false;
  List<ParamTypeItem> paramList;

  List<DeviceTypeItem> typeList = new List<DeviceTypeItem>();
  DeviceTypeItem selectedItem;
  List<DropdownMenuItem<DeviceTypeItem>> dropdownWidget =
      new List<DropdownMenuItem<DeviceTypeItem>>();

  TextEditingController _nameController;
  TextEditingController _codeController;
  TextEditingController _altiController;
  TextEditingController _locationController;
  TextEditingController _remarkController;

  _DeviceNewInfoState(this.devInfo);

  @override
  initState() {
    super.initState();

    _nameController = new TextEditingController(text: devInfo.name ?? '');
    _codeController = new TextEditingController(text: devInfo.code ?? '');
    _altiController = new TextEditingController(
        text: (devInfo.alti == 0.0) ? '' : devInfo.alti.toString());
    _locationController =
        new TextEditingController(text: devInfo.location ?? '');
    _remarkController = new TextEditingController(text: devInfo.remark ?? '');

    paramList = List<ParamTypeItem>();

    getDeviceType();

    _nameController.addListener(_checkNameInputValue);
    _codeController.addListener(_checkCodeInputValue);
    _locationController.addListener(_checkLocationInputValue);
  }

  @override
  void dispose() {
    _locationController.removeListener(_checkLocationInputValue);
    _codeController.removeListener(_checkCodeInputValue);
    _nameController.removeListener(_checkNameInputValue);
    _locationController.dispose();
    _altiController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  _checkNameInputValue() {
    if (_nameController.text.length > 32) {
      String tmp = _nameController.text;
      tmp = tmp.substring(0, 32);
      _nameController.text = tmp;
      _nameController.selection =
          new TextSelection.collapsed(offset: tmp.length);
    }
  }

  _checkCodeInputValue() {
    if (_codeController.text.length > 128) {
      String tmp = _codeController.text;
      tmp = tmp.substring(0, 128);
      _codeController.text = tmp;
      _codeController.selection =
          new TextSelection.collapsed(offset: tmp.length);
    }
  }

  _checkLocationInputValue() {
    if (_locationController.text.length > 128) {
      String tmp = _locationController.text;
      tmp = tmp.substring(0, 128);
      _locationController.text = tmp;
      _locationController.selection =
          new TextSelection.collapsed(offset: tmp.length);
    }
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this._codeController.text = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        print('The user did not grant the camera permission!');
        setState(() {
          this.devInfo.code = null;
        });
      } else {
        print('Unknown error: $e');
        setState(() => this.devInfo.code = null);
      }
    } on FormatException {
      print(
          'null (User returned using the "back"-button before scanning anything. Result)');
      setState(() => this.devInfo.code = null);
    } catch (e) {
      print('Unknown error: $e');
      setState(() => this.devInfo.code = null);
    }
  }

  Future<Null> getDeviceType() async {
    var url = '$Server_IOT_URL/base.device.type/aggregate';
    var projection = [
      {
        "\$match": {
          "_removed": {"\$exists": false},
        }
      },
      {
        "\$lookup": {
          "from": 'base.device.param_type',
          "localField": 'paramTypes',
          "foreignField": '_id',
          "as": 'paramTypes'
        }
      },
      {
        "\$project": {
          "name": 1,
          "code": 1,
          "paramTypes": {
            "_id": 1,
            "name": 1,
            "code": 1,
            "type": 1,
            "value": 1,
            "required": 1
          }
        }
      }
    ];
    print("projection: " + json.encode(projection));
    var oldTypeItem = null;

    var httpClient = new HttpClient();

    try {
      var request = await httpClient.postUrl(Uri.parse(url));
      request.headers.contentType =
          new ContentType("application", "json", charset: "utf-8");
      request.write(json.encode(projection));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        String jsonStr = await response.transform(utf8.decoder).join();
//        print('base.device.type/base.device.param_type: $json');
        var typeItems = json.decode(jsonStr);
        for (var item in typeItems) {
          var oidDesc = item['_id'];
          String oid = oidDesc['\$oid'];
          String tmpname = item['name'];
          tmpname = (tmpname.length > 12)
              ? item['name'].substring(0, 12)
              : item['name'];

          DeviceTypeItem newItem =
              new DeviceTypeItem(oid, item['code'].toString(), tmpname);
          typeList.add(newItem);

          newItem.paramTypes = new List<ParamTypeItem>();
          var params = item['paramTypes'];
          if (params != null && params.length > 0) {
            for (var si in params) {
              ParamTypeItem paramItem = ParamTypeItem.from(si);
              newItem.paramTypes.add(paramItem);
            }
          }

          ///设备编辑时的当前设备类型
          if (oid == devInfo.typeOid) {
            oldTypeItem = newItem;
          }
        }
      } else {
        print('DeviceNewInfo failed:\nHttp status ${response.statusCode}');
      }
    } catch (exception) {
      print('DeviceNewInfo exception: $exception');
    }

    // If the widget was removed from the tree while the message was in flight,
    // we want to discard the reply rather than calling setState to update our
    // non-existent appearance.
    if (!mounted) return;

    if (typeList.isNotEmpty) {
      setState(() {
        dropdownWidget = typeList.map((DeviceTypeItem item) {
          return new DropdownMenuItem<DeviceTypeItem>(
            value: item,
            child: new Text(
              item.name,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: new TextStyle(
                color: Colors.black,
                fontSize: 12.0,
              ),
            ),
          );
        }).toList();
        if (oldTypeItem != null) _typeChanged(oldTypeItem);
        isParamsVisible = true;
      });
    }
  }

  _typeChanged(DeviceTypeItem newValue) {
    //if (newValue.oid == devInfo.typeOid) return;
    print('typeChanged: ${newValue.name}');
    bool isContainerK = false;

    paramList.clear();
    paramList.addAll(newValue.paramTypes);
    for (ParamTypeItem item in paramList) {
      Object oldValue = devInfo.params[item.oid];
      if (oldValue == null) oldValue = item.defaultValue;

      if (oldValue == null) oldValue = '';
      item.inputController = new TextEditingController(text: '$oldValue');
      isContainerK = true;
    }

    setState(() {
      selectedItem = newValue;
      isParamsVisible = isContainerK;
    });
  }

  _prevStep() {
    Navigator.of(context).pop();
  }

  _submit() async {
    ///数据校验

    String name = _nameController.text.replaceAll(' ', '');
    if (name.isEmpty) {
      _showMessage('设备名称不能为空');
      return;
    }
    if (name.length < 2) {
      _showMessage('设备名称超范围\n长度范围：2~32字符');
      return;
    }
    String code = _codeController.text.replaceAll(' ', '');
    if (code.isEmpty) {
      _showMessage('设备ID不能为空');
      return;
    }
    if (code.length < 2) {
      _showMessage('设备ID超范围\n长度范围：2~128字符');
      return;
    }
    if (selectedItem == null || selectedItem.oid.isEmpty) {
      _showMessage('设备类型未选择');
      return;
    }
    if (_altiController.text.isNotEmpty &&
        Utils.isNotNumber(_altiController.text)) {
      _showMessage('海拔存在非数字字符');
      return;
    } else if (_altiController.text.isNotEmpty &&
        (num.parse(_altiController.text) < -15000 ||
            num.parse(_altiController.text) > 15000)) {
      _showMessage('海拔超范围\n'
          '数值范围：-15000.0~15000.0');
      return;
    }

    if (_locationController.text.isNotEmpty &&
        (_locationController.text.length < 2 ||
            _locationController.text.length > 128)) {
      _showMessage('设备安装位置超范围\n'
          '长度范围：2~128字符');
      return;
    }

    if (devInfo.name != name) devInfo.name = name;

    if (devInfo.code != code) devInfo.code = code;

    if (devInfo.typeOid != selectedItem.oid) devInfo.typeOid = selectedItem.oid;

    if (_altiController.text.isEmpty) _altiController.text = "0.0";
    if (devInfo.alti != num.parse(_altiController.text))
      devInfo.alti = num.parse(_altiController.text);

    if (devInfo.location != _locationController.text)
      devInfo.location = _locationController.text;

    if (devInfo.remark != _remarkController.text)
      devInfo.remark = _remarkController.text;

    ///提取参数列表中的输入值
    var newParams = {};
    for (ParamTypeItem item in paramList) {
      var oid = item.oid;
      TextEditingController controller = item.inputController;
      var newValue = controller.text;

      ///参数为必填项，或者为选填项但内容不为空
      if (item.required == 1 || item.required == 0 && newValue.isNotEmpty) {
        if (item.type == 1) {
          if (Utils.isNotNumber(newValue) ||
              item.min != null && num.parse(newValue) < item.min ||
              item.max != null && num.parse(newValue) > item.max) {
            _showMessage(
                '${item.name}必须为数字。范围：${item.min??""}〜${item.max??""}');
            return;
          }
        } else if (item.type == 2) {
          if (item.min != null && newValue.toString().length < item.min ||
              item.max != null && newValue.toString().length > item.max) {
            _showMessage(
                '${item.name}必须为字符串。长度范围：${item.min??""}〜${item.max??""}');
            return;
          }
        }
        newParams[oid] = newValue;
      }
    }
    devInfo.params = newParams;

    //TODO
    if (devInfo.editable && devInfo.isNotDirty) {
      _showMessage('设备信息没有修改！');
      return;
    }

    int isExist = await devInfo.verifyDeviceCode();
    if (isExist != null) {
      if (isExist > 0) {
        _showMessage('设备ID已存在');
        return;
      }
    }

    await devInfo.commit().then((String responseString) {
      var responseData = json.decode(responseString);
      if (responseData['_id'] != null)
        _showSuccessDialog('设备添加成功');
      else if (responseData['updatedOn'] != null) _showEditSuccess('设备修改成功');
    });
  }

  void _showMessage(String msg) {
    showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(content: new Text(msg), actions: <Widget>[]);
        });
  }

  Future<Null> _showEditSuccess(String string) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(string),
          actions: <Widget>[
            new FlatButton(
              child: new Text('确认'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => new HomePage()),
                  ModalRoute.withName('/homepage'),
                );
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (_) => new DeviceDetail(oid: devInfo.oid),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  _showSuccessDialog(String msg) {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text(msg),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) => new HomePage()),
                      ModalRoute.withName('/homepage'),
                    );
                  },
                  child: new Text('返回查看')),
              new FlatButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) => new HomePage()),
                      ModalRoute.withName('/homepage'),
                    );
                    Navigator.of(context).push(new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                      return new CreateDevice();
                    }));
                  },
                  child: new Text('继续添加'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = new List<Widget>();

    ///设备名称
    children.add(new Row(
      children: <Widget>[
        new Text(
          '*',
          style: new TextStyle(
            color: Colors.red,
            fontSize: 20.0,
          ),
        ),
        new Expanded(
          child: new InputCell(
              label: '设备名称', inputController: _nameController, need: true),
        ),
      ],
    ));

    ///设备ID
    children.add(new Row(
//      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new Text(
          '*',
          style: new TextStyle(
            color: Colors.red,
            fontSize: 20.0,
          ),
        ),
        new Expanded(
          child: new InputCell(
              label: '设备ID', inputController: _codeController, need: true),
        ),
        new IconButton(
          onPressed: scan,
          icon: new Image.asset(
            'images/saoyisao.png',
            height: 18.0,
          ),
          //child: new Text('扫一扫'),
        ),
      ],
    ));

    ///设备类型
    children.add(new Row(
      children: <Widget>[
        new Text(
          '*',
          style: new TextStyle(
            color: Colors.red,
            fontSize: 20.0,
          ),
        ),
        new Expanded(
          child: new CustomCell(
            label: '设备类型',
            child: new DropdownButtonHideUnderline(
              child: new DropdownButton(
                items: dropdownWidget,
                value: selectedItem,
                isDense: true,
                hint: new Text(
                  '请选择',
                ),
                onChanged: _typeChanged,
              ),
            ),
          ),
        ),
      ],
    ));

    ///参数
    if (isParamsVisible) {
      for (ParamTypeItem item in paramList)
        children.add(new Row(
          children: <Widget>[
            new Text(
              '*',
              style: new TextStyle(
                color: Colors.transparent,
                fontSize: 20.0,
              ),
            ),
            new Expanded(
                child: new InputCell(
              label: '${item.name}',
              inputController: item.inputController,
            )),
          ],
        ));
    }

    ///海拔
    children.add(new Row(
      children: <Widget>[
        new Text(
          '*',
          style: new TextStyle(
            color: Colors.transparent,
            fontSize: 20.0,
          ),
        ),
        new Expanded(
            child: new InputCell(
                label: '海拔(米)',
                inputController: _altiController,
                keyboardType: TextInputType.number)),
      ],
    ));

    ///安装位置
    children.add(new Row(
      children: <Widget>[
        new Text(
          '*',
          style: new TextStyle(
            color: Colors.transparent,
            fontSize: 20.0,
          ),
        ),
        new Expanded(
          child: new InputCell(
            label: '安装位置',
            inputController: _locationController,
          ),
        ),
      ],
    ));

    ///描述
    children.add(new Row(
      children: <Widget>[
        new Text(
          '*',
          style: new TextStyle(
            color: Colors.transparent,
            fontSize: 20.0,
          ),
        ),
        new Expanded(
          child: new Text(
            '描述',
            style: new TextStyle(
              color: Colors.grey[500],
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    ));
    children.add(new Row(
      children: <Widget>[
        new Text(
          '*',
          style: new TextStyle(
            color: Colors.transparent,
            fontSize: 20.0,
          ),
        ),
        new Expanded(
          child: new EnsureVisibleWhenFocused(
            focusNode: _focusNodeRemark,
            child: new TextField(
              focusNode: _focusNodeRemark,
              controller: _remarkController,
              decoration: new InputDecoration(
                hintText: '请输入',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    ));

    return new Scaffold(
//      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('设备信息'),
        leading: null,
        automaticallyImplyLeading: true,
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new ListView(
              padding: new EdgeInsets.all(16.0),
              children: children,
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
                      onPressed: _submit,
                      child: new Text(
                        '完成',
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
