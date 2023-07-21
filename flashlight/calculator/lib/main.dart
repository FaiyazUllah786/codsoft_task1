
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:google_fonts/google_fonts.dart';

import './widget/buttons.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
          textTheme: GoogleFonts.arimoTextTheme()),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String expression = '';
  String result = '';
  String history = '';
  void errorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Text(
          'Invalid Expression',
          style: TextStyle(fontSize: 20,color: Colors.black),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
    );
  }

  String calc() {
    try {
      Parser p = Parser();
      Expression e = p.parse(expression);
      ContextModel cm = ContextModel();
      var ans = e.evaluate(EvaluationType.REAL, cm);
      if (ans.toString() == 'Infinity' || ans.toString() == '-Infinity'||ans.toString()=='NaN') {
        errorMessage();
        ans = 0;
      }
      return ans.toString().length > 10
          ? ans.toStringAsPrecision(3)
          : ans.toString();
    } catch (e) {
      errorMessage();
      return expression;
    }
  }

  void _buttonOnClick(btnVal) {
    print(btnVal);
    switch (btnVal) {
      case 'AC/C':
        {
          setState(() {
            expression = '';
          });
        }
        break;
      case 'DEL':
        {
          if(expression.length>0){
            setState(() {
              expression = expression.substring(0, expression.length - 1);
            });
          }

        }
        break;
      case '=':
        {
          setState(() {
            result = calc();
            history = expression;
            expression = result;
          });
        }

        break;

      default:
        {
          setState(() {
            expression += btnVal;
          });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = (MediaQuery.of(context).padding.top + kToolbarHeight);
    final deviceHeight = MediaQuery.of(context).size.height;
    final bodyHeight = deviceHeight - appBarHeight;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
        backgroundColor: Colors.transparent,
        title: const Text('Calculator'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.3), Colors.white],
            begin: Alignment.bottomRight,
            end: Alignment.topRight,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              //2 Expanded widgets (screen and Buttons)
              Container(
                height: bodyHeight * 0.30,
                width: deviceWidth,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        history,
                        overflow: TextOverflow.fade,
                        maxLines: 3,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 25),
                      ),
                      Text(
                        expression,
                        textAlign: TextAlign.end,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 50),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: bodyHeight * 0.70,
                width: deviceWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //Button column
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onDoubleTap: () {
                                setState(() {
                                  expression = '';
                                  result = '';
                                  history = '';
                                });
                              },
                              child: Button(
                                height: bodyHeight * 0.7 * 0.14,
                                width: deviceWidth * 0.18,
                                color: Colors.red,
                                text: 'AC/C',
                                callBack: _buttonOnClick,
                              ),
                            ),
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.grey,
                              text: 'DEL',
                              callBack: _buttonOnClick,
                            ),
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.blue.withOpacity(0.4),
                              text: '/',
                              callBack: _buttonOnClick,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.white,
                              text: '7',
                              callBack: _buttonOnClick,
                            ),
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.white,
                              text: '8',
                              callBack: _buttonOnClick,
                            ),
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.white,
                              text: '9',
                              callBack: _buttonOnClick,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.white,
                              text: '4',
                              callBack: _buttonOnClick,
                            ),
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.white,
                              text: '5',
                              callBack: _buttonOnClick,
                            ),
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.white,
                              text: '6',
                              callBack: _buttonOnClick,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.white,
                              text: '1',
                              callBack: _buttonOnClick,
                            ),
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.white,
                              text: '2',
                              callBack: _buttonOnClick,
                            ),
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.white,
                              text: '3',
                              callBack: _buttonOnClick,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.42,
                              color: Colors.white,
                              text: '0',
                              callBack: _buttonOnClick,
                            ),
                            Button(
                              height: bodyHeight * 0.7 * 0.14,
                              width: deviceWidth * 0.18,
                              color: Colors.white,
                              text: '.',
                              callBack: _buttonOnClick,
                            ),
                          ],
                        ),
                      ],
                    ),

                    //operators button column
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Button(
                          height: bodyHeight * 0.7 * 0.14,
                          width: deviceWidth * 0.18,
                          color: Colors.blue.withOpacity(0.4),
                          text: '*',
                          callBack: _buttonOnClick,
                        ),
                        Button(
                          height: bodyHeight * 0.7 * 0.14,
                          width: deviceWidth * 0.18,
                          color: Colors.blue.withOpacity(0.4),
                          text: '-',
                          callBack: _buttonOnClick,
                        ),
                        Button(
                          height: bodyHeight * 0.7 * 0.26,
                          width: deviceWidth * 0.18,
                          color: Colors.blue.withOpacity(0.4),
                          text: '+',
                          callBack: _buttonOnClick,
                        ),
                        Button(
                          height: bodyHeight * 0.70 * 0.26,
                          width: deviceWidth * 0.18,
                          color: Colors.white,
                          btnColor: Colors.blue.withOpacity(0.7),
                          text: '=',
                          callBack: _buttonOnClick,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
