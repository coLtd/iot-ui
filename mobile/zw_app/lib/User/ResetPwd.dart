import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zw_app/Constant.dart';
import 'package:zw_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:zw_app/User/Account.dart';
import 'package:zw_app/component/InputCell.dart';
import 'package:zw_app/component/TimerText.dart';

class ResetPwd extends StatefulWidget {
  ResetPwd({Key key, this.username}) : super(key: key);
  final String username;

  @override
  _ResetPwdState createState() => new _ResetPwdState();
}

class _ResetPwdState extends State<ResetPwd> {
  final Dependencies dependencies = new Dependencies();

  TextEditingController _nameController;
  TextEditingController _verifyCodeController;
  TextEditingController _passController;

  @override
  initState() {
    super.initState();

    _nameController = new TextEditingController(text: widget.username);
    _verifyCodeController = new TextEditingController();
    _passController = new TextEditingController();
  }

  @override
  void dispose() {
    _passController.dispose();
    _verifyCodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<Null> _stoped() async {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
        dependencies.stopwatch.reset();
      }
    });
  }

  Future<Null> _requestVerifyCode() async {
    if (dependencies.stopwatch.isRunning) {
      return;
    }

    var body = {"mobile": widget.username};
    var url = '$Server_ISS_USER_URL/tenant/staff/me/code';

    http.Response response = await http.post(url, body: json.encode(body), encoding: latin1);
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == HttpStatus.OK ||
        response.statusCode == HttpStatus.UNAUTHORIZED) {
      setState(() {
        if (dependencies.stopwatch.isRunning) {
          dependencies.stopwatch.stop();
        } else {
          dependencies.stopwatch.start();
        }
      });
    } else {
      showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('请求验证码失败，请稍后再试'),
          );
        },
      );
      return;
    }
  }

  Future<Null> _resetPwd() async {
    String code = _verifyCodeController.text.replaceAll(' ', '');
    if (code.isEmpty) {
      _showMessage('验证码不能为空');
      return;
    }

    String pass = _passController.text.replaceAll(' ', '');
    if (pass.isEmpty) {
      _showMessage('密码不能为空');
      return;
    }

    var body = {"mobile": widget.username, "code": code, "password": pass};
    var url = '$Server_ISS_USER_URL/tenant/staff/me/pwd/reset';

    http.Response response = await http.put(url, body: json.encode(body), encoding: latin1);
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == HttpStatus.OK ||
        response.statusCode == HttpStatus.UNAUTHORIZED) {
      Account.clearToken();
      _showMessage('重置密码成功');
      Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new LoginPage()),
        ModalRoute.withName('/loginpage'),
      );
      return;

    } else {
      showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('重置密码失败。'),
          );
        },
      );
      return;
    }
  }

  void _showMessage(String msg) {
    showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(content: new Text(msg), actions: <Widget>[]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('重置密码'),
        centerTitle: true,
      ),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            new InputCell(
                label: '帐户', inputController: _nameController, need: true),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new InputCell(
                      label: '验证码',
                      inputController: _verifyCodeController,
                      need: true),
                ),
                new FlatButton(
                  color: const Color(0xFF30aaff),
                  shape: new RoundedRectangleBorder(
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(20.0))),
                  onPressed: _requestVerifyCode,
                  child: dependencies.stopwatch.isRunning
                  ? new TimerText(dependencies: dependencies, stoped: _stoped)
                  : new Text(
                    '获取验证码',
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
            new InputCell(
                label: '新密码', inputController: _passController, need: true),
            new RaisedButton(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 6),
              color: const Color(0xFF30aaff),
              shape: new RoundedRectangleBorder(
                  borderRadius:
                      new BorderRadius.all(new Radius.circular(20.0))),
              onPressed: _resetPwd,
              child: new Text(
                '重置密码',
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
