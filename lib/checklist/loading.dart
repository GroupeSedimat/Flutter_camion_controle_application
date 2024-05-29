import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightBlue,
      child: const Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  "Loading",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  )
              ),
              SizedBox(height: 20,),
              SpinKitFadingCircle(
                color: Colors.amber,
                size: 80.0,
              ),
            ]
        ),
      ),
    );
  }
}