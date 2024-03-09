import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:login/login.dart';
import 'package:login/userPreferences.dart';
import 'package:provider/provider.dart';

import 'custom_textfield.dart';

class Opening extends StatefulWidget {
  const Opening({super.key});

  @override
  State<Opening> createState() => _OpeningState();
}

class _OpeningState extends State<Opening> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final CollectionReference _items=FirebaseFirestore.instance.collection("items");

  EmailOTP myauth = EmailOTP();

  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9_.+-]+@(?:(?:[a-zA-Z0-9-]+\.)?[a-zA-Z]+\.)?iitrpr\.ac\.in$",
  );
  final RegExp _phoneRegex = RegExp(
    r"^[0-9]{10}$",
  );

  Future<bool> isEmailExists(String email) async {
    QuerySnapshot querySnapshot = await _items.where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  }

  bool _validateEmail() {
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    if (_emailRegex.hasMatch(email)&&_phoneRegex.hasMatch(phone)) {
      return true;
    } else {
      _emailController.clear();
      _phoneController.clear();
      return false;
    }
  }

  void sendOTP() async {
    if(_emailController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty){
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill all fields")));
    }
    else{
      if(_validateEmail()){
        if(await isEmailExists(_emailController.text.toString())){
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Email already exists")));
        }
        else{
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
      }
      else{
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invaild Email or Phone No")));
      }
    }


  }

  void verifyOTP() async {

    if (await myauth.verifyOTP(otp: _otpController.text) == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("OTP is verified")));
      await _items.add({
        "name":_nameController.text.toString(),
        "address":_addressController.text.toString(),
        "email":_emailController.text.toString(),
        "phone":_phoneController.text.toString(),
      });
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false,arguments: {'email': _emailController.text.toString()});
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
                "Create your account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text("We need to register your details!",
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
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'Name',
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email',
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: 'Phone',
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: _addressController,
                        hintText: 'Address',
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
                    child: Text(
                      "Send OTP",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                child: Form(
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _otpController,
                        hintText: 'OTP',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
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
                      // Navigator.pushNamedAndRemoveUntil(context, 'verify', (route) => false);
                      if (await myauth.verifyOTP(otp: _otpController.text) == true) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("OTP is verified")));
                      await _items.add({
                      "name":_nameController.text.toString(),
                      "address":_addressController.text.toString(),
                      "email":_emailController.text.toString(),
                      "phone":_phoneController.text.toString(),
                      });
                      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
                      } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("Invaild OTP")));
                      }
                    },
                    child: Text(
                      "Verify OTP",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, 'login', (route) => false);
                    },
                    child: Text('Login'),
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
