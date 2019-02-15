import 'package:flutter/material.dart';

class ParamTypeItem {

  String oid;
  String code;
  String name;
  int type;
  num max;
  num min;
  int required;
  Object defaultValue;

  Object currentValue;

  TextEditingController inputController;

  ParamTypeItem(this.oid, this.name, this.defaultValue, this.type, [this.required]);

  ParamTypeItem.from (Map map) {

    this.oid = map['_id']['\$oid'];
    this.code = map['code'];
    this.name = map['name'];
    this.type = map['type'];
    if (this.type == 1) {
      this.max = map['max'];
      this.min = map['min'];
    } else if (this.type == 2) {
      this.max = map['maxLength'];
      this.min = map['minLength'];
    }
    this.required = map['required'];
    this.defaultValue = map['value'];

  }
}
