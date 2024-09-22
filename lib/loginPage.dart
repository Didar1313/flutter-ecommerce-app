import 'package:ecommerceapp/bottomNaviBar/bottomNavigationBar.dart';
import 'package:ecommerceapp/registrationPage/userRegistration.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green[700],
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Sign in",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "WellCome Back",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.green[700]),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Glad to see you back..",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w200,
                              color: Colors.green[700]),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 5, 0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  hintText: "Enter your email"),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: _password,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.password),
                                  hintText: "Enter your password"),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(120, 0, 0, 0),
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.green[700],
                        ),
                        child: RawMaterialButton(
                          elevation: 0,
                          onPressed: () async {
                            User? user = await _login(
                                email: _email.text, pass: _password.text);
                            if (user != null) {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => BottomNavigation()));
                            }
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(90, 0, 0, 0),
                            child: Text(
                              "Don't have account?",
                              style: TextStyle(
                                  fontWeight: FontWeight.w200,
                                  fontSize: 15,
                                  color: Colors.black87),
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(context,MaterialPageRoute(builder: (_)=>UserRegistration()));
                              },
                              child: Text(
                                "Register here...",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.green[700]),
                              ))
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<User?> _login({required String email, required String pass}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential =
      await auth.signInWithEmailAndPassword(email: email, password: pass);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found for that email")),
        );
      } else if (e.code == "wrong-password") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Wrong password provided")),
        );
      }
    }
    return user;
  }
}
