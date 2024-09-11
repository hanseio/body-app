/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

exports.kakaoCustomAuth = functions.https.onRequest(async (request, response) => {
  const kakaoAccessToken = request.body.kakao_access_token;

  try {
    // Kakao API를 사용하여 사용자 정보 가져오기
    const kakaoUserInfo = await axios.get('https://kapi.kakao.com/v2/user/me', {
      headers: { 'Authorization': `Bearer ${kakaoAccessToken}` }
    });

    const kakaoId = kakaoUserInfo.data.id;
    const email = kakaoUserInfo.data.kakao_account.email;

    // Firebase에서 사용자 찾기 또는 생성
    let firebaseUser;
    try {
      firebaseUser = await admin.auth().getUserByEmail(email);
    } catch (error) {
      firebaseUser = await admin.auth().createUser({
        email: email,
        emailVerified: true,
      });
    }

    // 커스텀 클레임 설정
    await admin.auth().setCustomUserClaims(firebaseUser.uid, { kakaoId: kakaoId });

    // Firebase 커스텀 토큰 생성
    const firebaseToken = await admin.auth().createCustomToken(firebaseUser.uid);

    response.json({ firebase_custom_token: firebaseToken });
  } catch (error) {
    console.error('Error:', error);
    response.status(500).send('Authentication failed');
  }
});
