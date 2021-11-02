import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class ContactController extends GetxController{
  //All State Variable used for Adding contacts or Retrieving Contacts
 final phoneNumber="+919667041944".obs;
 final fullName="MD MOBIN".obs;
 var isNotificationClicked=false.obs;
 var contactList=<Widget>[].obs;
 List<Map> allContact=[{}].obs;
 //Function To addContact in Widget 
 addList(phoneNumber,name) {
   return Padding(
     padding: const EdgeInsets.all(10.0),
     child: Container(
       width: double.infinity,
       height: 60,
       decoration: BoxDecoration(
         color: Colors.redAccent,
         borderRadius: BorderRadius.circular(5),
       ),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         children: [
           const Icon(Icons.person, color: Colors.white, size: 30,),
           SizedBox(
             height:30,
             width: 80,
             child: FittedBox(
               fit: BoxFit.scaleDown,
               child: Text(phoneNumber,
                 overflow:TextOverflow.ellipsis,
                 style: const TextStyle(
                 color: Colors.white,
                 fontSize: 12,
                 fontWeight: FontWeight.w900,
               ),
               ),
             ),
           ),
           SizedBox(
             height:30,
             width: 80,
             child: FittedBox(
               fit: BoxFit.scaleDown,
               child: Text(name,
                 overflow:TextOverflow.ellipsis,
                 style: const TextStyle(
                 color: Colors.white,
                 fontSize: 12,
                 fontWeight: FontWeight.w900,
               ),
               ),
             ),
           ),
         ],
       ),
     ),
   );
 }

 }
