import 'package:flutter/material.dart';

class AddDevice extends StatefulWidget {
  AddDevice({Key key}) : super(key: key);

  @override
  _AddDeviceState createState() => new _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  int _index = 0;

  stepTapped(index) {
    print('stepTapped: $_index');
    setState(() {
      _index = index;
    });
  }
  stepContinue() {
    print('stepContinue: $_index');
    setState(() {
      ++_index;
      print('stepContinue2222: $_index');
    });

  }
  stepCancel() {

  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('设备定位'),
        leading: null,
        automaticallyImplyLeading: true,
      ),
      body: new Stepper(
        currentStep: _index,
        steps: [
          new Step(title: new Text('1'),
              content: new Text('first step')),
          new Step(title: new Text('2'),
              content: new Text('first step')),
          new Step(title: new Text('3'),
              content: new Text('first step')),
          new Step(title: new Text('4'),
              content: new Text('first step')),
        ],
        type: StepperType.horizontal,
        onStepTapped: stepTapped,
        onStepContinue: stepContinue,
        onStepCancel: stepCancel,
      ),
    );
  }
}