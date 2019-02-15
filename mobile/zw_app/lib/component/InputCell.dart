import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zw_app/component/EnsureVisibleWhenFocused.dart';

class InputCell extends StatefulWidget {
  InputCell(
      {Key key,
      @required this.label,
      this.hintText,
      this.inputController,
      this.keyboardType: TextInputType.text,
      this.need: false,
      this.obscureText: false,
      this.delivied: true})
      : super(key: key);

  final String label;
  final String hintText;
  final bool need; //必填项
  final bool obscureText;
  final TextEditingController inputController;
  final TextInputType keyboardType;
  final bool delivied;

  @override
  InputCellState createState() {
    return new InputCellState();
  }
}

class InputCellState extends State<InputCell> {
  FocusNode _focusNode = new FocusNode();
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Text(
                widget.label,
                style: new TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16.0,
                ),
              ),
              new SizedBox(width: 10.0),
              new Expanded(
                child: new EnsureVisibleWhenFocused(
                  focusNode: _focusNode,
                  child: new TextField(
                    focusNode: _focusNode,
                    controller: widget.inputController,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    decoration: new InputDecoration(
                      hintText: widget.hintText == null ? '请输入' : widget.hintText,
                      border: InputBorder.none,
                    ),
                    style: new TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          new SizedBox(height: 4.0),
          widget.delivied
              ? new Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: new BoxDecoration(
                    border: new Border.all(
                      color: Colors.grey[400],
                      width: 0.3,
                    ),
                  ),
                )
              : new Container(),
        ],
      ),
    );
  }
}
