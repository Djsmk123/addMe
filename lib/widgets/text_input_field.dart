import 'package:addme/Contoller/authetication_controller.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//Widget for TextInput Field
// ignore: must_be_immutable
class InputFileds extends StatelessWidget {
  final bool isOtp;
  final String title;
  InputFileds({Key? key, required this.isOtp, required this.title}) : super(key: key);
  var controller=Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).size.width > 500
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 5, 10,
          MediaQuery.of(context).size.width / 5, 0)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 20, 10,
          MediaQuery.of(context).size.width / 20, 0),
      child: Obx(
            () => TextFormField(
          keyboardType:TextInputType.phone,
          obscureText: isOtp ? true : false,
          validator: (value){
           if(!isOtp)
             {
                   if (value!.length!=10 || !value.isNumericOnly) {
                    return "please enter a valid mobile number";
                   }

             }
           else
             {
               if(value!.length!=6) {
                 return "please enter six digit OTP";
               }
             }

          },
          controller: isOtp
              ? controller.otpController.value
              : controller.phoneNumber.value,
          decoration: InputDecoration(
              isDense: true,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: !isOtp
                  ? CountryCodePicker(
                barrierColor: Colors.red,
                backgroundColor: Colors.black,
                closeIcon: const Icon(Icons.phone),
                initialSelection: '+91',
                onChanged: (CountryCode countryCode) {
                  controller.selectedCountryCode.value =
                      countryCode.toString();
                },
                showCountryOnly: false,
                showOnlyCountryWhenClosed: false,
              )
                  : const Text(""),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
                gapPadding: 0,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
                gapPadding: 0,
              ),
              hintText: title,
              hintStyle: const TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.grey)),
        ),
      ),
    );
  }
}