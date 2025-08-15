import 'package:dart_eval/dart_eval.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String calculatorField = "0";
  String last = "0";
  bool erase = true;

  String _lastKey = '';

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final logicalKey = event.logicalKey;
      setState(() => _lastKey = logicalKey.keyLabel);

      // Handle numpad numbers
      if (logicalKey.keyId >= LogicalKeyboardKey.numpad0.keyId &&
          logicalKey.keyId <= LogicalKeyboardKey.numpad9.keyId) {
        push_character(logicalKey.keyLabel.replaceAll('Numpad ', ''));
      }
      // Handle operators and Enter
      else {
        switch (logicalKey) {
          case LogicalKeyboardKey.slash:
            push_character("/");
            break;
          case LogicalKeyboardKey.asterisk:
          case LogicalKeyboardKey.numpadMultiply:
            push_character("*");
            break;
          case LogicalKeyboardKey.minus:
          case LogicalKeyboardKey.numpadSubtract:
            push_character("-");
            break;
          case LogicalKeyboardKey.equal:
            if (event.character == "+") push_character("+");
          case LogicalKeyboardKey.numpadAdd:
            push_character("+");
            break;
          case LogicalKeyboardKey.backspace:
            erase_one();
            break;
          case LogicalKeyboardKey.enter:
          case LogicalKeyboardKey.numpadEnter:
            evaluateExpression();
            break;
          case LogicalKeyboardKey.digit9:
            if (event.character == "(")
              push_character("(");
            else
              push_character("9");
            break;

          case LogicalKeyboardKey.digit1:
            push_character("1");
            break;
          case LogicalKeyboardKey.digit2:
            push_character("2");
            break;
          case LogicalKeyboardKey.digit3:
            if (event.character == "/") {
              push_character("/");
            } else
              push_character("3");

            break;
          case LogicalKeyboardKey.digit4:
            push_character("4");
            break;
          case LogicalKeyboardKey.digit5:
            if (event.character == "%")
              push_character("%");
            else
              push_character("5");
            break;
          case LogicalKeyboardKey.digit6:
            push_character("6");
            break;
          case LogicalKeyboardKey.digit7:
            if (event.character == "&")
              push_character("&");
            else
              push_character("7");
            break;

          case LogicalKeyboardKey.digit8:
            if (event.character == "*")
              push_character("*");
            else
              push_character("8");
            break;
          case LogicalKeyboardKey.digit0:
            print(event.character);
            if (event.character == ")")
              push_character(")");
            else
              push_character("0");
            break;
          default:
            if (event.character == "|") {
              push_character("|");
            }
            break;
        }
      }
    }
    return false;
  }

  void clear() {
    setState(() {
      calculatorField = "0";
    });
  }

  void erase_one() {
    setState(() {
      if (calculatorField.length == 1) {
        erase = true;
        calculatorField = "0";
        return;
      }
      if (calculatorField.length > 0) {
        String lastChar =
            calculatorField[calculatorField.length - 1] +
            calculatorField[calculatorField.length - 2];

        if (lastChar == ">>" || lastChar == "<<" || lastChar == "~/")
          calculatorField = calculatorField.substring(
            0,
            calculatorField.length - 1,
          );

        calculatorField = calculatorField.substring(
          0,
          calculatorField.length - 1,
        );
      }
    });
  }

  void push_character(String character) {
    setState(() {
      if (erase || (calculatorField == "0" && isNumeric(character))) {
        if (isNumeric(character))
          calculatorField = "";
        else if (character != ">>" &&
            character != "<<" &&
            character != "~/" &&
            character != "|" &&
            character != "&" &&
            character != "^") {
          calculatorField = last;
        }
        erase = false;
      }
      if (calculatorField.length < 25) calculatorField += character;
    });
  }

  bool isNumeric(String s) {
    if (s.isEmpty) {
      return false;
    }
    try {
      double.parse(s);
      return true;
    } catch (e) {
      return false;
    }
    ;
  }

  void evaluateExpression() {
    setState(() {
      try {
        calculatorField = eval(calculatorField).toString();
        last = calculatorField;
      } catch (e) {
        calculatorField = "ERROR";
      }
      erase = true;
    });
  }

  Widget numpadkey(
    String key,
    void Function()? onPressed, {
    background_color = Colors.black26,
    foreground_color = Colors.white,
    shadow_color = Colors.blueGrey,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Center(
          child: Text(key, style: TextStyle(fontSize: 20.0), maxLines: 1),
        ),

        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: background_color,
          foregroundColor: foreground_color,
          shadowColor: shadow_color,
          enableFeedback: false,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
          minimumSize: const Size(double.infinity, double.infinity),
          animationDuration: Duration(milliseconds: 5),
        ),
      ),
    );
  }

  Widget numpad(double space) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  numpadkey(
                    "|",
                    () => push_character("|"),
                    background_color: Colors.blueGrey,
                  ),
                  SizedBox(width: space),
                  numpadkey(
                    "&",
                    () => push_character("&"),
                    background_color: Colors.blueGrey,
                  ),
                  SizedBox(width: space),
                  numpadkey(
                    "^",
                    () => push_character("^"),
                    background_color: Colors.blueGrey,
                  ),
                  SizedBox(width: space),
                  numpadkey(
                    "<<",
                    () => push_character("<<"),
                    background_color: Colors.blueGrey,
                  ),
                  SizedBox(width: space),
                  numpadkey(
                    ">>",
                    () => push_character(">>"),
                    background_color: Colors.blueGrey,
                  ),

                  SizedBox(width: space),
                  numpadkey(
                    "←",
                    () => erase_one(),
                    background_color: Colors.blueGrey,
                  ),
                ],
              ),
            ),
            SizedBox(height: space),
            Expanded(
              child: Row(
                children: [
                  numpadkey("%", () {
                    push_character("%");
                  }),
                  SizedBox(width: space),
                  numpadkey("~/", () {
                    push_character("~/");
                  }),

                  SizedBox(width: space),
                  numpadkey("(", () {
                    push_character("(");
                  }),
                  SizedBox(width: space),
                  numpadkey(")", () {
                    push_character(")");
                  }),
                  SizedBox(width: space),
                  numpadkey("+", () {
                    push_character("+");
                  }),
                ],
              ),
            ),
            SizedBox(height: space),
            Expanded(
              child: Row(
                children: [
                  numpadkey("1", () {
                    push_character("1");
                  }),
                  SizedBox(width: space),
                  numpadkey("2", () {
                    push_character("2");
                  }),
                  SizedBox(width: space),
                  numpadkey("3", () => push_character("3")),
                  SizedBox(width: space),
                  numpadkey("-", () => push_character("-")),
                ],
              ),
            ),
            SizedBox(height: space),
            Expanded(
              child: Row(
                children: [
                  numpadkey("4", () => push_character("4")),
                  SizedBox(width: space),
                  numpadkey("5", () => push_character("5")),
                  SizedBox(width: space),
                  numpadkey("6", () => push_character("6")),
                  SizedBox(width: space),
                  numpadkey("*", () => push_character("*")),
                ],
              ),
            ),

            SizedBox(height: space),
            Expanded(
              child: Row(
                children: [
                  numpadkey("7", () => push_character("7")),
                  SizedBox(width: space),
                  numpadkey("8", () => push_character("8")),
                  SizedBox(width: space),
                  numpadkey("9", () => push_character("9")),

                  SizedBox(width: space),
                  numpadkey("/", () => push_character("/")),
                ],
              ),
            ),
            SizedBox(height: space),
            Expanded(
              child: Row(
                children: [
                  numpadkey(".", () => push_character(".")),
                  SizedBox(width: space),
                  numpadkey("0", () => push_character("0")),
                  SizedBox(width: space),

                  numpadkey("C", () => clear()),

                  SizedBox(width: space),
                  numpadkey(
                    "=",
                    evaluateExpression,
                    background_color: Colors.cyan[300],
                    foreground_color: Colors.black,
                  ),
                ],
              ),
            ),

            SizedBox(height: space),
          ],
        ),
      ),
    );
  }

  Widget textZone() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            top: 1.0,
            bottom: 0.0,
          ),
          child: Text(
            calculatorField,
            style: TextStyle(fontSize: 50.0, color: Colors.white),
            maxLines: 1,
          ),
        ),
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void onPressed() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(child: Column(children: [textZone(), numpad(10)])),
    );
  }
}
