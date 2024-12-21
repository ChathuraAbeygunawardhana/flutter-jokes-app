import 'package:flutter/material.dart';

class JokeCard extends StatelessWidget {
  final String joke;

  const JokeCard({
    super.key,
    required this.joke,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
