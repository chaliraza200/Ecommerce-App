import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String?> signUp(String firstName,String lastName,String email, String password)async{
    try{
      UserCredential userCredential = await  _auth.createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
  'firstName': firstName,
  'lastName': lastName,
  'email': email,
  });
      return null;
    }
    on FirebaseAuthException catch (e){
      return e.message;
    }
    }
  Future<String?> signIn(String email, String password)async{
  try{
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return null;
  }
  on FirebaseAuthException catch (e){
    return e.message;
  }
  }
  Future<void> signOut()async{
    await _auth.signOut();
  }
}
