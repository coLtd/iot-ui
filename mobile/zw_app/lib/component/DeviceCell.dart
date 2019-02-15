import 'package:flutter/material.dart';
import 'package:zw_app/devices/Device.dart';

class DeviceCell extends StatelessWidget {
  DeviceCell({Key key, this.device, this.isLocal: false, this.onItemClicked})
      : super(key: new ObjectKey(device));

  final Device device;
  final bool isLocal;
  final ValueChanged<String> onItemClicked;

//  @override
//  DeviceCellState createState() =>  new DeviceCellState(device);
//}
//
//class DeviceCellState extends State<DeviceCell> {
//  final Device device;
//
//  DeviceCellState(this.device);

  ///格式化设备时间字段
  _createdOnFmt() {
    var now = new DateTime.now();
    var datetime = new DateTime.fromMillisecondsSinceEpoch(device.updatedOn);
    String dt = datetime.toString();
    if (now.year == datetime.year &&
        now.month == datetime.month &&
        now.day == datetime.day)
      return dt.substring(11, 16);
    else
      return dt.substring(0, 16);
  }

  void _handleTap() {
    onItemClicked(device.oid);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    if (isLocal)
      children.add(new Image.asset(
        'images/jinggao.png',
        height: 16.0,
      ));
    children.add(new Text(
      _createdOnFmt(),
    ));

    return new ListTile(
      onTap: _handleTap,
      leading: null,
      title: new Text(device.name),
      subtitle: new Text(device.code),
      trailing: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: children,
      ),
    );
  }
}
