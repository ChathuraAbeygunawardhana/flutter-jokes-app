import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Jokes App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  List<String> jokes = [];
  bool isLoading = false;

  MyAppState() {
    loadJokes();
  }

  Future<void> loadJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cachedJokes = prefs.getStringList('jokes');
    if (cachedJokes != null && cachedJokes.isNotEmpty) {
      jokes = cachedJokes;
    } else {
      await fetchJokes();
    }
    notifyListeners();
  }

  Future<void> fetchJokes() async {
    isLoading = true;
    notifyListeners();
    List<String> fetchedJokes = [];
    for (int i = 0; i < 5; i++) {
      final response = await http.get(Uri.parse('https://v2.jokeapi.dev/joke/Any'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['type'] == 'single') {
          fetchedJokes.add(data['joke']);
        } else {
          fetchedJokes.add('${data['setup']} - ${data['delivery']}');
        }
      } else {
        fetchedJokes.add('Failed to fetch joke');
      }
    }
    jokes = fetchedJokes;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('jokes', jokes);
    isLoading = false;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Jokes App'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await appState.fetchJokes();
            },
          ),
        ],
      ),
      body: Center(
        child: appState.isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text('Random Jokes:'),
                  for (var joke in appState.jokes)
                    Card(
                      color: Colors.grey[200],
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          joke,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                ],
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
