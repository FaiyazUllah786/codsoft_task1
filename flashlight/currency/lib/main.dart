import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import './database/currency.dart';
import './utils/conversion.dart';
import './widget/buttons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await Hive.openBox('Currency_Storage');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Conversion>(
      create: (context) => Conversion(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var box = Hive.box('Currency_Storage');
  bool _isUpdating = false;

  late Conversion _myProvider;

  @override
  void initState() {
    var _myProvider = Provider.of<Conversion>(context, listen: false);
    Future.delayed(
      Duration.zero,
      () {
        try {
          Currency.updateCurrencyRate(context).then((value) {
            setState(() {});
            print('Updated Successfully');
          });
          print('Currency Rate Updated in INIT STATE');
        } catch (e) {
          print('Could Not Update Currency Rate');
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _myProvider.amountController.dispose();
    _myProvider.amountController2.dispose();
    _myProvider.amountController.removeListener(_myProvider.conversionFromTo);
    _myProvider.amountController2.removeListener(_myProvider.conversionToFrom);
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = (MediaQuery.of(context).padding.top + kToolbarHeight);
    final deviceHeight = MediaQuery.of(context).size.height;
    final bodyHeight = deviceHeight - appBarHeight;
    final deviceWidth = MediaQuery.of(context).size.width;

    var conversion = Provider.of<Conversion>(context);
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.purple],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'Currency Converter',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 20),
                child: _isUpdating
                    ? CircularProgressIndicator()
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white, width: 1.5)),
                        onPressed: () {
                          setState(() {
                            _isUpdating = true;
                          });

                          Currency.updateCurrencyRate(context).then((value) {
                            setState(() {
                              _isUpdating = false;
                            });
                            print(box.keys.toList());
                          });
                        },
                        child: Text(
                          'Update Rate',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          body: box.isNotEmpty
              ? Center(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //coversion layout
                      Container(
                        height: bodyHeight * 0.30,
                        width: deviceWidth,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  key: ValueKey(1),
                                  onTap: () {
                                    conversion.showListCurrencies(
                                        context, ValueKey(1));
                                    print(ValueKey(1));
                                    setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 50,
                                    width: deviceWidth * 0.25,
                                    child: Card(
                                      color: Colors.pinkAccent,
                                      elevation: 4,
                                      child: Center(
                                        child: Text(
                                          conversion.sourceCurrency,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Flexible(
                                  child: Container(
                                    height: 50,
                                    width: deviceWidth * 0.75,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          width: 1.5, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: FocusScope(
                                      onFocusChange: (value) {
                                        if (value == true) {
                                          conversion.focusField = 1;
                                          conversion.amountController
                                              .addListener(
                                                  conversion.conversionFromTo);
                                          print('1st field');
                                        } else {
                                          conversion.amountController
                                              .removeListener(
                                                  conversion.conversionFromTo);
                                          print('listener 2 remove');
                                        }
                                      },
                                      child: TextField(
                                        enableInteractiveSelection: false,
                                        textAlign: TextAlign.end,
                                        decoration: InputDecoration(
                                          fillColor:
                                              Colors.purple.withOpacity(0.4),
                                          filled: true,
                                          border: InputBorder.none,
                                          counterText: '',
                                          contentPadding:
                                              EdgeInsets.only(left: 10),
                                        ),
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w300,
                                        ),
                                        maxLength: 20,
                                        controller: conversion.amountController,
                                        keyboardType: TextInputType.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                conversion.swapButton();
                              },
                              borderRadius: BorderRadius.circular(500),
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(500)),
                                  margin: EdgeInsets.only(
                                    left: deviceWidth * 0.08,
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  height: deviceHeight * 0.05,
                                  width: deviceWidth * 0.1,
                                  child: Center(
                                    child: Image.asset(
                                      'assets/icon/exchange.png',
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            ),
                            //destination TextConversion field
                            Row(
                              children: [
                                InkWell(
                                  key: ValueKey(2),
                                  onTap: () {
                                    conversion.showListCurrencies(
                                        context, ValueKey(2));
                                    print(ValueKey(2));
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 50,
                                    width: deviceWidth * 0.25,
                                    child: Card(
                                      elevation: 4,
                                      color: Colors.pinkAccent,
                                      child: Center(
                                          child: Text(
                                        conversion.destinationCurrency,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Flexible(
                                  child: Container(
                                    height: 50,
                                    width: deviceWidth * 0.75,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          width: 1.5, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: FocusScope(
                                      onFocusChange: (value) {
                                        if (value == true) {
                                          conversion.focusField = 2;
                                          conversion.amountController2
                                              .addListener(
                                                  conversion.conversionToFrom);
                                          print('2nd field');
                                        } else {
                                          conversion.amountController2
                                              .removeListener(
                                                  conversion.conversionToFrom);
                                          print('listener 1 removed');
                                        }
                                      },
                                      child: TextField(
                                        enableInteractiveSelection: false,
                                        maxLength: 20,
                                        textAlign: TextAlign.end,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              Colors.purple.withOpacity(0.4),
                                          border: InputBorder.none,
                                          counterText: '',
                                          contentPadding:
                                              EdgeInsets.only(left: 10),
                                        ),
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w300),
                                        controller:
                                            conversion.amountController2,
                                        keyboardType: TextInputType.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //Buttons layout
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
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.40,
                                      color: Colors.red,
                                      text: 'C',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.40,
                                      color: Colors.black54,
                                      text: 'DEL',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.25,
                                      color: Colors.white,
                                      text: '7',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.25,
                                      color: Colors.white,
                                      text: '8',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.25,
                                      color: Colors.white,
                                      text: '9',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.25,
                                      color: Colors.white,
                                      text: '4',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.25,
                                      color: Colors.white,
                                      text: '5',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.25,
                                      color: Colors.white,
                                      text: '6',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.25,
                                      color: Colors.white,
                                      text: '1',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.25,
                                      color: Colors.white,
                                      text: '2',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.25,
                                      color: Colors.white,
                                      text: '3',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.40,
                                      color: Colors.white,
                                      text: '0',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                    Button(
                                      height: bodyHeight * 0.7 * 0.14,
                                      width: deviceWidth * 0.40,
                                      color: Colors.white,
                                      text: '.',
                                      callBack: conversion.buttonOnClick,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                      'No Currency Rates are present\nPlease Tap On Update Rate'),
                )),
    );
  }
}
