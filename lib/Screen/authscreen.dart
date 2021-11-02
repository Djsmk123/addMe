// ignore_for_file: file_names
import 'dart:developer';
import 'package:addme/Contoller/authetication_controller.dart';
import 'package:addme/widgets/labels.dart';
import 'package:addme/widgets/text_input_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'home_screen.dart';

final _firebaseAuth = FirebaseAuth.instance;
PhoneAuthCredential? phoneAuth;
class AuthScreen extends StatelessWidget {
  AuthScreen({Key? key,}) : super(key: key);
  //Loading AuthController in AuthScreen class...
  final controller=Get.put(AuthController());
  //......................
  //FormKeys.......
  final List<GlobalKey<FormState>> _formKey = [GlobalKey<FormState>(), GlobalKey<FormState>()];
  //.....................
  //Functions To Verify Mobile Number as well as for sign in.........................
  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    controller.otpCode.value=authCredential.smsCode!;

    phoneAuth=authCredential;
    log(phoneAuth!.smsCode.toString());
    log("verification completed ${authCredential.smsCode}");
  }
  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      showMessage("The phone number entered is invalid!",BuildContext);
      log(exception.code);
    }
  }
  _onCodeSent(String verificationId, int? forceResendingToken) {
    controller.verificationId.value = verificationId;
    log(forceResendingToken.toString());
    log("code sent");
  }
  void showMessage(String errorMessage,context) {
    showDialog(
        builder: (BuildContext builderContext) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(errorMessage),
            actions: [
              TextButton(
                child: const Text("Ok"),
                onPressed: () async {
                  Navigator.of(builderContext).pop();
                },
              )
            ],
          );
        }, context: context).then((value) {

        controller.isLoading.value = false;

    });
  }
  _onCodeTimeout(String timeout) {
    log(timeout);
    return null;
  }
  Future<void> phoneSignIn({required String phoneNumber}) async {
    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeTimeout);
  }
  //....................................................
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
            builder: (context, constraint) {
              return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraint.maxHeight),
                    child: Obx(
                      ()=> controller.isLoading.isFalse?
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          const SizedBox(
                            height: 50,
                          ),
                          const Center(
                            child: Text("Add-Me",textAlign: TextAlign.center,style: TextStyle(
                                color: Color(0XFFee8d56),
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2
                            ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const Center(
                            child:  Text("Continue with Mobile Number.",style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const Label(title: "Phone Number",),
                          Form(
                            key: _formKey[0],
                              child: InputFileds(title: "Phone Number",isOtp: false,)),
                          const Label(title: "OTP",),
                          Form(
                              key: _formKey[1],
                              child: InputFileds(title: "OTP",isOtp: true,)),
                          Padding(
                            padding: MediaQuery.of(context).size.width>500?EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/5, 30, MediaQuery.of(context).size.width/5, 30):EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/20, 30 , MediaQuery.of(context).size.width/20, 30),
                            child: GestureDetector(
                              onTap: () {
                                //If Phone number is Valid Only
                                if( _formKey[0].currentState!.validate())
                                  {
                                    phoneSignIn(phoneNumber: controller
                                        .selectedCountryCode.value +
                                        controller.phoneNumber.value.text);
                                    controller.otpSent.value = true;
                                  }
                              },
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                height:80,
                                decoration: BoxDecoration(
                                    color: const Color(0XFFee8d56),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0XFFee8d56),)
                                ),
                                child: const Text("Verify Mobile Number",style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  wordSpacing: 5,
                                ),),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: controller.otpSent.isTrue,
                            child: Padding(
                              padding: MediaQuery.of(context).size.width>500?EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/5, 30, MediaQuery.of(context).size.width/5, 30):EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/20, 30 , MediaQuery.of(context).size.width/20, 30),
                              child: GestureDetector(
                                onTap: ()async {
                                  controller.isLoading.value=true;
                                  if (controller.otpCode.value !=
                                      controller
                                          .otpController.value.text) {
                                    controller.isLoading.value = false;
                                    Get.snackbar(
                                      "Add-Me",
                                      "Wrong Otp",
                                      backgroundColor:
                                      const Color(0XFFee8d56),
                                      icon: const Icon(Icons.error,
                                          color: Colors.white),
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                 if (phoneAuth!.smsCode != null && controller.otpCode.value==controller.otpController.value.text) {
                                    try {
                                      //Catch Error if any during SignIn Firebase..........
                                      await _firebaseAuth.signInWithCredential(phoneAuth!).catchError((error){
                                        log(error.message.toString());
                                        Get.snackbar(
                                          "Add-Me",
                                          error.message.toString(),
                                          backgroundColor:
                                          const Color(0XFFee8d56),
                                          icon: const Icon(Icons.error,
                                              color: Colors.white),
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      });
                                      controller.isLoading.value = false;
                                      //Checking If user is Already Registered or Not in Firebase
                                      if(_firebaseAuth.currentUser!.phoneNumber!.isNotEmpty)
                                        {
                                          await  FirebaseFirestore.instance.collection('database').doc(FirebaseAuth.instance.currentUser!.phoneNumber).get().then((value) {
                                            if(value.exists) {
                                              controller.isUserExist.value=true;
                                            }
                                          }
                                          );
                                          if(controller.isUserExist.isFalse)
                                          {
                                            await  showDialog(context: context, builder:(BuildContext widget)  {
                                              return AlertDialog(
                                                  title:const Text("Please enter your name",style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  ),
                                                  backgroundColor:
                                                  const Color(0XFFee8d56),
                                                  content: Form(
                                                    child: TextFormField(
                                                      controller: controller.nameController.value,
                                                      keyboardType:TextInputType.name,
                                                      decoration: const InputDecoration(
                                                          isDense: true,
                                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(   color: Colors.white, width: 2),
                                                            gapPadding: 0,
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(color:Colors.white, width: 2),
                                                            gapPadding: 0,
                                                          ),
                                                          hintText: "Name",
                                                          hintStyle: TextStyle(
                                                            letterSpacing: 2,
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 12,
                                                            color: Colors.white,)),
                                                    ),

                                                  ),

                                                  actions: [
                                                    TextButton(
                                                        onPressed: () async {
                                                          await FirebaseFirestore.instance.collection('database').doc(FirebaseAuth.instance.currentUser!.phoneNumber).
                                                          set({'name':controller.nameController.value.text,
                                                            'friend':FieldValue.arrayUnion([])});
                                                          Navigator.pop(context);
                                                          controller.nameController.value.clear();
                                                          controller.otpController.value.clear();
                                                          controller.phoneNumber.value.clear();

                                                          Get.toNamed('/home');
                                                        },
                                                        child: const Text("Next",style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                        )
                                                    )
                                                  ]
                                              );
                                            });
                                          }
                                          else
                                          {
                                            controller.nameController.value.clear();
                                            controller.otpController.value.clear();
                                            controller.phoneNumber.value.clear();
                                            Get.toNamed("/home");
                                          }
                                        }
                                    }
                                    catch (e) {
                                      log(e.toString());
                                    }
                                    }

                                },
                                child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  height:80,
                                  decoration: BoxDecoration(
                                      color: const Color(0XFFee8d56),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0XFFee8d56),)
                                  ),
                                  child: const Text("Log in",style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    wordSpacing: 5,
                                  ),),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ):const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          color: Colors.deepOrange,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
              );
            }
        )
    );
  }
}




