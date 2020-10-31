import 'package:cloud_firestore/cloud_firestore.dart';

//UserManager class
class UserManager{

  //function to get user details
  //NB: You can add as much parameters as you wish in the function
  addUserDetails(String email,   String uid){
    Firestore.instance.collection('flutter_users').document(uid).setData({
      'email' : email,
      'uid' : uid
    });

  }




}