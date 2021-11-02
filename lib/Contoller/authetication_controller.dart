import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
class AuthController extends GetxController {
  //All State Variable used for Authentication
  Rx<TextEditingController> phoneNumber=TextEditingController().obs;
  Rx<TextEditingController>  otpController=TextEditingController().obs;
  Rx<TextEditingController>  nameController=TextEditingController().obs;
  var otpSent=false.obs;
  var selectedCountryCode='+91'.obs;
  var verificationId="".obs;
  var otpCode="".obs;
  var isLoading = false.obs;
  var isUserExist=false.obs;
}