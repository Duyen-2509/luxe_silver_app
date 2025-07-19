import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBNYH1x--pxgHyEBLdKKuPnYv9ccuTwuxo',
    appId: '1:438307077739:web:9c0b03c7379c914586bb2e',
    messagingSenderId: '438307077739',
    projectId: 'luxesilver-1d5f0',
    authDomain: 'luxesilver-1d5f0.firebaseapp.com',
    storageBucket: 'luxesilver-1d5f0.firebasestorage.app',
    measurementId: 'G-HL5MFLL0PG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD48ycfgDfApKm5nMg-Xls_Pc4VWYINBDU',
    appId: '1:438307077739:android:56409d2a4054707586bb2e',
    messagingSenderId: '438307077739',
    projectId: 'luxesilver-1d5f0',
    storageBucket: 'luxesilver-1d5f0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLqCGkfRBuQPB1DW6SqAKtG3ELwlcVsCM',
    appId: '1:438307077739:ios:d9815ecb0e0dcf7986bb2e',
    messagingSenderId: '438307077739',
    projectId: 'luxesilver-1d5f0',
    storageBucket: 'luxesilver-1d5f0.firebasestorage.app',
    androidClientId:
        '438307077739-iradqeupbj0p9ptad380o1v5l4tvmplr.apps.googleusercontent.com',
    iosClientId:
        '438307077739-u2pp4ghkpdjdtfpima90rbfmbvvl2pr4.apps.googleusercontent.com',
    iosBundleId: 'com.example.luxeSilverApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCLqCGkfRBuQPB1DW6SqAKtG3ELwlcVsCM',
    appId: '1:438307077739:ios:d9815ecb0e0dcf7986bb2e',
    messagingSenderId: '438307077739',
    projectId: 'luxesilver-1d5f0',
    storageBucket: 'luxesilver-1d5f0.firebasestorage.app',
    androidClientId:
        '438307077739-iradqeupbj0p9ptad380o1v5l4tvmplr.apps.googleusercontent.com',
    iosClientId:
        '438307077739-u2pp4ghkpdjdtfpima90rbfmbvvl2pr4.apps.googleusercontent.com',
    iosBundleId: 'com.example.luxeSilverApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBNYH1x--pxgHyEBLdKKuPnYv9ccuTwuxo',
    appId: '1:438307077739:web:211d4912ae75a09386bb2e',
    messagingSenderId: '438307077739',
    projectId: 'luxesilver-1d5f0',
    authDomain: 'luxesilver-1d5f0.firebaseapp.com',
    storageBucket: 'luxesilver-1d5f0.firebasestorage.app',
    measurementId: 'G-PCF7Q1JY7E',
  );
}
