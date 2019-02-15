import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:zw_app/Constant.dart';
import 'package:zw_app/User/Account.dart';

class DeviceInfo extends Object {
  Future<int> verifyDeviceCode() async {
    /// 设备ID唯一性校验
    var url = '$Server_IOT_URL/tenant.device/count';

    if (oid != null) {
      return null;
    }

    var filter = {
      "code": {"\$regex": "^$code\$", "\$options": "si"}
    };
    String queryString = Uri.encodeQueryComponent(json.encode(filter));
    print('verifyDeviceCode.filter: ' + json.encode(filter));
    url = url + '?filter=$queryString';

    var httpClient = new HttpClient();

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        String jsonString = await response.transform(utf8.decoder).join();
        print("verifyDeviceCode response: \n" + jsonString);
        return int.parse(jsonString);
      } else {
        return -1;
      }
    } catch (exception) {
      return -1;
    }
  }

  Future<String> commit() async {
    ///提交更新数据
    var url = '$Server_IOT_URL/tenant.device';

    Map objBody = await this.asMap();

    if (oid != null) {
      objBody = {
        "filter": {
          "_id": {"\$oid": oid}
        },
        "update": {"\$set": objBody}
      };
    }
    print("device.data string: \n" + json.encode(objBody));

    var httpClient = new HttpClient();

    try {
      var request = await httpClient.openUrl(
          (oid == null) ? 'POST' : 'PUT', Uri.parse(url));
      request.headers.contentType =
          new ContentType("application", "json", charset: "utf-8");
      request.write(json.encode(objBody));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        String jsonString = await response.transform(utf8.decoder).join();
        print("tenant.device response: \n" + jsonString);
        return jsonString;
      } else {
        String jsonString = await response.transform(utf8.decoder).join();
        return jsonString;
      }
    } catch (exception) {
      var responseData = {'status': -1, 'errmessage': '网络错误'};
      return json.encode(responseData);
    }
  }

  String oid;
  String _code;
  String _name;
  num _lng;
  num _lat;
  num _alti;
  String _location; //安装位置
  String _remark; //描述
  int _status; //当前状态

  String _typeOid; //设备类型ID, base.device.type中的ID值；
  String typeName; //设备类型名称
  String _farmlandOid; //地块ID
  String farmlandName; //地块名称

  var _params; //参数
  String _staffOid; //操作人ID，tenant.staff中的ID值；
  String updatedOn; //操作时间

  static const int BIT_DEVICE_FARMLAND_OID = 0x0001;
  static const int BIT_DEVICE_LNG = BIT_DEVICE_FARMLAND_OID << 1;
  static const int BIT_DEVICE_LAT = BIT_DEVICE_LNG << 1;
  static const int BIT_DEVICE_NAME = BIT_DEVICE_LAT << 1;
  static const int BIT_DEVICE_CODE = BIT_DEVICE_NAME << 1;
  static const int BIT_DEVICE_TYPE_OID = BIT_DEVICE_CODE << 1;
  static const int BIT_DEVICE_LOCATION = BIT_DEVICE_TYPE_OID << 1;
  static const int BIT_DEVICE_ALTI = BIT_DEVICE_LOCATION << 1;
  static const int BIT_DEVICE_REMARK = BIT_DEVICE_ALTI << 1;
  static const int BIT_DEVICE_STATUS = BIT_DEVICE_REMARK << 1;
  static const int BIT_DEVICE_K_VALUE = BIT_DEVICE_REMARK << 1;
  static const int BIT_DEVICE_PARAMS = BIT_DEVICE_K_VALUE << 1;
  static const int BIT_DEVICE_STAFF_OID = BIT_DEVICE_PARAMS << 1;

  bool _editable;
  int _dirty; //脏数据标识符

  DeviceInfo() {
    _params = {};
    clear();
    _editable = false;
    _dirty = 0;
  }

  DeviceInfo.from(this.oid, Map map) {
    _params = {};
    _editable = false;
    _dirty = 0;
  }

  void clear() {
    oid = null;
    _code = null;
    _name = null;
    _lng = 0.0;
    _lat = 0.0;
    _alti = 0.0;
    _location = null;
    _remark = null;
    _status = 1;

    _typeOid = null;
    typeName = null;
    _farmlandOid = null;
    farmlandName = null;

    _params.clear();
    _staffOid = null;
    updatedOn = null;
  }

  set editable(bool able) {
    this._editable = true;
    _dirty = 0;
  }

  bool get editable => this._editable;

  bool get isNotDirty => this._dirty == 0;
  bool get isDirty => this._dirty > 0;

  set code(String code) {
    this._code = code;
    _dirty = (_dirty | DeviceInfo.BIT_DEVICE_CODE);
  }

  String get code => this._code;

  set name(String name) {
    this._name = name;
    _dirty = (_dirty | DeviceInfo.BIT_DEVICE_NAME);
  }

  String get name => this._name;

  set alti(num alti) {
    this._alti = alti;
    _dirty = (_dirty | DeviceInfo.BIT_DEVICE_ALTI);
  }

  num get alti => this._alti;

  set location(String loc) {
    this._location = loc;
    _dirty = (_dirty | DeviceInfo.BIT_DEVICE_LOCATION);
  }

  String get location => this._location;

  set remark(String desc) {
    this._remark = desc;
    _dirty = (_dirty | DeviceInfo.BIT_DEVICE_REMARK);
  }

  String get remark => this._remark;

  set status(bool value) {
    this._status = value ? 1 : 0;
    _dirty = (_dirty | DeviceInfo.BIT_DEVICE_STATUS);
  }

  bool get status => this._status == 1 ? true : false;

  set typeOid(String oid) {
    this._typeOid = oid;
    this._dirty = (_dirty | DeviceInfo.BIT_DEVICE_TYPE_OID);
  }

  String get typeOid => this._typeOid;

  set farmlandOid(String oid) {
    this._farmlandOid = oid;
    this._dirty = (_dirty | DeviceInfo.BIT_DEVICE_FARMLAND_OID);
  }

  String get farmlandOid => this._farmlandOid;

  num get lng => this._lng;
  num get lat => this._lat;

  void setLngLat({num lng: 0, num lat: 0}) {
    if (lng != null && lng != _lng) {
      this._lng = lng;
      _dirty = (_dirty | DeviceInfo.BIT_DEVICE_LNG);
    }
    if (lat != null && lat != _lat) {
      this._lat = lat;
      _dirty = (_dirty | DeviceInfo.BIT_DEVICE_LAT);
    }
  }

  set params(var newMap) {
    if (_params.length == 0) {
      _params = newMap;
      _dirty = (_dirty | DeviceInfo.BIT_DEVICE_PARAMS);
    } else
      this._params.forEach((Object k, Object v) {
        if (newMap[k] != v) this._params[k] = newMap[k];
        _dirty = (_dirty | DeviceInfo.BIT_DEVICE_PARAMS);
      });
  }

  Map get params => this._params;

  set staffOid(String oid) {
    this._staffOid = oid;
    this._dirty = (_dirty | DeviceInfo.BIT_DEVICE_STAFF_OID);
  }

  String get staffOid => this._staffOid;

  Future<Map> asMap() async {
    var ret = {};

    if (oid == null) {
      ret['code'] = this.code;
      ret['name'] = this.name;
      ret['lng'] = this.lng;
      ret['lat'] = this.lat;
      ret['alti'] = this.alti;
      ret['location'] = this.location;
      ret['remark'] = this.remark;
      ret['status'] = this._status;

      ret['type'] = {"\$oid": this.typeOid};
      ret['farmland'] = {"\$oid": this.farmlandOid};

      ret['params'] = this.params;

      String userId = await Account.getStaffOid();
      if (userId != null) ret['staff'] = {"\$oid": '$userId'};
    } else {
      print(_dirty);

      if ((_dirty & BIT_DEVICE_CODE) > 0) ret['code'] = this.code;
      if ((_dirty & BIT_DEVICE_NAME) > 0) ret['name'] = this.name;
      if ((_dirty & BIT_DEVICE_LNG) > 0) ret['lng'] = this.lng;
      if ((_dirty & BIT_DEVICE_LAT) > 0) ret['lat'] = this.lat;
      if ((_dirty & BIT_DEVICE_ALTI) > 0) ret['alti'] = this.alti;
      if ((_dirty & BIT_DEVICE_LOCATION) > 0) ret['location'] = this.location;
      if ((_dirty & BIT_DEVICE_REMARK) > 0) ret['remark'] = this.remark;
      if ((_dirty & BIT_DEVICE_STATUS) > 0) ret['status'] = this._status;
      if ((_dirty & BIT_DEVICE_TYPE_OID) > 0)
        ret['type'] = {"\$oid": this.typeOid};
      if ((_dirty & BIT_DEVICE_FARMLAND_OID) > 0)
        ret['farmland'] = {"\$oid": this.farmlandOid};
      if ((_dirty & BIT_DEVICE_STAFF_OID) > 0)
        ret['farmland'] = {"\$oid": this.staffOid};
      if ((_dirty & BIT_DEVICE_PARAMS) > 0) {
        //TODO
//        Map tmp = new Map();
//        this.params.forEach((key, value) {
//          Map obj = value;
//          tmp['$key'] = obj['currentValue'];
//        });
        ret['params'] = this.params;
      }
    }

    return ret;
  }

  @override
  String toString() {
    var ret = this.asMap();
    return ret.toString();
  }

  String toJSONString() {
    var ret = this.asMap();
    return json.encode(ret);
  }
}
