import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zw_app/component/SelectButton.dart';

class CustomButtonBar extends StatefulWidget {
  CustomButtonBar({Key key, this.items}) : super(key: key);

//  static final List<String> titles;
//  static final List<bool> values;
//  final ValueChanged<int> onChanged;

  @override
  _CustomButtonBarState createState() => new _CustomButtonBarState();

  final List<Item> items;
}

class _CustomButtonBarState extends State<CustomButtonBar> {
  Item _selectedValue;

//  final List<int> values;
//  final ValueChanged<int> onChanged;

  List<bool> selecteds;
  int currentSelected = -1;

  _CustomButtonBarState();

  @override
  void initState() {
    super.initState();
    _selectedValue = null;
  }

  void _onSelected(int value) {
    print('_onSelected: $value');
    setState(() {
//      onChanged(value);
      if (currentSelected == -1) {
        currentSelected = value;
        selecteds[currentSelected] = true;
      } else if (currentSelected == value) {
        selecteds[currentSelected] = false;
        currentSelected = -1;
      } else {
        print(selecteds[currentSelected]);
        selecteds[currentSelected] = false;
        print(selecteds[currentSelected]);
        currentSelected = value;
        selecteds[currentSelected] = true;
        print(selecteds[currentSelected]);
      }
    });
  }

  Widget build(BuildContext context) {
    return new Ink(
      color: Colors.grey[200],
      height: 48.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.items.map((Item item) {
          return new GestureDetector(
            onTap: () {
              // this class is a ancestor of IconSelectItem.
              // setState will rebuild children.
              setState(() {
                if (_selectedValue != null && _selectedValue == item)
                  _selectedValue = null;
                else
                  _selectedValue = item;
              });
            },
            child: new Text(
              item.title,
              style: item != null && item == _selectedValue
                  ? new TextStyle(color: Colors.red)
                  : new TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Item {
  String title;
  String value;
  bool selected;

  Item(this.title, this.value, [this.selected = false]);
}
