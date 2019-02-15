import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zw_app/Constant.dart';
import 'package:zw_app/home.dart';
import 'package:http/http.dart' as http;
import 'package:zw_app/User/Account.dart';
import 'package:zw_app/component/InputCell.dart';
import 'package:zw_app/User/ResetPwd.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new LoginPage(),
      routes: <String, WidgetBuilder>{
        '/homepage': (BuildContext context) {
          return new HomePage();
        },
        '/loginpage': (BuildContext context) {
          return new LoginPage();
        },
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _user;
  String _pass;
  bool _enabled = false;

  final TextEditingController _userController = new TextEditingController();
  final TextEditingController _passController = new TextEditingController();

  Future<HttpClientResponse> _response;

  @override
  void initState() {
    super.initState();

    _userController.addListener(_checkInputValue);
    _passController.addListener(_checkInputValue);
    initData();
  }

  Future<Null> initData() async {
    _user = await Account.userName;
    _pass = await Account.userPass;
    String token = await Account.token;
    if (token != null && token.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new HomePage()),
        ModalRoute.withName('/homepage'),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _userController.text = _user;
      _passController.text = _pass;
    });
  }

  @override
  void dispose() {
    _passController.removeListener(_checkInputValue);
    _userController.removeListener(_checkInputValue);

    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  _checkInputValue() {
    if (_userController.text.length >= 2 &&
        _userController.text.length <= 32 &&
        _passController.text.length >= 6 &&
        _passController.text.length <= 16) {
      setState(() {
        _enabled = true;
      });
    } else {
      setState(() {
        _enabled = false;
      });
    }
  }

  void _login() async {
    //保存到本地
    if (_user != _userController.text || _pass != _passController.text) {
      _user = _userController.text;
      _pass = _passController.text;
      await Account.setNamePass(_user, _pass);
    }
    var url = '$Server_Oauth_URL/token';
    var body =
        "grant_type=password&client_id=2&client_secret=1&username=$_user&password=$_pass";
    http.post(url, body: "$body").then((response) {

      if (response.statusCode == HttpStatus.OK) {
        Account.saveToken(response.body);
        Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => new HomePage()),
          ModalRoute.withName('/homepage'),
        );
      } else {
        String responseString = response.body;
        var responseData = json.decode(responseString);
        showDialog(
          context: context,
          child: new AlertDialog(
            title: new Text('登录失败'),
            content: new Text('用户名或密码错误'),
          ),
        );
      }
    });
  }

  void _fogretPass() async {
    if (_user != _userController.text) {
      _user = _userController.text;
      await Account.setNamePass(_user, '');
    }
    setState(() {
      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (_) => new ResetPwd(username: _user),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    double totalHeight = MediaQuery.of(context).size.height;
    double floatHeight = totalHeight * 0.5;

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          new Column(
//                    shrinkWrap: true,
            children: <Widget>[
              new Container(
                height: (totalHeight - floatHeight) / 2,
                color: Theme.of(context).primaryColor,
                child:

                    ///标题
                    new Center(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Image.asset(
                        'images/logo-xin.png',
                        height: 32.0,
                      ),
                      new SizedBox(width: 8.0),
                      new Text(
                        '智维 3.0',
                        style: new TextStyle(
                          fontSize: 32.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              new Container(
                height: floatHeight / 2,
                color: Theme.of(context).primaryColor,
              ),
              new Container(
                height: floatHeight / 2,
              ),
              new Container(
                height: (totalHeight - floatHeight) / 2,
                child: new Center(
                  child: new Container(
                    padding: EdgeInsets.all(4.0),
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: new BoxDecoration(
                      shape: BoxShape.rectangle,
                      color:
                          _enabled ? const Color(0xFF30aaff) : Colors.grey[400],
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(20.0)),
                    ),
                    child: new FlatButton(
                      onPressed: _enabled ? _login : null,
                      child: new Text('登录',
                          style: new TextStyle(
                              fontSize: 20.0, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          new Container(
            padding: EdgeInsets.all(16.0),
            width: MediaQuery.of(context).size.width * 0.9,
            height: floatHeight,
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10.0,
                  offset: new Offset(0.0, 10.0),
                ),
              ],
              borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
            ),
            child: new ListView(
              children: <Widget>[
                ///服务器
                new InputCell(
                  label: '服务器',
                  inputController: null,
                  hintText: '',
                ),

                ///用户名
                new InputCell(
                  label: '账号',
                  inputController: _userController,
                  hintText: '请输入用户名',
                ),

                ///密码
                new InputCell(
                  label: '密码',
                  inputController: _passController,
                  hintText: '6-12位密码',
                  obscureText: true,
                ),

                ///忘记密码
                new Align(
                  alignment: Alignment.centerRight,
                  child: new FlatButton(
                    onPressed: _fogretPass,
                    child: new Text(
                      '忘记密码',
                      style: new TextStyle(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
