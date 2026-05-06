import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Learning Terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MagicCounterPage(),
    );
  }
}

class MagicCounterPage extends StatefulWidget {
  const MagicCounterPage({super.key});

  @override
  State<MagicCounterPage> createState() => _MagicCounterPageState();
}

class _MagicCounterPageState extends State<MagicCounterPage> {
  int _counter = 0;
  bool _isDarkMode = true;
  final TextEditingController _controller = TextEditingController();
  String _message = 'Спробуй вгадати закляття...';

  final Set<String> _learnedSpells = {};

  void _processInput() {
    setState(() {
      String input = _controller.text.trim().toLowerCase();

      if (input == 'avada kedavra') {
        _counter = 0;
        _message = 'Тобі підкорилася Темна Магія! Reset.';
        _learnedSpells.add('avada kedavra');
      } else if (input == 'lumos') {
        _isDarkMode = false;
        _message = 'Ти вивчив Lumos! Світло активовано.';
        _learnedSpells.add('lumos');
      } else if (input == 'nox') {
        _isDarkMode = true;
        _message = 'Nox підкорився тобі! Темрява.';
        _learnedSpells.add('nox');
      } else if (input.startsWith('expelliarmus')) {
        String valuePart = input.replaceFirst('expelliarmus', '').trim();
        int? value = int.tryParse(valuePart);
        if (value != null) {
          _counter -= value;
          _message = 'Expelliarmus! Віднято $value';
          _learnedSpells.add('expelliarmus [n]');
        } else {
          _message = 'Майже! Але Експеліармус потребує числа.';
        }
      } else {
        int? value = int.tryParse(input);
        if (value != null) {
          _counter += value;
          _message = 'Магічна енергія зросла на $value';
        } else {
          _message = 'Такого закляття не існує в твоїй книзі... 🤔';
        }
      }
      _controller.clear();
    });
  }

  String _displaySpell(String spell, String placeholder) {
    return _learnedSpells.contains(spell) ? spell : placeholder;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isDarkMode ? Colors.black87 : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final cardColor = _isDarkMode ? Colors.grey[900] : Colors.blueGrey[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Academy of Magic IoT',
          style: TextStyle(fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📖 КНИГА ЗАКЛЯТЬ:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _displaySpell('lumos', '*****'),
                    style: _spellStyle(textColor),
                  ),
                  Text(
                    _displaySpell('nox', '***'),
                    style: _spellStyle(textColor),
                  ),
                  Text(
                    _displaySpell('avada kedavra', '***** *******'),
                    style: _spellStyle(textColor),
                  ),
                  Text(
                    _displaySpell('expelliarmus [n]', '************ [n]'),
                    style: _spellStyle(textColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Вивчено: ${_learnedSpells.length}/4',
                    style: const TextStyle(fontSize: 12, color: Colors.amber),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Energy Level:',
                  style: TextStyle(color: textColor, fontSize: 22),
                ),
                Text(
                  '$_counter',
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.amberAccent : Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _controller,
                  style: TextStyle(color: textColor, fontSize: 20),
                  decoration: InputDecoration(
                    labelText: 'Введи закляття, щоб вивчити його...',
                    labelStyle: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.amber.withOpacity(0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.amber,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onSubmitted: (_) => _processInput(),
                ),
                const SizedBox(height: 30),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _spellStyle(Color color) {
    return TextStyle(
      fontFamily: 'Courier',
      fontSize: 16,
      color: color,
      height: 1.6,
    );
  }
}
