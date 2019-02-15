import 'package:zw_app/devices/ParamTypeItem.dart';

class DeviceTypeItem {

  String oid;
  String code;
  String name;

  List<ParamTypeItem> paramTypes;

  DeviceTypeItem(this.oid, this.code, this.name);
}