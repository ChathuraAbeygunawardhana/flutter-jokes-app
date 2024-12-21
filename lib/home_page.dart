import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'joke_card.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                    color: Colors.black87,
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
                      JokeCard(joke: joke),
                  ],
                ),
              ),
      ),
    );
  }
}
