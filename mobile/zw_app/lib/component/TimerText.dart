import 'dart:async';
import 'package:flutter/material.dart';

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({
    this.hundreds,
    this.seconds,
    this.minutes,
  });
}

class Dependencies {

  final List<ValueChanged<ElapsedTime>> timerListeners = <ValueChanged<ElapsedTime>>[];
  final TextStyle textStyle = const TextStyle(fontSize: 24.0, color: Colors.white, fontFamily: "Bebas Neue");
  final Stopwatch stopwatch = new Stopwatch();
  final int timerMillisecondsRefreshRate = 1000;
}

class TimerText extends StatefulWidget {
  TimerText({this.dependencies, this.stoped});
  final Dependencies dependencies;
  final VoidCallback stoped;

  TimerTextState createState() => new TimerTextState(dependencies: dependencies, stoped: stoped);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.dependencies, this.stoped});
  final Dependencies dependencies;
  final VoidCallback stoped;
  Timer timer;
  int milliseconds;

  @override
  void initState() {
    super.initState();
    timer = new Timer.periodic(new Duration(milliseconds: dependencies.timerMillisecondsRefreshRate), callback);
    print('============ initState');
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
    print('============ dispose');
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = dependencies.stopwatch.elapsedMilliseconds;
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final ElapsedTime elapsedTime = new ElapsedTime(
        hundreds: hundreds,
        seconds: seconds,
        minutes: minutes,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
      if (seconds > 59) {
        stoped();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new RepaintBoundary(
          child: new SizedBox(
            height: 24.0,
            child: new MinutesAndSeconds(dependencies: dependencies),
          ),
        ),
      ],
    );
  }
}


class MinutesAndSeconds extends StatefulWidget {
  MinutesAndSeconds({this.dependencies});
  final Dependencies dependencies;

  MinutesAndSecondsState createState() => new MinutesAndSecondsState(dependencies: dependencies);
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState({this.dependencies});
  final Dependencies dependencies;

  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (!this.mounted) return;
    if (elapsed.minutes != minutes || elapsed.seconds != seconds) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
//    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    int sec = seconds % 60;
    int aa = 60 - sec;
    String secondsStr = aa.toString().padLeft(2, '0');
    return new Text('$secondsStr', style: dependencies.textStyle);
  }
}

class Hundreds extends StatefulWidget {
  Hundreds({this.dependencies});
  final Dependencies dependencies;

  HundredsState createState() => new HundredsState(dependencies: dependencies);
}

class HundredsState extends State<Hundreds> {
  HundredsState({this.dependencies});
  final Dependencies dependencies;

  int hundreds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (!this.mounted) return;
    if (elapsed.hundreds != hundreds) {
      setState(() {
        hundreds = elapsed.hundreds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return new Text(hundredsStr, style: dependencies.textStyle);
  }
}
