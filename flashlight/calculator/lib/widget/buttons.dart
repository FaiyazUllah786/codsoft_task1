import 'package:flutter/material.dart';

import 'glassdesign.dart';

class Button extends StatefulWidget {
  double? height;
  double? width;
  Color? color;
  Color? btnColor;
  String text;
  Function callBack;

  Button({
    super.key,
    this.height,
    this.width,
    this.color,
    this.btnColor,
    required this.text,
    required this.callBack,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GlassMorphism(
        start: 0.1,
        end: 0.7,
        child: InkWell(
          onTap: () {
            widget.callBack(widget.text);
          },
          splashColor: Colors.blue.withOpacity(0.6),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.btnColor,
            ),
            height: widget.height,
            width: widget.width,
            child: Center(
                child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            )),
          ),
        ),
      ),
    );
  }
}
