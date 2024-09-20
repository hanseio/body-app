import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // 추가로 import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '153020199339-b9srubcn6tqlld3gssrqtua2e47o6lr4.apps.googleusercontent.com',
    scopes: [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/user.gender.read',
    ],
  );

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      if (mounted) {
        // logger.e('Google Sign-In Error', error: e); // logger 사용 시
        debugPrint('Google Sign-In Error: $e'); // debugPrint 사용 시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구글 로그인 실패: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleKakaoSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      // 여기서 Firebase Custom Auth를 사용해야 합니다.
      // 아래 URL은 예시이며, 실제 Firebase Function URL로 교체해야 합니다.
      final url = Uri.https('https://us-central1-buddy-hanse-240911-1d091.cloudfunctions.net', '/kakaoCustomAuth');
      final response = await http.post(
        url,
        body: json.encode({'kakao_access_token': token.accessToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final customToken = json.decode(response.body)['firebase_custom_token'];
        await FirebaseAuth.instance.signInWithCustomToken(customToken);
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      } else {
        throw Exception('Failed to get Firebase custom token');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buddy에 로그인')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _handleGoogleSignIn,
                    child: const Text('구글로 로그인'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handleKakaoSignIn,
                    child: const Text('카카오로 로그인'),
                  ),
                ],
              ),
      ),
    );
  }
}
