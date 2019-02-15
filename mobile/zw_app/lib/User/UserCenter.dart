import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zw_app/Constant.dart';
import 'package:zw_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:zw_app/User/Account.dart';

class UserCenter extends StatefulWidget {
  UserCenter({Key key}) : super(key: key);

  @override
  _UserCenterState createState() => new _UserCenterState();
}

class _UserCenterState extends State<UserCenter> {
  Future<Null> _logout() async {
    String token = await Account.token;
    print('token: $token');

    if (token == null) {
      Account.clearToken();
      Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new LoginPage()),
        ModalRoute.withName('/loginpage'),
      );
      return null;
    }

    var url = '$Server_Oauth_URL/logout?token=$token';

    http.Response response = await http.post(url, body: "", encoding: latin1);
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == HttpStatus.OK ||
        response.statusCode == HttpStatus.UNAUTHORIZED) {
      Account.clearToken();
      Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new LoginPage()),
        ModalRoute.withName('/loginpage'),
      );
    } else {
      showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('登出失败，请稍后重试'),
          );
        },
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('我的'),
        centerTitle: true,
      ),
      body: new Container(
        padding: const EdgeInsets.all(32.0),
        alignment: Alignment.bottomCenter,
        child: new FlatButton(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 6),
          color: const Color(0xFF30aaff),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.all(new Radius.circular(20.0))),
          onPressed: _logout,
          child: new Text(
            '登出',
            style: new TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
