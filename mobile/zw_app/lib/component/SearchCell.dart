import 'package:flutter/material.dart';

class SearchCell extends StatefulWidget {
  SearchCell(
      {Key key,
      this.inputController,
      this.onChanged,
      this.onButtonClicked,
      this.hintText})
      : super(key: key);

  final String hintText;
  final TextEditingController inputController;
  final VoidCallback onButtonClicked;
  final ValueChanged<String> onChanged;

  @override
  _SearchCellState createState() => new _SearchCellState();
}

class _SearchCellState extends State<SearchCell> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: new EdgeInsets.all(10.0),
      color: Theme.of(context).primaryColor,
      child: new Container(
        //padding: new EdgeInsets.only(left: 8.0),
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.all(new Radius.circular(40.0)),
        ),
        child: new Row(
          children: <Widget>[
            new IconButton(
              icon: new Icon(
                Icons.search,
                color: Colors.grey[400],
              ),
              onPressed: widget.onButtonClicked,
            ),
            new Expanded(
              child: new TextField(
                controller: widget.inputController,
                decoration: new InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                ),
                onChanged: (String value) {
                  widget.onChanged(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
