import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:zw_app/Constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Account {
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<String> getStaffOid() async {
    var obj = await Account.parse();
    return obj['sub'];
  }

  static Future<Map<String, dynamic>> getFarmlandFilter() async {
    var obj = await Account.parse();

    String myOid = obj['sub'];
    Map<String, Object> filter = {"staff":{"\$oid":myOid}};

    ///TODO 多个组织的情况下，稍后可能会根据用户选择组织身份进行后续展示；
    var roles = obj['roles'];
    Iterable<String> keys = roles.keys;
    for (String key in keys) {
      //only one
      filter["tenant"] = {"\$oid": key};
      var roleArr = roles['$key'];
      var l = [];
      for (String v in roleArr){
        var t = {"\$oid":v};
        l.add(t);
      }
      filter["roles"] = l;
      break;
    }

    return filter;
  }

  static Future<Map<String, dynamic>> parse() async {
    Map<String, dynamic> obj = await _prefs.then((SharedPreferences prefs) {
      String token = prefs.getString('token') ?? '';
//      print('token: $token');
      if (token.isEmpty) return null;

      List<String> arr = token.split('.');
      if (arr == null || arr.length != 3) return null;
      String tmpStr = new String.fromCharCodes(base64.decode(arr[1]));
      if (tmpStr == null) return null;
      Map<String, dynamic> obj = json.decode(tmpStr);

      if (obj == null) return null;
      return obj;
    });

    return obj;
  }

  static Future<String> get token async {
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString('token');
    return token;
  }

  static void clearToken() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt("expires_in", 0);
    prefs.setString("token", '');
    print('clear token');
  }

  static void saveToken(String responseBody) async {
    Map obj = json.decode(responseBody);
    int expiresIn = obj['expires_in'];
    String jwtString = obj['access_token'];
    final SharedPreferences prefs = await _prefs;
    prefs.setInt("expires_in", expiresIn);
    prefs.setString("token", jwtString);
    print('save token');
  }

  static Future<Null> setNamePass(String name, String pass) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("username", name);
    prefs.setString("password", pass);
  }

  static Future<String> get userName async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('username');
  }

  static Future<String> get userPass async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('password');
  }

  static Future<List<Map<Object,Object>>> getOwnerFarmland() async {
    var url = '$Server_IOT_URL/tenant.staff_roles';
    var filterMap = await Account.getFarmlandFilter();
    String encodeFilter = Uri.encodeQueryComponent(json.encode(filterMap));
    url = url + '?filter=$encodeFilter';

    List<Map<Object,Object>> farmlands = await http.get(url).then((response) {
//      print("getOwnerFarmland Response status: ${response.statusCode}");
//      print("getOwnerFarmland Response body: ${response.body}");

      List<Map<Object,Object>> farmlands = new List<Map<Object,Object>>();
      if (response.statusCode == HttpStatus.OK) {
        String jsonString = response.body;
        var data = json.decode(jsonString);
        var items = data['items'];
        for (var item in items) {
          var farmland = item['farmlands'];
          for(var i in farmland) {
            farmlands.add(i);
          }
        }
        return farmlands;
      } else {
        //TODO fail
        return null;
      }
    });
    return farmlands;
  }

}
