import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:login/userPreferences.dart';
import 'package:provider/provider.dart';

import 'custom_textfield.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  EmailOTP myauth = EmailOTP();
  final CollectionReference _items=FirebaseFirestore.instance.collection("items");

  Future<bool> isEmailExists(String email) async {
    QuerySnapshot querySnapshot = await _items.where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  }

  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9_.+-]+@(?:(?:[a-zA-Z0-9-]+\.)?[a-zA-Z]+\.)?iitrpr\.ac\.in$",
  );

  bool _validateEmail() {
    String email = _emailController.text.trim();

    if (_emailRegex.hasMatch(email)) {
      return true;
    } else {
      _emailController.clear();
      return false;
    }
  }

  void sendOTP() async {
    if(_validateEmail()){
      if(await isEmailExists(_emailController.text.toString())){
        await myauth.setSMTP(
            host: "smtp-relay.brevo.com",
            auth: true,
            username: "dep24p02@gmail.com",
            password: "PDTM2fHF36S0AhUt",
            secure: "TLS",
            port: 587
        );
        await myauth.setConfig(
            appEmail: "dep24p02@gmail.com",
            appName: "Email OTP",
            userEmail: _emailController.text,
            otpLength: 6,
            otpType: OTPType.digitsOnly);
        if (await myauth.sendOTP() == true) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("OTP has been sent")));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("OTP send failed")));
        }
      }
      else{
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Email does not exists")));
      }
    }
    else{
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invaild Email")));
    }
  }

  void verifyOTP() async {
    if (await myauth.verifyOTP(otp: _otpController.text) == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("OTP is verified")));
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false,arguments: {'email': _emailController.text.toString()},);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invaild OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Login",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                  "Enter your email!",
                  style: TextStyle(
                    fontSize: 16,
                  )),
              const SizedBox(
                height: 30,
              ),
              Container(
                child: Form(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      // Navigator.pushNamedAndRemoveUntil(context, 'verify', (route) => false);
                      sendOTP();
                    },
                    child: Text("Send OTP",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Form(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _otpController,
                        hintText: 'OTP',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      if (await myauth.verifyOTP(otp: _otpController.text) == true) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("OTP is verified")));
                      userProvider.loginUser(_emailController.text);
                      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
                      } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("Invaild OTP")));
                      }
                    },
                    child: Text("Verify",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  InkWell(
                    onTap: (){
                      Navigator.pushNamedAndRemoveUntil(context, 'opening',(route)=>false);
                    },
                    child: Text('Signup'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
