import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      
backgroundColor: Colors.purple [99],
      body: SingleChildScrollView(
        child: Column(
        children: [
          Container(
            width: w,
            height: h*0.3,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/image2.webp"
                ),
                fit: BoxFit.cover
              )
            ),
            child: Column(
              children: [
                SizedBox(height: h*0.12,),
                const CircleAvatar(
                  //backgroundColor: Colors.purple[400],
                  radius: 100,
                  backgroundImage: AssetImage(
                   "assets/images/836.jpg"
                  ),
                )

              ],
            )
          ),

          
          const SizedBox(height: 65,),

          const Text(
            "Bienvenue sur votre profil",

            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color:Colors.purple,
            ),
          ),
           Text(
            "Sedimat@gmail.com",

            style: TextStyle(
              fontSize: 18,
              color:Colors.purple[300],
            ),
          ),
        const SizedBox(height: 200,),
          Container(
            width: w*0.3,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: const DecorationImage(
                image: AssetImage(
                  "assets/images/purple-wallpaper.jpg"
                ),
                fit: BoxFit.cover
              )
            ),

            
            child: const Center(
              child: Text(
                     "Se déconnecter",
                     style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color:Colors.white,
                     ),
                     ),
            ),
          ),

         

        ],
      )
      )

    );
  }
}