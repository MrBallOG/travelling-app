const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {Timestamp} = require("firebase-admin/firestore");
const express = require("express");
const cors = require("cors");
const {fileUpload} = require("./fileUploadMiddleware");
const {fileOperations} = require("./fileOperationsMiddleware");

admin.initializeApp();

const db = admin.firestore();
const bucket = admin.storage().bucket();
const auth = admin.auth();
const app = express();

app.use(cors());

app.use(async (req, res, next) => {
  const header = req.headers.authorization;
  if (!header) {
    const err = new Error("Missing authorization header");
    err.statusCode = 401;
    return next(err);
  }
  const headerArr = header.split(" ");
  if (headerArr.length !== 2 || headerArr[0] !== "Bearer") {
    const err = new Error("Authorization must be a bearer token");
    err.statusCode = 401;
    return next(err);
  }
  try {
    const token = await auth.verifyIdToken(headerArr[1]);
    req.uid = token.uid;
    next();
  } catch (_) {
    const err = new Error("Invalid token");
    err.statusCode = 401;
    return next(err);
  }
});

// authorization bearer token => req.headers.authorization
app.post("/photo", fileUpload, fileOperations, async (req, res, next) => {
  const uid = req.uid;
  const metadata = {
    metadata: {
      uid: uid,
    },
  };
  const file = bucket.file(req.file.filename);
  await file.save(req.file.buffer);
  await file.setMetadata(metadata);
  functions.logger.info("STORAGE: Photo saved", req.file.filename);

  const tempPhoto = {
    uid: uid,
    file: req.file.filename,
    longitude: req.body.longitude,
    latitude: req.body.latitude,
  };
  await db.collection("tempPhotos").add(tempPhoto);
  functions.logger.info("FIRESTORE: TempPhoto created", req.file.filename);

  res.sendStatus(200);
});

app.use((err, req, res, next) => {
  if ([400, 401].includes(err.statusCode)) {
    functions.logger.info("USER-ERROR", err.message);
    res.status(err.statusCode).json({error: err.message});
  } else {
    functions.logger.error("SERVER-ERROR", err.message);
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
// firebase functions:shell => createUser({uid: "some uid"})

exports.createUser = functions.auth.user().onCreate(async (user) => {
  const newUser = {
    uid: user.uid,
    badges: [],
    dailyPhotoCount: 0,
    photoUploadTime: Timestamp.now(),
    messagingTokens: [],
  };
  await db.collection("users").add(newUser);
  functions.logger.info("FIRESTORE: User created", newUser);
});
