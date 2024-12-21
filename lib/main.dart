import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'dart:async';

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
  bool isOnline = true;
  Timer? _connectivityTimer;

  MyAppState() {
    checkInitialConnectivity();
    setupConnectivityStream();
    setupPeriodicConnectivityCheck();
    loadJokes();
  }

  Future<void> checkInitialConnectivity() async {
    isOnline = await checkInternetConnection();
    notifyListeners();
  }

  void setupConnectivityStream() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      isOnline = await checkInternetConnection();
      notifyListeners();
    });
  }

  void setupPeriodicConnectivityCheck() {
    _connectivityTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      bool wasOnline = isOnline;
      isOnline = await checkInternetConnection();
      if (wasOnline != isOnline) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
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
    if (!isOnline) {
      return;
    }
    
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

  void _showOfflineAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Can\'t fetch new jokes since you are offline'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Jokes App'),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[200],
              child: TextButton.icon(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.black,
                ),
                label: Text(
                  'Fetch new jokes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                onPressed: () async {
                  if (!appState.isOnline) {
                    _showOfflineAlert();
                  } else {
                    await appState.fetchJokes();
                  }
                },
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: appState.isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Fetching new jokes',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          appState.isOnline ? Icons.wifi : Icons.wifi_off,
                          color: appState.isOnline ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          appState.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: appState.isOnline ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text('Random Jokes:'),
                    for (var joke in appState.jokes)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Card(
                          color: Colors.grey[200],
                          child: Container(
                            width: double.infinity,
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
                      ),
                  ],
                ),
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
