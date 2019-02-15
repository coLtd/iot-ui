import 'package:flutter/material.dart';

class GradientAppBar extends StatefulWidget {
  const GradientAppBar({
    Key key,
    this.title,
    this.leading,
    this.actions,
  }) : super(key: key);

  final String title;
  final Widget leading;
  final List<Widget> actions;
  final double barHeight = 66.0;

  @override
  _GradientAppBarState createState() => new _GradientAppBarState();
}

class _GradientAppBarState extends State<GradientAppBar> {

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    Widget leading = widget.leading;
    if (leading == null) {
      leading = const BackButton(color: Colors.white,);
    }

    Widget actions;
    if (widget.actions != null && widget.actions.isNotEmpty) {
      actions = new Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.actions,
      );
    } else {
      actions = new IconButton(
        icon: new Icon(Icons.threesixty,
          color: Colors.transparent,),
        onPressed: null,
      );
    }

    return new Container(
      padding: new EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight + widget.barHeight,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          leading,
          new Text(widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 20.0)
          ),
          actions,
        ],
      ),
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
            colors: [const Color(0xFF30aaff), const Color(0xFF2bd0fe)],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.5, 0.0),
            stops: [0.0, 0.5],
            tileMode: TileMode.clamp),
      ),
    );
  }
}
