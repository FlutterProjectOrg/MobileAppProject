import 'package:flutter/material.dart';
import 'dart:async';

class InputOTP extends StatelessWidget {
  final int length;
  final Function(String) onChanged;
  final bool enabled;

  const InputOTP({
    Key? key,
    this.length = 6,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputOTPGroup(
      length: length,
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}

class InputOTPGroup extends StatefulWidget {
  final int length;
  final Function(String) onChanged;
  final bool enabled;

  const InputOTPGroup({
    Key? key,
    required this.length,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  _InputOTPGroupState createState() => _InputOTPGroupState();
}

class _InputOTPGroupState extends State<InputOTPGroup> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  String otpValue = "";

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    otpValue = _controllers.map((c) => c.text).join();
    widget.onChanged(otpValue);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> slots = [];
    for (int i = 0; i < widget.length; i++) {
      slots.add(
        InputOTPSlot(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          onChanged: (value) => _onChanged(i, value),
        ),
      );

      if (i < widget.length - 1) {
        slots.add(InputOTPSeparator());
      }
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: slots);
  }
}

class InputOTPSlot extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const InputOTPSlot({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  }) : super(key: key);

  @override
  _InputOTPSlotState createState() => _InputOTPSlotState();
}

class _InputOTPSlotState extends State<InputOTPSlot>
    with SingleTickerProviderStateMixin {
  bool isActive = false;
  late Timer _caretTimer;
  bool showCaret = true;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() {
        isActive = widget.focusNode.hasFocus;
      });
    });

    _caretTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (isActive) {
        setState(() {
          showCaret = !showCaret;
        });
      } else if (!showCaret) {
        setState(() {
          showCaret = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _caretTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(
          color: isActive ? Colors.blue : Colors.grey,
          width: isActive ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            maxLength: 1,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: "",
            ),
            onChanged: widget.onChanged,
            keyboardType: TextInputType.number,
          ),
          if (isActive && showCaret && widget.controller.text.isEmpty)
            Positioned(
              left: 22,
              top: 12,
              child: Container(width: 2, height: 20, color: Colors.black),
            ),
        ],
      ),
    );
  }
}

class InputOTPSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Icon(Icons.remove, size: 18, color: Colors.grey),
    );
  }
}
