import 'package:flutter/material.dart';

class InscriptionPage extends StatelessWidget {
  const InscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List images = [
      "google.png",
      "facebook.png",
      "twitter.png"
    ];

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.purple[99],
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10.0, top: 30.0),
                child: Icon(Icons.arrow_back),
              ),
            ),
            Container(
              width: w,
              height: h * 0.3,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/image2.webp"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: h * 0.12),
                  const CircleAvatar(
                    radius: 100,
                    backgroundImage: AssetImage(
                      "assets/images/836.jpg",
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              width: w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50,),
                  Container(
                    decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 7,
                          offset: const Offset(1, 1),
                          color:Colors.grey.withOpacity(0.3)
                        )
                      ]
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Entrez votre email ', // Ajoutez votre texte ici
                        prefixIcon: const Icon(Icons.email, color:Colors.purpleAccent),
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)), // Définissez l'opacité souhaitée
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color:Colors.white,
                            width: 1.0
                          )
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color:Colors.white,
                            width: 1.0
                          )
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 50,),
                  Container(
                    decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 7,
                          offset: const Offset(1, 1),
                          color:Colors.grey.withOpacity(0.3)
                        )
                      ]
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Entrez votre mot de passe', // Ajoutez votre texte ici
                        prefixIcon: const Icon(Icons.password, color:Colors.purpleAccent),
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)), // Définissez l'opacité souhaitée
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color:Colors.white,
                            width: 1.0
                          )
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color:Colors.white,
                            width: 1.0
                          )
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 65,),
            Container(
              width: w*0.3,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: const DecorationImage(
                  image: AssetImage("assets/images/purple-wallpaper.jpg"),
                  fit: BoxFit.cover
                )
              ),
              child: const Center(
                child: Text(
                  "S'inscrire",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color:Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: w*0.2),
            RichText(
              text: TextSpan(
                text: "Inscrivez-vous en utilisant ces méthodes suivantes:",
                style: TextStyle(
                  color:Colors.grey[500],
                  fontSize: 20
                ),
              ),
            ),
            Wrap(
              children: List<Widget>.generate(
                3,
                (index){
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(
                          "assets/images/"+images[index]
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
