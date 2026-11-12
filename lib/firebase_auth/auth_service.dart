import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final cloudinary = CloudinaryPublic('pqgou8fa', 'ml_default', cache: false);
  Future<String?> signUp(String firstName,String lastName,String email, String password)async{
    try{
      UserCredential userCredential = await  _auth.createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': '',
        'isAdmin': false,
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
  Future<String?> resetPassword(String email)async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    }
    on FirebaseAuthException catch (e){
      return e.message;
    }
  }
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // NAYI LINE — initialize() call karo authenticate() se pehle
      await googleSignIn.initialize(
        serverClientId: '672903843437-hsgosdv3rm2qsv3bddfdvv0pu6v68pna.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      if (googleUser == null) return "Sign in cancelled";

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      String uid = userCredential.user!.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'firstName': userCredential.user!.displayName ?? '',
          'lastName': '',
          'email': userCredential.user!.email ?? '',
          'phone': '',
        });
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }
  // Stage 1: Send OTP code to the phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification on some Android devices (rare, but handle it)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? "Verification failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

// Stage 2: Verify the OTP code the user typed in
  Future<String?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      String uid = userCredential.user!.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'firstName': '',
          'lastName': '',
          'email': '',
          'phone': userCredential.user!.phoneNumber ?? '',
        });
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final cloudinary = CloudinaryPublic('pqgou8fa', 'ml_default', cache: false);

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
      );

      String downloadUrl = response.secureUrl;

      String uid = _auth.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImageUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
