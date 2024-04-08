import 'package:flutter/material.dart';
import 'package:flutter_application_1/inscription_page.dart';
import 'package:flutter_application_1/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Mobility corner app",
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: <Widget>[
              SplashPage(imagePath: 'assets/images/image5.jpg', text: 'Bienvenue dans mobility corner Application'),
              SplashPage(imagePath: 'assets/images/image9.jpg', text: 'Rapide simple et efficace '),
              LastSplashPage(),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    _controller.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                  },
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  final String imagePath;
  final String text;

  const SplashPage({required this.imagePath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class LastSplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/image3_tablet.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: Text('Connectez-vous'),
        ),
      ),
    );
  }
}
