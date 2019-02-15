import 'package:flutter/material.dart';
import 'package:zw_app/devices/CreateDevice.dart';
import 'package:zw_app/overview/OverviewPage.dart';
import 'package:zw_app/GIS/GisPage.dart';
import 'package:zw_app/devices/DeviceList.dart';
import 'package:zw_app/NavigationItemView.dart';
import 'package:zw_app/User/UserCenter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex;
  String _title;
  BottomNavigationBarType _type = BottomNavigationBarType.fixed;
  List<NavigationItemView> _navigationBarItems;
  List<List<Widget>> _currentActions;
  List<Widget> _currentLeading;

  @override
  void initState() {
    super.initState();
    _navigationBarItems = [
      new NavigationItemView(
          icon: new Icon(Icons.subject),
          title: '概况',
          child: new OverviewPage(),
          color: Colors.brown,
          vSync: this),
      new NavigationItemView(
          icon: new Icon(Icons.location_on),
          title: 'GIS',
          child: new GisPage(),
          color: Colors.redAccent,
          vSync: this),
      new NavigationItemView(
          icon: new Icon(Icons.view_list),
          title: '设备',
          child: new DeviceList(),
          color: Colors.teal,
          vSync: this),
    ];
    _currentActions = [
      <Widget>[],
      <Widget>[],
      <Widget>[
        new IconButton(
          icon: new Icon(Icons.add),
          tooltip: 'Append new Device',
          onPressed: _createDevice,
        ),
      ],
    ];
    _currentLeading = [
      new Container(),
      new Container(),
      new IconButton(
        icon: new Icon(Icons.person),
        tooltip: 'User Setting',
        onPressed: _userCenter,
      ),
    ];

    _currentIndex = 2;
    _title = _navigationBarItems[_currentIndex].title;
    for (NavigationItemView view in _navigationBarItems) {
      view.controller.addListener(_rebuild);
    }
    _navigationBarItems[_currentIndex].controller.value = 1.0;
  }

  @override
  void dispose() {
    for (NavigationItemView view in _navigationBarItems) {
      view.controller.dispose();
    }
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Widget _buildTransitionStack() {
    final List<FadeTransition> transitions = <FadeTransition>[];

    for (NavigationItemView view in _navigationBarItems) {
      transitions.add(view.transition(_type, context));
    }

    /// We want to have the newly animating (fading in) views on top.
    transitions.sort((FadeTransition a, FadeTransition b) {
      final Animation<double> aAnimation = a.opacity;
      final Animation<double> bAnimation = b.opacity;
      final double aValue = aAnimation.value;
      final double bValue = bAnimation.value;
      return aValue.compareTo(bValue);
    });

    return new Stack(
      children: transitions,
    );
  }

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
    setState(() {
      Navigator
          .of(context)
          .push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new UserCenter();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: new AppBar(
          leading: _currentLeading[_currentIndex],
          title: new Text(_title),
          centerTitle: true,
          actions: _currentActions[_currentIndex],
          elevation: 1.0,
        ),
        body: new Center(
          child: _buildTransitionStack(),
        ),
        bottomNavigationBar: new BottomNavigationBar(
          type: _type,
          currentIndex: _currentIndex,
          items: _navigationBarItems
              .map((bottomNavigationBarItem) => bottomNavigationBarItem.item)
              .toList(),
          onTap: (int index) {
            _navigationBarItems[_currentIndex].controller.reverse();
            _currentIndex = index;
//            setState(() {
              _title = _navigationBarItems[_currentIndex].title;
//            });
            _navigationBarItems[_currentIndex].controller.forward();
          },
        ));
  }
}
