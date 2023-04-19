const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {Timestamp} = require("firebase-admin/firestore");

admin.initializeApp();
const db = admin.firestore();

// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// const warsaw = {
//   continent: "Europe",
//   country: "Poland",
//   administrationArea: "Mazowicekie",
//   city: "Warsaw",
// };

// const badge = {
//   continent: "Europe",
//   country: "Poland",
//   administrationArea: "Mazowicekie",
//   requirements: { // {places: [warsaw, płock]}
//     count: 10,
//     distinctArea: false,
//   },
// };

// https://ajv.js.org/json-schema.html#keywords-for-numbers, https://express-validator.github.io/docs/custom-error-messages -> validation
// firebase functions:shell => createUser({uid: "0UgNpe4TuhWEAu7E99LiJhk1E3G2"})

exports.createUser = functions.auth.user().onCreate(async (user) => {
  const newUser = {
    uid: user.uid,
    dailyPhotoCount: 0,
    photoUploadTime: Timestamp.now(),
    messagingTokens: [],
  };
  await db.collection("users").add(newUser);
  functions.logger.info("User created", newUser);
});
