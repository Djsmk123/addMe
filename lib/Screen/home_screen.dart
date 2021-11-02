import 'dart:developer';

import 'package:addme/Contoller/contactcontroller.dart';
import 'package:addme/Screen/authscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
class HomeScreen extends StatelessWidget {
   HomeScreen({Key? key}) : super(key: key);
   //Creations of controller for stateManagement
  final controller=Get.put(ContactController());
  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: ()async{
        if(controller.isNotificationClicked.isTrue) {
          controller.isNotificationClicked.value=false;
        }
       return false;
      },
      child: Obx(
          ()=> Scaffold(
          floatingActionButton:controller.isNotificationClicked.isFalse?FloatingActionButton(
            onPressed: () async {
                final granted=await FlutterContactPicker.hasPermission();
                if(!granted)
                  {
                    await FlutterContactPicker.requestPermission();
                  }
                final PhoneContact contact = await FlutterContactPicker.pickPhoneContact();
                //Removing All special Character from Phone number including White Spaces & Name
                 var temp=contact.phoneNumber.toString().split(":");
                controller.phoneNumber.value=temp[1].replaceAll(RegExp('}'), '').removeAllWhitespace;
                controller.phoneNumber.value=controller.phoneNumber.replaceAll(RegExp('-'), '');
                controller.fullName.value=contact.fullName.toString();
                //Check if Selected Phone Number Contains Country Code or Note
                if(controller.phoneNumber.toString().length.isEven) {
                 await showDialog(context: context, builder: (BuildContext widget)  {
                   var newCountryCode="+91";
                    return  AlertDialog(
                      title: const Text("Select Country Code",style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      ),
                    content:CountryCodePicker(
                        barrierColor: Colors.red,
                      backgroundColor: Colors.black,
                      closeIcon: const Icon(Icons.phone),
                      initialSelection: '+91',
                      onChanged: (CountryCode countryCode){
                        newCountryCode=countryCode as String;
                      },
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.done),
                          onPressed: (){
                            controller.phoneNumber.value=newCountryCode+controller.phoneNumber.value.toString();
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                    });
                }
                //Checking if Number is already exists in the userList
                 bool flag=false;
                 for (var element in controller.allContact) {
                   if(element.containsValue(controller.phoneNumber.value))
                     {
                       flag=true;
                       break;
                     }
                 }
                 if(flag)
                 {
                   Get.snackbar(
                     "ADD_ME",
                     "No Duplicate Entries Allowed",
                     backgroundColor: Colors.deepOrange,
                     snackPosition: SnackPosition.BOTTOM,
                     icon: const Icon(Icons.clear,color: Colors.white,size: 30,),
                   );

                 }

               else
                 {
                   controller.allContact.add({controller.fullName.value:controller.phoneNumber.value});
                  FirebaseFirestore.instance.collection('database').doc(FirebaseAuth.instance.currentUser!.phoneNumber).get().then((value) {
                    if(value.exists)
                      {
                        FirebaseFirestore.instance.collection('database').doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                            .update({'friend':FieldValue.arrayUnion([{controller.fullName.value:controller.phoneNumber.value}]),
                          'name':FirebaseAuth.instance.currentUser!.displayName,
                        });
                      }
                    else {
                      FirebaseFirestore.instance.collection('database').doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                          .set({
                        'friend':FieldValue.arrayUnion([{controller.fullName.value:controller.phoneNumber.value}
                        ]),
                        'name':FirebaseAuth.instance.currentUser!.displayName
                      });
                    }
                  });
                }


            },
            enableFeedback: true,
            elevation: 10,
            hoverColor: Colors.green,
            backgroundColor:  const Color(0XFFee8d56),
            child: const Icon(Icons.add,color:Colors.white,),
          ):null,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor:  const Color(0XFFee8d56),
              elevation: 0,
          title: const Text("Add-Me",style: TextStyle(
           color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 30
          ),
          ),
            actions: [
              IconButton(
                onPressed: () {
                  controller.isNotificationClicked.value=true;
                },
                icon: const Icon(Icons.notifications,color: Colors.white,size: 30,),

              ),
              IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Get.delete<ContactController>();
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>AuthScreen()),
                );
                },
                icon: const Icon(Icons.logout,color: Colors.white,size: 30,),

              ),

            ],
          ),
          body:Obx(
            ()=> ListView(
              children: [
                Visibility(
                  visible: controller.isNotificationClicked.isFalse,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Your Friends",style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                    ),
                  ),
                ),
                Visibility(
                  visible: controller.isNotificationClicked.isFalse,
                  child: GetBuilder<ContactController>(builder: (controller) {
                    return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                            .collection('database')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.lightBlueAccent,
                              ),
                            );
                          }
                          final List<QueryDocumentSnapshot> documents =
                              snapshot.data!.docs;
                          controller.contactList.clear();
                     /*  controller.allContact.clear();*/
                          for (var item in documents) {
                            if (item.id ==
                                FirebaseAuth
                                    .instance.currentUser!.phoneNumber) {
                              for (var contacts in item.get('friend')) {
                                var temp =
                                    contacts
                                        .toString();
                                temp = temp.replaceAll(RegExp('{'), '');
                                temp = temp.replaceAll(RegExp('}'), '');
                                var temp2 = temp.split(':');
                                controller.contactList.add(
                                    controller.addList(temp2[0], temp2[1].removeAllWhitespace));
                               var flag=0;
                                for (var element in controller.allContact) {
                                  if(element.containsKey(temp2[0]))
                                  {
                                    flag=1;
                                    break;
                                  }
                                }
                                if(flag!=1) {
                                  controller.allContact.add({temp2[0]: temp2[1]});
                                }
                              }
                            }
                          }
                          return Column(
                            children: controller.contactList,
                          );
                        });
                  }
                 ),
                ),
                Visibility(
                  visible: controller.isNotificationClicked.isTrue,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Who add You as  Friends",style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                    ),
                  ),
                ),
                Visibility(
                  visible: controller.isNotificationClicked.isTrue,
                  child: GetBuilder<ContactController>(builder: (controller) {
                    return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('database').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.lightBlueAccent,
                              ),
                            );
                          }
                          final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
                          controller.contactList.clear();
                          for(var item in documents)
                          {
                            for(var contacts in item.get('friend')) {
                              var temp = contacts
                                  .toString()
                                  .removeAllWhitespace;
                              temp = temp.replaceAll(RegExp('{'), '');
                              temp = temp.replaceAll(RegExp('}'), '');
                              var temp2 = temp.split(':');
                              if(temp2[1]==FirebaseAuth.instance.currentUser!.phoneNumber)
                                {   controller.contactList.add(controller.addList(item.get('name').toString(),item.id.toString(),));
                                    break;
                                }
                          }
                          }

                          return Column(
                            children: controller.contactList,
                          );

                        }
                    );

                  }
                  ),
                ),
              ],

            ),
          ),
        ),
      ),
    );
  }
}


