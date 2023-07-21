import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:torch_light/torch_light.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.black));
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: FlashLight(),
    );
  }
}

class FlashLight extends StatefulWidget {
  const FlashLight({super.key});

  @override
  State<FlashLight> createState() => _FlashLightState();
}

class _FlashLightState extends State<FlashLight> with WidgetsBindingObserver {
  bool _isTurnOn = false;

  //Handling AppLifeCycles
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _isTurnOn == true) {
      setState(() {
        _isTurnOn = false;
        TorchLight.disableTorch();
        Fluttertoast.showToast(
            msg: 'FlashLight is turned off',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.SNACKBAR,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    }
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _isTurnOn = false;
        _height = 0.0;
        _size = 0;
        _color = Colors.white;
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    print("InitState");
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print("Dispose");
    super.dispose();
  }

  void _showToast(String title) async {
    await Fluttertoast.showToast(
        msg: title,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.black54,
        duration: Duration(milliseconds: 300),
      ),
    );
  }

//Check for the availability of a camera flash on the device
  Future<bool> _isTorchAvailable(BuildContext context) async {
    try {
      return await TorchLight.isTorchAvailable();
    } on Exception catch (_) {
      _showMessage(
        'FlashLight not found!',
        context,
      );
      rethrow;
    }
  }

  var _height = 0.0;
  double _size = 0;
  Color _color = Colors.white;

  void changeFlashSize() {
    setState(() {
      if (_isTurnOn == true) {
        _size = 250;
        _color = Colors.yellow;
      }
    });
  }

// /UI Design:
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
      ),
      Container(
        alignment: Alignment.bottomCenter,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(children: [
          AnimatedContainer(
            alignment: Alignment.bottomCenter,
            duration: Duration(milliseconds: 800),
            height: _height,
            width: MediaQuery.of(context).size.width,
            curve: Curves.easeOut,
            onEnd: changeFlashSize,
            color: Color.fromRGBO(241, 60, 60, 1),
          ),
        ]),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark),
          backgroundColor: Colors.transparent,
          title: Text('FlashLight App'),
        ),
        body: FutureBuilder(
          future: _isTorchAvailable(context),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!) {
              return SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AnimatedSize(
                          duration: Duration(milliseconds: 1000),
                          curve: Curves.easeInOutCubicEmphasized,
                          child: SizedBox(
                            height: _size,
                            child: Image.asset('assets/icon/flashlogo.png'),
                          )),
                      InkWell(
                        onTap: () async {
                          //Error Handling:
                          if (!_isTurnOn) {
                            try {
                              await TorchLight.enableTorch();
                              setState(() {
                                _isTurnOn = true;
                                _height = MediaQuery.of(context).size.height;
                                _color = Colors.yellow;
                                _showToast('FlashLight is ON');
                              });
                            } on Exception catch (_) {
                              _showMessage('Could not enable torch', context);
                            }
                          } else {
                            try {
                              await TorchLight.disableTorch();
                              setState(() {
                                _isTurnOn = false;
                                _height = 0.0;
                                _size = 0;
                                _color = Colors.white;
                                _showToast('FlashLight is OFF');
                              });
                            } on Exception catch (_) {
                              _showMessage('Could not disable torch', context);
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Card(
                          elevation: 10,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            decoration: BoxDecoration(
                                color: _color,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.flashlight_on_rounded,
                                  size: 100,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Tap on Torch',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              return const Center(
                child: Text('No torch available.'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    ]);
  }
}
