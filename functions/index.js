const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {Timestamp} = require("firebase-admin/firestore");
const express = require("express");
const cors = require("cors");
const {fileUpload} = require("./fileUploadMiddleware");
const {fileOperations} = require("./fileOperationsMiddleware");
const fs = require("fs");
const path = require("path");

admin.initializeApp();

const db = admin.firestore();
const app = express();

app.use(cors());

// authorization bearer token => req.headers.authorization
app.post("/photo", fileUpload, fileOperations, (req, res, next) => {
  const uploadDir = path.join(__dirname, "ha.jpeg");
  fs.writeFile(uploadDir, req.file.buffer, (err) => {
    if (err) {
      next(err);
    }
  });
  res.json({
    filename: req.file.filename,
    body: req.body,
  });
});

app.use((err, req, res, next) => {
  if (err.statusCode === 400) {
    functions.logger.info(err.message);
    res.status(400).json({error: err.message});
  } else {
    functions.logger.error(err.message);
    res.status(500).json({error: "Server error"});
  }
});

exports.api = functions.https.onRequest(app);

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
    badges: [],
    dailyPhotoCount: 0,
    photoUploadTime: Timestamp.now(),
    messagingTokens: [],
  };
  await db.collection("users").add(newUser);
  functions.logger.info("User created", newUser);
});
