import 'package:flutter/material.dart';

import 'package:hive/hive.dart';

import '../widget/glassdesign.dart';
import '../database/currency.dart';

class Conversion extends ChangeNotifier {
  int focusField = 0;
  TextEditingController amountController = TextEditingController();
  TextEditingController amountController2 = TextEditingController();
  String sourceCurrency = 'INR';

  String destinationCurrency = 'USD';

  double enteredAmount = 0;
  double enteredAmount2 = 0;

  void buttonOnClick(btnVal) {
    print('$btnVal in conversion provider');

    switch (btnVal) {
      case 'C':
        {
          amountController.clear();
          amountController2.clear();
        }
        break;
      case 'DEL':
        {
          if (focusField == 1 && amountController.text.length > 1) {
            amountController.text = amountController.text
                .substring(0, amountController.text.length - 1);
          } else if (focusField == 2 && amountController2.text.length > 1) {
            amountController2.text = amountController2.text
                .substring(0, amountController2.text.length - 1);
          } else {
            amountController.clear();
            amountController2.clear();
          }
        }
        break;
      default:
        {
          if (focusField == 1) {
            amountController.text += btnVal;
            print('${amountController.text} in conversion provider');
          } else if (focusField == 2) {
            amountController2.text += btnVal;
          } else {}
        }
    }
    notifyListeners();
  }

  void conversionFromTo() {
    print('excuting in conversion file FROM');
    try {
      enteredAmount = double.parse(amountController.text);
      print(enteredAmount);
      String result = Currency.convertAmount(
          sourceCurrency: sourceCurrency,
          destinationCurrency: destinationCurrency,
          enteredAmount: enteredAmount);
      amountController2.text = result;
      print("$enteredAmount $sourceCurrency in $destinationCurrency: $result");
      print('first:$enteredAmount');
    } catch (e) {
      print('Some Parsing Errors');
    }
    notifyListeners();
  }

  void conversionToFrom() {
    print('excuting in conversion file TO');
    try {
      enteredAmount2 = double.parse(amountController2.text);
      String result = Currency.convertAmount(
          sourceCurrency: destinationCurrency,
          destinationCurrency: sourceCurrency,
          enteredAmount: enteredAmount2);
      amountController.text = result;
      print("$enteredAmount2 $destinationCurrency in $sourceCurrency: $result");
      print('second:$enteredAmount2');
    } catch (e) {
      print('Some Parsing Errors');
    }
    notifyListeners();
  }

  void showListCurrencies(BuildContext context, Key key) {
    print('Calling From conversion file');
    var box = Hive.box('Currency_Storage');
    if (box.length == Currency.currencyMap.length &&
        box.length == Currency.currencyIcons.length) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.purple],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
            child: ListView.builder(
              itemCount: box.length,
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    if (key == ValueKey(1)) {
                      sourceCurrency = box.keys.toList()[index];
                      print(sourceCurrency);
                      notifyListeners();
                    } else {
                      destinationCurrency = box.keys.toList()[index];
                      print(destinationCurrency);
                      notifyListeners();
                    }
                    Navigator.of(ctx).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: GlassMorphism(
                      start: 0.2,
                      end: 0.1,
                      child: ListTile(
                        leading: Text(
                          Currency.currencyIcons[box.keys.toList()[index]]!,
                          style: TextStyle(fontSize: 20),
                        ),
                        title: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            Currency.currencyMap[box.keys.toList()[index]]!,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        subtitle: Text(
                          '1 USD = ${box.values.toList()[index]} ${box.keys.toList()[index]}',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        // trailing:
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something Went Wrong')));
    }
    notifyListeners();
  }

  void swapButton() {
    String temp = sourceCurrency;
    sourceCurrency = destinationCurrency;
    destinationCurrency = temp;
    String temp2 = amountController.text;
    amountController.text = amountController2.text;
    amountController2.text = temp2;
    notifyListeners();
  }
}
