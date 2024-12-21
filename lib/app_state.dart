import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

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
    bool hasTimeout = false;

    try {
      for (int i = 0; i < 5 && !hasTimeout; i++) {
        try {
          final response = await http.get(
            Uri.parse('https://v2.jokeapi.dev/joke/Any')
          ).timeout(
            Duration(seconds: 5),
            onTimeout: () {
              hasTimeout = true;
              throw TimeoutException('Request timed out');
            },
          );

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
        } on TimeoutException {
          print('Request timed out, reverting to cached jokes');
          hasTimeout = true;
          break;
        } catch (e) {
          print('Error fetching joke: $e');
          fetchedJokes.add('Failed to fetch joke');
        }
      }

      if (!hasTimeout && fetchedJokes.isNotEmpty) {
        jokes = fetchedJokes;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setStringList('jokes', jokes);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
