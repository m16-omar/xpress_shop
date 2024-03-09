import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class AuthController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///FUNCTION TO SELECT IMAGE FROM GALLERY OR CAMERA

  pickProfileImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();

    XFile? _file = await _imagePicker.pickImage(source: source);

    if (_file != null) {
      return await _file.readAsBytes();
    } else {
      print('No Image selected or captured');
    }
  }

  ///FUNCTION TO UPLOAD IMAGE TO FIREBASE STORAGE

  _uploadImageToStorage(Uint8List? image) async {
    Reference ref =
        _storage.ref().child('ProfileImages').child(_auth.currentUser!.uid);
    UploadTask uploadTask = ref.putData(image!);

    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<String> createNewUser(
      String email, String fullName, String password, Uint8List? image) async {
    String res = 'Some error occured!';

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String downloadUrl = await _uploadImageToStorage(image);

      await _firestore.collection('Buyers').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'profileImage': downloadUrl,
        'email': email,
        'buyerId': userCredential.user!.uid,
      });

      res = 'Success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  ///FUNCTION TO LOGIN THE CREATED USER

  Future<String> loginUser(String email, String password) async {
    String res = 'Some error occured';

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      res = 'Success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
