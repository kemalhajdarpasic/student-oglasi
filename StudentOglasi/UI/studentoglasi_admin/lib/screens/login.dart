import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_admin/providers/studenti_provider.dart';
import 'package:studentoglasi_admin/screens/studetni_list_screen.dart';
import 'package:studentoglasi_admin/utils/util.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  late StudentiProvider _studetniProvider;

  @override
  Widget build(BuildContext context) {
    _studetniProvider = context.read<StudentiProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/loginpage2.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.75),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Container(
            width: 500,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              margin: EdgeInsets.all(20.0),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Prijava',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: 'Korisničko ime',
                        prefixIcon: Icon(Icons.person,
                            color: Colors.black.withOpacity(0.6)),
                      ),
                      controller: _usernameController,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        labelText: 'Lozinka',
                        prefixIcon: Icon(Icons.lock,
                            color: Colors.black.withOpacity(0.6)),
                      ),
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () async {
                        var username = _usernameController.text;
                        var password = _passwordController.text;

                        Authorization.username = username;
                        Authorization.password = password;

                        try {
                          await _studetniProvider.get();

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const StudentiListScreen(),
                            ),
                          );
                        } on Exception catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.error, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Pogrešno korisničko ime ili lozinka'),
                              ],
                            ),
                            backgroundColor: Colors.redAccent,
                          ));
                          _usernameController.clear();
                          _passwordController.clear();
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 233, 247, 253)),
                        minimumSize: MaterialStateProperty.all<Size>(Size(
                            130, 40)), // Set the minimum size of the button
                      ),
                      child: Text('Prijavi se'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
