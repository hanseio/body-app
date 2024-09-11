import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구글 로그인 실패: $e')),
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
      final url = Uri.https('your-firebase-function-url.com', '/kakaoCustomAuth');
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
